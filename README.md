#SVelter

##Description
This software is designed to identify both simple and complex rearrangements from paired-end sequencing data. Users could ran it easily by just alling *SVelter.py* with proper parameters. It's also possible to ran it on multiple cores by calling different sub-functions separately.

##Required third-party resources
R:        [https://www.r-project.org/](https://www.r-project.org/)
          with  *mixtools*  package installed

python:   [https://www.python.org/](https://www.python.org/)
          with *getopt,glob,math,numpy,scipy,random,pickle,time,itertools* installed

samtools: [http://samtools.sourceforge.net/](http://samtools.sourceforge.net/)


## Quick Start
Download and Install
```
git clone git@github.com:mills-lab/svelter.git
```

recompile might be necessary
```
python setup.py install
```


Index Reference genome
``` 
SVelter.py Setup --reference reference.fa --workdir /working/directory --exclude exclude.ref.bed --copyneutral CN2.ref.bed --ref-index indexed-ref/ --svelter-path SVelter/ 
```
Run SVelter with its default setting:
```
SVelter.py --sample /absolute/path/of/sample.bam --workdir /working/directory
```

##Test Data
Test data are available from: [SVelter Test Data Box](https://umich.box.com/s/owzli74p3g0vmrp0zwjx0neznopp1ch3), together with [results from SVelter](https://umich.box.com/s/i8kk5bjcm7rqjqtxu5jb6ajdfoym9imh)

Pre-indexed files for certain references are also available from [the box linked above](https://umich.box.com/s/t9kefajmkmsb6ajgaawo0erxosf32r2m). It's recommended to download to accelerate the *Setup* step.

Index Reference genome
``` 
SVelter.py Setup --reference hg19.fa --workdir /working/directory/ --exclude ../svelter/Support/Exclude.hg19.bed --copyneutral ../svelter/Support/CN2.hg19.bed --svelter-path ../svelter/ --segdup ../svelter/Support/Segdup.hg19.bed --ref-index ..Index.Reference/
```
Run SVelter with its default setting:
```
SVelter.py --sample sample.bam --workdir /working/directory/
```

###Required files:
`exclude.ref.bed` , `CN2.ref.bed`  and `Segdup.ref.bed`  are available from the folder *Support* for some versions of reference genome. Users could replace with their custom version as long as both are in bed format. For more details, please see *Support*. 


*Pre-indexed* files of certain reference genomes have been produced through [box link](https://umich.box.com/s/t9kefajmkmsb6ajgaawo0erxosf32r2m). For specific reference, if not *pre-indexed* files provided, the optional parameter '--ref-index' could be omit and the indexed files would be produced through the setup step. 

###Attention:
1. reference file should have been indexed by calling samtools first:  `samtools faidx ref.fasta`
2. working directory is required to be writable for temporal files 
3. with large sample size (eg. >50X whole genome sequencing), it is recommended that these parameters `--null-copyneutral-perc 0.01` added to your command; with small ones (eg. <10x), `--null-copyneutral-perc 0.5` is recommended.   This parameter decides the number of CN2 regions extracted for building null model.


##Usage
SVelter.py  [options]  [parameters]

###Options:
```
  Setup
  NullModel
  BPSearch
  BPIntegrate
  SVPredict
  SVIntegrate
```

###Parameters:
####For `Setup`:
#####Required Parameters:
```
--workdir, writable working directory.
--reference, absolute path of reference genome. eg: .../SVelter/reference/genome.fa
--exclude, absolute path of bed file indicating regions to be excluded from analysis. If not provided, no mappable regions will be excluded.
--copyneutral,absolute, path of bed file indicating copy neutural regions based on which null statistical models would be built. If not provided, genome would be randomly sampled for null model.
--svelter-path, folder which contains all SVelter scripts.
```
#####Optional Parameters:
```
--segdup, absolute path of bed file indicating segmental duplications in genome, that would be excluded from analysis
--ref-index, folders containin pre-indexed files, if applicable. For certain versions of human genome, the indexed files are availabel from https://github.com/mills-lab/svelter.
```
####For other step:
#####Required:
```
  --workdir, writable working directory.
  
  --sample, input alignment file in bam format
```

#####Optional:
```
--null-model, specify which stat model to be fitted on each parameter. if --null-model==C / Complex, negative bimodal distribution will be fitted to insertlenth; else, normal will be used

--null-copyneutral-length, minimum length requirement for --copyneutral regions used to build null model (default: 2000)

--null-copyneutral-perc, percentage of regions from --copyneutral to utilize (default: 0.1)

--null-random-length, specify the length of random regions if --copyneutral parameter not used (default: 5000)

--null-random-num, specify the number of random regions if --copyneutral parameter not used (default: 10000)

--num-iteration, maximum number of iterations per structure will run in SV predicting step

--qc-map-cutoff, the minimum mapping quality required for a breakpoint to be reported (default: 0.0)

--qc-align, minimum alignment quality required for mapped reads in bam file (default: 20)

--qc-split, minimum alighment of clipped parts of reads considered as a soft clip (default: 20)

--qc-structure, minimum quality score of a resolved structure to be considered as PASS and included in the output vcf file

--split-min-len, the minumum length of clip read considered as split; (default:10% of read length)

--prefix, output prefix for vcf and svelter files (default: input.vcf, input.svelter)

--ploidy, limit algorithm to specific zygosity (0:heterozygous only; 1:homozygous only; 2:both; default:2)
```


###For faster processing, SVelter could run with multiple cores:

####Step1: Build null models:
```
SVelter.py NullModel --sample /absolute/path/of/sample.bam --workdir /working/directory
```

```
Optional Parameters:

--chromosome, name of chromosome to run. should match chromosome name in bam file

--null-model, specify which stat model to be fitted on each parameter. if --null-model==C / Complex, negative bimodal distribution will be fitted to insertlenth; else, normal will be used

--null-copyneutral-length, minimum length requirement for --copyneutral regions used to build null model (default: 2000)

--null-copyneutral-perc, percentage of regions from --copyneutral to utilize (default: 0.1)

--null-random-length, specify the length of random regions if --copyneutral parameter not used (default: 5000)

--null-random-num, specify the number of random regions if --copyneutral parameter not used (default: 10000)

--qc-align, minimum alignment quality required for mapped reads in bam file (default: 20)

--qc-split, minimum alighment of clipped parts of reads considered as a soft clip (default: 20)

--split-min-len, the minumum length of clip read considered as split  (default:10% of read length)
```

####Step2: Search for Breakpoints:
```
SVelter.py BPSearch --sample /absolute/path/of/sample.bam --workdir /working/directory
```

```
Optional Parameters:

--chromosome, name of chromosome to run. should match chromosome name in bam file

--null-model, specify which stat model to be fitted on each parameter. if --null-model==C / Complex, negative bimodal distribution will be fitted to insertlenth; else, normal will be used

--qc-align, minimum alignment quality required for mapped reads in bam file (default: 20)

--qc-split, minimum alighment of clipped parts of reads considered as a soft clip (default: 20)

--split-min-len, the minumum length of clip read considered as split; (default:10% of read length)

--qc-map-tool, the tool extracts mappability information from a bigWig file,avaliable from: http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/bigWigSummary

--qc-map-file, .bigWig file used to decide local genomic mappability, avaliable from: ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Homo_sapiens/encodeDCC/wgEncodeMapability/

--qc-map-cutoff, the minimum mapping quality required for a breakpoint to be reported (default: 0.0)
```

####Step3: Cluster Breakpoints:
```
SVelter.py BPIntegrate --sample /absolute/path/of/sample.bam --workdir /working/directory
```

```
Optional Parameters:

--chromosome, name of chromosome to run. should match chromosome name in bam file

--batch, specify number of structures in each separate file (if 0, output files will be calssified by chromosomes; default, all BP clustered will be integrated in one txt file)
```

####Step4: Resolve complex structural variants:
```
SVelter.py SVPredict --sample sample.bam --workdir /working/directory --bp-file input/file/containing/clustered/bps
 ```
 
 ```
Optional Parameters:

--num-iteration, maximum number of iterations per structure will run

--ploidy, limit algorithm to specific zygosity (0:heterozygous only; 1:homozygous only; 2:both; default:2)

--null-model, specify which stat model to be fitted on each parameter. if --null-model==C / Complex, negative bimodal distribution will be fitted to insertlenth; else, normal will be used

--qc-align, minimum alignment quality required for mapped reads in bam file (default: 20)
```

####Step5: Write output in vcf format:
```
SVelter.py SVIntegrate --workdir /working/directory --prefix output  --input-path path/of/output/from/Step4
```

```
Optional Parameters:

--qc-structure, minimum quality score of a resolved structure to be considered as PASS and included in the output vcf file
```

