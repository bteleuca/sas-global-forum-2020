# Access Data
Access data from S3:
## From SAS Viya 3.5
Assumptions:
    * you have access to a S3 bucket
    * you have a user with rights for S3
    * you have a S3 *access key id* and *secret key*

Sample code loading the *loan_final313.csv* from the *gelsasYYY* bucket , into a caslib *AWSYYY*. 
In SAS Studio V write:
```SAS
* Initialize session variables;
options msglevel=i;
%let gateuserid=&sysuserid ;
%let clib=AWSS3;
* Change the bucket and region to match your AWS S3 settings;
* gelsas301 if your user is gatedemo301;
%let bucket=gelsasYYY; 
%let region=AsiaPacificSydney;

* Change the credentials to your AWS S3 user;
%let accesskey=ABCDEF.....;
%let secret=abcDEFghijKLM...;

%put Userid is:&gateuserid Region is:&region bucket is:&bucket;

* Parametrize libname; 
data sess_param;
	userid=%tslit(&gateuserid.);
	if substr(userid, 1, 3) = 'gat' then do;
		call symput('clib', upcase(catx('3', 'AWSS', substr(userid, 9, 3))));
		y=catx('_', 'AWS', substr(userid, 9, 3));
		z=catx('', 'gelsas', substr(userid, 9, 3)); end;
	else do ;   
		call symput('clib',upcase(catx('3', 'AWSS',substr(userid,4,3))));
		y=catx('_','AWSS3',substr(userid,4,3)); 
		z=catx('', 'gelsas', substr(userid, 4, 3));end; 
	put y $char8.;
	put z $char8.;
	put userid $char3.;
run;
%put CASLIB is: &clib; 

* start CAS session;
CAS mySession SESSOPTS=(CASLIB=casuser TIMEOUT=999 LOCALE="en_US" metrics=true);


* define the caslib on the S3 bucket AWS SAS Sandbox;
/* CREDENTIALS CHANGE every week!*/

caslib &clib. datasource=(srctype="s3"
               accesskeyid= "&accesskey"
               secretaccesskey= "&secret" 
               region="&region"
               bucket="&bucket"
               usessl=true) global;

* Assign all available caslib;
caslib _all_ assign;

/*list the contents of the libraries*/
proc casutil;
        list tables incaslib="&clib";
        list files incaslib="&clib";
        list tables incaslib="casuser";
        list files incaslib="casuser";
run;

/* cross-load a .csv file from S3 to CAS*/
* from AWSS3 to CASUSER;
proc casutil incaslib=&clib. outcaslib=casuser;
    droptable casdata="&gateuserid._loan" incaslib="casuser" quiet;
    load casdata="loan_final313.csv" casout="&gateuserid._loan" copies=0 promote; 
run; quit;

/*list detailed information about the library and the table*/
proc cas;
	/* list the information about each table */
	session mySession;
	table.tableinfo / caslib="casuser";
	run;
	table.tabledetails /caslib="casuser" name="&gateuserid._loan";
	/* get detailed resource usage for a table */
	run;
quit;

cas mySession terminate;
```

## From SAS 9.4
You cand access data from a Data Integration Studio job, Download file node, or write your own proc s3 in SAS Studio.