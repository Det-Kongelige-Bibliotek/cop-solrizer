<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	       xmlns:oa="http://www.openarchives.org/OAI/2.0/"
	       xmlns:ese="http://www.europeana.eu/schemas/ese/"
	       xmlns:dc="http://purl.org/dc/elements/1.1/"
	       xmlns:dcterms="http://purl.org/dc/terms/"
	       xmlns:md="http://www.loc.gov/mods/v3"
	       xmlns:h="http://www.w3.org/1999/xhtml" 
	       xmlns:crypto="http://exslt.org/crypto"
	       xmlns:exsl="http://exslt.org/common"
	       extension-element-prefixes="exsl crypto"
	       exclude-result-prefixes="oa ese dc dcterms md"
	       version="1.0">

  
  <xsl:param name="base_uri" select="/oa:OAI-PMH/oa:request"/>
  <xsl:param name="set_spec" select="/oa:OAI-PMH/oa:request/@set"/>
  <xsl:param name="prefix"   select="/oa:OAI-PMH/oa:request/@metadataPrefix"/>
  <xsl:param name="resolution">cop_thumbnail</xsl:param>

   <xsl:param name="iiif_thumb_nails"><xsl:text>/full/!225,/0/native.jpg</xsl:text></xsl:param>

  <xsl:param name="iiif_scaling">
    <xsl:choose>
      <xsl:when test="$resolution = 'europeana'"><xsl:text>/full/!400,/0/native.jpg</xsl:text></xsl:when>
      <xsl:when test="$resolution = 'full'"><xsl:text>/full/full/0/native.jpg</xsl:text></xsl:when>
      <xsl:otherwise><xsl:text>/full/!250,/0/native.jpg</xsl:text></xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <xsl:output encoding="UTF-8"/>

 <xsl:template match="/">
    <add>
      <xsl:apply-templates select="/oa:OAI-PMH"/>
    </add> 
  </xsl:template>

  <xsl:template match="oa:OAI-PMH">
    <xsl:apply-templates select="oa:ListRecords"/>
  </xsl:template>

  <xsl:template match="oa:ListRecords">
    <xsl:apply-templates select="oa:record[oa:metadata/node()]"/>
    <xsl:apply-templates select="oa:resumptionToken"/>
  </xsl:template>

  <xsl:template match="oa:record">
    <doc>
      <xsl:element name="field">
	<xsl:attribute name="name">id</xsl:attribute>
	<xsl:value-of select="substring-after(normalize-space(oa:header/oa:identifier),'oai:kb.dk:')"/>
      </xsl:element>
      <xsl:apply-templates select="oa:metadata"/>
    </doc>
  </xsl:template>

  <xsl:template match="oa:metadata">
    <xsl:apply-templates select="ese:record"/>
  </xsl:template>

  <xsl:template match="oa:resumptionToken">
    <xsl:variable name="next_chunk_uri">
      <xsl:value-of select="concat($base_uri,'?resumptionToken=',.,'&amp;verb=ListRecords')"/>
    </xsl:variable>
    <xsl:message>
      Resuming harvesting with <xsl:value-of select="$next_chunk_uri"/>
    </xsl:message>
    <xsl:apply-templates select="document($next_chunk_uri)/oa:OAI-PMH"/>
  </xsl:template>


  <xsl:template match="ese:record">

    
    <xsl:variable name="mods" select="document(concat(
			      'http://www.kb.dk/cop/syndication',
	                      substring-after(normalize-space(ese:isShownAt),'www.kb.dk'),
			      '?format=mods'))"/>

    <xsl:variable name="lang" select="$mods//md:languageOfCataloging/md:languageTerm"/>

    <xsl:element name="field">
      <xsl:attribute name="name">full_title_tesim</xsl:attribute>
      <xsl:for-each select="$mods//md:mods/md:titleInfo">
	<xsl:value-of select="normalize-space(.)"/><xsl:if test="position() &lt; last()"><xsl:text>; </xsl:text></xsl:if>
      </xsl:for-each>
    </xsl:element>

    <xsl:for-each select="$mods//md:mods/md:titleInfo">
      <xsl:element name="field">
	<xsl:attribute name="name">title_tsim</xsl:attribute>
	<xsl:value-of select="normalize-space(.)"/>
      </xsl:element>
    </xsl:for-each>


      <xsl:element name="field">
	<xsl:attribute name="name">author_tsim</xsl:attribute><xsl:if test="position() &lt; last()"><xsl:text>; </xsl:text></xsl:if>
	<xsl:for-each select="dc:creator">
	  <xsl:value-of select="normalize-space(.)"/><xsl:if test="position() &lt; last()"><xsl:text>; </xsl:text></xsl:if>
	</xsl:for-each>
      </xsl:element>



    <xsl:for-each select="dc:description|dc:format|dc:type|dc:language|dc:contributor|dc:publisher|dc:rights|dc:coverage">
      <xsl:element name="field">
	<xsl:attribute name="name"><xsl:value-of select="concat(local-name(.),'_tsim')"/></xsl:attribute>
	<xsl:value-of select="normalize-space(.)"/>
      </xsl:element>
    </xsl:for-each>

  
    <xsl:for-each select="dc:date[number(.) = number(.)][1]">
      <xsl:element name="field">
	<xsl:attribute name="name">pub_date_tsim</xsl:attribute>
	<xsl:value-of select="number(.)" /> <!-- concat(normalize-space(.),'-12-31T23:59:59Z')"/ -->
      </xsl:element>
    </xsl:for-each>
    <xsl:for-each select="dc:date">
      <xsl:element name="field">
	<xsl:attribute name="name">readable_date_string_tsim</xsl:attribute>
	<xsl:value-of select="normalize-space(.)"/>
      </xsl:element>
    </xsl:for-each>


    <xsl:for-each select="$mods//md:mods/md:extension">
      <xsl:for-each  select="h:div">
	<xsl:for-each  select="h:a[not(contains(@href,'/editions/'))]">
	  <xsl:element name="field">
	    <!-- xsl:choose>
	      <xsl:when test="@xml:lang">
		<xsl:attribute name="name"><xsl:value-of select="concat('subject_',@xml:lang)"/></xsl:attribute>
	      </xsl:when>
	      <xsl:otherwise -->
		<xsl:attribute name="name">subject_topic_facet_tsim</xsl:attribute>
	      <!-- /xsl:otherwise>
	    </xsl:choose -->
	    <xsl:value-of select="normalize-space(.)"/>
	</xsl:element>
	</xsl:for-each>
      </xsl:for-each>
    </xsl:for-each>

    <xsl:for-each select="ese:type|ese:rights|ese:dataProvider">
      <xsl:element name="field">
	<xsl:attribute name="name">ese_<xsl:value-of select="local-name(.)"/>_tsim</xsl:attribute>
	<xsl:value-of select="normalize-space(.)"/>
      </xsl:element>
    </xsl:for-each>

    <xsl:for-each select="ese:isShownBy">
      <xsl:element name="field">
	<xsl:attribute name="name">ese_<xsl:value-of select="local-name(.)"/>_tsim</xsl:attribute>
	<xsl:choose>
	  <xsl:when test="contains(.,'www.kb.dk/imageService')">
	    <xsl:value-of select="concat('http://kb-images.kb.dk',
				  substring-after(substring-before(.,'.jpg'),'imageService'),
				  $iiif_scaling)"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:value-of select="normalize-space(.)"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:element>
    </xsl:for-each>


    <xsl:for-each select="ese:isShownBy">
      <xsl:element name="field">
	<xsl:attribute name="name">ese_<xsl:value-of select="local-name(.)"/>_tsim</xsl:attribute>
	<xsl:choose>
	  <xsl:when test="contains(.,'www.kb.dk/imageService')">
	    <xsl:value-of select="concat('http://kb-images.kb.dk',
				  substring-after(substring-before(.,'.jpg'),'imageService'),
				  $iiif_scaling)"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:value-of select="normalize-space(.)"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:element>
    </xsl:for-each>


    <xsl:for-each select="ese:isShownBy">
      <xsl:element name="field">
	<xsl:attribute name="name">iiif_thumb_nails_ssm</xsl:attribute>
	<xsl:choose>
	  <xsl:when test="contains(.,'www.kb.dk/imageService')">
	    <xsl:value-of select="concat('http://kb-images.kb.dk',
				  substring-after(substring-before(.,'.jpg'),'imageService'),
				  $iiif_thumb_nails)"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:value-of select="normalize-space(.)"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:element>
    </xsl:for-each>


    <xsl:for-each select="ese:isShownBy">
      <xsl:element name="field">
	<xsl:attribute name="name">content_metadata_image_iiif_info_ssm</xsl:attribute>
	<xsl:value-of select="concat('http://kb-images.kb.dk',
			      substring-after(substring-before(.,'.jpg'),'imageService'),
			      '/info.json')"/>
      </xsl:element>
    </xsl:for-each>

    <xsl:for-each select="ese:isShownAt">
      <xsl:element name="field">
	<xsl:attribute name="name">ese_<xsl:value-of select="local-name(.)"/>_tsim</xsl:attribute>
	<xsl:value-of select="normalize-space(.)"/>
      </xsl:element>
    </xsl:for-each>

     <xsl:for-each select="ese:isShownAt">
      <xsl:element name="field">
	<xsl:attribute name="name">mods_tsim</xsl:attribute>
	<xsl:value-of select="concat(
			      'http://www.kb.dk/cop/syndication',
	                      substring-after(normalize-space(.),'www.kb.dk'),
			      '?format=mods')"/>
      </xsl:element>
    </xsl:for-each>

    <xsl:element name="field"><xsl:attribute name="name">spotlight_exhibit_slug_slugger-title_bsi</xsl:attribute>true</xsl:element>

  </xsl:template>

</xsl:transform>
