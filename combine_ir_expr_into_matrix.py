
import os,sys,glob
from collections import defaultdict

script,folder,output_prefix=sys.argv


# collections of functions

def collect_ir_expr_iread(folder,outputfile='',column_id='',tag='*ir.txt'):
#fragments	junction_reads	fpkm	entropy_score

    allfiles = glob.glob(folder+'/'+tag)
    G = defaultdict(dict)
    samples = []

    # get list of all retained introns
    irlist = {}
    for ifile in allfiles:
        f = open(ifile)
        f.readline()
        for line in f:
            t=line.strip().split('\t')
            if t[6] == 'yes':
                irlist[t[0]]=0
        f.close()


    # record FPKM
    for ifile in allfiles:
        f=open(ifile)
        isample = ifile.split('/')[-1].split('.ir.txt')[0]
        samples.append(isample)
        f.readline()
        for line in f:
            t = line.strip().split('\t')
            ir = t[0]
            if ir in irlist:
                irfpkm = t[column_id]
                G[ir][isample] = irfpkm
        f.close()

    #counts object
    ret={}
    ret['samples'] =  samples
    ret['expr']  =  G
    #ret = filter_expr(ret)
    print(len(ret['expr'].keys()),' introns retained')
    # write to file if needed
    if len(outputfile) > 1:
        f = open(outputfile,'w')
        header = 'ir'+'\t'+'\t'.join(samples)+'\n'
        f.write(header)
        allgenes = list(G.keys())
        allsamples = samples

        for i in range(len(allgenes)):
            igene = allgenes[i]
            f.write(igene)   # start of one line
            for j in range(len(allsamples)):
                jsample = allsamples[j]
                value = G.get(igene,{}).get(jsample)      # counts in one line
                if repr(value) == "None":
                    f.write('\t'+'0')
                else:
                    f.write('\t'+value)
            f.write('\n')  # end of one line
        f.close()
    else:
        'The file name for the output needs to be specified.'
    # return 
    return(ret)
   
# main
collect_ir_expr_iread(folder,output_prefix+'.counts.txt',column_id=1)
collect_ir_expr_iread(folder,output_prefix+'.fpkm.txt',column_id=3)



