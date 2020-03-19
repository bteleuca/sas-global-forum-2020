Exports SAS Viya Lineage metadata into a format that can be imported in SAS 9 Lineage
* Double-click the Get Viya Relationships job definition file and then copy the SAS code below:
```SAS
*   Importing SAS Viya Relationship Information to a SAS 9 System;
*   Vince DelGobbo, November 2018;
options ls=max nodate;
* Input parameters;
%global REFERENCE_LIMIT RELATIONSHIP_LIMIT;
* Global macro variables;
%global BASE_URI REF_SOURCE;
* Set the base URI for service calls;
%let BASE_URI=%sysfunc(getoption(servicesbaseurl));
* Value for the Source property of references;
%let REF_SOURCE=&SYSTCPIPHOSTNAME;
* FILEREFs for the references and the response headers;
filename refs sasfsvam parenturi="&SYS_JES_JOB_URI"
name='references.json'
contenttype='application/json'
contentdisp='attachment; filename="references.json"';
filename resp_hdr temp;
* Get the references;
proc http url="&BASE_URI/relationships/references?start=0%nrstr(&limit)=&REFERENCE_LIMIT"
method='get'
oauth_bearer=sas_services
out=refs
headerout=resp_hdr
headerout_overwrite
verbose;
run; quit;
*** TODO: Add error checking;
data _null_;
infile resp_hdr;
input;
if (_N_ eq 1) then putlog 'NOTE: >>>>>> References response headers';
putlog _infile_;
run;
* FILEREF for the relationships;
filename rels sasfsvam parenturi="&SYS_JES_JOB_URI"
name='relationships.json'
contenttype='application/json'
contentdisp='attachment; filename="relationships.json"';;
proc http url="&BASE_URI/relationships/relationships?start=0%nrstr(&limit)=&RELATIONSHIP_LIMIT"
method='get'
oauth_bearer=sas_services
out=rels
headerout=resp_hdr
headerout_overwrite
verbose;
run; quit;
*** TODO: Add error checking;
data _null_;
infile resp_hdr;
input;
if (_N_ eq 1) then putlog 'NOTE: >>>>>> Relationships response headers';
putlog _infile_;
run;
* Create a format for content type mapping for references - from my SGF 2018 paper :-) ;
filename contmap sasfsvam "&_WEBIN_FILEURI";
data work.ref_contentmapping;
length fmtname $8 type $1 start end $100 hlo $1 label $256;
infile contmap dlm=',' end=eof;
input start label;
fmtname = 'REF_CMAP';
type = 'C';
end = start;
output;
if (eof) then do;
call missing (of start--end);
hlo = 'O';
label = '-1';
output;
end;
run;

proc format cntlin=work.ref_contentmapping; run; quit;
* Create a format for relationship type for relationships;
data work.relationshipmapping;
length fmtname $8 type $1 start end $15 hlo $1 label $2;
infile cards dlm=',';
fmtname = 'RMAP';
type = 'C';
if (_n_ eq 1) then do;
call missing (of start--label);
hlo = 'O';
label = '-1';
output;
call missing (of start--label);
end;
input start label;
end = start;
output;
cards;
Dependent,D
Contains,I
Parent,P
Associated,A
Equivalent,E
Synonymous,S
run;
proc format cntlin=work.relationshipmapping; run; quit;
* Rename variables to make them easier to work with when creating the XML;
libname refs json fileref=refs;
libname rels json fileref=rels;
proc datasets lib=work nolist;
* References;
delete items;
run;
copy in=refs out=work;
select items / mt=data;
run;
delete refs;
run;
change items=refs;
run;
modify refs;
rename analysisTimeStamp = ref_analysisTimeStamp
contentType = ref_contentType
createdBy = ref_createdBy
creationTimeStamp = ref_creationTimeStamp
id = ref_id
modifiedBy = ref_modifiedBy
modifiedTimeStamp = ref_modifiedTimeStamp
name = ref_name
source = ref_source
version = ref_version;
run;
* Relationships;
delete items;
run;
copy in=rels out=work;
select items / mt=data;
run;
delete rels;
run;
change items=rels;
run;
modify rels;
rename createdBy = rel_createdBy
creationTimeStamp = rel_creationTimeStamp
id = rel_id
modifiedBy = rel_modifiedBy
modifiedTimeStamp = rel_modifiedTimeStamp
referenceId = rel_referenceId
relatedReferenceId = rel_relatedReferenceId
relatedResourceUri = rel_relatedResourceUri
source = rel_source
type = rel_type
version = rel_version;
run; quit;

*;
* Some references do not have a value for contentType. Remove them
* from the references data and flag them for review.
*;
data work.refs_final(drop=ordinal_:)
work.refs_missing_contenttype;
set work.refs;
if (ref_contentType eq '')
then do;
putlog 'WARNING: Omitting reference due to missing content type. ' ref_modifiedBy= ref_id=;
output work.refs_missing_contenttype;
end;
else do;
* Perform content type mapping;
ref_contentType_remapped = strip(put(ref_contentType, $ref_cmap.));
output work.refs_final;
end;
run;
* Create a format for content type mapping for related references;
data work.rel_contentmapping;
length fmtname $8 type $1 start end $36 hlo $1 label $256;
keep fmtname -- label;
set work.refs_final end=eof;
fmtname = 'REL_CMAP';
type = 'C';
start = ref_id;
end = start;
label = put(ref_contentType, $ref_cmap.);
output;
if (eof) then do;
call missing (of start--end);
hlo = 'O';
label = '-1';
output;
end;
run;
proc format cntlin=work.rel_contentmapping; run; quit;
*;
* Do not include relationships for references that were removed
* because they did not have values for content type.
*;
* Determine the records that need to be omitted;
proc sql;
create table work.rels_omitted(drop=ordinal:)
as select rels.*
from work.rels as rels, work.refs_missing_contenttype as refs
having (rels.rel_relatedReferenceId eq refs.ref_id);
quit;

* Sort the data in preparation for match merging;
proc sort data=work.rels_omitted; by rel_id; run; quit;
proc sort data=work.rels; by rel_id; run; quit;
* Determine the records to keep;
data work.rels_final(keep=resourceURI rel:);
merge work.rels
work.rels_omitted(in=inomitted);
by rel_id;
if (not inomitted);
* Perform content/object type mapping;
rel_type_remapped = strip(put(rel_type, $rmap.));
related_contentType_remapped = strip(put(rel_relatedReferenceId, $rel_cmap.));
run;
* Sort the data in preparation for match merging;
proc sort data=work.refs_final out=work.refs_final_sorted; by resourceUri; run; quit;
proc sort data=work.rels_final out=work.rels_final_sorted; by resourceUri; run; quit;
* Get all of the relationships of a reference;
data work.alldata;
merge work.refs_final_sorted(in=inrefs)
work.rels_final_sorted(in=inrels);
by resourceUri;
length in_refs in_rels 8;
in_refs = 0;
in_rels = 0;
if (inrefs) then in_refs = 1;
if (inrels) then in_rels = 1;
if (inrefs) then output;
run;
* Create the XML;
filename relxml sasfsvam parenturi="&SYS_JES_JOB_URI"
name='relationships_to_load.xml'
contenttype='text/xml'
contentdisp='attachment; filename="relationships_to_load.xml"';
data _null_;
set work.alldata end=eof;
file relxml;
indent = ' ';

if (_n_ eq 1) then do;
put '<relationshipModels>';
end;
* Reference XML;
put '<relationshipModel version="1">';
put indent '<resource version="1">';
put indent indent '<date>' ref_analysisTimeStamp +(-1) '</date>';
put indent indent '<externalId>' resourceUri +(-1) '</externalId>';
put indent indent '<label>' ref_name +(-1) '</label>';
put indent indent '<objectType>' ref_contentType_remapped +(-1) '</objectType>';
put indent indent '<properties>';
put indent indent indent '<property name="CreatedByUser">';
put indent indent indent indent '<value>' ref_createdBy +(-1) '</value>';
put indent indent indent '</property>';
put indent indent indent '<property name="ModifiedByUser">';
put indent indent indent indent '<value>' ref_modifiedBy +(-1) '</value>';
put indent indent indent '</property>';
put indent indent indent '<property name="CreationTimeStamp">';
put indent indent indent indent '<value>' ref_creationTimeStamp +(-1) '</value>';
put indent indent indent '</property>';
put indent indent indent '<property name="ModifiedTimeStamp">';
put indent indent indent indent '<value>' ref_modifiedTimeStamp +(-1) '</value>';
put indent indent indent '</property>';
put indent indent indent '<property name="ExternalId">';
put indent indent indent indent '<value>' resourceUri +(-1) '</value>';
put indent indent indent '</property>';
put indent indent indent '<property name="Source">';
***put indent indent indent indent '<value>' ref_source +(-1) '</value>';
put indent indent indent indent "<value>&REF_SOURCE</value>";
put indent indent indent '</property>';
put indent indent '</properties>';
put indent '</resource>';
* Relationship XML, if any;
if (rel_id ne '') then do;
put indent '<relationships>';
put indent indent '<relationship>';
put indent indent indent '<relationshipType>' rel_type_remapped +(-1) '</relationshipType>';
put indent indent indent indent '<resource version="1">';
put indent indent indent indent indent '<objectType>' related_contentType_remapped +(-1) '</objectType>';
put indent indent indent indent indent '<externalId>' rel_relatedResourceUri +(-1) '</externalId>';
put indent indent indent indent '</resource>';
put indent indent indent indent '<properties>';
put indent indent indent indent indent '<property name="CreatedByUser">';
put indent indent indent indent indent indent '<value>' rel_createdBy +(-1) '</value>';
put indent indent indent indent indent '</property>';
put indent indent indent indent indent '<property name="ModifiedByUser">';
put indent indent indent indent indent indent '<value>' rel_modifiedBy +(-1) '</value>';
put indent indent indent indent indent '</property>';
put indent indent indent indent indent '<property name="CreationTimeStamp">';
put indent indent indent indent indent indent '<value>' rel_creationTimeStamp +(-1) '</value>';

put indent indent indent indent indent '</property>';
put indent indent indent indent indent '<property name="ModifiedTimeStamp">';
put indent indent indent indent indent indent '<value>' rel_modifiedTimeStamp +(-1) '</value>';
put indent indent indent indent indent '</property>';
put indent indent indent indent indent '<property name="Source">';
put indent indent indent indent indent indent '<value>' rel_source +(-1) '</value>';
put indent indent indent indent indent '</property>';
put indent indent indent indent '</properties>';
put indent indent '</relationship>';
put indent '</relationships>';
end;
put '</relationshipModel>';
EOF:
if (eof) then do;
put '</relationshipModels>';
end;
run;
* Create links for items to download;
data work.downloads;
length link varchar(1024);
link = "<a href=""&_FILESRVC_RELXML_URI/content"">Relationships in XML format</a>";
output;
link = "<a href=""&_FILESRVC_REFS_URI/content"">Raw References in JSON format</a>";
output;
link = "<a href=""&_FILESRVC_RELS_URI/content"">Raw Relationships in JSON format</a>";
output;
run;
title 'Click a Link to Download an Item';
proc print data=work.downloads noobs label style(header)=[just=center];
label link = 'Item';
run; quit;
* Create a report of references without a content type;
title 'References Without a Value of Content Type';
proc print data=work.refs_missing_contenttype n style(header)=[just=center];
id resourceUri;
var ref_id ref_createdBy ref_creationTimeStamp ref_modifiedBy
ref_modifiedTimeStamp ref_analysisTimeStamp ref_version;
run; quit;
```
* End of SAS Job Definition code file;