
# specify input data and output settings
bam="./data/mouse_test.bam"
intronbed="meta/intron_mouse_3875.bed"
output="./tmp_output"
total_mapped=62000000
iread.py $bam $intronbed -o $output -t $total_mapped -q 255

