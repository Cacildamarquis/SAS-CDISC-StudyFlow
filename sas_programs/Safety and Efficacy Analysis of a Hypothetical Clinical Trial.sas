/* Creating SDTM AE */
proc import datafile="/home/u64100426/Clinicaltrial/ae.csv" out=ae_raw dbms=csv 
		replace;
	getnames=yes;
	guessingrows=max;
run;
data sdtm_ae(label='Subject adverse events');
	set ae_raw(rename=(studyid=STUDYID usubjid=USUBJID domain=DOMAIN aeseq=AESEQ 
		aeser=AESER aeterm=AETERM aesev=AESEV aestdtc=AESTDTC aeendtc=AEENDTC));
	DOMAIN='AE';

	if upcase(AESEV) not in('MILD', 'MODERATE', 'SEVERE') then
		AESEV=" ";
	label STUDYID="Study Identifier" DOMAIN="Domain Abbreviation" 
		USUBJID="Unique Subject Identifier" AESEQ="Sequence Number" 
		AETERM="Reported Term for the Adverse Event" AESER="Serious Event" 
		AESEV="Severity/Intensity" AESTDTC="Start Date/Time of Adverse Event" 
		AEENDTC="End Date/Time of Adverse Event";
	keep STUDYID DOMAIN USUBJID AESEQ AETERM AESER AESEV AESTDTC AEENDTC;
run;

proc sort data=sdtm_ae;
	by STUDYID DOMAIN USUBJID AESEQ;
run;

proc contents data=sdtm_ae;
run;

/* Creating SDTM DM */
proc import datafile="/home/u64100426/Clinicaltrial/dm.csv" out=dm_raw dbms=csv 
		replace;
	getnames=yes;
	guessingrows=max;
run;

data sdtm_dm;
	set dm_raw(rename=(studyid=STUDYID domain=DOMAIN subjid=SUBJID usubjid=USUBJID 
		rfstdtc=RFSTDTC rfendtc=RFENDTC rfxstdtc=RFXSTDTC rfxendtc=RFXENDTC 
		rfpendtc=RFPENDTC dthdtc=DTHDTC dmdtc=DMDTC dmdy=DMDY dthfl=DTHFL 
		siteid=SITEID age=AGE ageu=AGEU sex=SEX race=RACE ethnic=ETHNIC arm=ARM 
		armcd=ARMCD actarm=ACTARM actarmcd=ACTARMCD country=COUNTRY));
	DOMAIN="DM";
	label STUDYID="Study Identifier" DOMAIN="Domain Abbreviation" 
		SUBJID="Subject Identifier for the Study" USUBJID="Unique Subject Identifier" 
		RFSTDTC="Date/Time of First Study Treatment" 
		RFENDTC="Date/Time of End of Participation" 
		RFXSTDTC="Date/Time of First Exposure to Treatment" 
		RFXENDTC="Date/Time of Last Exposure to Treatment" 
		RFPENDTC="Date/Time of End of Participation" 
		DMDTC="Date/Time of Collection of Subject Characteristics" 
		DMDY="Study Day of Collection of Subject Characteristics" 
		DTHDTC="Date/Time of Death" DTHFL="Subject Death Flag" 
		SITEID="Study Site Identifier" AGE="Age" AGEU="Age Units" SEX="Sex" 
		RACE="Race" ETHNIC="Ethnicity" ARM="Description of Planned Arm" 
		ARMCD="Planned Arm Code" ACTARM="Description of Actual Arm" 
		ACTARMCD="Actual Arm Code" COUNTRY="Country";
	format RFSTDTC date9.;
	keep STUDYID DOMAIN USUBJID SUBJID RFSTDTC RFENDTC RFXSTDTC RFXENDTC RFPENDTC 
		DTHDTC DTHFL SITEID AGE AGEU SEX RACE ETHNIC ARMCD ARM ACTARMCD ACTARM 
		COUNTRY DMDTC DMDY;
run;

proc sort data=sdtm_dm;
	by STUDYID DOMAIN USUBJID;
run;

proc contents data=sdtm_dm;
run;

/* Moving variables to suppae */
data suppae;
	set sdtm_ae;
	RDOMAIN='AE';
	IDVAR='AESEQ';
	IDVARVAL=strip(put(aeseq, best.));
	QNAM='AEBDSYCD';
	QLABEL='Sponsor Body System Code';
	QVAL=strip(aebdsycd);
	QORIG='CRF';
	keep STUDYID RDOMAIN USUBJID IDVAR IDVARVAL QNAM QLABEL QVAL QORIG;
run;



/* Creating ADAM AE */
proc sort data=sdtm_ae;
	by USUBJID;
run;

proc sort data=sdtm_dm;
	by USUBJID;
run;

