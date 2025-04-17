<?xml version="1.0" encoding="UTF-8"?>

<!-- == Provenance: YATC-internal/ada-2-fhir-r4/env/zibs/2020/payload/0.7-beta1/nl-core-NutritionAdvice.xsl == -->
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
                xmlns:local="#local.2024111408213060858030100">
   <!-- ================================================================== -->
   <!--
        Converts ADA voedingsadvies to FHIR NutritionOrder resource conforming to profile nl-core-NutritionAdvice.
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
   <xsl:variable name="profileNameNutritionAdvice"
                 select="'nl-core-NutritionAdvice'"/>
   <!-- ================================================================== -->
   <xsl:template match="voedingsadvies"
                 name="nl-core-NutritionAdvice"
                 mode="nl-core-NutritionAdvice"
                 as="element(f:NutritionOrder)?">
      <!-- Creates an nl-core-NutritionAdvice instance as a NutritionOrder FHIR instance from ADA voedingsadvies element. -->
      <xsl:param name="in"
                 select="."
                 as="element()?">
         <!-- ADA element as input. Defaults to self. -->
      </xsl:param>
      <xsl:param name="patient"
                 select="patient/*"
                 as="element()?">
         <!-- Optional ADA instance or ADA reference element for the patient. -->
      </xsl:param>
      <xsl:for-each select="$in">
         <NutritionOrder>
            <xsl:call-template name="insertLogicalId">
               <xsl:with-param name="profile"
                               select="$profileNameNutritionAdvice"/>
            </xsl:call-template>
            <meta>
               <profile value="{nf:get-full-profilename-from-adaelement(.)}"/>
            </meta>
            <xsl:for-each select="indicatie">
               <extension url="http://hl7.org/fhir/StructureDefinition/workflow-reasonReference">
                  <valueReference>
                     <xsl:call-template name="makeReference">
                        <xsl:with-param name="in"
                                        select="probleem"/>
                        <xsl:with-param name="profile"
                                        select="$profileNameProblem"/>
                     </xsl:call-template>
                  </valueReference>
               </extension>
            </xsl:for-each>
            <status value="active"/>
            <intent value="order"/>
            <xsl:call-template name="makeReference">
               <xsl:with-param name="in"
                               select="$patient"/>
               <xsl:with-param name="wrapIn"
                               select="'patient'"/>
            </xsl:call-template>
            <!--No suitable field to map to dateTime is present in the ada instance, hence current-dateTime is used instead. See https://github.com/Nictiz/Nictiz-R4-zib2020/issues/179.-->
            <dateTime>
               <xsl:attribute name="value">
                  <xsl:value-of select="current-dateTime()"/>
               </xsl:attribute>
            </dateTime>
            <oralDiet>
               <xsl:for-each select="dieet_type">
                  <type>
                     <text>
                        <xsl:call-template name="string-to-string">
                           <xsl:with-param name="in"
                                           select="."/>
                        </xsl:call-template>
                     </text>
                  </type>
               </xsl:for-each>
               <xsl:call-template name="util:logMessage">
                  <xsl:with-param name="msg">The zib doesn't provide enough information to determine the right mapping of consistency, as it depends on the type of food (BITS ticket ZIB-1617). Therefore the mapping for solid food is used which may not be right for the information that is transformed.</xsl:with-param>
                  <xsl:with-param name="level">WARN</xsl:with-param>
                  <xsl:with-param name="terminate">false</xsl:with-param>
               </xsl:call-template>
               <xsl:for-each select="consistentie">
                  <texture>
                     <modifier>
                        <text>
                           <xsl:call-template name="string-to-string">
                              <xsl:with-param name="in"
                                              select="."/>
                           </xsl:call-template>
                        </text>
                     </modifier>
                  </texture>
               </xsl:for-each>
            </oralDiet>
            <xsl:for-each select="toelichting">
               <note>
                  <text>
                     <xsl:call-template name="string-to-string">
                        <xsl:with-param name="in"
                                        select="."/>
                     </xsl:call-template>
                  </text>
               </note>
            </xsl:for-each>
         </NutritionOrder>
      </xsl:for-each>
   </xsl:template>
</xsl:stylesheet>