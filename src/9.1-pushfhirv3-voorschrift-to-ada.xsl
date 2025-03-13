<?xml version="1.0" encoding="UTF-8"?>
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