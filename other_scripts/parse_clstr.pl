#!/urs/bin/perl -w

#>Cluster 0
#0	315nt, >a_GG12-C01-09|Other|81... *


if(@ARGV != 1) {
	print "Usage: $0 input.clstr\n";
	exit;
}
my %strains = ();
my %classes = ();
open(IN, $ARGV[0]) or die "Can't open the file $ARGV[0]\n";
$/ = ">Cluster ";
<IN>;
my %info = ();
my %info_class = ();
while(<IN>) {
	chomp $_;
	my @lines = split("\n",$_);
	my $head = shift(@lines);
	foreach my $line (@lines) {
		my @temp_class = split(">",$line);
		my ($strain,$class,$dump) = split(/\|/,$temp_class[1]);
		if($info{$head}{$strain}) {
			$info{$head}{$strain}++;
		} else {
			$info{$head}{$strain} = 1;
		}
		$strains{$strain} = 1;
		if($info_class{$head}{$class}) {
			$info_class{$head}{$class}++;
		} else {
			$info_class{$head}{$class} = 1;
		}
		$classes{$class} = 1;
	}
}
open (STRAIN, ">$ARGV[0].strain_info");
open (CLASS, ">$ARGV[0].class_info");
my @strains = sort keys %strains;
my $pri = join("\t",@strains);
print STRAIN "Cluster\t$pri\t#conserved\tClasses\n";
foreach my $cluster (sort { $a <=> $b } keys %info) {
	my $count = 0;
	my $line = "";
	print STRAIN $cluster;
	foreach my $strain (sort keys %strains) {
		if($info{$cluster}{$strain}) {
			$line .= "\t$info{$cluster}{$strain}";
			$count++;
		} else {
			$line .= "\t0";
		}
	}
	my @unique_class = (sort keys %{$info_class{$cluster}});
	if(@unique_class > 1) {	##elimina casos qls que tengan rRNA y otros				
		my @temp = @unique_class;
		@unique_class = ();
		foreach my $temp (@temp) {
			if($temp eq "rRNA") {
				@temp = ();
				@unique_class = ();
				push(@unique_class,"rRNA");						
			} else {
				push(@unique_class,$temp);
			}
		}
	}
	if(@unique_class > 1) {	##elimina casos qls que tengan processed transcript
		my @temp = @unique_class;
		@unique_class = ();
		foreach my $temp (@temp) {
			if($temp ne "processed_transcript") {
				push(@unique_class,$temp);
			}
		}
	}
	if(@unique_class > 1) {	##elimina casos qls que tengan ncRNA
		my @temp = @unique_class;
		@unique_class = ();
		foreach my $temp (@temp) {
			if($temp ne "ncRNA") {
				push(@unique_class,$temp);
			}
		}
	}
	if(@unique_class > 1) {	##elimina casos qls que tengan miscRNA
		my @temp = @unique_class;
		@unique_class = ();
		foreach my $temp (@temp) {
			if($temp ne "miscRNA") {
				push(@unique_class,$temp);
			}
		}
	}
	if(@unique_class > 1) {	##elimina casos qls que tengan sRNA
		my @temp = @unique_class;
		@unique_class = ();
		foreach my $temp (@temp) {
			if($temp ne "sRNA") {
				push(@unique_class,$temp);
			}
		}
	}
	if(@unique_class > 1) {	##elimina casos qls que tengan guide RNA
		my @temp = @unique_class;
		@unique_class = ();
		foreach my $temp (@temp) {
			if($temp ne "gRNA") {
				push(@unique_class,$temp);
			}
		}
	}
	if(@unique_class > 1) {	##elimina casos qls que tengan processed transcript y guide RNA eliminandolos
		my @temp = @unique_class;
		@unique_class = ();
		foreach my $temp (@temp) {
			if($temp ne "Hgc") {
				push(@unique_class,$temp);
			}
		}
	}
	if(@unique_class > 1) {	##elimina casos qls que tengan processed transcript y guide RNA eliminandolos
		my @temp = @unique_class;
		@unique_class = ();
		foreach my $temp (@temp) {
			if($temp ne "CRISPR") {
				push(@unique_class,$temp);
			}
		}
	}
	if(@unique_class == 0) {	##Si queda sin clase despues se guarda como Multiple classes
		$unique_class[0] = "Multiple_classes";
	}
	if(@unique_class ==2 && (($unique_class[0] eq "tmRNA" && $unique_class[1] eq "tRNA") || (($unique_class[0] eq "tRNA" && $unique_class[1] eq "tmRNA")))) {
		@unique_class = ();
		$unique_class[0] = "tmRNA";
	}
	if(@unique_class ==2 && (($unique_class[0] eq "RNase_P" || $unique_class[1] eq "ribozyme") || (($unique_class[0] eq "ribozyme" || $unique_class[1] eq "RNase_P")))) {
		@unique_class = ();
		$unique_class[0] = "RNase_P";
	}
	if(@unique_class ==2 && ($unique_class[0] eq "snoRNA" && $unique_class[1] =~ m/snoRNA/)){
		shift(@unique_class);
	}
	if(@unique_class ==2 && ($unique_class[1] eq "snoRNA" && $unique_class[0] =~ m/snoRNA/)){
		pop(@unique_class);
	}
	if(@unique_class ==2 && ($unique_class[1] =~ m/snoRNA/ && $unique_class[0] =~ m/snoRNA/)){
		@unique_class = ();
		$unique_class[0] = "snoRNA";
	}
	if(@unique_class > 1) {	##se guarda como Multiple classes si tiene mas de 1
		my $tempp = join ";",@unique_class;
		@unique_class = ();
		$unique_class[0] = $tempp;
	}
	print STRAIN "$line\t$count\t$unique_class[0]\n";
}
close STRAIN;
my @classes = sort keys %classes;
$pri = join("\t",@classes);
print CLASS "Cluster\t$pri\t#conserved\n";
foreach my $cluster (sort { $a <=> $b } keys %info_class) {
	my $count = 0;
	my $line = "";
	print CLASS $cluster;
	foreach my $class (sort keys %classes) {
		if($info_class{$cluster}{$class}) {
			$line .= "\t$info_class{$cluster}{$class}";
			$count++;
		} else {
			$line .= "\t0";
		}
	}
	print CLASS "$line\t$count\n";
}
close CLASS;
