![iREAD](https://github.com/genemine/iread/blob/master/iREAD_files/ir1.png)
# 1. iREAD
## 1.1 Description
iREAD (intron **R**Etention **A**nalysis and **D**etector)is a tool to detect intron retention(IR) events from RNA-seq datasets. Independent introns, referring to those introns that do not overlap with any exons of any splice isoforms, are used for detecting IRs. iREAD takes `two input files`: (1) a BAM file representing transcritome, and a bed-like text file containing independent intron coordinates, and output intron retention events based on a set of criteria that filter for reliable IR events. These criteria involves the number of reads/fragments in intronic regions, FPKM, junction reads, read distribution patterns within an intron.

## 1.2 Download

* **software**

The source codes are tested and work on both MacOS and Linux operating system. They are freely available for non-commercial use.<br>

| **Version** | **Changes** |
| - | - |
| [iREAD_0.8.0.zip](http://www.genemine.org/codes/iREAD_0.8.0.zip) | Multi-core computing implemented;         <br>Outputs merged into a single | file.
| [iREAD_0.6.0.zip](http://www.genemine.org/codes/iREAD_0.6.0.zip) |  |

* **Independent intron annotation(input files of iREAD)**

>human<br>
[human_introns_ensemblv77](http://www.genemine.org/introns/intron_annotation_human_ensemblv77.bed) (Also included in the 'meta' folder in iREAD package)<br>
[human_introns_gencodev25](http://www.genemine.org/introns/intron_annotation_human_gencodev25.bed)<br>
[human_introns_gencodev19](http://www.genemine.org/introns/intron_annotation_human_gencodev19.bed)<br>

>mouse<br>
[mouse_introns_ensemblv75](http://www.genemine.org/introns/intron_annotation_mouse_ensemblv75.bed) (Also included in the 'meta' folder in iREAD package)<br>
[mouse_introns_gencodevM10](http://www.genemine.org/introns/intron_annotation_mouse_gencodevM10.bed)<br>
[mouse_introns_gencodevM1](http://www.genemine.org/introns/intron_annotation_mouse_gencodevM1.bed)<br>

>others<br>
[drosophila_introns_ensemblv84](http://www.genemine.org/introns/intron_annotation_drosophila_ensemblv84.bed)<br>

**Notes: Users can calculate independent intron annotations of their interested species/versions using [GTFtools](http://www.genemine.org/gtftools.php)**
<br>

# 2. Dependencies
* Samtools(version:1.2)
* Bedops(version:2.4.20), available at: https://bedops.readthedocs.io/en/latest/
* The PERL module Parallel::ForkManager needs to be installed to support multi-core computing
* python module: argparse. If not installed, run 'pip install argparse' from shell to install.

# 3. Install
After downloading the source file, unzip it, and ***add the iREAD package path to your environmental variable PATH*** by modifying your .bashrc or .bash_profile file in your home directory. 

**Note 1:** In the first line of the BASH, PERL and Python scripts in iREAD, the path for BASH, PERL and Python is set as follows by default:
```bash
BASH: /bin/bash
PERL: /usr/bin/perl
Python: /usr/bin/python
```
Just in case, if your BASH/PERL/Python is not in the default path, please ***change the first line (e.g. #!/usr/bin/python) in the scripts so that it correctly points to BASH/PERL/Python*** in your machine. <br>

**Note 2:** And, check that all scripts in the package are excecutable.

# 4. Usage
## 4.1 Run iREAD
Using iREAD is very simple. Only one command needs to be issued form command line, and you would be able to identify IR events from RNA-seq data. For illustration purpose, we have included a test BAM file and a intron coordinate text file along with the iREAD package for testing the package. After you unzip the source package, you should see two folders inside: one is **data** containing test data, the other is **meta** containing text files of intron coordinates for mouse (Ensembl ver75) and human(Ensembl ver77), respectively.
<br><br>
To run the iREAD for IR detection, assuming that you are in the folder of iREAD, just issue the following command from shell:
```bash
iread.py data/mouse_test.bam meta/intron_mouse_3875.bed -o tmp_output -t 62000000
```
**Notes:** Regarding the command above, -t specifies the totally number of mapped reads, which is needed to be provided for calculating FPKM. For this test data, the total number of mapped reads is 62000000 (reads mapped to the whole genome). The BAM file was aligned using STAR. After you run the above command, you will see screen output as below:
![running_screen](https://github.com/genemine/iread/blob/master/iREAD_files/screen.png)
<br>
It takes a few seconds to finish. After it is done, a folder named 'tmp_output' would be generated which contains output files inside. The file with suffix being .ir.txt records the identified IR events from your given BAM files.

## 4.2 Help document
To get help, use:
```bash
iread.py -h
```

# 5. Contact
If any questions, please do not hesitate to contact me at:
<br>
Hongdong Li `hongdong@csu.edu.cn` or `Hongdong.Li@systemsbiology.org`
<br>
Nathan Price `Nathan.Price@systemsbiology.org`

# How to cite?
If you use this tool, please cite the following work.
<br>
>Hong-Dong Li, Cory C. Funk, Nathan D. Price, iREAD: A Tool For Intron Retention Detection From RNA-seq Data, bioRxiv 135624; doi: https://doi.org/10.1101/135624
<br>

**Funding:** This work was supported by the NIA U01AG006786 (NDP) and start-up funding (NO. 502041004) from Central South University (HDL). 
