use Getopt::Long qw(GetOptions);
Getopt::Long::Configure qw(gnu_getopt);
use strict;
use diagnostics;

## --------------------- CHEKING OPTIONS --------------------- ##
my $usage = "
	Usage: perl $0 [options] -i <input> --min <length min> --max <length max>

Options
-x	Consider input as Bowtie2 indexes	(Default: FASTA file)
-t	Threads 				(Default: 1)
-N	Mistmatch (0 or 1)			(Default: 1)
-c	Seqs had the class (in other hand	(Default: yes)
	the seqs had the organism origin
	-yes|no-)
-o output folder
			
";

if (@ARGV < 7){
	die $usage;
}

## --------------------- OPTIONS --------------------- ##

my $input;
my $min_len = 50;
my $max_len = 500;
my $index;
my $threads = 1;
my $mistmatch = 1;
my $class = "yes";
my $output;
GetOptions(
	'i=s' => \$input,
	'min=i' => \$min_len,
	'max=i' => \$max_len,
	'x' => \$index,
	't=i' => \$threads,
	'N=i' => \$mistmatch,
	'c=s' => \$class,
	'o=s' => \$output,

) or die "Not valid option(s) found!\n";




## --------------------- OPTIONS INSPECTION --------------------- #

## --- mistmatch
if ($mistmatch > 1 || $mistmatch < 0){
	print "Not valid number for mistmatch. Selected 1 for run\n";
	$mistmatch = 1;
}


## is FASTA?
if (! $index){

	my $head_file = `head -1 $input`;
	chomp $head_file;

	if ($head_file !~ /\>/){

		print "FASTA file?. The first line of file $input not contain a FASTA head.\n";
		exit;
	}

} else {

	my $bt2_index_files = `ls $input*bt2 `;
	chomp $bt2_index_files;

	if (!$bt2_index_files){

		print "INDEX file?. Index for Bowtie2 not found.\n";
		exit;
	
	}

}

## class or organism

if ($class !~ /yes|no/){
	print "Not available option for Class (-c). Selected 'yes'.\n";
	$class = "yes";
}



## --------------------- FOLDERS --------------------- #

system "mkdir -p $output/index/";
system "mkdir -p $output/00-NRDR_mapping/00-reports";




## --------------------- RUTES --------------------- ##

my $NRDR = "bin/all_ncRNA.fa";




## --------------------- RUN --------------------- ##


## STEP 1 ----- PARSE NRDR

$/ = ">";

my $detect_temp = `ls bin/*.fa| grep "temp"`;
chomp $detect_temp;

if (!$detect_temp){

	open (IN,"<","$NRDR");
	open (my $fh_1,">","bin/temp.fasta");

	<IN>;
	while (<IN>){
		chomp $_;

		my @div_seq = split ("\n", $_);

		my $head = shift (@div_seq);
		my $seq = join ("", @div_seq);

		my $length_seq = length ($seq);

		$head =~ s/ /_/g;

		my @div_head = split (/\|/, $head);
		my $size_head = scalar (@div_head);

		if ($size_head >= 2){
			if ($length_seq >= $min_len && $length_seq <= $max_len){

				my @div_head = split (/\|/, $head);

				my $RNA_class = pop (@div_head);
				my $organism = pop (@div_head);

				my @div_RNA_class = split (",", $RNA_class);
				my @div_organism = split (",", $organism);

				my %uniq_organism;
				my %uniq_class;

				foreach my $each_organism (@div_organism){
					 #my @div_1 = split ("_", $each_organism);
					#my $join_1 = $div_1[0] . "_" . $div_1[1];
					#$uniq_organism{$join_1} = 0;
					my @div_1 = split ("_", $each_organism);
					if (defined $div_1[0] && defined $div_1[1]) {
						my $join_1 = $div_1[0] . "_" . $div_1[1];
						$uniq_organism{$join_1} = 0;
						} else {
							warn "Skipping incomplete data in: $each_organism\n";
						}


				}


				foreach my $each_class (@div_RNA_class){
					my @div_2 = split (/\(/, $each_class);
					my $join_2 = $div_2[1];
					$join_2 =~ s/\)//g;
					$join_2 =~ s/riboswitch/Riboswitch/g;
					$join_2 =~ s/ /_/g;
					$uniq_class{$join_2} = 0;
				}

				my @all_classes = keys (%uniq_class);
				my @all_organisms = keys (%uniq_organism);

				my $recover_class = join (",", @all_classes);
				my $recover_organism = join (",", @all_organisms);

				if ($class eq "yes"){
					print $fh_1 ">$recover_class\n";
					print $fh_1 "$seq\n";
				} else {
					print $fh_1 ">$recover_organism\n";
					print $fh_1 "$seq\n";
				}
			}
		}
	}
}



$/ = "\n";




### STEP 2 ----- MAKING BOWTIE2

my $name_out = "out";

