# 1. iREAD
## 1.1 Description
iREAD (intron **R**Etention **A**nalysis and **D**etector)is a tool to detect intron retention(IR) events from RNA-seq datasets. Independent introns, referring to those introns that do not overlap with any exons of any splice isoforms, are used for detecting IRs. iREAD takes `two input files`: (1) a BAM file representing transcritome, and a bed-like text file containing independent intron coordinates, and output intron retention events based on a set of criteria that filter for reliable IR events. These criteria involves the number of reads/fragments in intronic regions, FPKM, junction reads, read distribution patterns within an intron.

## 1.2 Download

* **software**

    The source codes are tested and work on both MacOS and Linux operating system. They are freely available for non-commercial use.<br>
| **Version** | **Changes** |
| - | - |
| [iREAD_0.8.0.zip](http://www.genemine.org/codes/iREAD_0.8.0.zip) | Multi-core computing implemented; <br>Outputs merged into a single | file.
| [iREAD_0.6.0.zip](http://www.genemine.org/codes/iREAD_0.6.0.zip) |  |

* **Independent intron annotation(input files of iREAD)**

>human

[human_introns_ensemblv77](http://www.genemine.org/introns/intron_annotation_human_ensemblv77.bed) (Also included in the 'meta' folder in iREAD package)<br>
[human_introns_gencodev25](http://www.genemine.org/introns/intron_annotation_human_gencodev25.bed)<br>
[human_introns_gencodev19](http://www.genemine.org/introns/intron_annotation_human_gencodev19.bed)<br>
>mouse

[mouse_introns_ensemblv75](http://www.genemine.org/introns/intron_annotation_mouse_ensemblv75.bed) (Also included in the 'meta' folder in iREAD package)<br>
[mouse_introns_gencodevM10](http://www.genemine.org/introns/intron_annotation_mouse_gencodevM10.bed)<br>
[mouse_introns_gencodevM1](http://www.genemine.org/introns/intron_annotation_mouse_gencodevM1.bed)<br>
>others

[drosophila_introns_ensemblv84](http://www.genemine.org/introns/intron_annotation_drosophila_ensemblv84.bed)
`Notes: Users can calculate independent intron annotations of their interested species/versions using [GTFtools](http://www.genemine.org/gtftools.php)`
<br>
