
# specify input data and output settings
bam="./data/mouse_1819.bam"
intronbed="meta/intron_mouse_3875.bed"
output="./tmp_output"
total_mapped=62000000
iread.py $bam $intronbed -o $output -t $total_mapped -k 1
grep yes tmp_output/mouse_1819.ir.txt | wc 

