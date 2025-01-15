[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A523.04.0-23aa62.svg)](https://www.nextflow.io/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)
[![run with singularity](https://img.shields.io/badge/run%20with-singularity-1d355c.svg?labelColor=000000)](https://sylabs.io/docs/)

## Introduction

**emilytrybulec/repeatMaskerFaster** is a bioinformatics pipeline that takes a finished genome and performs repeat masking in batches. It produces a masked genome (.fasta.masked), detailed information about the repetitive elements identified by RepeatMasker (.out), and multiple sequence alignment of the repetitive regions identified in the sequence with the corresponding consensus sequences from the RepeatMasker database (.align). 

1. [`Repeat Masker`](https://www.repeatmasker.org/)
2. [`Repeat Masker on the Cluster`](https://github.com/Dfam-consortium/RepeatMasker_Nextflow)
   

## Usage

> _If you are new to Nextflow and nf-core, please refer to [this page](https://nf-co.re/docs/usage/installation) on how to set-up Nextflow._

### Configurations and parameters

First, go through nextflow.config to configure the pipeline to your needs. The batch size determines how big of chuncks your genome will be split into for faster processing, and the soft masking option can be modified to change how your output genome is masked.  


`nextflow.config`:

```config
params {

    // Input options
    soft_mask                  = true
    batch_size                 = 50000000

    species                    = null
    genome_fasta               = null
    consensus_fasta            = null
    cluster                    = null
}
```


Next, create a params.yaml file to input information in place of the null configurations. This information can also be supplied in teh command line, as shown [below](#running-the-pipeline) This file will contain your genome and preferred out directory name. The RepeatMasker species flag is used to warmup RepeatMasker, and a consensus path and can be supplied to process your genome against known repeats, if available.     
  
`params.yaml`:

```yaml
params {
   genome_fasta           : "/core/labs/Oneill/Finished_Genomes_for_Annotation/BayDuikerCDO11_5Jan2023_RaconR3.fasta"
   outdir                 :  "bay_duiker_softmask"
   species                : "cow"
   consensus_fasta        : "/core/labs/Oneill/etrybulec/bay_duiker/cephalophus_dorsalis_ad.fa"
   cluster                : "xanadu"
}
```

### Downloading/updating the pipeline

When you run the above command, Nextflow automatically pulls the pipeline code from GitHub and stores it as a cached version. When running the pipeline after this, it will always use the cached version if available - even if the pipeline has been updated since. To make sure that you're running the latest version of the pipeline, make sure that you regularly update the cached version of the pipeline:

```bash
nextflow pull emilytrybulec/repeatMaskerFaster
```

### Running the pipeline

You can run the pipeline using:

```bash
nextflow run emilytrybulec/repeatMaskerFaster \
   -profile <docker/singularity/.../institute> \
   -params-file params.yaml
```

Xanadu users: please refer to the [`example script`](https://github.com/emilytrybulec/repeatMaskerFaster/blob/main/nextflow.sh).    

OR... if you prefer to put all of your options in the command line, you will not need a params file:  
```bash
nextflow run emilytrybulec/repeatMaskerFaster \
   -profile <docker/singularity/.../institute> \
   --genome_fasta /core/labs/Oneill/Finished_Genomes_for_Annotation/BayDuikerCDO11_5Jan2023_RaconR3.fasta \
   --consensus_fasta /core/labs/Oneill/etrybulec/bay_duiker/cephalophus_dorsalis_ad.fa \
   --outdir bay_duiker_repeatmasker \
   --cluster xanadu
```

## Core Nextflow arguments

:::note
These options are part of Nextflow and use a _single_ hyphen (pipeline parameters use a double-hyphen).
:::

### `-profile`

Use this parameter to choose a configuration profile. Profiles can give configuration presets for different compute environments.

Several generic profiles are bundled with the pipeline which instruct the pipeline to use software packaged using different methods (Docker, Singularity, Podman, Shifter, Charliecloud, Apptainer, Conda) - see below.

:::info
We highly recommend the use of Docker or Singularity containers for full pipeline reproducibility, however when this is not possible, Conda is also supported.
:::

The pipeline also dynamically loads configurations from [https://github.com/nf-core/configs](https://github.com/nf-core/configs) when it runs, making multiple config profiles for various institutional clusters available at run time. For more information and to see if your system is available in these configs please see the [nf-core/configs documentation](https://github.com/nf-core/configs#documentation).

Note that multiple profiles can be loaded, for example: `-profile test,docker` - the order of arguments is important!
They are loaded in sequence, so later profiles can overwrite earlier profiles.

If `-profile` is not specified, the pipeline will run locally and expect all software to be installed and available on the `PATH`. This is _not_ recommended, since it can lead to different results on different machines dependent on the computer enviroment.

- `test`
  - A profile with a complete configuration for automated testing
  - Includes links to test data so needs no other parameters
- `docker`
  - A generic configuration profile to be used with [Docker](https://docker.com/)
- `singularity`
  - A generic configuration profile to be used with [Singularity](https://sylabs.io/docs/)
- `podman`
  - A generic configuration profile to be used with [Podman](https://podman.io/)
- `shifter`
  - A generic configuration profile to be used with [Shifter](https://nersc.gitlab.io/development/shifter/how-to-use/)
- `charliecloud`
  - A generic configuration profile to be used with [Charliecloud](https://hpc.github.io/charliecloud/)
- `apptainer`
  - A generic configuration profile to be used with [Apptainer](https://apptainer.org/)
- `wave`
  - A generic configuration profile to enable [Wave](https://seqera.io/wave/) containers. Use together with one of the above (requires Nextflow ` 24.03.0-edge` or later).
- `conda`
  - A generic configuration profile to be used with [Conda](https://conda.io/docs/). Please only use Conda as a last resort i.e. when it's not possible to run the pipeline with Docker, Singularity, Podman, Shifter, Charliecloud, or Apptainer.

### `-resume`

Specify this when restarting a pipeline. Nextflow will use cached results from any pipeline steps where the inputs are the same, continuing from where it got to previously. For input to be considered the same, not only the names must be identical but the files' contents as well. For more info about this parameter, see [this blog post](https://www.nextflow.io/blog/2019/demystifying-nextflow-resume.html).

You can also supply a run name to resume a specific run: `-resume [run-name]`. Use the `nextflow log` command to show previous run names.

### `-c`

Specify the path to a specific config file (this is a core Nextflow command). See the [nf-core website documentation](https://nf-co.re/usage/configuration) for more information.

## Custom configuration

### Resource requests

Whilst the default requirements set within the pipeline will hopefully work for most people and with most input data, you may find that you want to customise the compute resources that the pipeline requests. Each step in the pipeline has a default set of requirements for number of CPUs, memory and time, which can be found in [the base configuration file](https://github.com/emilytrybulec/repeatMaskerFaster/blob/main/conf/base.config). For most of the steps in the pipeline, if the job exits with any of the error codes specified [here](https://github.com/nf-core/rnaseq/blob/4c27ef5610c87db00c3c5a3eed10b1d161abf575/conf/base.config#L18) it will automatically be resubmitted with higher requests (2 x original, then 3 x original). If it still fails after the third attempt then the pipeline execution is stopped.

To change the resource requests, please see the [max resources](https://nf-co.re/docs/usage/configuration#max-resources) and [tuning workflow resources](https://nf-co.re/docs/usage/configuration#tuning-workflow-resources) section of the nf-core website.


## Credits

emilytrybulec/repeatMaskerFaster was originally written by the [DFAM consortium](https://github.com/Dfam-consortium/RepeatMasker_Nextflow) and modified for the Xanadu cluster by Emily Trybulec with the help of Jessica Storer.


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
