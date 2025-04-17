<?xml version="1.0" encoding="UTF-8"?>

<!-- == Provenance: YATC-internal/ada-2-fhir-r4/env/zibs/2020/payload/0.5-beta1/nl-core-TextResult.xsl == -->
<!-- == Distribution: MP9-Medicatieproces-9.3.0; 1.0.10; 2025-04-16T18:06:20.52+02:00 == -->
<xsl:stylesheet exclude-result-prefixes="#all"
                version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://hl7.org/fhir"
                xmlns:util="urn:hl7:utilities"
                xmlns:f="http://hl7.org/fhir"
                xmlns:nf="http://www.nictiz.nl/functions"
                xmlns:yatcs="https://nictiz.nl/ns/YATC-shared"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
                xmlns:uuid="http://www.uuid.org"
                xmlns:local="#local.202411140821304328470100">
   <!-- ================================================================== -->
   <!--
        Converts ADA tekst_uitslag to FHIR DiagnosticReport resource conforming to profile nl-core-TextResult and FHIR Media resource conforming to profile nl-core-TextResult.VisualResult.
    -->
   <!-- ================================================================== -->
   <!--
        Copyright © Nictiz
        
        This program is free software; you can redistribute it and/or modify it under the terms of the
        GNU Lesser General Public License as published by the Free Software Foundation; either version
        2.1 of the License, or (at your option) any later version.
        
        This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
        without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
        See the GNU Lesser General Public License for more details.
        
        The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
    -->
   <!-- ================================================================== -->
   <xsl:output method="xml"
               indent="yes"/>
   <xsl:strip-space elements="*"/>
   <xsl:variable name="profileNameTextResult"
                 select="'nl-core-TextResult'"/>
   <xsl:variable name="profileNameTextResultVisualResult"
                 select="'nl-core-TextResult.VisualResult'"/>
   <!-- ================================================================== -->
   <xsl:template match="tekst_uitslag"
                 name="nl-core-TextResult"
                 mode="nl-core-TextResult"
                 as="element(f:DiagnosticReport)?">
      <!-- Creates a FHIR DiagnosticReport instance conforming to profile nl-core-TextResult from ADA tekst_uitslag element. -->
      <xsl:param name="in"
                 select="."
                 as="element()?">
         <!-- ADA element as input. Defaults to self. -->
      </xsl:param>
      <xsl:param name="subject"
                 as="element()?">
         <!-- Optional ADA instance or ADA reference element for the patient. -->
      </xsl:param>
      <xsl:for-each select="$in">
         <DiagnosticReport>
            <xsl:call-template name="insertLogicalId">
               <xsl:with-param name="profile"
                               select="$profileNameTextResult"/>
            </xsl:call-template>
            <meta>
               <profile value="{nf:get-full-profilename-from-adaelement(.)}"/>
            </meta>
            <xsl:for-each select="tekst_uitslag_status">
               <status>
                  <xsl:call-template name="code-to-code">
                     <xsl:with-param name="in"
                                     select="."/>
                     <xsl:with-param name="codeMap"
                                     as="element()*">
                        <map inCode="pending"
                             inCodeSystem="2.16.840.1.113883.2.4.3.11.60.40.4.16.1"
                             code="registered"/>
                        <map inCode="preliminary"
                             inCodeSystem="2.16.840.1.113883.2.4.3.11.60.40.4.16.1"
                             code="preliminary"/>
                        <map inCode="final"
                             inCodeSystem="2.16.840.1.113883.2.4.3.11.60.40.4.16.1"
                             code="final"/>
                        <map inCode="appended"
                             inCodeSystem="2.16.840.1.113883.2.4.3.11.60.40.4.16.1"
                             code="appended"/>
                        <map inCode="corrected"
                             inCodeSystem="2.16.840.1.113883.2.4.3.11.60.40.4.16.1"
                             code="corrected"/>
                     </xsl:with-param>
                  </xsl:call-template>
                  <extension url="http://nictiz.nl/fhir/StructureDefinition/ext-CodeSpecification">
                     <valueCodeableConcept>
                        <xsl:call-template name="code-to-CodeableConcept">
                           <xsl:with-param name="in"
                                           select="."/>
                        </xsl:call-template>
                     </valueCodeableConcept>
                  </extension>
               </status>
            </xsl:for-each>
            <xsl:for-each select="tekst_uitslag_type">
               <code>
                  <xsl:call-template name="code-to-CodeableConcept">
                     <xsl:with-param name="in"
                                     select="."/>
                  </xsl:call-template>
               </code>
            </xsl:for-each>
            <xsl:call-template name="makeReference">
               <xsl:with-param name="in"
                               select="$subject"/>
               <xsl:with-param name="wrapIn"
                               select="'subject'"/>
            </xsl:call-template>
            <xsl:for-each select="tekst_uitslag_datum_tijd">
               <effectiveDateTime>
                  <xsl:attribute name="value">
                     <xsl:call-template name="format2FHIRDate">
                        <xsl:with-param name="dateTime"
                                        select="xs:string(./@value)"/>
                     </xsl:call-template>
                  </xsl:attribute>
               </effectiveDateTime>
            </xsl:for-each>
            <xsl:for-each select="visueel_resultaat">
               <media>
                  <xsl:call-template name="makeReference">
                     <xsl:with-param name="in"
                                     select="."/>
                     <xsl:with-param name="profile"
                                     select="$profileNameTextResultVisualResult"/>
                     <xsl:with-param name="wrapIn"
                                     select="'link'"/>
                  </xsl:call-template>
               </media>
            </xsl:for-each>
            <xsl:for-each select="tekst_resultaat">
               <conclusion value="{@value}"/>
            </xsl:for-each>
         </DiagnosticReport>
      </xsl:for-each>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="visueel_resultaat"
                 name="nl-core-TextResult.VisualResult"
                 mode="nl-core-TextResult.VisualResult"
                 as="element(f:Media)?">
      <!-- Creates a FHIR Media instance conforming to profile nl-core-TextResult.VisualResult from ADA tekst_uitslag element. -->
      <xsl:param name="in"
                 select="."
                 as="element()?">
         <!-- ADA element as input. Defaults to self. -->
      </xsl:param>
      <xsl:param name="subject"
                 as="element()?">
         <!-- Optional ADA instance or ADA reference element for the patient. -->
      </xsl:param>
      <xsl:for-each select="$in">
         <Media>
            <xsl:call-template name="insertLogicalId">
               <xsl:with-param name="profile"
                               select="$profileNameTextResultVisualResult"/>
            </xsl:call-template>
            <meta>
               <profile value="{nf:get-full-profilename-from-adaelement(.)}"/>
            </meta>
            <status value="unknown"/>
            <xsl:call-template name="makeReference">
               <xsl:with-param name="in"
                               select="$subject"/>
               <xsl:with-param name="wrapIn"
                               select="'subject'"/>
            </xsl:call-template>
            <content>
               <!-- Needed to satisfy constraint att-1. 'application/octet-stream' is basically 'unknown' ('arbitrary binary data') -->
               <contentType value="application/octet-stream"/>
               <data value="{@value}"/>
            </content>
         </Media>
      </xsl:for-each>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="tekst_verslag"
                 mode="_generateDisplay">
      <!-- Template to generate a display that can be shown when referencing this instance. -->
      <xsl:variable name="parts"
                    as="item()*">
         <xsl:text>Text report</xsl:text>
         <xsl:if test="tekst_uitslag_datum_tijd[@value]">
            <xsl:value-of select="concat('date ', tekst_uitslag_datum_tijd/@value)"/>
         </xsl:if>
      </xsl:variable>
      <xsl:value-of select="string-join($parts[. != ''], ', ')"/>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="visueel_resultaat"
                 mode="_generateDisplay">
      <!-- Template to generate a display that can be shown when referencing this instance. -->
      <xsl:variable name="parts"
                    as="item()*">
         <xsl:text>Text report, visual result</xsl:text>
      </xsl:variable>
      <xsl:value-of select="string-join($parts[. != ''], ', ')"/>
   </xsl:template>
</xsl:stylesheet>