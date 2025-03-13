<?xml version="1.0" encoding="UTF-8"?>

<!-- == Provenance: YATC-internal/ada-2-fhir-r4/env/zibs/2020/payload/0.5-beta1/nl-core-AnatomicalLocation.xsl == -->
<!-- == Distribution: MP9-Medicatieproces-9.3.0; 1.0.7; 2025-01-17T18:03:28.04+01:00 == -->
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
                xmlns:local="#local.2024111408213002198890100"
                xmlns:nm="http://www.nictiz.nl/mappings">
   <!-- ================================================================== -->
   <!--
        Converts ADA anatomische_locatie to FHIR valueCodeableConcept element conforming to profile nl-core-AnatomicalLocation.
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
   <!-- ================================================================== -->
   <xsl:template match="anatomische_locatie"
                 mode="nl-core-AnatomicalLocation"
                 name="nl-core-AnatomicalLocation"
                 as="element()*">
      <!-- Creates FHIR valueCodeableConcept element from ADA anatomische_locatie element. -->
      <xsl:param name="in"
                 select="."
                 as="element()?">
         <!-- Ada 'anatomische_locatie' element containing the zib data -->
      </xsl:param>
      <xsl:param name="doWrap"
                 select="false()"
                 as="xs:boolean">
         <!-- Optional boolean to wrap the resulting element in a 'valueCodeableConcept' element. -->
      </xsl:param>
      <xsl:param name="profile"/>
      <xsl:for-each select="$in">
         <xsl:choose>
            <xsl:when test="$doWrap">
               <valueCodeableConcept>
                  <xsl:call-template name="_doAnatomicalLocation">
                     <xsl:with-param name="profile"
                                     select="$profile"/>
                  </xsl:call-template>
               </valueCodeableConcept>
            </xsl:when>
            <xsl:otherwise>
               <xsl:call-template name="_doAnatomicalLocation">
                  <xsl:with-param name="profile"
                                  select="$profile"/>
               </xsl:call-template>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:for-each>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template name="_doAnatomicalLocation">
      <xsl:param name="profile"/>
      <xsl:for-each select="lateraliteit">
         <extension url="http://nictiz.nl/fhir/StructureDefinition/ext-AnatomicalLocation.Laterality">
            <valueCodeableConcept>
               <xsl:call-template name="code-to-CodeableConcept">
                  <xsl:with-param name="in"
                                  select="."/>
               </xsl:call-template>
            </valueCodeableConcept>
         </extension>
      </xsl:for-each>
      <xsl:choose>
         <xsl:when test="$profile = $profileNameHearingFunctionHearingAid">
            <xsl:for-each select="hulpmiddel_anatomische_locatie">
               <xsl:call-template name="code-to-CodeableConcept">
                  <xsl:with-param name="in"
                                  select="."/>
               </xsl:call-template>
            </xsl:for-each>
         </xsl:when>
         <xsl:otherwise>
            <xsl:for-each select="locatie">
               <xsl:call-template name="code-to-CodeableConcept">
                  <xsl:with-param name="in"
                                  select="."/>
               </xsl:call-template>
            </xsl:for-each>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
</xsl:stylesheet>