<?xml version="1.0"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:exsl="http://exslt.org/common"
  xmlns:fcs="http://clarin.eu/fcs/1.0"
  xmlns:sru="http://www.loc.gov/zing/srw/"
  xmlns="http://www.w3.org/1999/xhtml" exclude-result-prefixes="xsl exsl xd tei fcs sru">
  <xsl:import href="fcs/result2view_v1.xsl"/>
  <xsl:output method="html" media-type="text/xhtml" indent="yes" encoding="UTF-8" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"/> 

  <xsl:template match="tei:ptr" mode="record-data">
    <xsl:variable name="linkTarget">
      <xsl:choose>
        <xsl:when test="contains(@target, 'http://')">_blank</xsl:when>
        <xsl:otherwise/> <!-- empty string -->
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="target">
      <xsl:choose>
        <xsl:when test="contains(@target, 'http://')">
           <xsl:value-of select="@target"/>   
        </xsl:when>
        <xsl:when test="ancestor::tei:div[@type = 'sampleText']">
          <xsl:call-template name="formURL">
            <xsl:with-param name="action">searchRetrieve</xsl:with-param>
            <xsl:with-param name="q" select="concat('sampleText==', @target)"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="contains(@target, '|')">
          <xsl:call-template name="formURL">
            <xsl:with-param name="action">searchRetrieve</xsl:with-param>
            <xsl:with-param name="q" select="substring-after(@target, '|')"/>
            <!-- <xsl:with-param name="x-context" select="substring-before(@target, '|')"/>-->
            <xsl:with-param name="x-context">vicav-bib</xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="formURL">
            <xsl:with-param name="action">explain</xsl:with-param>
            <xsl:with-param name="x-context" select="@target"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <a href="{$target}" target="{$linkTarget}">Click here!</a>
  </xsl:template>

  <xsl:template name="getTitle">
    <xsl:value-of select="//tei:fileDesc//tei:title"/>by <xsl:apply-templates select="//tei:fileDesc/tei:author"/>
  </xsl:template>
  
  <xsl:template name="getAuthor">
    <div class="tei-authors"> by <xsl:apply-templates select="//tei:fileDesc/tei:author"/></div>
  </xsl:template>
  
  <xsl:template name="generateImg">
    <xsl:choose>
      <xsl:when test="starts-with(@target, 'http://') or starts-with(@target, '/')">
        <img src="{@target}" alt="{@target}"/>
      </xsl:when>
      <xsl:otherwise>
        <img src="http://corpus3.aac.ac.at/vicav/images/{@target}" alt="{@target}"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Suppress metadata rendering. Is explicitly rendered elsewhere</xd:desc>
  </xd:doc>
  <xsl:template match="//fcs:DataView[@type='metadata']" mode="record-data"/>  

  <xd:doc>
    <xd:desc>Suppress teiHeader rendering. Is explicitly rendered elsewhere</xd:desc>
  </xd:doc>
  <xsl:template match="tei:teiHeader" mode="record-data"/>
  
  <xd:doc>
    <xd:desc>Suppress rendering the tei:div of type positioning as it only containse a
    machine readable geo tag used by the map function.</xd:desc>
  </xd:doc>
  <xsl:template match="tei:div[@type='positioning']" mode="record-data">
    <xsl:apply-templates select=".//tei:ref" mode="record-data"/>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Glottonyms need special treatment, they will be searched in the whole document and
    rendered here.
    </xd:desc>
  </xd:doc>
  <xsl:template match="tei:div[@type='glottonyms']" mode="record-data">
    <div class="tei-div glottonyms">
      <xsl:call-template name="typeToHeading"/>
      <div class="official-glottonyms"><span class="official-glottonyms-label">Official name:</span><xsl:apply-templates select="//tei:name[@xml:lang='eng']" mode="record-data"/><xsl:apply-templates select="//tei:name[@xml:lang='ara']" mode="record-data"/></div>
      <div class="local-glottonyms"><span class="local-glottonyms-label">Local name:</span><xsl:apply-templates select="//tei:name[@type='latLoc']" mode="record-data"/><xsl:apply-templates select="//tei:name[@type='araLoc']" mode="record-data"/></div>
    </div>
  </xsl:template>
  
  <xsl:template match="tei:name[@xml:lang]" mode="record-data">
    <span class="{@xml:lang}"><xsl:value-of select="."/></span>
  </xsl:template>
  
  <xsl:template match="tei:name[@type]" mode="record-data">
    <span class="{@xml:lang} tei-type-{@type}"><xsl:value-of select="."/></span>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Return the result if there is exactly one result</xd:desc>
  </xd:doc>
  <xsl:template match="sru:records[count(sru:record) = 1]" mode="table">
    <xsl:apply-templates select="sru:record/*" mode="record-data"/>
    <xsl:variable name="rec_uri">
      <xsl:call-template name="_getRecordURI"/>
    </xsl:variable>
    <div class="title">
      <xsl:choose>
        <xsl:when test="$rec_uri">
          <!-- it was: htmlsimple, htmltable -link-to-> htmldetail; otherwise -> htmlpage -->
          <!--                        <a class="internal" href="{my:formURL('record', $format, my:encodePID(.//recordIdentifier))}">-->
          <a class="value-caller" href="{$rec_uri}&amp;x-format={$format}">
            <xsl:call-template name="getTitle"/>
          </a>                         
          <!--                        <span class="cmd cmd_save"/>-->
        </xsl:when>
        <xsl:otherwise>
          <!-- FIXME: generic link somewhere anyhow! -->
          <xsl:call-template name="getTitle"/>
        </xsl:otherwise>
      </xsl:choose>                        
    </div>
    <div class="data-view metadata">
        <xsl:apply-templates select="//fcs:DataView[@type='metadata']/*" mode="record-data"/>
    </div>
    <div class="tei-teiHeader">
      <xsl:apply-templates select="//tei:teiHeader/*" mode="record-data"/>
    </div>
  </xsl:template>
</xsl:stylesheet>
