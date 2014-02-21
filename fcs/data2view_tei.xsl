<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exsl="http://exslt.org/common"
    xmlns:aac="urn:general" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:sru="http://www.loc.gov/zing/srw/" xmlns:exist="http://exist.sourceforge.net/NS/exist"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" version="1.0"
    exclude-result-prefixes="xsl exsl aac tei sru exist xd">

    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>Stylesheet for formatting TEI-elements inside a FCS/SRU-result. the TEI-elements
                are expected without namespace (!) (just local names) This is not nice, but is
                currently in results like that.</xd:p>
            <xd:p> The templates are sorted by TEI-elements they match. if the same transformation
                applies to multiple elements, it is extracted into own named-template and called
                from the matching templates. the named templates are at the bottom.</xd:p>
        </xd:desc>
    </xd:doc>

    <xd:doc>
        <xd:desc>Put TEI content into a div</xd:desc>
    </xd:doc>
    <xsl:template match="tei:TEI" mode="record-data">
        <div class="tei-TEI">
            <xsl:if test="@xml:id">
                <xsl:attribute name="class">
                    <xsl:value-of select="concat('tei-TEI ', @xml:id)"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates mode="record-data"/>
        </div>
    </xsl:template>

    <xd:doc>
        <xd:desc>Put TEI Header content into a div</xd:desc>
    </xd:doc>
    <xsl:template match="tei:teiHeader" mode="record-data">
        <div class="tei-teiHeader">
            <xsl:apply-templates mode="record-data"/>
        </div>
    </xsl:template>

    <xd:doc>
        <xd:desc>Generate some generelly useful information contained in the TEI header</xd:desc>
    </xd:doc>
    <xsl:template match="tei:fileDesc" mode="record-data">
        <h1>
            <xsl:value-of select="tei:titleStmt/tei:title"/>
        </h1>
        <p class="tei-authors">
            <xsl:apply-templates select="tei:author" mode="record-data"/>
        </p>
        <p class="tei-publicationStmt"><xsl:value-of select="tei:publicationStmt/tei:pubPlace"/>,
                <xsl:value-of select="tei:publicationStmt/tei:date"/></p>
        <p class="tei-editionStmt">Edition: <xsl:value-of select="tei:editionStmt/tei:edition"/></p>
        <p class="tei-sourceDesc">
            <xsl:for-each select="tei:sourceDesc/tei:p">
                <p>
                    <xsl:value-of select="."/>
                </p>
            </xsl:for-each>
        </p>
        <xsl:choose>
            <xsl:when test="tei:publicationStmt/tei:availability[@status='restricted']">
                <p class="tei-publicationStmt">All rights reserved!</p>
                <xsl:if test="tei:publicationStmt/tei:availability//tei:ref[@type='license']">
                    <p class="tei-ref-license">
                        <a
                            href="{tei:publicationStmt/tei:availability//tei:ref[@type='license']/@target}"
                            >License</a>
                    </p>
                </xsl:if>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xd:doc>
        <xd:desc>revisionDesc is not meaningful right now, for internal use</xd:desc>
    </xd:doc>
    <xsl:template match="tei:revisionDesc" mode="record-data"/>
    
    <xd:doc>
        <xd:desc>A TEI biblStruct is mapped to a HTML div element</xd:desc>
    </xd:doc>
    <xsl:template match="tei:biblStruct" mode="record-data">
        <div class="tei-biblStruct" id="{@xml:id}">
            <xsl:apply-templates mode="record-data"/>
        </div>
    </xsl:template>

    <xd:doc>
        <xd:desc>Presents monographs <xd:p> Convention used is: </xd:p>
            <xd:p> Author, Author, ... : Title, Title, ... </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="tei:monogr" mode="record-data">
        <span class="tei-authors"><xsl:apply-templates mode="record-data" select="tei:author"
        /></span><span class="xsl-author-title-separator">: </span><span class="tei-titles"><xsl:apply-templates mode="record-data"
                select="tei:title"/></span>.<xsl:apply-templates mode="record-data"
            select="tei:imprint"/>
    </xsl:template>

    <xd:doc>
        <xd:desc>Presents dependent publications <xd:p> Convention used is: </xd:p>
            <xd:p> Author, Author, ... : Title, Title, ... in -> monogr </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="tei:analytic" mode="record-data">
        <span class="tei-authors"><xsl:apply-templates mode="record-data" select="tei:author"
            /></span><span class="xsl-author-title-separator">: </span><span class="tei-titles"><xsl:apply-templates mode="record-data"
                select="tei:title"/></span> in </xsl:template>

    <xd:doc>
        <xd:desc>Return text and spacer if needed</xd:desc>
    </xd:doc>
    <xsl:template match="tei:author" mode="record-data">
        <span class="tei-author">
            <xsl:value-of select="."/>
        </span>
        <xsl:if test="following-sibling::tei:author">, </xsl:if>
    </xsl:template>

    <xd:doc>
        <xd:desc>Return text and spacer if needed</xd:desc>
    </xd:doc>
    <xsl:template match="tei:title" mode="record-data">
        <span class="tei-title">
            <xsl:value-of select="."/>
        </span>
        <xsl:if test="following-sibling::tei:title">, </xsl:if>
    </xsl:template>

    <xd:doc>
        <xd:desc>TEI Imprint as imprint span</xd:desc>
    </xd:doc>
    <xsl:template match="tei:imprint" mode="record-data">
        <span class="tei-imprint"><xsl:apply-templates mode="record-data"/></span>. </xsl:template>

    <xd:doc>
        <xd:desc>TEI pubPlace as pubPlace span</xd:desc>
    </xd:doc>
    <xsl:template match="tei:pubPlace" mode="record-data">
        <span class="tei-pubPlace">
            <xsl:value-of select="."/>
        </span>
    </xsl:template>

    <xsl:template match="tei:imprint/tei:date" mode="record-data">
        <span class="tei-imprint-date">
            <xsl:value-of select="."/>
        </span>
        <xsl:if test="following-sibling::tei:idno|following-sibling::tei:biblScope">
            <xsl:value-of select="'. '"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="tei:idno[@type='issn']" mode="record-data">
        <xsl:if test=". != ''">
            <span class="tei-idno-issn">ISSN: <xsl:value-of select="."/></span>
            <xsl:if test="following-sibling::tei:biblScope">
                <xsl:value-of select="', '"/>
            </xsl:if>
        </xsl:if>
    </xsl:template>

    <xsl:template match="tei:biblScope" mode="record-data">
        <xsl:if test=". != ''">
            <span class="tei-biblScope">
                <xsl:value-of select="."/>
            </span>
            <xsl:if test="following-sibling::tei:biblScope">
                <xsl:value-of select="', '"/>
            </xsl:if>
        </xsl:if>
    </xsl:template>

    <xsl:template match="tei:biblScope[@type = 'vol']" mode="record-data">
        <xsl:if test=". != ''">
            <span class="tei-biblScope-vol">Volume: <xsl:value-of select="."/></span>
            <xsl:if test="following-sibling::tei:biblScope">
                <xsl:value-of select="', '"/>
            </xsl:if>
        </xsl:if>
    </xsl:template>

    <xsl:template match="tei:biblScope[@type = 'issue']" mode="record-data">
        <xsl:if test=". != ''">
            <span class="tei-biblScope-issue">Issue: <xsl:value-of select="."/></span>
            <xsl:if test="following-sibling::tei:biblScope">
                <xsl:value-of select="', '"/>
            </xsl:if>
        </xsl:if>
    </xsl:template>

    <xsl:template match="tei:biblScope[@type = 'pages']" mode="record-data">
        <xsl:if test=". != ''">
            <span class="tei-biblScope-pages"><xsl:value-of select="."/> pages</span>
            <xsl:if test="following-sibling::tei:biblScope">
                <xsl:value-of select="', '"/>
            </xsl:if>
        </xsl:if>
    </xsl:template>

    <xsl:template match="tei:biblScope[@type = 'startPage']" mode="record-data">
        <xsl:if test=". != ''">
            <span class="tei-biblScope-startPage">p. <xsl:value-of select="."/></span>
            <xsl:if test="following-sibling::tei:biblScope">
                <xsl:value-of select="', '"/>
            </xsl:if>
        </xsl:if>
    </xsl:template>

    <xd:doc>
        <xd:desc/>
    </xd:doc>
    <xsl:template match="tei:series" mode="record-data">
        <div class="cs-xsl-error"> TODO! </div>
    </xsl:template>

    <xd:doc>
        <xd:desc>Notes in biblStruct are used to specify index terms</xd:desc>
    </xd:doc>
    <xsl:template match="tei:biblStruct/tei:note" mode="record-data">
        <xsl:apply-templates mode="record-data"/>
    </xsl:template>

    <xd:doc>
        <xd:desc>Notes in biblStruct are used to specify index terms</xd:desc>
    </xd:doc>
    <xsl:template match="tei:biblStruct/tei:note/tei:index" mode="record-data">
        <div class="indexTerms">
            <ul class="tei-index">
                <xsl:apply-templates mode="record-data"/>
            </ul>
        </div>
    </xsl:template>

    <xsl:template match="tei:index/tei:term" mode="record-data">
        <xsl:variable name="href">
            <xsl:call-template name="formURL">
                <xsl:with-param name="q" select="concat('vicavTaxonomy=', .)"/>
            </xsl:call-template>
        </xsl:variable>
        <li>
            <xsl:choose>
                <xsl:when test="@type = 'vicavTaxonomy'">
                    <a href="{$href}">
                        <xsl:value-of select="."/>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </li>
    </xsl:template>
    <xd:doc>
        <xd:desc>Ignore the text tag for TEI</xd:desc>
    </xd:doc>
    <xsl:template match="tei:TEI/tei:text" mode="record-data">
        <xsl:apply-templates mode="record-data"/>
    </xsl:template>

    <xd:doc>
        <xd:desc>Put TEI body content into a div</xd:desc>
    </xd:doc>
    <xsl:template match="tei:body" mode="record-data">
        <div class="tei-body">
            <xsl:apply-templates mode="record-data"/>
        </div>
    </xsl:template>

    <xd:doc>
        <xd:desc>A head section is assumed to contain a number of headings <xd:p> To generate HTML
                headings from these we use another mode. If you want the heading to contain an
                author you can supersede the getAuthor template in your projects customization.
            </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="tei:head" mode="record-data">
        <div class="tei-head">
            <xsl:apply-templates select="." mode="tei-body-headings"/>
        </div>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Count div elemetents that are ancestor of this node and have a tei:head element</xd:desc>
    </xd:doc>
    <xsl:template name="tei-div-count">
        <xsl:param name="current-node" select='.'/>
        <xsl:param name="div-count" select='0'/>
        <xsl:choose>
            <xsl:when test="$current-node/ancestor::tei:div"><xsl:call-template name="tei-div-count">
                <xsl:with-param name="div-count">
                    <xsl:choose>
                        <xsl:when test="$current-node/ancestor::tei:div/tei:head">
                            <xsl:value-of select="$div-count + 1"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$div-count"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:with-param>
                <xsl:with-param name="current-node" select="$current-node/ancestor::tei:div"/>
            </xsl:call-template></xsl:when>
            <xsl:otherwise><xsl:value-of select="$div-count"/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Utillity "function" to get the contetn into the right header tag</xd:desc>
    </xd:doc>
    <xsl:template name="div-count-to-html-header">
        <xsl:param name="div-count" select="1"/>
        <xsl:param name="content"></xsl:param>
        <xsl:choose>
            <xsl:when test="$div-count = 1">
                <h1><xsl:copy-of select="$content"/></h1>
            </xsl:when>
            <xsl:when test="$div-count = 2">
                <h2><xsl:copy-of select="$content"/></h2>
            </xsl:when>
            <xsl:when test="$div-count = 3">
                <h3><xsl:copy-of select="$content"/></h3>
            </xsl:when>
            <xsl:when test="$div-count = 4">
                <h4><xsl:copy-of select="$content"/></h4>
            </xsl:when>
            <xsl:when test="$div-count = 5">
                <h5><xsl:copy-of select="$content"/></h5>
            </xsl:when>
            <xsl:otherwise>
                <h6><xsl:copy-of select="$content"/></h6>
                <!-- there are no more html h tags! -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="getAuthor"/>

    <xsl:template match="*" mode="tei-body-headings">
        <xsl:call-template name="div-count-to-html-header">
            <xsl:with-param name="div-count">
                <xsl:call-template name="tei-div-count"/>
            </xsl:with-param>
            <xsl:with-param name="content">
                <xsl:apply-templates mode="record-data"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xd:doc>
        <xd:desc>Generate headings according to the type attribute of a div <xd:p> Superseed this in
                your local projects xsl if you want to adapt it. </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="typeToHeading">
        <xsl:call-template name="typeToHeading_base"/>
    </xsl:template>

    <xd:doc>
        <xd:desc>Default implementation of the type lookup <xd:p>This uses the dict.xml file.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="typeToHeading_base">
        <xsl:variable name="lookup" select="@type"/>
        <h3>
            <xsl:call-template name="dict">
                <xsl:with-param name="key" select="@type"/>
            </xsl:call-template>
        </h3>
    </xsl:template>

    <xsl:template match="tei:div[@type]" mode="record-data">
        <div class="tei-div {@type}">
            <xsl:call-template name="typeToHeading"/>
            <xsl:apply-templates mode="record-data"/>
        </div>
    </xsl:template>

    <xd:doc>
        <xd:desc>some special elements retained in data, due to missing correspondencies in tei if
            it will get more, we should move to separate file</xd:desc>
    </xd:doc>
    <xsl:template match="aac_HYPH1 | aac:HYPH1" mode="record-data">
        <xsl:apply-templates/>
        <xsl:text> </xsl:text>
    </xsl:template>

    <xd:doc>
        <xd:desc>some special elements retained in data, due to missing correspondencies in tei if
            it will get more, we should move to separate file</xd:desc>
    </xd:doc>
    <xsl:template match="aac_HYPH2  | aac:HYPH2" mode="record-data">
        <xsl:apply-templates/>
        <xsl:text> </xsl:text>
    </xsl:template>

    <xd:doc>
        <xd:desc>some special elements retained in data, due to missing correspondencies in tei if
            it will get more, we should move to separate file</xd:desc>
    </xd:doc>
    <xsl:template match="aac_HYPH3  | aac:HYPH3" mode="record-data">
        <xsl:apply-templates/>
        <xsl:text> </xsl:text>
    </xsl:template>

    <xd:doc>
        <xd:desc>tei:address elements are mapped to html:address (???) elements <xd:p>Suche elements
                occur in ... </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="address | tei:address" mode="record-data">
        <address>
            <xsl:if test="tei:street">
                <xsl:value-of select="tei:street"/>
                <br/>
            </xsl:if>
            <xsl:if test="tei:postCode | tei:settlement">
                <xsl:value-of select="tei:postCode"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="tei:settlement"/>
                <br/>
            </xsl:if>
            <xsl:if test="tei:country">
                <xsl:value-of select="tei:country"/>
            </xsl:if>
        </address>
    </xsl:template>

    <xd:doc>
        <xd:desc>tei:bibl elements are (???)</xd:desc>
    </xd:doc>
    <xsl:template match="bibl | tei:bibl" mode="record-data">
        <xsl:call-template name="inline"/>
    </xsl:template>

    <xd:doc>
        <xd:desc>tei:cit elements are mapped to html:quote elements <xd:p>Suche elements occur in
                ... </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="cit|tei:cit" mode="record-data">
        <quote>
            <xsl:apply-templates mode="record-data"/>
        </quote>
    </xsl:template>

    <xd:doc>
        <xd:desc>tei:data elements are formatted as spans with an apropriate class <xd:p>Suche
                elements occur in ... </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="date|tei:date" mode="record-data">
        <span class="date">
            <!--<xsl:value-of select="."/>-->
            <xsl:apply-templates mode="record-data"/>
            <!--            <span class="note">[<xsl:value-of select="@value"/>]</span>-->
        </span>
    </xsl:template>

    <xd:doc>
        <xd:desc>tei:div elements are mapped to html:div elements <xd:p>Note: html:div elements are
                defined even fuzzier than tei:div elements.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="div|tei:div" mode="record-data">
        <div>
            <xsl:if test="@type">
                <xsl:attribute name="class">
                    <xsl:value-of select="concat('tei-type-', @type)"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates mode="record-data"/>
        </div>
    </xsl:template>

    <xd:doc>
        <xd:desc>tei:p elements are mapped to html:p elements </xd:desc>
    </xd:doc>
    <xsl:template match="p|tei:p" mode="record-data">
        <p>
            <xsl:if test="@rend">
                <xsl:attribute name="class">
                    <xsl:call-template name="rend-without-color">
                        <xsl:with-param name="rend-text" select="@rend"/>
                    </xsl:call-template>
                </xsl:attribute>
                <xsl:if test="substring-after(string(@rend), 'color(')">
                    <xsl:attribute name="style">
                        <xsl:call-template name="rend-color-as-html-style">
                            <xsl:with-param name="rend-text" select="@rend"/>
                        </xsl:call-template>
                    </xsl:attribute>
                </xsl:if>
            </xsl:if>
            <xsl:apply-templates mode="record-data"/>
        </p>
    </xsl:template>

    <xd:doc>
        <xd:desc>TEI ptr elements are mapped to "Click here" links
        </xd:desc>
    </xd:doc>
    <xsl:template match="tei:ptr[not(contains(@target, '.JPG') or 
        contains(@target, '.jpg') or
        contains(@target, '.PNG') or
        contains(@target, '.png'))]" mode="record-data">
        <xsl:call-template name="generateTarget"/>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>TEI ref elements are mapped to links that contain the contents of ref 
        </xd:desc>
    </xd:doc>
    <xsl:template match="tei:ref[not(contains(@target, '.JPG') or 
        contains(@target, '.jpg') or
        contains(@target, '.PNG') or
        contains(@target, '.png'))]" mode="record-data">
        <xsl:call-template name="generateTarget">
            <xsl:with-param name="linkText"><xsl:apply-templates mode="record-data"/></xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template  match="tei:ptr[contains(@target, '.JPG') or 
        contains(@target, '.jpg') or
        contains(@target, '.PNG') or
        contains(@target, '.png')]" mode="record-data">
        <xsl:call-template name="generateImgHTMLTags"/>
    </xsl:template>
    
    <xsl:template match="tei:ref[contains(@target, '.JPG') or 
        contains(@target, '.jpg') or
        contains(@target, '.PNG') or
        contains(@target, '.png')]" mode="record-data">
        <xsl:call-template name="generateImgHTMLTags">
            <xsl:with-param name="altText"><xsl:value-of select="."/></xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Special handling of target declarations that point to other resources
            <xd:p> Note: You most likely have
                to supply you're own logic by superseding this. </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="generateTarget">
        <xsl:param name="linkText" select="'Click here'"/>
        <xsl:variable name="linkTarget">
            <xsl:choose>
                <xsl:when test="starts-with(@target, 'http://') or starts-with(@target, 'https://')">_blank</xsl:when>
                <xsl:otherwise/>
                <!-- empty string -->
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="target">
            <xsl:choose>
                <xsl:when test="starts-with(@target, 'http://') or starts-with(@target, 'https://') or starts-with(@target, '/')">
                    <xsl:value-of select="@target"/>
                </xsl:when>
                <xsl:when test="contains(@target, '|')">
                    <xsl:call-template name="formURL">
                        <xsl:with-param name="action">searchRetrieve</xsl:with-param>
                        <xsl:with-param name="q" select="substring-after(@target, '|')"/>
                        <xsl:with-param name="x-context" select="substring-before(@target, '|')"/>
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
        <a href="{$target}" target="{$linkTarget}">
            <xsl:value-of select="$linkText"/>
        </a>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Generates img tags from ref or ptr
        <xd:p>Supersede this if you want to change the default lookup path for example.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="generateImgHTMLTags">
        <xsl:param name="altText" select="@target"/>
        <xsl:choose>
            <xsl:when test="starts-with(@target, 'http://') or starts-with(@target, '/') or starts-with(@target, 'https://')">
                <img src="{@target}" alt="{$altText}"/>
            </xsl:when>
            <xsl:otherwise>
                <img src="{@target}" alt="{$altText}"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>tei:table elements are mapped to html:table elements <xd:p>Note: These elements are
                found eg. in the mecmua transkription.</xd:p>
            <xd:p>There is a class attribute "tei-table" so it is possible to format these tables
                differently form eg. blind tables used elsewhere.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="table|tei:table" mode="record-data">
        <table class="tei-table">
            <xsl:apply-templates mode="record-data"/>
        </table>
    </xsl:template>

    <xd:doc>
        <xd:desc>tei:row elements are mapped to html:tr elements </xd:desc>
    </xd:doc>
    <xsl:template match="row|tei:row" mode="record-data">
        <tr>
            <xsl:apply-templates mode="record-data"/>
        </tr>
    </xsl:template>

    <xd:doc>
        <xd:desc>tei:cell elements are mapped to html:td elements </xd:desc>
    </xd:doc>
    <xsl:template match="cell|tei:cell" mode="record-data">
        <td>
            <xsl:if test="./@cols">
                <xsl:attribute name="colspan">
                    <xsl:value-of select="./@cols"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates mode="record-data"/>
        </td>
    </xsl:template>

    <xd:doc>
        <xd:desc>tei:hi is mapped to html:span and @rend is mapped to @class</xd:desc>
        <xd:p>Note these elements are found eg. in the mecmua transkription</xd:p>
    </xd:doc>
    <xsl:template match="hi|tei:hi" mode="record-data">
        <span>
            <xsl:if test="@rend">
                <xsl:attribute name="class">
                    <xsl:call-template name="rend-without-color">
                        <xsl:with-param name="rend-text" select="@rend"/>
                    </xsl:call-template>
                </xsl:attribute>
                <xsl:if test="substring-after(string(@rend), 'color(')">
                    <xsl:attribute name="style">
                        <xsl:call-template name="rend-color-as-html-style">
                            <xsl:with-param name="rend-text" select="@rend"/>
                        </xsl:call-template>
                    </xsl:attribute>
                </xsl:if>
            </xsl:if>
            <xsl:apply-templates mode="record-data"/>
        </span>
    </xsl:template>

    <xd:doc>
        <xd:desc>Lemma form
        <xd:p>
            Default priority="0.5"
            We do enforce latin before arabic script.
        </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="tei:form[@type='lemma']" mode="record-data">
        <span class="tei-form-lemma">
            <xsl:apply-templates select="tei:orth[not(contains(@xml:lang, '-arabic'))]" mode="record-data"/><xsl:text> </xsl:text>
            <xsl:apply-templates select="tei:orth[contains(@xml:lang, '-arabic')]" mode="record-data"/>
            <xsl:apply-templates select="*[not(name() = 'orth')]"></xsl:apply-templates>
        </span>        
    </xsl:template>
    
    <xsl:template match="tei:form[@type='inflected']" mode="record-data">
        <span class="tei-form-inflected">
            <xsl:apply-templates select="tei:orth[not(contains(@xml:lang, '-arabic'))]" mode="record-data"/><xsl:text> </xsl:text>
            <xsl:apply-templates select="tei:orth[contains(@xml:lang, '-arabic')]" mode="record-data"/>
            <span class="tei-form-ana">
                <xsl:choose>
                    <xsl:when test="@ana='#adj_f'">f</xsl:when>
                    <xsl:when test="@ana='#adj_pl'">pl</xsl:when>
                    <xsl:when test="@ana='#n_pl'">pl</xsl:when>
                    <xsl:when test="@ana='#v_pres_sg_p3'">pres</xsl:when>
                </xsl:choose>
            </span>
            <xsl:apply-templates select="*[not(name() = 'orth')]"></xsl:apply-templates>
        </span>
    </xsl:template>
    
    <xsl:template match="tei:orth[contains(@xml:lang, '-vicav')]|tei:orth[contains(@xml:lang, '-arabic')]" mode="record-data">
        <span class="tei-orth {@xml:lang}">
            <xsl:apply-templates mode="record-data"/>
        </span>
    </xsl:template>
    
    <xsl:template match="tei:gramGrp" mode="record-data">
        <dl class="tei-gramGrp">
            <xsl:apply-templates mode="record-data"/>
        </dl>
    </xsl:template>
    
    <xsl:template match="tei:gram[@type]" mode="record-data">
        <dt class="tei-gram">
            <xsl:call-template name="dict">
                <xsl:with-param name="key" select="@type"/>
            </xsl:call-template>
        </dt>
        <dd class="tei-gram {@type}">
            <xsl:apply-templates mode="record-data"/> 
        </dd>
    </xsl:template>
    
    <xsl:template match="tei:sense" mode="record-data">
        <div class="tei-sense">
            <xsl:if test="tei:def">            
                <div class="tei-defs">
                    <xsl:apply-templates select="tei:def[@xml:lang='en']"/>
                    <xsl:apply-templates select="tei:def[@xml:lang='de']"/>
                    <xsl:apply-templates select="tei:def[not(@xml:lang='en' or @xml:lang='de')]"/>               
                </div>
            </xsl:if>
            <xsl:if test="tei:cit">
                <div class="tei-cits">
                    <xsl:apply-templates select="tei:cit" mode="record-data"/>
                </div>
            </xsl:if>
            <xsl:apply-templates select="*[not(name() = 'def' or name() = 'cit')]" mode="record-data"/>
        </div>
    </xsl:template>
    
    <xsl:template match="tei:def[@xml:lang]">
        <span class="tei-def-{@xml:lang}"><xsl:apply-templates mode="record-data"/></span>
    </xsl:template>
    
    <xsl:template match="tei:cit[(@type='translation')]" mode="record-data">
         <span class="tei-cit-translation-{@xml:lang}"><xsl:apply-templates mode="record-data"/></span>                 
    </xsl:template>
    
    <xsl:template match="tei:cit[@type='example']" mode="record-data">
        <div class="tei-cit-example">
            <xsl:apply-templates mode="record-data"/>
        </div>
    </xsl:template>
    
    <xsl:template match="tei:quote[contains(@xml:lang,'-vicav')]" mode="record-data">
        <span class="tei-quote-vicav-transcr"><xsl:apply-templates mode="record-data"/></span>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>tei:entry elements are the base elements for any lexicographical definitions
            <xd:p></xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="tei:entry" mode="record-data">
        <div class="tei-entry">
            <xsl:apply-templates mode="record-data"/>                                           
        </div>
    </xsl:template>

    <xd:doc>
        <xd:desc>tei:foreign elements are formatted as divs with an apropriate language class
                <xd:p>Suche elements occur in ... </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="foreign | tei:foreign" mode="record-data">
        <div lang="{@lang}">
            <xsl:apply-templates mode="record-data"/>
        </div>
    </xsl:template>
    <xd:doc>
        <xd:desc>tei:geo elements are mapped to spans optionally as link to more
            information.</xd:desc>
    </xd:doc>
    <xsl:template match="geo | tei:geo" mode="record-data">
        <xsl:call-template name="inline"/>
    </xsl:template>
    <xd:doc>
        <xd:desc>tei:l elements are expanded and a html:br element as added.</xd:desc>
    </xd:doc>
    <xsl:template match="l | tei:l" mode="record-data">
        <xsl:apply-templates mode="record-data"/>
        <br/>
    </xsl:template>
    <xsl:template match="lb | tei:lb" mode="record-data">
        <br/>
    </xsl:template>
    <xsl:template match="lg | tei:lg" mode="record-data">
        <div class="lg">
            <p>
                <xsl:apply-templates mode="record-data"/>
            </p>
        </div>
    </xsl:template>
    <xd:doc>
        <xd:desc>tei:milestone elemnts are not retained</xd:desc>
        <xd:p>Replced by three dots (...)</xd:p>
    </xd:doc>
    <xsl:template match="milestone | tei:milestone" mode="record-data">
        <xsl:text>...</xsl:text>
    </xsl:template>

    <!-- for STB: dont want pb -->
    <xsl:template match="pb | tei:pb" mode="record-data"/>
    <!--<xsl:template match="pb" mode="record-data">
        <div class="pb">p. <xsl:value-of select="@n"/>
        </div>
    </xsl:template>-->
    <xsl:template match="place | tei:place" mode="record-data">
        <xsl:copy>
            <xsl:apply-templates mode="record-data"/>
        </xsl:copy>
    </xsl:template>
    <xd:doc>
        <xd:desc>tei:persName, tei:placeName etc. elements are mapped to spans optionally as link to
            more information.</xd:desc>
    </xd:doc>
    <xsl:template match="persName | placeName | name | tei:persName | tei:placeName | tei:name"
        mode="record-data">
        <xsl:call-template name="inline">
            <xsl:with-param name="additional-style" select="string(../@rend)"/>
        </xsl:call-template>
    </xsl:template>

    <xd:doc>
        <xd:desc>tei:quote elements are mapped to spans optionally as link to more
            information.</xd:desc>
    </xd:doc>
    <xsl:template match="quote | tei:quote" mode="record-data">
        <xsl:call-template name="inline"/>
    </xsl:template>
    <xd:doc>
        <xd:desc>tei:rs elements are mapped to spans optionally as link to more
            information.</xd:desc>
    </xd:doc>
    <xsl:template match="rs | tei:rs" mode="record-data">
        <xsl:call-template name="inline"/>
    </xsl:template>

    <xd:doc>
        <xd:desc>tei:seg elements are mapped to spans optionally as link to more information.
                <xd:p>Note: These may not make sense in a particular project eg. STB.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="seg | tei:seg" mode="record-data">
        <xsl:call-template name="inline"/>
    </xsl:template>

    <!-- handing over to aac:stand.xsl -->
    <!--<xsl:template match="seg" mode="record-data">
        <xsl:apply-templates select="."/>
    </xsl:template>-->
    <!--
    <xsl:template match="seg[@type='header']" mode="record-data"/>
    <xsl:template match="seg[@rend='italicised']" mode="record-data">
        <em>
            <xsl:apply-templates mode="record-data"/>
        </em>
    </xsl:template>
    -->

    <xd:doc>
        <xd:desc>
            <xd:p>a rather sloppy section optimized for result from aacnames listPerson/tei:person
                this should occur only in lists, not in text </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="tei:person" mode="record-data">
        <div class="person">
            <xsl:apply-templates select="tei:birth|tei:death|tei:occupation" mode="record-data"/>
            <xsl:variable name="elem-link">
                <xsl:call-template name="elem-link"/>
            </xsl:variable>
            <a href="{$elem-link}">
                <xsl:value-of select="tei:persName"/> in text</a>

            <!--<div class="links">
                <ul>
                    <xsl:apply-templates select="tei:link" mode="record-data"/>
                </ul>
            </div>-->
        </div>
    </xsl:template>

    <xd:doc>
        <xd:desc>Suppressed. Already used as a title. </xd:desc>
    </xd:doc>
    <xsl:template match="tei:person/tei:persName" mode="record-data"/>

    <xd:doc>
        <xd:desc>Suppressed. Not really nice for output. (???) </xd:desc>
    </xd:doc>
    <xsl:template match="tei:sex" mode="record-data"/>

    <xsl:template match="tei:birth" mode="record-data">
        <div>
            <span class="label">geboren: </span>
            <span class="{local-name()}" data-when="{@when}">
                <xsl:value-of select="concat(@when, ', ', tei:placeName)"/>
            </span>
        </div>
    </xsl:template>
    <xsl:template match="tei:death" mode="record-data">
        <div>
            <span class="label">gestorben: </span>
            <span class="{local-name()}" data-when="{@when}">
                <xsl:value-of select="concat(@when, ', ', tei:placeName)"/>
            </span>
        </div>
    </xsl:template>
    <xsl:template match="tei:occupation" mode="record-data">
        <div class="{local-name()}">
            <xsl:value-of select="."/>
        </div>
    </xsl:template>
    <xsl:template match="tei:link" mode="record-data">
        <li>
            <a href="{@target}">
                <xsl:value-of select="@target"/>
            </a>
        </li>
    </xsl:template>

    <xsl:strip-space elements="tei:s tei:w tei:c tei:fs"/>
    <xd:doc>
        <xd:desc>Handle TEI sentence markers</xd:desc>
    </xd:doc>
    <xsl:template match="tei:s" mode="record-data">
        <span class="tei-s">
            <xsl:apply-templates mode="record-data"/>
        </span>
    </xsl:template>

    <xd:doc>
        <xd:desc/>
    </xd:doc>
    <xsl:template match="tei:c" mode="record-data">
        <span class="tei-c">
            <xsl:value-of select="."/>
        </span>
    </xsl:template>

    <xsl:template match="tei:w" mode="record-data">
        <span>
            <xsl:attribute name="class">
                <xsl:value-of select="concat('tei-w pos ', tei:fs/tei:f[@name = 'pos'])"/>
            </xsl:attribute>
            <xsl:if test="tei:fs/tei:f[@name='wordform']">
                <xsl:if test="(tei:fs/tei:f[@name='wordform'])[@xml:lang]">
                    <xsl:attribute name="data-lang">
                        <xsl:value-of select="(tei:fs/tei:f[@name='wordform'])/@xml:lang"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:value-of select="tei:fs/tei:f[@name='wordform']"/>
            </xsl:if>
            <xsl:apply-templates mode="record-data"/>
        </span>
    </xsl:template>

    <xsl:template match="tei:w/tei:fs" mode="record-data">
        <dl class="tei-fs">
            <xsl:apply-templates mode="record-data"/>
        </dl>
    </xsl:template>

    <xsl:template match="tei:w/tei:fs/tei:f" mode="record-data" priority="0">
        <dt class="{@name}">
            <xsl:if test="@lang">
                <xsl:attribute name="data-lang">
                    <xsl:value-of select="@xml:lang"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:call-template name="dict">
                <xsl:with-param name="key" select="@name"/>
            </xsl:call-template>
        </dt>
        <dd>
            <xsl:value-of select="."/>
        </dd>
    </xsl:template>

    <xsl:template match="tei:w/tei:fs/tei:f[@name='wordform']" mode="record-data" priority="1"> </xsl:template>

    <xsl:template match="tei:w/tei:fs/tei:f[@name='pos']" mode="record-data" priority="1">
            <dt class="pos">
                <xsl:call-template name="dict">
                    <xsl:with-param name="key" select="@name"/>
                </xsl:call-template>
            </dt>
            <dd>
                <xsl:call-template name="dict">
                    <xsl:with-param name="key" select="normalize-space(.)"/>
                    <xsl:with-param name="fallback">Please add word form <xsl:value-of
                            select="concat('&quot;', ., '&quot;')"/> to dict.xml!</xsl:with-param>
                </xsl:call-template>
            </dd>
    </xsl:template>

    <xd:doc>
        <xd:desc>For internal use, don't produce any HTML</xd:desc>
    </xd:doc>
    <xsl:template match="tei:fs[@type='change']" mode="record-data"/>
    
    <xd:doc>
        <xd:desc>For internal use, don't produce any HTML</xd:desc>
    </xd:doc>
    <xsl:template match="tei:fs[@type='create']" mode="record-data"/>
    
    <xd:doc>
        <xd:desc>Get the "argument" of color() used in @rend attributes and return it as html inline
            style attribute. <xd:p>Note: assumes only one color().</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="rend-color-as-html-style">
        <xsl:param name="rend-text"/>
        <xsl:choose>
            <xsl:when test="substring-after(string($rend-text), 'color(')">color: #<xsl:value-of
                    select="substring-before(substring-after(string($rend-text), 'color('), ')')"
                />;</xsl:when>
            <xsl:otherwise>
                <!-- there is nothing that could be returened, is there? -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xd:doc>
        <xd:desc>Get everything but the color() part in @rend attributes <xd:p>Note: assumes only
                one color().</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="rend-without-color">
        <xsl:param name="rend-text"/>
        <xsl:choose>
            <xsl:when test="substring-after(string($rend-text), 'color(')">
                <xsl:value-of
                    select="substring-after(substring-before(string($rend-text), 'color('), ')')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="string($rend-text)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>