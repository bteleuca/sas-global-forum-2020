# Prepare Data
Options:
## Use a Data Studio plan.
## Write your own code in SAS® Studio V.
Example: Calculate an aggregated (summary) table containing:
* year
* loan_portfolio = sum of Loan_amount (by year)
* npl (Non-Performing Loans) = sum of Loan_amount where loan_condition = ‘Bad Loan’ (by year)
* 0 otherwise
* npl_ratio (Non-Performing Loans Ratio) = Non-Performing Loans  / Loan Portfolio in %, (by year)

In SAS Studio V:
* Create a libname engine on top of CASUSER:
```SAS
options msglevel=i;
cas mySession sessopts=(messagelevel=all);
libname libcas cas caslib="casuser";
caslib _ALL_ assign;
```
* Use the table created with Data Studio and:

    * Summarize by year the npl and loan_amount variables
    * Calculate npl_ratio = npl/loan_amount
    * Fetch summaries for display and apply formats
    * Save the results to a table
    * Promote the table

* Summarize with summary cas action;
```SAS
proc cas;
   simple.summary result=r status=s /    /* 1 */
	inputs={"npl_ratio" "loan_amount" "npl"},
      subSet={"SUM","MAX", "MIN", "MEAN", "N"},
      table={
         name="&sysuserid._loan_enriched",
         caslib="casuser",
         computedVarsProgram="npl_ratio=npl/loan_amount",
         computedVars={"npl_ratio"},
         computedOnDemand=True,
         groupBy={"year"}},
      casout={name="&sysuserid._loan_agg", caslib="casuser" replace=True};
	run;
   if (s.severity == 0) then do;         /* 2 */
      table.fetch /
         format=True,
         fetchVars={
            "year", "_Column_", "_NObs_", "_Sum_ ",
            {name="_Sum_", format="EURO15.2"} {name="_Mean_", format="PERCENT8.4"}},
         table={caslib="casuser", name="&sysuserid._loan_agg"};
   end;
     table.promote /                             /* 3 */
         caslib="casuser" name="&sysuserid._loan_agg" targetcaslib="casuser";
   run;
quit;
```

* Check the log:
```log
NOTE: Active Session now MYSESSION.
NOTE: Executing action 'simple.summary'.
NOTE: Action 'simple.summary' used (Total process time):
NOTE:       real time               0.047012 seconds
NOTE:       cpu time                0.093612 seconds (199.12%)
NOTE:       total nodes             4 (16 cores)
NOTE:       total memory            125.05G
NOTE:       memory                  14.61M (0.01%)
NOTE:       bytes moved             1.09K
```

* Or, summarize with *proc mdsummary*:
```SAS
* summarize with proc mdsummary;
proc mdsummary data=libcas.&sysuserid._loan_enriched;
 var npl loan_amount;
 groupby year / out=libcas.&sysuserid._loan_agg2; /* 5 */
run;
```

You need to perform the npl_ratio calculation in a second step. Hint: _Sum_ for Column npl / _Sum_ for Column loan_amount:
 
* Terminate session
```SAS
cas mySession terminate;
```