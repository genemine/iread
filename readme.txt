software:	iREAD
coded with: 	perl(v5.18.2), python(v2.7)
function: 	identify intron retention events
input: 		RNA-seq BAM file. Currently BAM file from STAR(version:2.5.2b) was tested. 
		But BAM files from other aligners like TOPHAT can be used.

######################
### Dependents:  #####
1.	samtools: 1.2
2.	bedops: 2.4.20.  Download from https://bedops.readthedocs.io/en/latest/. convert2bed,
		bam2bed and bedmap in this package are used.


######################
### python modules  ##
1.	argparse   (run 'pip install argparse' to install this module)

