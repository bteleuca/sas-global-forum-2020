# Import SAS Viya metadata in SAS 9.4 Lineage.
1. Backup SAS 9 Metadata Server: Optional but recommended.
1. Use the Relationship REST API in SAS 9.4 (SAS Studio)
```SAS
/*Post an item to SAS 9 relationship service*/

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
```
*	Macro to check the status of the HTTP request;
```SAS
%put PROC HTTP Return code: &SYS_PROCHTTP_STATUS_CODE.; quit;
```

* POST the sample XML file *relationships_to_update.xml* (output of the GetViyaRelationships job). You can find a limited sample below:
```XML
<relationshipModels>
<relationshipModel version="1">
  <resource version="1">
    <date>2019-06-14T08:55:34.396Z</date>
    <externalId>loan_final313_sample.csv</externalId>
    <label>loan_final313_sample.csv</label>
    <objectType>4053
</objectType>
    <properties>
      <property name="CreatedByUser">
        <value>sas.dataPlans</value>
      </property>
      <property name="ModifiedByUser">
        <value>sas.dataPlans</value>
      </property>
      <property name="CreationTimeStamp">
        <value>2019-06-14T08:55:34.396Z</value>
      </property>
      <property name="ModifiedTimeStamp">
        <value>2019-06-14T08:55:34.396Z</value>
      </property>
      <property name="ExternalId">
        <value>loan_final313_sample.csv</value>
      </property>
      <property name="Source">
        <value>intviya01</value>
      </property>
    </properties>
  </resource>
</relationshipModel>
<relationshipModel version="1">
  <resource version="1">
    <date>2019-06-17T04:00:50.799Z</date>
    <externalId>/dataSources/providers/cas/sources/cas-shared-default~fs~AWSS3</externalId>
    <label>AWSS3</label>
    <objectType>4022
</objectType>
    <properties>
      <property name="CreatedByUser">
        <value>sas.dataPlans</value>
      </property>
      <property name="ModifiedByUser">
        <value>sas.dataPlans</value>
      </property>
      <property name="CreationTimeStamp">
        <value>2019-06-17T04:00:50.799Z</value>
      </property>
      <property name="ModifiedTimeStamp">
        <value>2019-06-17T04:00:50.799Z</value>
      </property>
      <property name="ExternalId">
        <value>/dataSources/providers/cas/sources/cas-shared-default~fs~AWSS3</value>
      </property>
      <property name="Source">
        <value>intviya01</value>
      </property>
    </properties>
  </resource>
  <relationships>
    <relationship>
      <relationshipType>D</relationshipType>
        <resource version="1">
          <objectType>4022
</objectType>
          <externalId>/dataSources/providers/cas/sources/cas-shared-default</externalId>
        </resource>
        <properties>
          <property name="CreatedByUser">
            <value>sas.dataPlans</value>
          </property>
          <property name="ModifiedByUser">
            <value>sas.dataPlans</value>
          </property>
          <property name="CreationTimeStamp">
            <value>2019-06-17T04:00:51.081Z</value>
          </property>
          <property name="ModifiedTimeStamp">
            <value>2019-06-17T04:00:51.081Z</value>
          </property>
          <property name="Source">
            <value> </value>
          </property>
        </properties>
    </relationship>
  </relationships>
  </relationshipModel>
</relationshipModels>
```

* Import the metadata into SAS 9.4.

* Check the imported objects in SAS 9.4 Lineage.
