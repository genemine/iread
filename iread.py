#!/usr/bin/python2
# This is the command line entry point to call intron retention.
# coded at: Central South University, Changsha 410083, P.R. China
# coded by: Hongdong Li. 
# contact: hongdong@csu.edu.cn
# Mar. 12, 2017



# import modules
import argparse
import os
import glob

# argument parser
parser = argparse.ArgumentParser()  # create a parser
parser.add_argument('bam_file',help="A coordinate-sorted BAM file resulting from read alignment. Samtools can be used for sorting.")
parser.add_argument('intron_file',help="a file listing introns in bed format.")
parser.add_argument('-o','--output_folder',help="a folder to output intron retention results. It will be created if not exist. And if it already exists, all data from the folde will be delted first.")
parser.add_argument('-n','--number_of_reads',help="threshold of number of intronic reads to determine an intron retention event. Default: 20")
parser.add_argument('-j','--junction_reads',help="threshold of number of exon-intron junction reads to determine an intron retention event. Default: 1")
parser.add_argument('-f','--fpkm',help="threshold of FPKM to determine an intron retention event. Default: 3")
parser.add_argument('-e','--entropy',help="threshold of entropy_score to determine an intron retention event. Range of this parameter is [0,1]. This score measures to which extent reads are uniformly distributed aross the whole region for a given intron. Default: 0.9")
parser.add_argument('-t','--total_reads',help="The total number of mapped reads/fragments from read aligners, say 50 million. This is used to calculate FPKM. Users can use samtools to calculate the number of mapped reads from the input bam file. It's needed to be provided by user.")
parser.add_argument('-k','--n_cores',help="The number of CPU cores to use. Default to n-2, where n is the total number of cores available.")
parser.add_argument('-q','--MAPQ',help="The MAPQ score for retrieving uniquely mapped reads. Default to 255, which is the score for unique mapping reads in STAR. If other aligners such as Hisat or TopHat are used, change this score accordingly.")
parser.add_argument('-s','--threads', help="Number of threads to use. Default to 20.")
parser.add_argument('-m','--mem', help="memory to use (unit: G). Default to 30.")
parser.add_argument('-b','--bias',help="an intron-length correction term for calculating FPKM of introns. This means that the length of intron used for calculating FPKM will be the true intron length plus this correction term. This is used to prevent very high FPKM for short introns. Default: 100.")

args = parser.parse_args()   # parse command-line arguments

######################################
#################  main   ############
######################################
bam_file=args.bam_file
if bam_file[-3:] == 'bam':
	pure_file_name = bam_file.split('/')[-1].split('.bam')[0]
elif bam_file[-3:] == 'BAM':
	pure_file_name = bam_file.split('/')[-1].split('.BAM')[0]
else:
	print('Input file needs to be a bam file with suffix .bam or .BAM')
	exit()

intron_file=args.intron_file

# creat output folder if not exists, which defaults to './tmp'
if args.output_folder:
	output_folder = args.output_folder
else:
	output_folder ="./tmp"

# threshold of number of reads in introns
if args.number_of_reads:
	number_of_reads = args.number_of_reads
else:
	number_of_reads = 20



# threshold of FPKM of introns
if args.fpkm:
	fpkm = args.fpkm
else:
	fpkm = 3

# number of total mapped reads. Used to calculate FPKM
if args.total_reads:
	total_reads = args.total_reads
else:
	print('*******************************************************************************')
	print('**** The total number of reads/fragments must be provided for calculating  ****')
	print('**** FPKM. One way is to use "samtools flagstat test.bam" to check how many ***')
	print('**** reads/fragments are aligned.                                           ***')
	print('*******************************************************************************')
	exit()
	#print('Get total_reads from BAM file since not provide.')
	#align_summary_file = output_folder+'/reads_summary.txt'
	#cmd='samtools flagstat '+ bam_file  + ' > ' + align_summary_file
	#os.system(cmd)
	#f=open(align_summary_file,'r')
	#for line in f:
#		if "properly paired" in line:
#			total_reads = int(int(line.split(' +')[0])/2)  # divided by two for calculating number of fragments
#	f.close()


# threshold of entropy of introns
if args.entropy:
	entropy = args.entropy
else:
	entropy = 0.9


# threhold of number of exon-intron junction reads
if args.junction_reads:
	junction_reads = args.junction_reads
else:
	junction_reads = 1


# number of cores
if args.n_cores:
	n_cores = args.n_cores
else:
	n_cores = 'default'


# scores for uniquely mapped reads
if args.MAPQ:
	MAPQ = args.MAPQ
else:
	MAPQ = 255   # 255 for STAR
# number of threads
if args.threads:
	threads = args.threads
else:
	threads = 20




# memory settings
if args.mem:
	mem = args.mem
else:
	mem = 30

# correction term for intron lengths
if args.bias:
	bias = args.bias
else:
	bias = 100

# reduce bam to intronic regions
cmd_reduce = 'bam2intron ' + ' ' + bam_file + ' ' + intron_file + ' ' + output_folder + ' ' + pure_file_name + ' ' +str(MAPQ) + ' '+str(threads)+' '+str(mem)+'G'
#print(cmd_reduce)
os.system(cmd_reduce)

# count intronic reads
cmd_count = 'count_intronic_reads.pl ' + output_folder + ' ' + pure_file_name + ' '+ n_cores + ' '+ intron_file
#cmd_count = 'count_intronic_reads_singlecore.pl ' + output_folder + ' ' + pure_file_name
os.system(cmd_count)

# combine

# determine IR events based on user-defined parameters.
cmd_assess = 'assess_intron.py ' + output_folder+" "+pure_file_name+" "+str(number_of_reads)+" "+ str(junction_reads)+" "+ str(entropy)+" "+str(fpkm)+" "+ str(total_reads)+" "+ str(bias)
os.system(cmd_assess)


############
#### There is always a song you like to sing.


