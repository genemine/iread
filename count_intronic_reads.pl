#!/usr/bin/env perl
# Function:
# 1. count reads which are truly expressed from intron regions
# 2. Calculate entropy for each intron
# 3. Clculate gene-level intron reads by summing reads over all introns for a given gene
# Author:  Hongdong Li, @ISB, 2015
# edited:  Hongdong li, @CSU, 2017
# updated: Hongdong li, @CSU, Mar.,2018 (added parallel computing)

use List::Util qw(sum);
use Math::Complex;
use Parallel::ForkManager;

############################################
################## Input  ##################
############################################

$dir=$ARGV[0];  # input directory
$pure_file_name = $ARGV[1];
$ncore = $ARGV[2];
$intron_file=$ARGV[3];

############################################
################# main   ###################
############################################

#@all=glob "$dir/*bambed.bed";
#$i=1;
#$n=scalar @all;
#foreach $alignfile (@all){

$alignfile = "$dir/$pure_file_name"."_bambed.bed";

print "--->   Counting intronic reads\n";
@t=split '_bambed',$alignfile;
$overlapfile= $t[0]."_overlap_initial.bed";
$intron_level=$t[0]."_intron_reads.txt";
$intron_entropy=$t[0]."_intron_entropy.txt";
$gene_level  =$t[0]."_intron_reads_gene.txt";


# store align position information of all reads overlapping with intron regions
%read_start=();
%read_end=();
%read_span=();
%read_length=();
open FILE,"$alignfile" or die "cannot open the read align file"; # bam2bed file of aligned reads
while ($line=<FILE>){
	chomp $line;
	@t=split '\t',$line;
	$read_start{$t[3]}=$t[1];	
	$read_end{$t[3]}=$t[2];
	$read_span{$t[3]}=$t[2]-$t[1];
	$read_length{$t[3]}=$t[5];
}
close FILE;


# count only reads expressed from intron regions
%gchr=(); 
%gcount=(); 
%gpaircount=(); 
%gpurecount=(); 
%gcounts=(); 
%gcountps=(); 
%gintronlen=(); 
%gpsreads=(); 
%gdel=();

# split overlap files
open FILE,"$overlapfile";
@olapfiles =();
$oldchr="0";
open FNEW,'>olap.tmp';
while ($line=<FILE>){
	chomp $line;
	@t=split "\t",$line;
	$ichr = $t[0];
	if ($ichr ne $oldchr){
		close FNEW;
		$currentoverlap="$dir/overlap_$ichr.bed";
		push (@olapfiles,$currentoverlap);
		open FNEW,">$currentoverlap";
		print FNEW "$line\n";
		$oldchr=$ichr;
	}else{
		print FNEW "$line\n";
	}
}
#print "@olapfiles\n";
unlink('olap.tmp');



################
#### parallel
if ($ncore eq "default"){
	system('getconf _NPROCESSORS_ONLN > ncore.txt');
	open FILE,"ncore.txt";
	$ncore=<FILE>;
	chomp $ncore;
	$ncore = $ncore-2;
	close FILE;
	unlink('ncore.txt');
}
print "--->   Cores to use: $ncore\n";