data adam_adae;
	length SAFFL TRTEMFL $1 TRTA $22 AETERM $200 AESEV $10 AESER $3;
	merge sdtm_ae(in=a) sdtm_dm(in=b keep=USUBJID RFSTDTC ACTARM);
	by USUBJID;

	if a and b;

	if not missing(AESTDTC) then
		AESTDT=input(strip(AESTDTC), anydtdte.);

	if not missing(AEENDTC) then
		AEENDT=input(strip(AEENDTC), anydtdte.);

	if not missing(RFSTDTC) then
		TRTSDT=input(strip(RFSTDTC), anydtdte.);
	format AESTDT AEENDT TRTSDT date9.;
	TRTA=strip(ACTARM);

	if not missing(AESTDT) and not missing(TRTSDT) then
		do;

			if AESTDT >=TRTSDT then
				SAFFL='Y';
			else
				SAFFL='N';
		end;
	else
		SAFFL='';

	if not missing(AESTDT) and not missing(TRTSDT) then
		do;

			if AESTDT >=TRTSDT then
				TRTEMFL='Y';
			else
				TRTEMFL='N';
		end;
	else
		TRTEMFL='';
	ADY=AESTDT - TRTSDT + 1;
	AESTDY=.;
	AEENDY=.;

	IF not missing(AESTDT) and not missing(TRTSDT) then
		AESTDY=AESTDT-TRTSDT;

	IF not missing(AEENDT) and not missing(TRTSDT) then
		AEENDY=AEENDT-TRTSDT;
	label usubjid='Unique Subject Identifier' 
		TRTSDT='Date of First Exposure to Treatment' 
		AESTDT='Start Date of Adverse Event' AEENDT='End Date of Adverse Event' 
		ADY='Analysis Relative Day of AE Start' AESTDY='Relative Day of AE Start' 
		AEENDY='Relative Day of AE End' SAFFL='Safety Population Flag' 
		TRTEMFL='Treatment Emergent Flag' TRTA='Actual Treatment' 
		AETERM='Reported Term for the Adverse Event' AESEV='Severity/Intensity' 
		AESER='Serious Event';
	retain STUDYID USUBJID AESEQ TRTSDT TRTA AESTDT AEENDT ADY AESTDY AEENDY SAFFL 
		TRTEMFL AETERM AESEV AESER;
	keep STUDYID USUBJID AESEQ TRTSDT TRTA AESTDT AEENDT ADY AESTDY AEENDY SAFFL 
		TRTEMFL AETERM AESEV AESER;
run;

proc sort data=adam_adae;
	by STUDYID USUBJID AESEQ;
run;

proc contents data=adam_adae;
run;

/* Creating TLFs */
proc freq data=adam_adae;
	tables AETERM*SAFFL/ missing nocol norow nopercent;
	title 'Table 1: AE Summary by Safety flag';
run;

proc means data=adam_adae n mean std;
	var ADY;
	class SAFFL;
	title 'Table 2: AE Onset Day Summary by Safety flag';
run;

proc print data=adam_adae noobs;
	var USUBJID AETERM AESEV AESTDT AEENDT ADY SAFFL TRTEMFL AESTDY AEENDY;
	title 'Listing: Adverse Events with relative Day';
run;

proc sgplot data=adam_adae;
	vbar AETERM / group=SAFFL datalabel groupdisplay=cluster;
	xaxis discreteorder=data;
	title 'Figure: AE Frequency by Safety flag';
run;

/* Creating ADAM ADSL dataset */

proc import datafile="/home/u64100426/Clinicaltrial/adsl.csv" out=adsl_raw 
		dbms=csv replace;
	getnames=yes;
	guessingrows=max;
run;

data adam_adsl;
	set adsl_raw(rename=(usubjid=USUBJID rfstdtc=RFSTDTC rfendtc=RFENDTC 
		dthfl=DTHFL saffl=SAFFL));
	format TRTSDT TRTEDT date9.;
run;

proc sort data=adam_adsl;
	by USUBJID;
run;
/* Survival test using Kaplan-Meier */
proc sql;
	create table surv_data as select a.*, b.DTHDTC from adam_adsl a left join 
		sdtm_dm b on a.USUBJID=b.USUBJID;
quit;

data survival;
	set surv_data;
	format TRTSDT TRTEDT date9.;
	SURVDAY=TRTEDT-TRTSDT;

	if SURVDAY <0 then
		SURVDAY=.;

	if upcase(DTHFL)='Y' then
		do;
			CNSR=0;
		end;
	else
		do;
			CNSR=1;
		end;
	TRTA=strip(ARM);
run;

proc lifetest data=survival plots=survival(atrisk);
	time SURVDAY*CNSR(1);
	strata TRTA;
	title 'Kaplan-Meier Survival Curve by treatment Arm';
run;