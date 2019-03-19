# 1. iREAD
## 1.1 Description
iREAD (intron **R**Etention **A**nalysis and **D**etector)is a tool to detect intron retention(IR) events from RNA-seq datasets. Independent introns, referring to those introns that do not overlap with any exons of any splice isoforms, are used for detecting IRs. iREAD takes `two input files`: (1) a BAM file representing transcritome, and a bed-like text file containing independent intron coordinates, and output intron retention events based on a set of criteria that filter for reliable IR events. These criteria involves the number of reads/fragments in intronic regions, FPKM, junction reads, read distribution patterns within an intron.

## 1.2 Download

* **software**
    \<br>The source codes are tested and work on both MacOS and Linux operating system. They are freely available for non-commercial use.

* **Independent intron annotation(input files of iREAD)**
| **Version** | **Changes** |
| - | - |
| [iREAD_0.8.0.zip]http://www.genemine.org/codes/iREAD_0.8.0.zip | Multi-core computing implemented; \<br>Outputs merged into a single | file.
| [iREAD_0.6.0.zip]http://www.genemine.org/codes/iREAD_0.6.0.zip |  |
