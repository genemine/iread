#!/usr/bin/python

# call intron retention events using a set of criteria.
# coded at: Central South University, Changsha 410083, P.R. China
# coded by: Hongdong Li. 
# contact: hongdong@csu.edu.cn



# import modules
import os
import glob
import sys
from sys import argv

# get input paramters
script,output_folder,pure_file_name,n_reads,n_junction,entropy,fpkm,total_reads,bias = argv

# convert to numbers
n_reads = float(n_reads)
n_junction = float(n_junction)
entropy = float(entropy)
fpkm = float(fpkm)
total_reads = float(total_reads)
bias = float(bias)

# determine IR events based on user-defined parameters.
#align_summary_file = output_folder+'/reads_summary.txt'
#f=open(align_summary_file,'r')
#for line in f:
#	if "properly paired" in line:
#		total_reads = int(int(line.split(' +')[0])/2)  # divided by two for calculating number of fragments
#f.close()


# identify intron retention events based using 
intron_reads_file = output_folder+'/'+pure_file_name+'_intron_reads.txt'
output_file= output_folder+'/'+pure_file_name+'.ir.txt'


print('--->   Identifying intron retention events')
f  = open(intron_reads_file)
fo = open(output_file,'w')


#1	3207317	3213438	ENSMUSG00000051951	6121	1-3207317-3213438-ENSMUSG00000051951-6121	0	0	0.000000
fo.write('intron_id\tfragments\tjunction_reads\tfpkm\tentropy_score\ttotal_fragments\tretention_at_given_cutoff\n')
for line in f:
	if line[0] != '#':
		table = line.strip().split('\t')
		ilength   = float(table[4])
		icounts   = float(table[6])
		ijunction = float(table[7])
		ientropy  = round(float(table[8]),6)
		ifpkm = round(1000000000*icounts/(ilength + bias)/total_reads,2)
		cnt= [table[5],table[6],table[7],str(ifpkm),str(ientropy),str(total_reads)]
		if ifpkm >= fpkm and ientropy >= entropy and ijunction >= n_junction and icounts >= n_reads:
			cnt.append('yes')
		else:
			cnt.append('no')		
		fo.write('\t'.join(cnt)+'\n')

f.close()
fo.close()

os.system('rm '+intron_reads_file)
print('--->   Intron retention data are output to '+output_file)
#######################################
## there is a song you like to sing
#######################################


