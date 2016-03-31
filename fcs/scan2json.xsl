<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:utils="http://aac.ac.at/content_repository/utils"
    xmlns:sru="http://www.loc.gov/zing/srw/"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fcs="http://clarin.eu/fcs/1.0"
    xmlns:cr="http://aac.ac.at/content_repository" 
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:exsl="http://exslt.org/common"
    version="1.0" exclude-result-prefixes="xsl utils sru xs fcs cr xd">
    <xsl:import href="../commons_v1.xsl"/>
    <xd:doc scope="stylesheet">
        <xd:desc>
            generate a json object of the scanResponse
            <xd:p>Output:</xd:p>
            <xd:pre>
     {index:"$scanClause", count:"$countTerms",
      terms: [{label:"label1", value:"value1", count:"#number"}, ...]
     }
</xd:pre>
            <xd:p>Sample input</xd:p>	
            <xd:pre>
&lt;sru:scanResponse xmlns:sru="http://www.loc.gov/zing/srw/" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fcs="http://clarin.eu/fcs/1.0/">
&lt;sru:version>1.2&lt;/sru:version>
   &lt;sru:terms path="//div[@type='diary-day']/p/date/substring(xs:string(@value),1,7)">
        &lt;sru:term>
        &lt;sru:value>1903-01&lt;/sru:value>
        &lt;sru:numberOfRecords>30&lt;/sru:numberOfRecords>
        &lt;/sru:term>
        &lt;sru:term>
        &lt;sru:value>1903-02&lt;/sru:value>
        &lt;sru:numberOfRecords>28&lt;/sru:numberOfRecords>
        &lt;/sru:term>
        &lt;sru:term>
        &lt;sru:value>1903-03&lt;/sru:value>
        &lt;sru:numberOfRecords>31&lt;/sru:numberOfRecords>
        &lt;/sru:term>
   &lt;/sru:terms>
   &lt;sru:extraResponseData>
        &lt;fcs:countTerms>619&lt;/fcs:countTerms>
    &lt;/sru:extraResponseData>
    &lt;sru:echoedScanRequest>
        &lt;sru:scanClause>diary-month&lt;/sru:scanClause>
        &lt;sru:maximumTerms>100&lt;/sru:maximumTerms>
    &lt;/sru:echoedScanRequest>
 &lt;/sru:scanResponse>
</xd:pre>
    </xd:desc>
    </xd:doc>
    <xsl:output indent="no" method="text" media-type="application/json" encoding="UTF-8"/>
    <xsl:decimal-format name="european" decimal-separator="," grouping-separator="."/>

    <xd:doc>
        <xd:desc/>
    </xd:doc>
    <xsl:template match="/">
        <xsl:variable name="countTerms" select="/sru:scanResponse/sru:extraResponseData/fcs:countTerms"/>
        <xsl:variable name="countReturned" select="count(/sru:scanResponse//sru:term)"/>
        <xsl:variable name="scanClauseJson">
            <xsl:call-template name="replace-string">
                <xsl:with-param name="text" select="/sru:scanResponse/sru:echoedScanRequest/sru:scanClause"/>
                <xsl:with-param name="replace">"</xsl:with-param>
                <xsl:with-param name="with">\"</xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        <xsl:text>{"index":"</xsl:text>
        <xsl:value-of select="$scanClauseJson"/>
        <xsl:text>", "indexSize":"</xsl:text>
        <xsl:value-of select="$countTerms"/>
        <xsl:text>", "countReturned":"</xsl:text>
        <xsl:value-of select="$countReturned"/>
        <xsl:text>", </xsl:text>
        <xsl:apply-templates select="/sru:scanResponse/sru:terms"/>
        <xsl:text>}</xsl:text>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Converts a single term to json format
            <xd:p> sample data: </xd:p>
            <xd:pre>
        &lt;sru:term>
        &lt;sru:value>cartesian&lt;/sru:value>
        &lt;sru:numberOfRecords>35645&lt;/sru:numberOfRecords>
        &lt;sru:displayTerm>Carthesian&lt;/sru:displayTerm>
        &lt;sru:extraTermData>&lt;/sru:extraTermData>
        &lt;/sru:term>
</xd:pre>
    </xd:desc>
    </xd:doc>
    <xsl:template match="sru:terms">
        <xsl:text>
"terms": [
</xsl:text>
        <!-- flatten ( => dont go deeper )  -->
        <xsl:apply-templates select=".//sru:term"/>
        <xsl:text>]</xsl:text>
    </xsl:template>
    
    <xsl:template match="sru:term">
        <xsl:variable name="href">
            <xsl:call-template name="generateLinkInScanResults">
                <xsl:with-param name="index" select="$index"/>
                <xsl:with-param name="format">htmlpagetable</xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="jsonSaveHref">
            <xsl:call-template name="replace-string">
                <xsl:with-param name="text" select="$href"/>
                <xsl:with-param name="replace">"</xsl:with-param>
                <xsl:with-param name="with">\"</xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="display">
            <xsl:choose>
                <xsl:when test="sru:displayTerm != ''">
                    <xsl:value-of select="sru:displayTerm"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="sru:value"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:text>{"value": "</xsl:text>
        <xsl:choose>
            <xsl:when test="sru:extraTermData/cr:type">
                <xsl:value-of select="concat(sru:extraTermData/cr:type, '=', translate(normalize-space(sru:value),'&#34;',''))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="translate(normalize-space(sru:value),'&#34;','')"/>                
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>", </xsl:text>
        <xsl:text>"label": "</xsl:text>
        <xsl:choose>
            <xsl:when test="sru:extraTermData/cr:type">
                <xsl:value-of select="translate(normalize-space($display),'&#34;','')"/> | <xsl:value-of select="concat(sru:extraTermData/cr:type, ' ', sru:numberOfRecords)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="translate(normalize-space($display),'&#34;','')"/> | <xsl:value-of select="sru:numberOfRecords"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>|", </xsl:text>
        <xsl:text>"nextHref": "</xsl:text>
        <xsl:value-of select="$jsonSaveHref"/>
        <xsl:text>", </xsl:text>
        <xsl:text>"count": "</xsl:text>
        <xsl:value-of select="sru:numberOfRecords"/>
        <xsl:text>"}</xsl:text>
        <xsl:if test="not(position()=last())">, </xsl:if><xsl:text>
</xsl:text>
        
        <!-- dont go deeper, because flattened <xsl:apply-templates select="sru:extraTermData/sru:terms/sru:term"/>-->
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Unused for json, needed for compilation</xd:desc>
    </xd:doc>
    <xsl:template name="continue-root"></xsl:template>
</xsl:stylesheet>