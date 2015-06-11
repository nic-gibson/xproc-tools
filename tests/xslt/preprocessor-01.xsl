<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:test="http://www.corbas.co.uk/ns/test"
  exclude-result-prefixes="xs xd"
  version="2.0">
  
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- test stylesheet for processed items -->
  <xsl:template match="/*">
    <xsl:copy>
      <xsl:attribute name="test:processed">true</xsl:attribute>
      <xsl:apply-templates select='@*|node()'/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>