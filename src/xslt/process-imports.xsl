<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.corbas.co.uk/ns/transforms/data"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xpath-default-namespace="http://www.corbas.co.uk/ns/transforms/data"
    version="2.0">
    
    <xsl:output indent="yes"/>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
      
    <xsl:template match="@xml:base">
        <xsl:attribute name="xml:base" select="resolve-uri(.)"></xsl:attribute>
    </xsl:template>
    
    <xsl:template match="@href|@stylesheet">
        <xsl:attribute name="{name()}" select="resolve-uri(., base-uri(.))"/>
    </xsl:template>
    
    <xsl:template match="import[not(exists(@enabled)) or xs:boolean(@enabled) = true()]">
        <xsl:variable name="uri" select="resolve-uri(@href, base-uri(.))"/>
        <xsl:variable name="imported" select="doc($uri)"/>
        <xsl:apply-templates select="$imported/manifest|$imported/group"/>
    </xsl:template>
    
    <xsl:template match="import[exists(@enabled) and xs:boolean(@enabled) = false()]"/>
    
</xsl:stylesheet>