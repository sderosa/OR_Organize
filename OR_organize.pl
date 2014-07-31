#!/usr/bin/perl -w
# This program takes olfactory receptor gene sequences, assigns the correct OR gene family 
# number and then organizes data into folders for each individual OR gene family. 
# The following programs are required:
# BioPerl,HMMER, FASTA,and ORA for instructions on installing these packages: 
#	http://laurelslabnotebook.blogspot.com/search/label/ORA (Thank you Laurel!)
# Selectseqs :
# http://raven.iab.alaska.edu/~ntakebay/teaching/programming/perl-scripts/perl-scripts.html
# Copyright 2014  DeRosa S 
# This is my first program, constructive feedback is appreciated :) 
#----------------------------------------------------------------------------------------
use strict;
use warnings;

# Full path to OR sequences in FASTA format
my $inputDir = " /Users/YourUser/Documents/OR_unlabeled/";

# Full path to where labeled OR sequences will be placed
my $outputDir = "/Users/YourUser/Documents/OR_Labeled_results/";

#Full path to where Selectseqs will create folders for each gene family 
my $SelectSeqOutputDir = "/Users/YourUser/Documents/GeneticData/";

my $pseudogene = 0;
my $RegHeader;
my $IDheader;
my $ORNum;
my @header;
my $header;
#----------------------------------------------------------------------------------------
print "What is the name of the species?"; 
my $spec_name = <STDIN>;
chomp($spec_name);
my $spec_ending .= "_ORs.fasta";
my $spec_file = join "", $spec_name, $spec_ending;
#print "$spec_file \n";
my $SpecFileResults = join "", $outputDir, $spec_name, "_results", $spec_ending;

#Run ora pipeline to label OR genes 
#Change to directory where ora pipeline is located 
chdir("/yourPath/ora-1.9.1/scripts");

my $run_ora = " or.pl --sequence$inputDir$spec_file > $SpecFileResults";
print "Running ORA Pipeline.  This may take a while";
system($run_ora);

#run the select seqs script 
open(IN,"$SpecFileResults") or die("can't open $SpecFileResults $!");
#open the output file from ora. 
while(my $line = <IN>) 
{
	my $first_char = substr($line, 0 , 1);
	#print "$first_char"
	if ($first_char eq ">" )
	{
		 @header = split /[\|]/, $line;
		if ($header[$#header] =~ m/PSEUDOGENE/)
		{
			$pseudogene = 1;
			
		}
		else
	    {
	      $pseudogene = 0; 
	    }
			if ($header[3] =~ m/^OR/)
			 {
			 	$ORNum=$header[3];
			 }
			elsif ($header[4] =~ m/^OR/)
       		{
				 $ORNum = $header[4];
			}
			else
			{
				 $ORNum = $header[5];
			}
		
			chomp($ORNum);
	    	my $DirName = join "",$SelectSeqOutputDir, $ORNum;	
			my $pseudoDirName= join "", $SelectSeqOutputDir, $ORNum,"_", "Pseudogene";
			unless (-e $DirName)
			{
		  		mkdir($DirName);
			}
		
			my $selectSeqFileName = join "", $SelectSeqOutputDir,$ORNum, "/", $spec_name, "_", "orig", "_" ,$ORNum, ".fasta";
			if($pseudogene)
			 {
			 	$selectSeqFileName = join "", $selectSeqFileName,"_", "Pseudogene";
			 }
			#print "$selectSeqFileName\n"; 			
 			unless (-e $selectSeqFileName)
     		{
    			
      			my $runSelectSeq = " perl selectSeqs.pl -m \"$ORNum\$\" $SpecFileResults > $selectSeqFileName";
        		#print "$runSelectSeq\n";
        		system($runSelectSeq);
        		 
        		 my $fileNameOR;
        		 my $fileNameID;
        		
        		if($pseudogene)
        		{
        			 $fileNameOR = join "", $SelectSeqOutputDir,$ORNum, "/", $spec_name, "_", $ORNum,"_", "Pseudogene", ".fasta";
        			 $fileNameID = join "", $SelectSeqOutputDir, $ORNum, "/", $spec_name, "_", $ORNum, "_", "ID", "Pseudogene", ".fasta"; 
        		}
        		else
        		{
        			 $fileNameOR = join "", $SelectSeqOutputDir,$ORNum, "/", $spec_name, "_", $ORNum, ".fasta";
        			 $fileNameID = join "", $SelectSeqOutputDir,$ORNum, "/", $spec_name, "_", $ORNum, "_","ID", ".fasta";
        	   	 	#print $fileNameOR;
        			#print "\n";
        		}
        			open FILEOR, ">", "$fileNameOR" or die "Cannot open file $fileNameOR $!";
        			open FILEID, ">", $fileNameID or die "Cannot open file $fileNameID $!";   
        			open(INPUT,"$selectSeqFileName") or die("can't open $selectSeqFileName $!"); 
        			while(my $row = <INPUT>) 
					{
					    my $first_element = substr($row, 0 , 1);
						if ($first_element eq ">" )
						{
							my @origHeader = split /[\|]/, $row;
				    		if($pseudogene)
				    		{
				    			$RegHeader = join "", ">", $spec_name, "_", $ORNum, "Pseudogene\n";
				    			 $IDheader = join "", $origHeader[0], "_", $spec_name, "_", $ORNum, "Pseudogene\n"; 
				    			 #print "$RegHeader";
				    			 #print "$IDheader";
				   			 }
				    			else
				   				 {	
				    				 $RegHeader = join "", ">",$spec_name, "_", $ORNum, "\n";
									 $IDheader = join "", $origHeader[0],"_",$spec_name, "_", $ORNum, "\n";	
								 }
							print( FILEOR "$RegHeader");
							print (FILEID "$IDheader");
 						}
 						else
 						{
 						print(FILEOR "$row");
 						print(FILEID "$row");					
 						}       		
        		}
        		close(INPUT) or die ("cannot close $selectSeqFileName $!");
        		close(FILEOR) or die("cannot close $fileNameOR $!");
        		close(FILEID) or die ("cannot close $fileNameID $!");      		
	  		}
		}	  
	}	
	  
close(IN) or die ("cannot close $SpecFileResults $!");
 
 
 
