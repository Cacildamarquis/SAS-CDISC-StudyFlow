
/* Dataset-level metadata */
data define_dataset;
    length dataset_name $8 label $256 domain $8 origin $20;
    infile datalines dsd;
    input dataset_name $ label $ domain $ origin $;
    datalines;
DM,Demographics,DM,Collected
AE,Adverse Events,AE,Collected
ADSL,Subject-Level Analysis Dataset,ADSL,Derived
ADAE,Adverse Events Analysis Dataset,ADAE,Derived
;
run;

/* Variable-level metadata */
data define_variable;
    length dataset_name $8 variable_name $32 label $256 type $8 origin $20;
    infile datalines dsd;
    input dataset_name $ variable_name $ label $ type $ origin $;
    datalines;
DM,USUBJID,Unique Subject Identifier,Char,Collected
DM,SEX,Sex,Char,Collected
DM,AGE,Age,Num,Collected
AE,AETERM,Reported Term for the Adverse Event,Char,Collected
AE,AESTDTC,Start Date/Time of Adverse Event,Char,Collected
ADSL,USUBJID,Unique Subject Identifier,Char,Derived
ADAE,AETERM,Reported Term for the Adverse Event,Char,Derived
ADAE,SAFFL,Safety Flag,Char,Derived
;
run;


proc export data=define_dataset
  outfile="/home/u64100426/Clinicaltrial/define_dataset.xlsx"
  dbms=xlsx replace;
run;
proc export data=define_variable
  outfile="/home/u64100426/Clinicaltrial/define_variable.xlsx"
  dbms=xlsx replace;
run;