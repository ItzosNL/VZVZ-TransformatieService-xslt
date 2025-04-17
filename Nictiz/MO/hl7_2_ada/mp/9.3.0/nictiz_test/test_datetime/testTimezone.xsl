<?xml version="1.0" encoding="UTF-8"?>

<!-- == Provenance: YATC-internal/hl7-2-ada/env/mp/9.3.0/nictiz_test/test_datetime/testTimezone.xsl == -->
<!-- == Distribution: MP9-Medicatieproces-9.3.0; 1.0.10; 2025-04-16T18:06:20.52+02:00 == -->
<xsl:stylesheet exclude-result-prefixes="#all"
                version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:nf="http://www.nictiz.nl/functions"
                xmlns:yatcs="https://nictiz.nl/ns/YATC-shared"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:local="#local.2024120415184397353550100">
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
   <!-- this import is to avoid compilation errors when running outside of oXygen with the super cool main files functionality -->
   <xsl:import href="../../../../../ada_2_fhir-r4/mp/9.3.0/beschikbaarstellen_medicatiegegevens/payload/beschikbaarstellen_medicatiegegevens_2_fhir.xsl"/>
   <!-- these imports are for the format date templates that we really need to test -->
   <xsl:import href="../../../../../common/includes/2_hl7_hl7_include.xsl"/>
   <xsl:import href="../../../../../common/includes/2_fhir_fhir_include-d551e151.xsl"/>
   <xsl:import href="../../../../../common/includes/hl7_2_ada_hl7_include.xsl"/>
   <xsl:import href="../../../../../common/includes/fhir_2_ada_fhir_include-d551e231.xsl"/>
   <xsl:output omit-xml-declaration="yes"
               indent="yes"/>
   <!-- this stylesheet aims to test ada_2_hl7, hl7_2_ada, ada_2_fhir, fhir_2_ada for handling dates (with or without timezone) -->
   <!-- ================================================================== -->
   <xsl:template match="/">
      <xsl:apply-templates select="@* | node()"
                           mode="testTimeZone"/>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="timezones_test/ada_vaguedate"
                 mode="testTimeZone">
      <xsl:element name="date">
         <xsl:element name="input_date">
            <xsl:apply-templates select="@* | node()"
                                 mode="#current"/>
         </xsl:element>
         <xsl:variable name="hl7v3Date">
            <xsl:call-template name="format2HL7Date">
               <xsl:with-param name="dateTime">
                  <xsl:value-of select="text()"/>
               </xsl:with-param>
               <xsl:with-param name="precision"/>
            </xsl:call-template>
         </xsl:variable>
         <xsl:element name="hl7v3_date">
            <xsl:value-of select="$hl7v3Date"/>
         </xsl:element>
         <xsl:element name="h2ada_date">
            <xsl:value-of select="nf:formatHL72VagueAdaDate($hl7v3Date, nf:determine_date_precision($hl7v3Date))"/>
         </xsl:element>
         <xsl:variable name="fhirDate"
                       as="xs:string?">
            <xsl:call-template name="format2FHIRDate">
               <xsl:with-param name="dateTime">
                  <xsl:value-of select="text()"/>
               </xsl:with-param>
               <xsl:with-param name="precision"/>
            </xsl:call-template>
         </xsl:variable>
         <xsl:element name="fhir__date">
            <xsl:value-of select="$fhirDate"/>
         </xsl:element>
         <xsl:element name="f2ada_date">
            <xsl:call-template name="format2ADADate">
               <xsl:with-param name="dateTime"
                               select="$fhirDate"/>
            </xsl:call-template>
         </xsl:element>
      </xsl:element>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="timezones_test/hl7_inputdate"
                 mode="testTimeZone">
      <xsl:element name="date">
         <xsl:copy>
            <xsl:apply-templates select="@* | node()"
                                 mode="#current"/>
         </xsl:copy>
         <xsl:variable name="adaDate"
                       select="nf:formatHL72VagueAdaDate(., nf:determine_date_precision(.))"/>
         <xsl:element name="h2ada_date">
            <xsl:value-of select="$adaDate"/>
         </xsl:element>
         <xsl:variable name="hl7v3Date">
            <xsl:call-template name="format2HL7Date">
               <xsl:with-param name="dateTime">
                  <xsl:value-of select="$adaDate"/>
               </xsl:with-param>
               <xsl:with-param name="precision"/>
            </xsl:call-template>
         </xsl:variable>
         <xsl:element name="hl7v3_date">
            <xsl:value-of select="$hl7v3Date"/>
         </xsl:element>
      </xsl:element>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="@* | node()"
                 mode="testTimeZone">
      <xsl:copy>
         <xsl:apply-templates select="@* | node()"
                              mode="#current"/>
      </xsl:copy>
   </xsl:template>
</xsl:stylesheet>