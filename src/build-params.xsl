<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:data="http://www.corbas.co.uk/ns/transforms/data"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  version="2.0">
  <xsl:template match="xsl:stylesheet">
    <c:param-set>
      <xsl:apply-templates select="@data:*"/>
    </c:param-set>
  </xsl:template>
  <xsl:template match="@data:*">
    <c:param name="{local-name()}" value="{.}"/>
  </xsl:template>
</xsl:stylesheet>
