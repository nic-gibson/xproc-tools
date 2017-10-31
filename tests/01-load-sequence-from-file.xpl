<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
	xmlns:ccproc="http://www.corbas.co.uk/ns/xproc/steps"
	xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0" name="test-script">
	
	<p:documentation>Simple test driver for the load-sequence-from-file module. Tests loading of two simple documents.</p:documentation>
	
	<p:serialization port="result" indent="true"/>
	
	<p:input port="manifest">
		<p:inline>
			<manifest xmlns="http://www.corbas.co.uk/ns/transforms/data">
				<item href="data/test-01.xml"/>
				<item href="data/test-02.xml"/>
			</manifest>			
		</p:inline>
	</p:input>
	
	<p:output port="result">
		<p:pipe port="result" step="merge-load"/>
	</p:output>
	
	<p:import href="../src/load-sequence-from-file.xpl"/>
	
	<ccproc:load-sequence-from-file name="load-manifest">
		<p:input port="source">
			<p:pipe port="manifest" step="test-script"/>
		</p:input>
	</ccproc:load-sequence-from-file>
	
	<p:wrap-sequence name="merge-load" wrapper="sequence" wrapper-namespace="http://www.corbas.co.uk/ns/test">
		<p:input port="source">
			<p:pipe port="result" step="load-manifest"/>
		</p:input>
	</p:wrap-sequence>
	
</p:declare-step>