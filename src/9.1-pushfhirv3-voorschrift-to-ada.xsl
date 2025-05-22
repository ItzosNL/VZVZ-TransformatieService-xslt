<?xml version="1.0" encoding="UTF-8"?>
<!--
Copyright © VZVZ

This program is free software; you can redistribute and/or modify it under the terms of 
the GNU General Public License as published by the Free Software Foundation; version 3 
of the License, and no later version.

We make every effort to ensure the files are as error-free as possible, but we take 
no responsibility for any consequences arising from errors during usage.

The full text of the license is available at http://www.gnu.org/licenses/gpl-3.0.html
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:saxon="http://saxon.sf.net/"
  exclude-result-prefixes="xs saxon"
  version="3.0">
  
  <xsl:import href="vf.includes/vf.utils.xsl"/>
  
  <xsl:variable name="mv2Ada" select="concat($hl7Mappings, '/fhir_2_ada-r4/mp/9.3.0/sturen_medicatievoorschrift/payload/sturen_medicatievoorschrift_2_ada.xsl')"/>
  <xsl:variable name="lab2Ada" select="concat($hl7Mappings, '/fhir_2_ada-r4/lab/3.0.0/sturen_laboratoriumresultaten/payload/sturen_laboratoriumresultaten_2_ada.xsl')"/>
<!--  <xsl:import href="../../mp/9.3.0/sturen_medicatievoorschrift/payload/sturen_medicatievoorschrift_2_ada.xsl"/>-->
<!--  <xsl:import href="../../lab/3.0.0/sturen_laboratoriumresultaten/payload/sturen_laboratoriumresultaten_2_ada.xsl"/>-->
  
  <xsl:template match="/">
    <xsl:variable name="data">
<!--      <xsl:call-template name="ada_sturen_medicatievoorschrift"/>-->
<!--      <xsl:call-template name="ada_sturen_laboratoriumresultaten"/>-->
      
      <xsl:sequence select="saxon:transform(saxon:compile-stylesheet(doc($mv2Ada)), .)"/>
      <xsl:sequence select="saxon:transform(saxon:compile-stylesheet(doc($lab2Ada)), .)"/>
    </xsl:variable>
    
    <adaxml xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="../ada_schemas/ada_sturen_medicatievoorschrift.xsd">
      <meta status="new" created-by="generated" last-update-by="generated"/>
      <xsl:copy-of select="$data/adaxml/data"/>
    </adaxml>
  </xsl:template>
</xsl:stylesheet>