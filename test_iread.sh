
# specify input data and output settings
bam="./data/mouse_test_byname.bam"
intronbed="meta/intron_mouse_3875.bed"
output="./tmp_output"
total_mapped=62000000
ncore=1
iread.py $bam $intronbed -k $ncore -o $output -t $total_mapped
