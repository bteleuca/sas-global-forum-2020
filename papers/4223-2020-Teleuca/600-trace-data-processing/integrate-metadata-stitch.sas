/*Put an item to SAS 9 relationship service*/
**********************************************
filename in temp encoding="utf-8" ; /*in file parameter*/

/* Change your file location*/
%let folder=C:\temp\lineage\;

filename hdrout "&folder.headerOut.txt"; 
/*audit file to check the HTTP request results*/

filename rel "&folder.relationships_to_update.xml";

proc http 
	headerout=hdrout /*we use the audit file option*/
	url="http://your-SAS-server/SASWIPClientAccess/rest/relsvc/relationships" method="PUT"
    webusername="youruser" /*user with Metadata Admin rights */
    webpassword="************"
    in=rel /*the file that will be posted*/
    ct="application/xml;charset=UTF-8";     
run;
*	Macro to check the status of the HTTP request;
%put PROC HTTP Return code: &SYS_PROCHTTP_STATUS_CODE.;
quit;
