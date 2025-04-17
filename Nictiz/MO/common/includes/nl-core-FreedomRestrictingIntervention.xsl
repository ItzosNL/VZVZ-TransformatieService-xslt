<?xml version="1.0" encoding="UTF-8"?>

<!-- == Provenance: YATC-internal/ada-2-fhir-r4/env/zibs/2020/payload/0.8.0-beta.1/nl-core-FreedomRestrictingIntervention.xsl == -->
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
                xmlns:local="#local.2024111408213082275520100"
                xmlns:nm="http://www.nictiz.nl/mappings">
   <!-- ================================================================== -->
   <!--
        Converts ADA vrijheidsbeperkende_interventie to FHIR Procedure resource conforming to profile nl-core-FreedomRestrictingIntervention.
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
   <xsl:variable name="profileNameFreedomRestrictingIntervention"
                 select="'nl-core-FreedomRestrictingIntervention'"/>
   <!-- ================================================================== -->
   <xsl:template match="vrijheidsbeperkende_interventie"
                 name="nl-core-FreedomRestrictingIntervention"
                 mode="nl-core-FreedomRestrictingIntervention"
                 as="element(f:Procedure)">
      <!-- Creates an nl-core-FreedomRestrictingIntervention instance as a Procedure FHIR instance from ADA vrijheidsbeperkende_interventie element. -->
      <xsl:param name="in"
                 select="."
                 as="element()?">
         <!-- ADA element as input. Defaults to self. -->
      </xsl:param>
      <xsl:param name="subject"
                 select="patient/*"
                 as="element()?">
         <!-- The subject as ADA element or reference. -->
      </xsl:param>
      <xsl:for-each select="$in">
         <Procedure>
            <xsl:call-template name="insertLogicalId">
               <xsl:with-param name="profile"
                               select="$profileNameFreedomRestrictingIntervention"/>
            </xsl:call-template>
            <meta>
               <profile value="{nf:get-full-profilename-from-adaelement(.)}"/>
            </meta>
            <xsl:if test="wilsbekwaam | wilsbekwaam_toelichting">
               <extension url="http://nictiz.nl/fhir/StructureDefinition/ext-FreedomRestrictingIntervention.LegallyCapable">
                  <xsl:for-each select="wilsbekwaam">
                     <extension url="legallyCapable">
                        <valueBoolean>
                           <xsl:call-template name="boolean-to-boolean">
                              <xsl:with-param name="in"
                                              select="."/>
                           </xsl:call-template>
                        </valueBoolean>
                     </extension>
                  </xsl:for-each>
                  <xsl:for-each select="wilsbekwaam_toelichting">
                     <extension url="legallyCapableComment">
                        <valueString>
                           <xsl:call-template name="string-to-string">
                              <xsl:with-param name="in"
                                              select="."/>
                           </xsl:call-template>
                        </valueString>
                     </extension>
                  </xsl:for-each>
               </extension>
            </xsl:if>
            <xsl:for-each select="instemming">
               <extension url="http://nictiz.nl/fhir/StructureDefinition/ext-FreedomRestrictingIntervention.Assent">
                  <valueCodeableConcept>
                     <xsl:call-template name="code-to-CodeableConcept">
                        <xsl:with-param name="in"
                                        select="."/>
                     </xsl:call-template>
                  </valueCodeableConcept>
               </extension>
            </xsl:for-each>
            <status>
               <xsl:choose>
                  <xsl:when test="xs:date(einde/@value) lt current-date()">
                     <xsl:attribute name="value"
                                    select="'completed'"/>
                  </xsl:when>
                  <xsl:otherwise>
                     <!-- In any other situation, we cannot know if the status is 'preparation' or 'in-progress' because there is no concept of the time difference between transformation and sending the FHIR resource -->
                     <xsl:attribute name="value"
                                    select="'unknown'"/>
                  </xsl:otherwise>
               </xsl:choose>
            </status>
            <category>
               <coding>
                  <system value="{$oidMap[@oid=$oidSNOMEDCT]/@uri}"/>
                  <code value="225317005"/>
                  <display value="beperking van bewegingsvrijheid"/>
               </coding>
            </category>
            <xsl:for-each select="soort_interventie">
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
            <xsl:choose>
               <xsl:when test="begin and einde">
                  <performedPeriod>
                     <xsl:call-template name="startend-to-Period">
                        <xsl:with-param name="start"
                                        select="begin"/>
                        <xsl:with-param name="end"
                                        select="einde"/>
                     </xsl:call-template>
                  </performedPeriod>
               </xsl:when>
               <xsl:when test="begin">
                  <performedDateTime>
                     <xsl:attribute name="value">
                        <xsl:call-template name="format2FHIRDate">
                           <xsl:with-param name="dateTime"
                                           select="xs:string(./@value)"/>
                        </xsl:call-template>
                     </xsl:attribute>
                  </performedDateTime>
               </xsl:when>
            </xsl:choose>
            <xsl:for-each select="reden_van_toepassen">
               <reasonCode>
                  <xsl:call-template name="code-to-CodeableConcept">
                     <xsl:with-param name="in"
                                     select="."/>
                  </xsl:call-template>
               </reasonCode>
            </xsl:for-each>
            <xsl:for-each select="juridische_situatie">
               <reasonReference>
                  <xsl:choose>
                     <xsl:when test="nf:resolveAdaInstance(juridische_situatie, $in)[vertegenwoordiging]">
                        <xsl:call-template name="makeReference">
                           <xsl:with-param name="in"
                                           select="juridische_situatie"/>
                           <xsl:with-param name="profile"
                                           select="$profileNameLegalSituationRepresentation"/>
                        </xsl:call-template>
                     </xsl:when>
                     <xsl:when test="nf:resolveAdaInstance(juridische_situatie, $in)[juridische_status]">
                        <xsl:call-template name="makeReference">
                           <xsl:with-param name="in"
                                           select="juridische_situatie"/>
                           <xsl:with-param name="profile"
                                           select="$profileNameLegalSituationLegalStatus"/>
                        </xsl:call-template>
                     </xsl:when>
                  </xsl:choose>
               </reasonReference>
            </xsl:for-each>
         </Procedure>
      </xsl:for-each>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="vrijheidsbeperkende_interventie"
                 mode="_generateDisplay">
      <!-- Template to generate a display that can be shown when referencing this instance. -->
      <xsl:variable name="parts"
                    as="item()*">
         <xsl:text>Freedom restricting intervention</xsl:text>
         <xsl:if test="soort_interventie[@displayName]">
            <xsl:value-of select="concat('type ', soort_interventie/@displayName)"/>
         </xsl:if>
         <xsl:if test="begin[@value]">
            <xsl:value-of select="concat('from ', begin/@value)"/>
         </xsl:if>
         <xsl:if test="einde[@value]">
            <xsl:value-of select="concat('until ', einde/@value)"/>
         </xsl:if>
      </xsl:variable>
      <xsl:value-of select="string-join($parts[. != ''], ', ')"/>
   </xsl:template>
</xsl:stylesheet>