if (!$index){

	my $head_file = `ls $input | awk -F "/" '{print \$NF}'`;
	chomp $head_file;

	my @name_parts = split (/\./, $input);
	$name_out = shift (@name_parts);

	system "bowtie2-build --threads $threads $input index/$name_out\n";
	system "bowtie2 -p $threads -a -N $mistmatch -x index/$name_out -f bin/temp.fasta -S $output/00-NRDR_mapping/$name_out.sam\n";
	system "sam2bed < $output/00-NRDR_mapping/$name_out.sam > $output/00-NRDR_mapping/$name_out\_raw.bed\n";
	system "cut -f 1-6 $output/00-NRDR_mapping/$name_out\_raw.bed > $output/00-NRDR_mapping/$name_out.bed\n";

	system "rm $output/00-NRDR_mapping/$name_out\_raw.bed\n";
	system "rm $output/00-NRDR_mapping/$name_out.sam\n";


} else {

	my @name_parts = split ("/", $input);
	$name_out = pop (@name_parts);

	system "bowtie2 -p $threads -a -N $mistmatch -x $input -f bin/temp.fasta -S $output/00-NRDR_mapping/$name_out.sam\n";
	system "sam2bed < $output/00-NRDR_mapping/$name_out.sam > $output/00-NRDR_mapping/$name_out\_raw.bed\n";
	system "cut -f 1-6 $output/00-NRDR_mapping/$name_out\_raw.bed > $output/00-NRDR_mapping/$name_out.bed\n";

	system "rm $output/00-NRDR_mapping/$name_out\_raw.bed\n";
	system "rm $output/00-NRDR_mapping/$name_out.sam\n";

}


#system "rm bin/temp.fasta"; ## <- REMOVE COMMENT


## OPTIONAL STEPS

if ($class eq "yes") {

	### STEP 3 ----- MAKING MERGEBED AND WRITE FINAL CLASS

	## NOTE: You can add cases here for to combine clases of NR2
	my %cases_of_merge = (

		"Cis-reg;Unclassified"	=> "Cis-reg",
		"Gene;SRP_RNA"		=> "SRP_RNA",
		"Gene;tmRNA"		=> "tmRNA",
		"RNase_P;ribozyme"	=> "RNase_P",

	);


	my @lines_mergeBed = `sortBed -i $output/00-NRDR_mapping/$name_out.bed | mergeBed -c 4,5,6 -o distinct,mean,distinct -s -d -10 -delim ";" -i -`;
	chomp @lines_mergeBed;

	open (my $fh_3,">","$output/00-NRDR_mapping/$name_out\_finalClass.bed");

	foreach my $each_line_merged (@lines_mergeBed){

		my @cols = split ("\t", $each_line_merged);

		if (!$cases_of_merge{$cols[3]}){
			my $recover_line_merge = join ("\t", @cols);
			print $fh_3 "$recover_line_merge\n";
		} else {
			$cols[3] = $cases_of_merge{$cols[3]};
			my $recover_line_merge = join ("\t", @cols);
			print $fh_3 "$recover_line_merge\n";
		}
	}


#system "sortBed -i $output/00-NRDR_mapping/$name_out.bed | mergeBed -c 4,5,6 -o distinct,mean,distinct -d -10 -delim \";\" -i - > $output/00-NRDR_mapping/$name_out\_finalClass.bed";

	### STEP 4 ----- SPLIT THE FILES (IN CASE OF MULTIFASTA)

	my @chromosomes = `cut -f 1 $output/00-NRDR_mapping/$name_out\_finalClass.bed | sort -u`;
	chomp @chromosomes;

	foreach my $each_chrom (@chromosomes){
		system "awk -F \"\\t\" '\$1 == \"$each_chrom\"' $output/00-NRDR_mapping/$name_out\_finalClass.bed > $output/00-NRDR_mapping/$each_chrom\_finalClass_split.bed\n";
	}

	### STEP 5 ----- STADS

	#system "perl bin/1_stads.pl\n";
	
}



























































#		## CODE USED BEFORE TO MODIFY THE HEAD OF SEQUENCES IN FASTA FILTERED BY LENGTH
### STEP 3 ----- PARSE class
###			Leave no-repeat class

#my @lines_BED = `cat 00-NRDR_mapping/$name_out.bed`;
#chomp @lines_BED;

#open (my $fh_2,">","00-NRDR_mapping/$name_out\_onlyCLASS.bed");

#foreach my $each_line_BED (@lines_BED){

#	my %remove_repeats;

#	my @cols = split ("\t", $each_line_BED);

#	my $annot = $cols[3];

#	my @div_annot = split (/\|/, $annot);

#	my $number_of_annot = scalar (@div_annot);

#	if ($number_of_annot > 2){

#		my $RNAclasses = pop (@div_annot);
#		my @div_RNAclasses = split (",", $RNAclasses);

#		foreach my $each_RNA_class (@div_RNAclasses){

#			my @obtain_class_raw = split (/\(/, $each_RNA_class);
#			my $the_class = pop (@obtain_class_raw);
#			$the_class =~ s/\)//g;

#			$remove_repeats{$the_class} = 0;

#		}
#		
#		my @clases_final_raw = keys (%remove_repeats);
#		my $clases_final = join ("|", @clases_final_raw);

#		$cols[3] = $clases_final;

#		my $recover = join ("\t", @cols);

#		print $fh_2 "$recover\n";

#	}
#}












