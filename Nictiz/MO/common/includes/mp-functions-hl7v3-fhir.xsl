<?xml version="1.0" encoding="UTF-8"?>

<!-- == Provenance: YATC-shared/xsl/util/mp-functions-hl7v3-fhir.xsl == -->
<!-- == Distribution: MP9-Medicatieproces-9.3.0; 1.0.10; 2025-04-16T18:06:20.52+02:00 == -->
<xsl:stylesheet exclude-result-prefixes="#all"
                version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:hl7="urn:hl7-org:v3"
                xmlns:f="http://hl7.org/fhir"
                xmlns:nf="http://www.nictiz.nl/functions"
                xmlns:yatcs="https://nictiz.nl/ns/YATC-shared"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:nwf="http://www.nictiz.nl/wiki-functions"
                xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
                xmlns:local="#local.2024020614533847069920100"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
   <!-- ================================================================== -->
   <!--
        TBD
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
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.9358_20210517124213"
                 match="toedieningsschema"
                 mode="HandleFHIRinCDAAdministrationSchedule9x">
      <!-- Create an MP CDA administration schedule based on ada toedieningsschema. Version FHIR. Override of version in 2_hl7_mp_include_9x.xsl -->
      <xsl:param name="in"
                 as="element()*"
                 select=".">
         <!-- The ada input element: toedieningsschema. Defaults to context. -->
      </xsl:param>
      <xsl:for-each select="$in">
         <effectiveTime xmlns="http://hl7.org/fhir">
            <xsl:attribute name="xsi:type"
                           select="'Timing'"/>
            <xsl:call-template name="adaToedieningsschema2FhirTimingContents">
               <xsl:with-param name="in"
                               select="."/>
               <xsl:with-param name="inHerhaalperiodeCyclischschema"
                               select="../../../herhaalperiode_cyclisch_schema"/>
            </xsl:call-template>
         </effectiveTime>
      </xsl:for-each>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.9359_20210517141255"
                 match="dosering"
                 mode="HandleDosering920">
      <!-- Template for dosage from MP 9 2.0 -->
      <!-- MP CDA Dosering -->
      <substanceAdministration classCode="SBADM"
                               moodCode="RQO"
                               xmlns="urn:hl7-org:v3">
         <templateId root="2.16.840.1.113883.2.4.3.11.60.20.77.10.9359"/>
         <xsl:for-each select=".">
            <xsl:for-each select="toedieningsschema[.//(@value | @code)]">
               <xsl:call-template name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.9358_20210517124213"/>
            </xsl:for-each>
            <xsl:if test="not(toedieningsschema[.//(@value | @code)]) and ../doseerduur[@value | @unit]">
               <!-- no toedieningsschema but there is doseerduur and there may be herhaalperiode_cyclisch_schema as well -->
               <effectiveTime xmlns="http://hl7.org/fhir">
                  <xsl:attribute name="xsi:type"
                                 select="'Timing'"/>
                  <xsl:for-each select="../..[herhaalperiode_cyclisch_schema[@value | @unit]]">
                     <xsl:call-template name="ext-InstructionsForUse.RepeatPeriodCyclicalSchedule">
                        <xsl:with-param name="in"
                                        select="."/>
                     </xsl:call-template>
                  </xsl:for-each>
                  <xsl:for-each select="../doseerduur[@value | @unit]">
                     <repeat>
                        <boundsDuration>
                           <xsl:call-template name="hoeveelheid-to-Duration">
                              <xsl:with-param name="in"
                                              select="."/>
                           </xsl:call-template>
                        </boundsDuration>
                     </repeat>
                  </xsl:for-each>
               </effectiveTime>
            </xsl:if>
            <xsl:for-each select="keerdosis[.//(@value | @code)]">
               <xsl:call-template name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.9048_20160614145840"/>
            </xsl:for-each>
            <xsl:for-each select="toedieningssnelheid[.//(@value | @code)]">
               <xsl:call-template name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.9150_20160726150449"/>
            </xsl:for-each>
            <xsl:for-each select="zo_nodig/maximale_dosering[.//(@value | @code)]">
               <maxDoseQuantity>
                  <xsl:call-template name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.9456_20231219114825"/>
               </maxDoseQuantity>
            </xsl:for-each>
         </xsl:for-each>
         <!-- Altijd verplicht op deze manier aanwezig in de HL7 substanceAdministration -->
         <consumable xsi:nil="true"/>
         <xsl:for-each select="zo_nodig/criterium[.//(@value | @code)]">
            <xsl:variable name="theOriginalText">
               <xsl:choose>
                  <xsl:when test="(. | code | criterium)/@originalText">
                     <xsl:value-of select="(. | code | criterium)/@originalText"/>
                  </xsl:when>
                  <xsl:when test="omschrijving/@value">
                     <xsl:value-of select="omschrijving/@value"/>
                  </xsl:when>
               </xsl:choose>
            </xsl:variable>
            <precondition>
               <xsl:call-template name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.9182_20170601000000">
                  <xsl:with-param name="inCode"
                                  select="(. | code | criterium)/@code"/>
                  <xsl:with-param name="inCodeSystem"
                                  select="(. | code | criterium)/@codeSystem"/>
                  <xsl:with-param name="inDisplayName"
                                  select="(. | code | criterium)/@displayName"/>
                  <xsl:with-param name="strOriginalText"
                                  select="$theOriginalText"/>
               </xsl:call-template>
            </precondition>
         </xsl:for-each>
      </substanceAdministration>
   </xsl:template>
   <!-- ================================================================== -->
   <xsl:template name="_handleDoseerinstructie">
      <!-- Helper template for doseerinstructie -->
      <xsl:param name="in"
                 as="element()?"
                 select=".">
         <!-- ada element doseerinstructie, defaults to context -->
      </xsl:param>
      <xsl:for-each select="$in">
         <!-- make the HL7 stuff -->
         <xsl:choose>
            <!-- geen dosering: pauze periode of 'gebruik bekend' of iets dergelijks -->
            <xsl:when test="not(dosering[.//(@value | @code | @nullFlavor)])">
               <entryRelationship typeCode="COMP"
                                  xmlns="urn:hl7-org:v3">
                  <xsl:for-each select="volgnummer[.//(@value | @code)]">
                     <sequenceNumber>
                        <xsl:attribute name="value"
                                       select="@value"/>
                     </sequenceNumber>
                  </xsl:for-each>
                  <!-- Als helemaal geen volgnummer opgegeven: zelf 1 invullen -->
                  <xsl:if test="not(volgnummer[.//(@value | @code)])">
                     <sequenceNumber>
                        <xsl:attribute name="value"
                                       select="1"/>
                     </sequenceNumber>
                  </xsl:if>
                  <!-- pauze periode -->
                  <xsl:if test="doseerduur[.//(@value | @unit)]">
                     <substanceAdministration classCode="SBADM"
                                              moodCode="RQO">
                        <templateId root="2.16.840.1.113883.2.4.3.11.60.20.77.10.9359"/>
                        <effectiveTime xmlns="http://hl7.org/fhir">
                           <xsl:attribute name="xsi:type"
                                          select="'Timing'"/>
                           <xsl:call-template name="adaDoseerinstructie2FhirTimingContents">
                              <xsl:with-param name="in"
                                              select="."/>
                              <xsl:with-param name="inHerhaalperiodeCyclischschema"
                                              select="../herhaalperiode_cyclisch_schema"/>
                           </xsl:call-template>
                        </effectiveTime>
                        <consumable xsi:nil="true"/>
                     </substanceAdministration>
                  </xsl:if>
               </entryRelationship>
            </xsl:when>
            <xsl:otherwise>
               <xsl:for-each select="dosering[.//(@value | @code | @nullFlavor)]">
                  <entryRelationship typeCode="COMP"
                                     xmlns="urn:hl7-org:v3">
                     <xsl:for-each select="../volgnummer[.//(@value | @code)]">
                        <sequenceNumber>
                           <xsl:attribute name="value"
                                          select="./@value"/>
                        </sequenceNumber>
                     </xsl:for-each>
                     <!-- Als helemaal geen volgnummer opgegeven: zelf 1 invullen -->
                     <xsl:if test="not(../volgnummer[.//(@value | @code)])">
                        <sequenceNumber>
                           <xsl:attribute name="value"
                                          select="1"/>
                        </sequenceNumber>
                     </xsl:if>
                     <xsl:for-each select=".">
                        <xsl:call-template name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.9359_20210517141255"/>
                     </xsl:for-each>
                  </entryRelationship>
               </xsl:for-each>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:for-each>
   </xsl:template>
</xsl:stylesheet>