my $pm = Parallel::ForkManager->new($ncore);
DATA_LOOP:
foreach my $olapfile (@olapfiles) {
   # Forks and returns the pid for the child:
   my $pid = $pm->start and next DATA_LOOP;


   # do things below: in each child process
   %allreadsid=();
   open NEW1,">$olapfile.part" or die;
   print NEW1 "#chr\tstart\tend\tgene\tintronLength\tintronID\treadCounts\tjunctionCounts\tentropy_score\n";


   open FILE,"$olapfile" or die "cannot open the read overlap file";
   while ($line=<FILE>){
	chomp $line;
	@t1=split '\|',$line;
	@t=split "\t",$t1[0];
	$intron_start=$t[1];
	$intron_end=$t[2];
	#$gene=$t[3];
	#$gchr{$gene}=$t[0];
	$intron_length=$t[4];
	#$gintronlen{$gene}+=$t[4];
	@intron=join("\t",@t[0..4]);
	$introndash=join("-",@t[0..4]);



	# divide intron into 8 bins: maximal 3 bits of information
	$nbins=8;
	$binwidth=($intron_end-$intron_start)/$nbins;	
	@binstart=();
	@binend=();
	@bincount=map {$_*0} (1..$nbins);
	foreach my $id (0..$nbins-1){
		$binstart[$id]=int($intron_start+$id*$binwidth);
		$binend[$id]=int($intron_start+($id+1)*$binwidth);
	}


	# below: for each intron
	@virtual_overlap_lengths=split ';',$t1[2];
	@readsid    =split ';',$t1[3];
	%pair1=();
	%pair2=();
	$count=0;
	$purecount=0;
	$countsplicing=0;
	$countpuresplicing=0;
	$psreads="";
	$del="";
	$nreads=scalar @virtual_overlap_lengths;
	foreach $k (0..$nreads-1){
		$overlaplen=$virtual_overlap_lengths[$k];
		$read=$readsid[$k];
		@tr=split ':',$read;
		$readid=$tr[0];
		$strand=$tr[1];
		$rstart=$read_start{$read};
		$rend=$read_end{$read};
		$rlength = $read_length{$read};

		# judge overlapping introns
		$judge1=0;$judge2=0;$judge3=0;$fullin=0;
		if ($rstart>=$intron_start+1 && $rstart <= $intron_end-1) {$judge1=1;}
		if ($rend  >=$intron_start+1 && $rend   <= $intron_end-1) {$judge2=1;}
		if ($rstart < $intron_start && $rend >  $intron_end  && $read_span{$read} == $rlength ) {$judge3=1;}
		if ($rstart >=$intron_start && $rend <= $intron_end){$fullin=1;}

		$totaljudge=$judge1+$judge2+$judge3;
		# reads overlap with intron
		if ($totaljudge > 0){
			
			# count reads fall into introns and genes
			if (exists $allreadsid{$readid}) {}else{
				$count++;
				#$gcount{$gene}++;
				if ( $fullin == 1  || $judge3 == 1){$purecount++;}
				$allreadsid{$readid}=0;
			}


			# determine whether a read is spliced or not
			$splicing=0;
			if ($read_span{$read} > $rlength) {
				$splicing=1;
				#$countsplicing++;
				#$gcounts{$gene}++;
			}

			# counts reads in each bin of an intron
			if ($splicing == 0 ){
			foreach $binid (0..$nbins-1){
				$thisbinstart=$binstart[$binid];
				$thisbinend  =$binend[$binid];
				$thisdifference=abs($read_span{$read}-$rlength);
				$binjudge=0;
				if ($rstart>=$thisbinstart && $rstart< $thisbinend) {$binjudge=1;}
				if ($rend  >=$thisbinstart && $rend < $thisbinend) {$binjudge=1;}
				if ($rstart<=$thisbinstart && $rend >=$thisbinend  && $thisdifference == 0 ) {$binjudge=1;}
				if ($binjudge == 1){$bincount[$binid]++;}

			}
			}

			## record paired reads
			#if ($strand eq "+") {
			#	$pair1{$readid}=0;
			#}else{
			#	$pair2{$readid}=0;
			#}		

			
			# determine whether a read completely falls into intron region
			$pureintron=0;
			if ($fullin==1 || $judge3==1){
				$pureintron=1;
			}
		

			# determine whether a full-intronic read is spliced
			#if ($splicing==1 && $pureintron==1){
			#	$countpuresplicing++;
			#	$gcountps{$gene}++;
			#	$psreads.=";$read_start{$read}-$read_end{$read}";
			#	$cdel=$read_end{$read}-$read_start{$read}-$rlength;
			#	$del.=";$cdel";
			#}

		}
	} # for each intron


	
	# calculate paired reads for each intron
	#$paircount=0;
	#foreach $thisread (keys %pair1){
	#	if (exists $pair2{$thisread}){
	#		$paircount++;
	#	}	
	#}

	# calculate entropy for intron
	if ($count >= 0 ){$entropy_score=&cal_entropy_score(@bincount);}

	# increase paircounts for the corresponding gene	
	#$gpaircount{$gene}+=$paircount;
	#$gpurecount{$gene}+=$purecount;
	
	# calculate junction count
	$junctioncount=$count-$purecount;


	# print counts for an intron
	if ($count >= 0 && $junctioncount >= 0 && $entropy_score >=0){
		print NEW1 "@intron\t$introndash\t$count\t$junctioncount\t$entropy_score\n";
		#$bincountstr=join("\t",@bincount);

		#$gpsreads{$gene}.=";$psreads";
		#$gdel{$gene}.=";$del";
	} # end of each intron
  }  # each sample end

  close FILE;
  close NEW1;
  #print "one process done\n";
  unlink($olapfile);
  $pm->finish; # Terminates the child process
}  # parallel end

$pm->wait_all_children; # wait until all child processes done

unlink($alignfile);
unlink($overlapfile);

#####################################
#####################################
# combine parts into a single file
@allparts= glob "$dir/*part";
open CMB,">$intron_level";
%ir_kept=();
foreach $ipart (@allparts){
	open FI,"$ipart";
	while ($line=<FI>){
		chomp $line;
		#print CMB "$line";
		@t=split '\t',$line;
		$ir_kept{$t[5]} = $line;
	}
	close FI;
	unlink($ipart);
}


# add all other introns that are in the inut list of independent introns to keep the output list the same length as the input list.
open FILE,"$intron_file" or die "cannot open the intron read file";
while ($line=<FILE>){
	chomp $line;
	@t=split '\t',$line;
	$irid = join("-", @t);
	if (exists($ir_kept{$irid})){
		print CMB "$ir_kept{$irid}\n";				
	}else{
		print CMB "$line\t$irid\t0\t0\t0.000000\n";
	}
}
close FILE;
close CMB;





##############################################
##############################################
############### sub-routines;


sub cal_entropy_score {
	my @a=@_;
	my $s=sum(@a);
	my $en = 0;
	if ($s > 0){
		my @p=map {$_/$s} (@a);
		foreach my $pi (@p) {if ($pi > 0)  {$en+=$pi*logn(1/$pi,2);}}
	}
	return sprintf("%.6f",$en/3); 
}

