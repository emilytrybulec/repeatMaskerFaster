[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A523.04.0-23aa62.svg)](https://www.nextflow.io/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)
[![run with singularity](https://img.shields.io/badge/run%20with-singularity-1d355c.svg?labelColor=000000)](https://sylabs.io/docs/)

## Introduction

**emilytrybulec/repeatMaskerFaster** is a bioinformatics pipeline that takes a finished genome and performs repeat masking in batches. It produces a masked genome (.fasta.masked), detailed information about the repetitive elements identified by RepeatMasker (.out), and multiple sequence alignment of the repetitive regions identified in the sequence with the corresponding consensus sequences from the RepeatMasker database (.align). 

1. [`Repeat Masker`](https://www.repeatmasker.org/)
2. [`Repeat Masker on the Cluster`](https://github.com/Dfam-consortium/RepeatMasker_Nextflow)
   

## Usage

> [!NOTE]
> If you are new to Nextflow and nf-core, please refer to [this page](https://nf-co.re/docs/usage/installation) on how to set-up Nextflow.

First, go through nextflow.config to configure the pipeline to your needs. The batchSize determines how big of chuncks your genome will be split into for faster processing, and the soft masking option can be modified to change how your output genome is masked.  


`nextflow.config`:

```config
params {

    // Input options
    soft_mask                  = true
    batchSize                  = 50000000

    species                    = null
    genome_fasta               = null
    consensus_fasta            = null
    cluster                    = null
}
```


Next, create a params.yaml file to input information in place of the null configurations. This file will contain your genome and preferred out directory name. The RepeatMasker species flag is used to warmup RepeatMasker, and, and a consensus path and can be supplied to process your genome against known repeats, if available.     
  
`params.yaml`:

```yaml
params {
   genome_fasta           : "/core/projects/colossalanalyses/Finished_Genomes_for_Annotation/BayDuikerCDO11_5Jan2023_RaconR3.fasta"
   outdir                 :  "bay_duiker_softmask"
   species                : "cow"
   cluster                : "xanadu"
}
```

Now, you can run the pipeline using:

```bash
nextflow pull emilytrybulec/repeatMaskerFaster
nextflow run emilytrybulec/repeatMaskerFaster \
   -profile <docker/singularity/.../institute> \
   -params-file params.yaml
```

Xanadu users: please refer to the [`example script`](https://github.com/emilytrybulec/repeat_curation/blob/main/nextflow.sh).    


## Credits

emilytrybulec/repeatMaskerFaster was originally written by Emily Trybulec with the help of Jessica Storer.


## Contributions and Support

If you would like to contribute to this pipeline, please see the [contributing guidelines](.github/CONTRIBUTING.md).

## Citations
If you use emilytrybulec/repeatMaskerFaster for your analysis, please cite it using this git.


This pipeline uses code and infrastructure developed and maintained by the [nf-core](https://nf-co.re) community, reused here under the [MIT license](https://github.com/nf-core/tools/blob/master/LICENSE).

> **The nf-core framework for community-curated bioinformatics pipelines.**
>
> Philip Ewels, Alexander Peltzer, Sven Fillinger, Harshil Patel, Johannes Alneberg, Andreas Wilm, Maxime Ulysse Garcia, Paolo Di Tommaso & Sven Nahnsen.
>
> _Nat Biotechnol._ 2020 Feb 13. doi: [10.1038/s41587-020-0439-x](https://dx.doi.org/10.1038/s41587-020-0439-x).
