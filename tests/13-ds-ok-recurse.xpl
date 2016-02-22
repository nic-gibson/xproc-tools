<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
	xmlns:ccproc="http://www.corbas.co.uk/ns/xproc/steps" name="tester"
	xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0">
	
	<p:documentation>Load a simple directory of xml files</p:documentation>
	
	<p:serialization port="result" indent="true"/>
  
  <p:output port="result" sequence="true">
    <p:pipe port="result" step="loader"/>
  </p:output>
		
	<p:import href="../src/directory-source.xpl"/>
	
  <ccproc:directory-source name="loader" fail-on-error='true'>
    <p:with-option name="path" select="resolve-uri('data/dir-source/02')"/>
  </ccproc:directory-source>

	

</p:declare-step>