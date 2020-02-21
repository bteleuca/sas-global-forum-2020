/*Post an item to SAS 9 relationship service*/
**********************************************;

/* Change your file location*/
%let folder=C:\temp\lineage\;

filename hdrout "&folder.headerOut.txt"; 
/*audit file to check the HTTP request results*/

filename rel "&folder.relationships_to_load.xml";
/*it is assumed you have this file, sample provided*/

proc http 
	url="http://your-SAS-server/SASWIPClientAccess/rest/relsvc/relationships" 
	method="POST"
    webusername="youruser" /*user with Metadata Admin rights */
    webpassword="************"
    in=rel /*the file that will be posted*/
    ct="application/xml;charset=UTF-8" /*Important explains if the content of the in file posted is a xml or json file*/
    headerout=hdrout headerout_overwrite;
/*we use the audit file option*/
run ;

*	Macro to check the status of the HTTP request;
%put PROC HTTP Return code: &SYS_PROCHTTP_STATUS_CODE.;

quit;