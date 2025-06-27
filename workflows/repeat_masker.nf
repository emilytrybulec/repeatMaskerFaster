/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/


include { paramsSummaryMap       } from 'plugin/nf-validation'

include { softwareVersionsToYAML } from '../subworkflows/nf-core/utils_nfcore_pipeline'

include { TWO_BIT } from '../modules/local/twoBit' 
include { REPEAT_VIEW } from '../modules/local/repeat_visualization' 
include { genSample; warmupRepeatMasker; twoBit; genBatches; twoBittoFa; RepeatMasker; adjCoordinates; combineRMOUTOutput; combineRMAlignOutput; makeMaskedFasta } from '../modules/local/repeatmasker_faster' 


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow REPEAT_MASKER {

    ch_db_fasta = Channel.fromPath(params.genome_fasta)
    ch_db_fasta
        .map { file -> tuple(id: file.baseName, file)  }
        .set { ch_genome_fasta }

    if (params.consensus_fasta == null) {
        ch_consensus = Channel.empty()
        ch_consensus_fasta = Channel.empty()
    } else { 
        ch_consensus = Channel.fromPath(params.consensus_fasta) 
        ch_consensus
            .map { file -> tuple(id: file.baseName, file)  }
            .set { ch_consensus_fasta }
    }


    if(params.species == null){
        ch_species = Channel.empty()
    } else {ch_species = params.species}

        genSample(ch_genome_fasta)
        warmupRepeatMasker(genSample.out.out, ch_species)
        twoBit(ch_genome_fasta)
        genBatches(warmupRepeatMasker.out.out, params.batch_size, twoBit.out.out)

        genBatches.out.bed
            .flatten()
            .set{ch_batches}

        ch_batches
            .combine(twoBit.out.out)
            .set{ch_batches_2bit}

        twoBittoFa(ch_batches_2bit)

        twoBittoFa.out.out
            .flatten()
            .map{ file -> tuple(file.baseName, file) }
            .set{batches_meta}

        ch_consensus_fasta
            .map{it[1]}
            .set{consensus_nometa}

        batches_meta
            .combine(consensus_nometa)
            .set{ch_rm_batches}

        if (params.libdir == null){
        RepeatMasker(ch_rm_batches, ch_species, params.soft_mask, [])

        } else {
        RepeatMasker(ch_rm_batches, ch_species, params.soft_mask, params.libdir)
        }

        ch_batches
            .flatten()
            .map{ file -> tuple(file.baseName, file) }
            .set{batches_bed_meta}
                
        batches_bed_meta
            .join(RepeatMasker.out.out)
            .join(RepeatMasker.out.align)
            .set{ch_rmout}

        adjCoordinates(ch_rmout)

        adjCoordinates.out.out
            .map {it[1]}
            .set{out_nometa}
        adjCoordinates.out.align
            .map {it[1]}
            .set{align_nometa}

        out_nometa
            .collect()
            .set{ch_out}
        align_nometa
            .collect()
            .set{ch_align}

        twoBit.out.out
            .map { file -> tuple(file.baseName, file) }
            .set{twoBit_meta}

        combineRMOUTOutput(twoBit_meta, ch_out)
        combineRMAlignOutput(twoBit_meta, ch_align, combineRMOUTOutput.out.trans)

        combineRMAlignOutput.out.align
                .set{repeatMasker_align}

        ch_genome_fasta
            .combine(combineRMOUTOutput.out.bed)
            .set{masked_ch}

        makeMaskedFasta(masked_ch, ch_species)

        makeMaskedFasta.out.masked
            .set{repeatMasker_fasta}
            
        TWO_BIT(repeatMasker_fasta)

        REPEAT_VIEW(repeatMasker_align, TWO_BIT.out.out)
    


}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
