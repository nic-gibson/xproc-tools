<xsl:stylesheet 
    xmlns="http://www.corbas.co.uk/ns/transforms/data"
    xpath-default-namespace="http://www.corbas.co.uk/ns/transforms/data"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0">
    
    <xsl:strip-space elements="*"/>
    <xsl:output indent="yes"/>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="group">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="processed-item">							
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="*/manifest">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="@href|@stylesheet">
        <xsl:attribute name="{name()}" select="resolve-uri(., base-uri(.))"/>
    </xsl:template>
    
    <xsl:template match="@xml:base"/>
    
    <!-- duplicate processed-item elements for each item contained -->
    <xsl:template match="processed-item/item">
        <processed-item>
            <xsl:apply-templates select="../@*"/>
            <xsl:copy>
                <xsl:apply-templates select="@*|node()"/>
            </xsl:copy>
        </processed-item>
    </xsl:template>
    
</xsl:stylesheet>

