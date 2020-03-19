# Export SAS Viya metadata.

How to move relationshipss from Viya Lineage into SAS 9 Lineage.
Credits: Liz McIntosh, Vincent DelGobbo. SAS Institute Inc.

## Create a SAS Viya Job

* Access the SAS Job Execution Web Application on your system:
**http://*your-server*/SASJobExecution/*

* Navigate to the folder location where you want to store your job and then select *New file* from the toolbar:

* Specify a name for the file, for example **Get Viya Relationships**, and then select OK. A job definition file is created by default.

* Double-click the Get Viya Relationships job definition file and then copy the SAS code from **GetViyaRelationshipsJobDefinition** file.

* Select *Save* and then select *Close* to save the job definition file.

* [SAS Job Execution Web Application documentation](
https://go.documentation.sas.com/?cdcId=pgmsascdc&cdcVersion=9.4_3.5&docsetId=jobexecug&docsetTarget=n055josnxfatfwn1pyr7p1ah7225.htm&locale=en)



## Create a SAS Viya Job Definition

* Right-click on the job definition file and then select *Properties* from the popup menu. 

* Expand the Parameters group and then select *Add a new parameter*. 
* Create  new parameters with these properties and then select *Save*:
```
Name Type Default Value Required
_action Character form,execute No
reference_limit Numeric 10000 Yes
relationship_limit Numeric 10000 Yes
```
* The _ACTION parameter specifies that an HTML input form should be displayed as the user interface if available. 

* The REFERENCE_LIMIT and RELATIONSHIP_LIMIT parameters limit the number of references and relationships extracted.

* Copy paste the content of **GetViyaRelationshipsJobForm**.

* Find in the file string, around line 50
```HTML
<input type="hidden" name="_program"     value="/gelcontent/DM/Demo/Jobs/Get Viya Relationships">
```

* Replace */gelcontent/DM/Demo/Jobs/Get Viya Relationships* with the correct path pointing to your Job Definition.

## Execute the SAS Viya Job to Export and Process the Relationships

* Access the application using this URL, replace **your-folder-path-to-the-job**:
**http://*your-server*/SASJobExecution/?_program=/your-folder-path-to-the-job/Get Viya Relationships*

* Specify the required inputs and then select *Run Code* to execute the job.

* Check Show Log.

## Results

* The job will generate a file with the Viya metadata objects converted to SAS 9 metadata objects. The file is called relationships_to_load.xml. 

* In the job execution window you will see **Click a Link to Download an Item**. You need the **‘Relationships in XML format’** file.

# Copyright
Copyright (c) 2019 by SAS Institute Inc., Cary, NC 27513 USA 