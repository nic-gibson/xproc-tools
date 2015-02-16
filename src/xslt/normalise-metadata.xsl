<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.corbas.co.uk/ns/transforms/data"
    xpath-default-namespace="http://www.corbas.co.uk/ns/transforms/data"
    version="2.0">
    
    <xsl:strip-space elements="*"/>
    <xsl:output indent="yes"/>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="item[ancestor::*/meta]">
        <xsl:copy>
            <xsl:apply-templates select="@* | * except meta"/>
            <xsl:apply-templates select="." mode="copy-meta">
                <xsl:with-param name="seen" select="()"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="meta"/>
    
    <xsl:template match="*" mode="copy-meta">
        <xsl:param name="seen" as="item()*"/>
        <xsl:copy-of select="meta[not(@name = $seen)]"/>
        <xsl:apply-templates select="parent::*" mode="copy-meta">
            <xsl:with-param name="seen" select="($seen, meta/@name)"/>
        </xsl:apply-templates>
        
    </xsl:template>
    
    
    
</xsl:stylesheet>