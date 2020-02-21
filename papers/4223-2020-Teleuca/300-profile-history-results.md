# Reporting on dataDiscovery.profile results table
Credit: Nicolas Robert and Wilbram Hazejager, SAS Institute Inc.
## Background
The Profile Results Table created by the ***dataDiscovery.profile*** CAS action has (a lot of) similarities with a key-value pair table. 
This following program provides a program to extract the results into multiple tables, including:
- table metrics
- column metrics
- frequencies
- pattern frequencies
- identification analysis
This makes it easy to use for standard reporting tools like SAS Visual Analytics.

# List of files with SAS code
- *02_SAS_client_extract_profile_results_with_history.sas* (contributor: Nicolas Robert)
  - Adds support for keeping history, creates indexes for optimized reporting performance, etc. 
  - Note that this code uses macro variables and other constructs that requires SPRE.
# How it Works
1. Run a profiling on a table
1. Open the 02_SAS_client_extract_profile_results_with_history.sas
1. The first time you run set in the program 'append_master=no'. It will create the initial tables.
1. The next time, ou run set in the program 'append_master=yes'. Profiling history will be appended to the tables described above.

# Copyright
Copyright (c) 2018 by SAS Institute Inc., Cary, NC 27513 USA 
