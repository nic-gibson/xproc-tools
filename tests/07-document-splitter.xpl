<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
	xmlns:ccproc="http://www.corbas.co.uk/ns/xproc/steps" 
	xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0" name="test">
	
	<p:input port="source">
		<p:document href="data/test-04.xml"></p:document>
	</p:input>
	
	<p:output port="result">
		<p:pipe port="result" step="count-results"/>
	</p:output>
	
	
	<p:import href="../src/split-document.xpl"/>
	
	<ccproc:split-document name="split-test">
			<p:input port="source">
				<p:pipe port="source" step="test"/>
			</p:input>
			<p:with-option name="match" select="'//para'"></p:with-option>
	</ccproc:split-document>
	
	<p:count name="count-results">
		<p:input port="source">
			<p:pipe port="result" step="split-test"/>
		</p:input>
	</p:count>
	
	
	
</p:declare-step>