OR_Organize
===========

Olfactory Receptor Gene Sequence Organizer 

This program takes OR sequences in FASTA format and labels the genes using the olfactory receptor gene assigner pipeline. Once the genes have been labeled, the program creates two seperate files for each OR# in the file with the headers as shown below:
>OR#_Genus_species  and >OR#_Genus_species_ID#(ensembl ID etc.)

Each of these files is then placed in a folder corresponding to the OR#.
Pseudogenes are also accounted for and headers are the same with _Pseudogene added to the end. 
