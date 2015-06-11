<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
	xmlns:ccproc="http://www.corbas.co.uk/ns/xproc/steps" name="tester"
	xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0">
	
	<p:documentation>Test the addition of params to files loaded from a manifest. </p:documentation>
	
	<p:serialization port="result" indent="true"/>
	
	<p:input port="manifest">
		<p:document href="manifests/02-manifest-metadata.xml"></p:document>
	</p:input>

	<p:output port="result">
			<p:pipe port="result" step="wrapper"></p:pipe>
	</p:output>
	
	<p:import href="../src/load-sequence-from-file.xpl"/>

	<ccproc:load-sequence-from-file name="loader">
		<p:input port="source">
			<p:pipe port="manifest" step="tester"/>
		</p:input>
	</ccproc:load-sequence-from-file>
	
	<p:wrap-sequence wrapper="c:result" name="wrapper">
		<p:input port="source">
			<p:pipe port="result" step="loader"/>
		</p:input>
	</p:wrap-sequence>
	

</p:declare-step>