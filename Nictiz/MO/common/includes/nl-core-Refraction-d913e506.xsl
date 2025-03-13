<?xml version="1.0" encoding="UTF-8"?>

<!-- == Provenance: YATC-internal/ada-2-fhir-r4/env/zibs/2020/payload/0.8.0-beta.1/nl-core-Refraction.xsl == -->
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
                xmlns:local="#local.2024111408213093501820100">
   <!-- ================================================================== -->
   <!--
        Converts ADA refractie to FHIR Observation resource conforming to profile nl-core-Refraction.
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
   <xsl:variable name="profileNameRefraction">nl-core-Refraction</xsl:variable>
   <!-- ================================================================== -->
   <xsl:template match="refractie"
                 name="nl-core-Refraction"
                 mode="nl-core-Refraction"
                 as="element(f:Observation)?">
      <!-- Creates an nl-core-Refraction instance as an Observation FHIR instance from ADA refractie element. -->
      <xsl:param name="in"
                 select="."
                 as="element()?">
         <!-- ADA element as input. Defaults to self. -->
      </xsl:param>
      <xsl:param name="subject"
                 select="patient/*"
                 as="element()?">
         <!-- Optional ADA instance or ADA reference element for the patient. -->
      </xsl:param>
      <xsl:for-each select="$in">
         <Observation>
            <xsl:call-template name="insertLogicalId">
               <xsl:with-param name="profile"
                               select="$profileNameRefraction"/>
            </xsl:call-template>
            <meta>
               <profile value="{nf:get-full-profilename-from-adaelement(.)}"/>
            </meta>
            <status value="final"/>
            <code>
               <coding>
                  <system value="{$oidMap[@oid=$oidSNOMEDCT]/@uri}"/>
                  <code value="251718005"/>
                  <display value="refractiesterkte"/>
               </coding>
            </code>
            <xsl:call-template name="makeReference">
               <xsl:with-param name="in"
                               select="$subject"/>
               <xsl:with-param name="wrapIn"
                               select="'subject'"/>
            </xsl:call-template>
            <xsl:for-each select="refractie_datum_tijd">
               <effectiveDateTime>
                  <xsl:attribute name="value">
                     <xsl:call-template name="format2FHIRDate">
                        <xsl:with-param name="dateTime"
                                        select="xs:string(./@value)"/>
                     </xsl:call-template>
                  </xsl:attribute>
               </effectiveDateTime>
            </xsl:for-each>
            <xsl:for-each select="anatomische_locatie[lateraliteit]">
               <bodySite>
                  <xsl:call-template name="nl-core-AnatomicalLocation"/>
                  <coding>
                     <system value="{$oidMap[@oid=$oidSNOMEDCT]/@uri}"/>
                     <code value="81745001"/>
                     <display value="oog"/>
                  </coding>
               </bodySite>
            </xsl:for-each>
            <xsl:for-each select="refractie_meet_methode">
               <method>
                  <xsl:call-template name="code-to-CodeableConcept">
                     <xsl:with-param name="in"
                                     select="."/>
                  </xsl:call-template>
               </method>
            </xsl:for-each>
            <xsl:for-each select="cilindrische_refractie">
               <xsl:for-each select="cilindrische_refractie_waarde">
                  <xsl:call-template name="_refractionComponent">
                     <xsl:with-param name="snomedCode">251797004</xsl:with-param>
                     <xsl:with-param name="snomedDisplay">cillindersterkte</xsl:with-param>
                     <xsl:with-param name="unit">dioptrie</xsl:with-param>
                  </xsl:call-template>
               </xsl:for-each>
               <xsl:for-each select="cilindrische_refractie_as">
                  <xsl:call-template name="_refractionComponent">
                     <xsl:with-param name="snomedCode">251799001</xsl:with-param>
                     <xsl:with-param name="snomedDisplay">as van cilinder</xsl:with-param>
                     <xsl:with-param name="unit">graden</xsl:with-param>
                  </xsl:call-template>
               </xsl:for-each>
            </xsl:for-each>
            <xsl:for-each select="prisma">
               <xsl:for-each select="prisma_waarde">
                  <xsl:call-template name="_refractionComponent">
                     <xsl:with-param name="snomedCode">251762001</xsl:with-param>
                     <xsl:with-param name="snomedDisplay">prismasterkte</xsl:with-param>
                     <xsl:with-param name="unit">prisma dioptrie</xsl:with-param>
                  </xsl:call-template>
               </xsl:for-each>
               <xsl:for-each select="prisma_basis">
                  <xsl:call-template name="_refractionComponent">
                     <xsl:with-param name="snomedCode">246223004</xsl:with-param>
                     <xsl:with-param name="snomedDisplay">richting van basis van prisma</xsl:with-param>
                     <xsl:with-param name="unit">graden</xsl:with-param>
                  </xsl:call-template>
               </xsl:for-each>
            </xsl:for-each>
            <xsl:for-each select="sferische_refractie">
               <xsl:for-each select="sferische_refractie_waarde">
                  <xsl:call-template name="_refractionComponent">
                     <xsl:with-param name="snomedCode">251795007</xsl:with-param>
                     <xsl:with-param name="snomedDisplay">sferische sterkte</xsl:with-param>
                     <xsl:with-param name="unit">dioptrie</xsl:with-param>
                  </xsl:call-template>
               </xsl:for-each>
               <xsl:for-each select="sferisch_equivalent">
                  <xsl:call-template name="_refractionComponent">
                     <xsl:with-param name="snomedCode">112881000146107</xsl:with-param>
                     <xsl:with-param name="snomedDisplay">sferisch equivalent</xsl:with-param>
                     <xsl:with-param name="unit">dioptrie</xsl:with-param>
                  </xsl:call-template>
               </xsl:for-each>
            </xsl:for-each>
            <xsl:for-each select="lees_additie">
               <xsl:call-template name="_refractionComponent">
                  <xsl:with-param name="snomedCode">251718005</xsl:with-param>
                  <xsl:with-param name="snomedDisplay">refractiesterkte</xsl:with-param>
                  <xsl:with-param name="unit">dioptrie</xsl:with-param>
               </xsl:call-template>
            </xsl:for-each>
         </Observation>
      </xsl:for-each>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template name="_refractionComponent">
      <!-- Helper template to create an Observation.component with the specified SNOMED code and the context translated to valueQuantity. -->
      <xsl:param name="snomedCode"
                 required="yes"/>
      <xsl:param name="snomedDisplay"
                 required="yes"/>
      <xsl:param name="unit"
                 select="@unit"/>
      <xsl:variable name="value"
                    select="if (starts-with(@value, '+')) then substring-after(@value, '+') else @value"/>
      <component>
         <code>
            <coding>
               <system value="{$oidMap[@oid=$oidSNOMEDCT]/@uri}"/>
               <code value="{$snomedCode}"/>
               <display value="{$snomedDisplay}"/>
            </coding>
         </code>
         <valueQuantity>
            <value value="{$value}"/>
            <unit value="{$unit}"/>
            <system value="http://unitsofmeasure.org"/>
            <code value="{nf:convert_ADA_unit2UCUM_FHIR($unit)}"/>
         </valueQuantity>
      </component>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="refractie"
                 mode="_generateDisplay">
      <!-- Template to generate a display that can be shown when referencing this instance. -->
      <xsl:variable name="parts"
                    as="item()*">
         <xsl:text>Refraction observation</xsl:text>
         <xsl:if test="refractie_datum_tijd[@value]">
            <xsl:value-of select="concat('measurement date ', refractie_datum_tijd/@value)"/>
         </xsl:if>
      </xsl:variable>
      <xsl:value-of select="string-join($parts[. != ''], ', ')"/>
   </xsl:template>
</xsl:stylesheet>