<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
	xmlns:ccproc="http://www.corbas.co.uk/ns/xproc/steps" name="tester"
	xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0">
	
	<p:documentation>Test that parameters from the manifest are applied
		to the stylesheet.</p:documentation>
	
	<p:serialization port="result" indent="true"/>
	
	<p:input port="manifest">
		<p:document href="manifests/08-manifest-threaded-check.xml"/>
	</p:input>
	
	<p:input port="source">
		<p:document href="data/test-03.xml"/>
	</p:input>
	
	<p:input port="parameters" kind="parameter" primary="true"/>

	

	<p:output port="result">
			<p:pipe port="result" step="threader"></p:pipe>
	</p:output>
	
	<p:import href="../src/load-sequence-from-file.xpl"/>
	<p:import href="../src/threaded-xslt.xpl"/>
	
	<ccproc:load-sequence-from-file name="loader">
		<p:input port="source">
			<p:pipe port="manifest" step="tester"/>
		</p:input>
	</ccproc:load-sequence-from-file>
	
	<ccproc:threaded-xslt name="threader">
		<p:input port="stylesheets">
			<p:pipe port="result" step="loader"/>
		</p:input>
		<p:input port="source">
			<p:pipe port="source" step="tester"/>
		</p:input>
		<p:input port="parameters">
			<p:inline><c:param name="bar-param" value="as-param"/></p:inline>
			<p:pipe port="parameters" step="tester"/>
		</p:input>
		
	</ccproc:threaded-xslt>
	


</p:declare-step>