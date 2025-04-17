<?xml version="1.0" encoding="UTF-8"?>

<!-- == Provenance: YATC-shared/xsl/util/mp-functions-fhir.xsl == -->
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
   <!-- Create contents of FHIR timing based on ada toedieningsschema -->
   <xsl:template name="adaToedieningsschema2FhirTimingContents"
                 match="toedieningsschema"
                 mode="adaToedieningsschema2FhirTimingContents">
      <xsl:param name="in"
                 as="element()?"
                 select=".">
         <!-- ada element toedieningsschema to be handled, optional but no output if empty, defaults to context -->
      </xsl:param>
      <xsl:param name="inDoseerduur"
                 as="element()?"
                 select="$in/../../doseerduur">
         <!-- the ada element for doseerduur, optional, defaults to $in/../../doseerduur -->
      </xsl:param>
      <xsl:param name="inToedieningsduur"
                 as="element()?"
                 select="$in/../toedieningsduur">
         <!-- the ada element for toedieningsduur, optional, defaults to $in/../toedieningsduur -->
      </xsl:param>
      <xsl:param name="inHerhaalperiodeCyclischschema"
                 as="element()?">
         <!-- the ada element for Herhaalperiode Cyclisch schema. Optional. 
            Does not default, because the extension is not on timing level in normal FHIR resources, but it is on timing level when used in CDA.
            Only fill this parameter here when you need the extension on timing level.
         -->
      </xsl:param>
      <xsl:for-each select="$in">
         <xsl:if test="$inDoseerduur or $inToedieningsduur or .//*[@value or @code]">
            <xsl:for-each select="$inHerhaalperiodeCyclischschema/..">
               <xsl:call-template name="ext-InstructionsForUse.RepeatPeriodCyclicalSchedule">
                  <xsl:with-param name="in"
                                  select="."/>
               </xsl:call-template>
            </xsl:for-each>
            <repeat xmlns="http://hl7.org/fhir">
               <!-- Issue MP-1817, use the same code as in ada-2-fhir there may be no differences -->
               <xsl:for-each select="..">
                  <xsl:call-template name="_buildTimingRepeat">
                     <xsl:with-param name="boundsDuration"
                                     as="element(f:boundsDuration)?">
                        <xsl:for-each select="$inDoseerduur[@value]">
                           <boundsDuration>
                              <xsl:call-template name="hoeveelheid-to-Duration">
                                 <xsl:with-param name="in"
                                                 select="."/>
                              </xsl:call-template>
                           </boundsDuration>
                        </xsl:for-each>
                     </xsl:with-param>
                  </xsl:call-template>
               </xsl:for-each>
            </repeat>
         </xsl:if>
      </xsl:for-each>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <!-- Create contents of FHIR timing based on ada doseerinstructie. Sometimes the doseerinstructie does not have a toedieningsschema, 
        but you still need it for a pause period in a cyclic schedule, so for elements herhaalperiode_cyclisch_schema and doseerduur. 
        Possibly there is a toedieningsduur without a schedule, which is strange, but oh well, sometimes people do strange things. Who are we to judge? -->
   <xsl:template name="adaDoseerinstructie2FhirTimingContents"
                 match="doseerinstructie"
                 mode="adaDoseerinstructie2FhirTimingContents">
      <xsl:param name="in"
                 as="element()?"
                 select=".">
         <!-- ada element doseerinstructie to be handled, optional but no output if empty, defaults to context -->
      </xsl:param>
      <xsl:param name="inHerhaalperiodeCyclischschema"
                 as="element()?">
         <!-- the ada element for Herhaalperiode Cyclisch schema. Optional. 
            Does not default, because the extension is not on timing level in normal FHIR resources, but it is on timing level when used in CDA.
            Only fill this parameter here when you need the extension on timing level.
         -->
      </xsl:param>
      <xsl:for-each select="$in">
         <xsl:variable name="theDosering"
                       as="element()?">
            <xsl:choose>
               <xsl:when test="dosering/toedieningsschema[.//(@value | @unit | @code | @nullFlavor)]">
                  <xsl:sequence select="dosering"/>
               </xsl:when>
               <xsl:otherwise>
                  <!-- fake input dosering/toedieningsschema, but we need the other elements and want to re-use the existing template -->
                  <dosering>
                     <toedieningsschema/>
                  </dosering>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:variable>
         <xsl:call-template name="adaToedieningsschema2FhirTimingContents">
            <xsl:with-param name="in"
                            select="$theDosering/toedieningsschema"/>
            <xsl:with-param name="inHerhaalperiodeCyclischschema"
                            select="$inHerhaalperiodeCyclischschema"/>
            <xsl:with-param name="inDoseerduur"
                            select="$in/doseerduur"/>
            <xsl:with-param name="inToedieningsduur"
                            select="$in/dosering/toedieningsduur"/>
         </xsl:call-template>
      </xsl:for-each>
   </xsl:template>
</xsl:stylesheet>