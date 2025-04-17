<?xml version="1.0" encoding="UTF-8"?>

<!-- == Provenance: YATC-internal/ada-2-fhir-r4/env/zibs/2020/payload/0.5-beta1/ext-TimeInterval.xsl == -->
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
                xmlns:local="#local.2024111408212991054380100"
                xmlns:nm="http://www.nictiz.nl/mappings">
   <!-- ================================================================== -->
   <!--
        
            Converts ADA TimeInterval to FHIR datatype Period or Duration, depending on the
                situation and conforming to different profiles. See the documentation on the
                templates.
        
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
   <xsl:template name="ext-TimeInterval.Period"
                 as="element()*">
      <!-- 
            If needed, create the Period part from ADA TimeInterval input. If the input
                doesn't contain neither the StartDateTime or EndDateTime concept, output is
                suppressed. Normally, the output will take the form of the ext-TimeInterval.Period
                extension, unless  is given.
            Please note: the input precision of the start and/or end date is not strictly
                adhered to; the start- en end date will be either a full date or a full date with
                time.
         -->
      <xsl:param name="in"
                 as="element()?"
                 select=".">
         <!-- ADA element as input. Defaults to self. -->
      </xsl:param>
      <xsl:param name="wrapIn"
                 as="xs:string"
                 select="''">
         <!-- Wrap the output in this element. If absent, the output will take the
            form of the ext-TimeInterval.Period extension. -->
      </xsl:param>
      <xsl:for-each select="$in">
         <xsl:if test="start_datum_tijd[@value != ''] or eind_datum_tijd[@value != ''] or tijds_duur[@value != '' or @unit != ''] or criterium[@value != '']">
            <xsl:choose>
               <!-- If no wrapIn is given, write out the extension element and iteratively call this template. -->
               <xsl:when test="$wrapIn = ''">
                  <extension url="{$urlExtTimeIntervalPeriod}">
                     <xsl:call-template name="ext-TimeInterval.Period">
                        <xsl:with-param name="wrapIn">valuePeriod</xsl:with-param>
                     </xsl:call-template>
                  </extension>
               </xsl:when>
               <xsl:otherwise>
                  <!-- Make fhir format of the ada input -->
                  <xsl:variable name="start"
                                as="xs:string?">
                     <xsl:if test="start_datum_tijd[@value]">
                        <xsl:variable name="startTmp">
                           <xsl:call-template name="format2FHIRDate">
                              <xsl:with-param name="dateTime"
                                              select="start_datum_tijd/@value"/>
                           </xsl:call-template>
                        </xsl:variable>
                        <xsl:value-of select="string-join($startTmp, '')"/>
                     </xsl:if>
                  </xsl:variable>
                  <xsl:variable name="end"
                                as="xs:string?">
                     <xsl:if test="eind_datum_tijd[@value]">
                        <xsl:variable name="startTmp">
                           <xsl:call-template name="format2FHIRDate">
                              <xsl:with-param name="dateTime"
                                              select="eind_datum_tijd/@value"/>
                           </xsl:call-template>
                        </xsl:variable>
                        <xsl:value-of select="string-join($startTmp, '')"/>
                     </xsl:if>
                  </xsl:variable>
                  <!-- Write out the element, if we have any input, or if only a duration or criterium is known -->
                  <xsl:if test="$start or $end or tijds_duur[@value | @unit] or criterium[@value]">
                     <xsl:element name="{$wrapIn}">
                        <!-- output the extension for tijds_duur -->
                        <xsl:call-template name="ext-TimeInterval.Duration"/>
                        <!-- Converts ADA gebruiksperiode/criterium to FHIR extension for MP9 2.0 -->
                        <xsl:for-each select="criterium[@value]">
                           <extension url="{$urlExtMedicationAgreementPeriodOfUseCondition}">
                              <valueString>
                                 <xsl:call-template name="string-to-string"/>
                              </valueString>
                           </extension>
                        </xsl:for-each>
                        <xsl:if test="$start">
                           <start value="{$start}"/>
                        </xsl:if>
                        <xsl:if test="$end">
                           <end value="{$end}"/>
                        </xsl:if>
                     </xsl:element>
                  </xsl:if>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:if>
      </xsl:for-each>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template name="ext-TimeInterval.Duration"
                 as="element()?">
      <!-- If needed, create the Duration part from ADA TimeInterval input. If the input
            doesn't contain the Duration concept or if the TimeInterval can be expressed as a
            Period, output is suppressed. Normally, the output will take the form of the
            ext-TimeInterval.Duration extension, unless  is
            given. -->
      <xsl:param name="in"
                 as="element()?"
                 select=".">
         <!-- ADA element as input. Defaults to self. -->
      </xsl:param>
      <xsl:param name="wrapIn"
                 as="xs:string?">
         <!-- Wrap the output in this element. If absent, the output will take the
            form of the ext-TimeInterval-Duration extension. -->
      </xsl:param>
      <xsl:for-each select="$in">
         <xsl:if test="tijds_duur[@value | @unit]">
            <xsl:choose>
               <!-- If no wrapIn is given, write out the extension element and iteratively call this template. -->
               <xsl:when test="$wrapIn != ''">
                  <xsl:element name="{$wrapIn}">
                     <xsl:call-template name="hoeveelheid-to-Duration">
                        <xsl:with-param name="in"
                                        select="tijds_duur"/>
                     </xsl:call-template>
                  </xsl:element>
               </xsl:when>
               <xsl:otherwise>
                  <extension url="http://nictiz.nl/fhir/StructureDefinition/ext-TimeInterval.Duration">
                     <xsl:call-template name="ext-TimeInterval.Duration">
                        <xsl:with-param name="wrapIn">valueDuration</xsl:with-param>
                     </xsl:call-template>
                  </extension>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:if>
      </xsl:for-each>
   </xsl:template>
</xsl:stylesheet>