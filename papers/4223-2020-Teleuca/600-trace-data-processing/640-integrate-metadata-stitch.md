# Integrate or Stitch Metadata Example

* A file has been prepared with 3 objects to stitch: *relationships_to_update.xml*. You can find a sample here:
```XML
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<relationshipModels>
    <relationshipModel version="1">
        <resource version="1">
            <date>2019-11-07T12:37:43.121+12:00</date>
            <id>A5CTTMUV.BY000001/ExternalTable</id>
            <objectType>223</objectType>
            <label>loan_final313.csv</label>
        </resource>
        <relationships>
            <relationship>
                <relationshipType>E</relationshipType>
                <resource>
                    <id>c796a96b-87fa-4f4b-ad3a-73006c9f6c34</id>
                    <label> c796a96b-87fa-4f4b-ad3a-73006c9f6c34</label>
                    <objectType>-1</objectType>
                </resource>
            </relationship>
        </relationships>
        <relationships>
            <relationship>
                <relationshipType>E</relationshipType>
                <resource>
                    <id>244d9045-a691-4282-b426-25434cccd006</id>
                    <label>loan_final313.csv</label>
                    <objectType>4128</objectType>
                </resource>
            </relationship>
        </relationships>
  </relationshipModel>
</relationshipModels>
```

* The code to run in SAS 9 (SAS Studio). * Makes use of SAS 9 Relationship Repository API. The file above will be 'PUT' to the metadata server.
```SAS
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

```

