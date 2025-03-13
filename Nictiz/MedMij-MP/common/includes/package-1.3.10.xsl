<?xml version="1.0" encoding="UTF-8"?>

<!-- == Provenance: YATC-internal/ada-2-fhir/env/zibs2017/payload/package-1.3.10.xsl == -->
<!-- == Distribution: MP9-Medicatieproces-9.0.7; 0.1; 2024-08-26T18:25:33.12+02:00 == -->
<xsl:stylesheet exclude-result-prefixes="#all"
                version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://hl7.org/fhir"
                xmlns:f="http://hl7.org/fhir"
                xmlns:nf="http://www.nictiz.nl/functions"
                xmlns:yatcs="https://nictiz.nl/ns/YATC-shared"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
                xmlns:uuid="http://www.uuid.org"
                xmlns:local="urn:fhir:stu3:functions"
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
   <!-- Without this import, all depending XSLs need to import it -->
   <xsl:import href="mp-functions-fhir.xsl"/>
   <xsl:import href="_zib2017-d570e212.xsl"/>
   <xsl:import href="ext-code-specification-1.0.xsl"/>
   <xsl:import href="ext-zib-medication-additional-information-2.0-d570e219.xsl"/>
   <xsl:import href="ext-zib-medication-copy-indicator-2.0-d570e220.xsl"/>
   <xsl:import href="ext-zib-medication-instructions-for-use-description-1.0.xsl"/>
   <xsl:import href="ext-zib-medication-medication-treatment-2.0.xsl"/>
   <xsl:import href="ext-zib-medication-period-of-use-2.0-d570e223.xsl"/>
   <xsl:import href="ext-zib-medication-repeat-period-cyclical-schedule-2.0.xsl"/>
   <xsl:import href="ext-zib-medication-stop-type-2.0-d570e225.xsl"/>
   <xsl:import href="ext-zib-medication-use-duration-2.0-d570e226.xsl"/>
   <xsl:import href="nl-core-patient-2.1-d570e227.xsl"/>
   <xsl:import href="nl-core-relatedperson-2.0-d570e229.xsl"/>
   <xsl:import href="nl-core-practitioner-2.0-d570e230.xsl"/>
   <xsl:import href="nl-core-practitionerrole-2.0-d570e231.xsl"/>
   <xsl:import href="nl-core-organization-2.0-d570e232.xsl"/>
   <xsl:import href="nl-core-humanname-2.0-d570e233.xsl"/>
   <xsl:import href="nl-core-address-2.0-d570e234.xsl"/>
   <xsl:import href="nl-core-contactpoint-1.0-d570e235.xsl"/>
   <xsl:import href="zib-advancedirective-2.1.xsl"/>
   <xsl:import href="zib-alert-2.1.xsl"/>
   <xsl:import href="zib-allergyintolerance-2.1.xsl"/>
   <xsl:import href="zib-body-height-2.1-d570e239.xsl"/>
   <xsl:import href="zib-body-weight-2.1-d570e241.xsl"/>
   <xsl:import href="zib-instructions-for-use-2.0-d570e242.xsl"/>
   <xsl:import href="zib-instructions-for-use-3.0.xsl"/>
   <xsl:import href="zib-LaboratoryTestResult-Observation-2.1.xsl"/>
   <xsl:import href="zib-LaboratoryTestResult-Specimen-2.1.xsl"/>
   <xsl:import href="zib-medicationagreement-2.2-d570e246.xsl"/>
   <xsl:import href="zib-medicationagreement-3.0.xsl"/>
   <xsl:import href="zib-medicationuse-2.2-d570e248.xsl"/>
   <xsl:import href="zib-medicationuse-3.0.xsl"/>
   <xsl:import href="zib-problem-2.1-d570e250.xsl"/>
   <!--<xsl:template match="/">
        <xsl:copy-of select="$labSpecimens"></xsl:copy-of>
    </xsl:template>-->
   <!-- ================================================================== -->
</xsl:stylesheet>