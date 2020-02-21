# Reporting on dataDiscovery.profile results table
## Background
The Profile Results Table created by the ***dataDiscovery.profile*** CAS action has (a lot of) similarities with a key-value pair table. 
This makes it difficult to use for standard reporting tools like SAS Visual Analytics.

This project is going to provide a DATA step to extract the results into multiple tables, including:
- table metrics
- column metrics
- frequencies
- pattern frequencies
- identification analysis

You could think of these tables corresponding to the various panels shown in the Profile Tab in SAS Data Explorer.

Long term, the idea is to enhance the CAS action to provide an option so the action creates those tables directly, a
nd provide an option in the various UIs in SAS Data Preparation for the user to specify that they want to create/export the metrics into into those tables.

For the time being the plan is to make the DATA step available to customers using github.sas.com in the "examples for learning" category.

## List of files with SAS code
- *02_SAS_client_extract_profile_results_with_history.sas* (contributor: Nicolas Robert)
  - Adds support for keeping history, creates indexes for optimized reporting performance, etc. 
  - Note that this code uses macro variables and other constructs that requires SPRE.



# Copyright
Copyright (c) 2018 by SAS Institute Inc., Cary, NC 27513 USA 
