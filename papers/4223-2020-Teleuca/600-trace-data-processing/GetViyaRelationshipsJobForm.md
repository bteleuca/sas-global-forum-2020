# Job Definition 
* Accompanies the **GetViyaRelationshipsJobDefinition**
```HTML
<!DOCTYPE html>
<html lang="en">
<head>
<title>Get Viya Relationships</title>
<style type="text/css">
@font-face {
font-family:AvenirNext;
src:url('/SASJobExecution/images/AvenirNextforSAS.woff') format('woff');
}
body, input, select {
font-family: AvenirNext,Helvetica,Arial,sans-serif;
text-rendering: optimizeLegibility;
-webkit-tap-highlight-color: rgba(0,0,0,0);
}
div {
color: #0072b2;
font-size: 16pt;
font-weight: bold;
height: 42px;
line-height: 42px;
vertical-align: middle;
white-space: nowrap;
}
span {
color: #4f4f4f;
display: inline-block;
font-size: 12pt;
font-weight: bold;
padding-top: 24px;
word-wrap: break-word;
}
.pointer {
cursor: pointer;
}
</style>
</head>
<body role="main">
<div>SAS<sup>&#174;</sup> Job Execution</div>
<h1>Get Viya Relationships</h1>
<p>
This program gets the references and relationships from this
system, and then creates XML that can be loaded into a SAS 9 system.
</p>
<p>
All fields on this page are required.
</p>
<hr/>
<br/>
<form action="/SASJobExecution/" method="post" target="_tab"
enctype="multipart/form-data">
<input type="hidden" name="_program" value="/gelcontent/Demo/DM/Jobs/Get Viya Relationships">
<input type="hidden" name="_action" value="wait,execute"/>
<input type="hidden" name="_output_type" value="ods_html5"/>
<input type="hidden" name="_csrf" value="$CSRF$">
<label for="REFERENCE_LIMIT">Specify the maximum number of references to return:</label>
<input type="text" name="REFERENCE_LIMIT" id="REFERENCE_LIMIT" value="10000" required class="pointer"/>
<br/>
<br/>
<label for="RELATIONSHIP_LIMIT">Specify the maximum number of relationships to return:</label>
<input type="text" name="RELATIONSHIP_LIMIT" id="RELATIONSHIP_LIMIT" value="10000" required class="pointer"/>
<br/>
<br/>
<label for="cont_map">Choose a file with the content mapping information:</label>
<input type="file" name="cont_map" id="cont_map" required class="pointer"/>
<br/>
<br/>
<hr/>
<input type="submit" value="Run code" class="pointer"/>
<input type="checkbox" name="_debug" id="_debug" value="log,trace" class="pointer"/>
<label for="_debug">Show SAS Log</label>
</form>
</body>
</html>
```
