my @split_files = `ls /mnt/d/Colaboraciones/Marisa_Nicolas/ncRNA_identificacion/NR2_search/Saureus_MRSA252_2/00-NRDR_mapping/\*_split.bed`;
chomp @split_files;

foreach my $each_file (@split_files){

	my $name_out = `ls $each_file | awk -F "/" '{print \$NF}' | awk -F "_finalClass" '{print \$1}'`;
	chomp $name_out;

	system "cut -f 4 $each_file | sort | uniq -c | awk ' BEGIN {print \"Class\\t$name_out\"}{print \$2 \"\\t\" \$1}' > /mnt/d/Colaboraciones/Marisa_Nicolas/ncRNA_identificacion/NR2_search/Saureus_MRSA252_2/00-NRDR_mapping//00-reports/$name_out\_ClassesNum.tab\n";

}

system "cat /mnt/d/Colaboraciones/Marisa_Nicolas/ncRNA_identificacion/NR2_search/Saureus_MRSA252_2/00-NRDR_mapping/00-reports/\*_ClassesNum.tab | cut -f 1 | grep -v \"Class\" | sort -u | awk ' BEGIN {print \"Class\"}{print \$0}' > /mnt/d/Colaboraciones/Marisa_Nicolas/ncRNA_identificacion/NR2_search/Saureus_MRSA252_2/00-NRDR_mapping/00-reports/1_RNAclass.list";

my @ClassesNum_files = `ls /mnt/d/Colaboraciones/Marisa_Nicolas/ncRNA_identificacion/NR2_search/Saureus_MRSA252_2/00-NRDR_mapping/00-reports/\*_ClassesNum.tab`;
chomp @ClassesNum_files;

my $join_files = join (" | perl z_merge_list.pl - ", @ClassesNum_files);

system "perl /mnt/d/Colaboraciones/Marisa_Nicolas/ncRNA_identificacion/NR2/bin/z_merge_list.pl /mnt/d/Colaboraciones/Marisa_Nicolas/ncRNA_identificacion/NR2_search/Saureus_MRSA252_2/00-NRDR_mapping/00-reports/1_RNAclass.list $join_files | sed 's/NO_MERGE/0/g' > /mnt/d/Colaboraciones/Marisa_Nicolas/ncRNA_identificacion/NR2_search/Saureus_MRSA252_2/00-NRDR_mapping/00-reports/z_final_TABLE_NR2.tab\n";

system "rm /mnt/d/Colaboraciones/Marisa_Nicolas/ncRNA_identificacion/NR2_search/Saureus_MRSA252_2/00-NRDR_mapping/00-reports/1_RNAclass.list"; ## <- REMOVE COMMENT
system "rm /mnt/d/Colaboraciones/Marisa_Nicolas/ncRNA_identificacion/NR2_search/Saureus_MRSA252_2/00-NRDR_mapping/00-reports/\*_ClassesNum.tab"; ## <- REMOVE COMMENT
