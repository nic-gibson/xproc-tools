<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
	xmlns:ccproc="http://www.corbas.co.uk/ns/xproc/steps"
	xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0" name="test-script">
	
	<p:documentation>Simple test driver for the directory-listing module. Runs with resolve on and off. 
	Filters on xml and xpl documents</p:documentation>
	
	<p:serialization port="result" indent="true"/>
	
	<p:output port="result">
		<p:pipe port="result" step="merge-load"/>
	</p:output>
	
	<p:import href="../src/directory-list.xpl"/>
	
	<ccproc:directory-list path="." include-filter="\.x[mp]l" name="base-listing"/>
	<ccproc:directory-list path="." include-filter="\.x[mp]l" resolve="true" name="resolved-listing"/>
	
	
	<p:wrap-sequence name="merge-load" wrapper="c:result">
		<p:input port="source">
			<p:pipe port="result" step="base-listing"/>
			<p:pipe port="result" step="resolved-listing"/>
		</p:input>
	</p:wrap-sequence>
	
</p:declare-step>