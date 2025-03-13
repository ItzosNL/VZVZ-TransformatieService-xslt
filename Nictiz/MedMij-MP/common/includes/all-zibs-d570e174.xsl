<?xml version="1.0" encoding="UTF-8"?>

<!-- == Provenance: YATC-internal/fhir-2-ada/env/zibs2017/payload/all-zibs.xsl == -->
<!-- == Distribution: MP9-Medicatieproces-9.0.7; 0.1; 2024-08-26T18:25:33.12+02:00 == -->
<xsl:stylesheet exclude-result-prefixes="#all"
                version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:f="http://hl7.org/fhir"
                xmlns:nf="http://www.nictiz.nl/functions"
                xmlns:yatcs="https://nictiz.nl/ns/YATC-shared"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
                xmlns:local="urn:fhir:stu3:functions">
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
   <!-- moved import of util here to prevent duplicate import warnings due to fhir use in ada-hl7v3 conversions (dosageInstructions in FHIR) -->
   <xsl:import href="constants-d570e175.xsl"/>
   <xsl:import href="datetime-d570e176.xsl"/>
   <xsl:import href="units-d570e177.xsl"/>
   <xsl:import href="utilities-d570e178.xsl"/>
   <xsl:import href="fhir_2_ada_fhir_include-d570e179.xsl"/>
   <!-- nl-core resources -->
   <xsl:import href="nl-core-patient-2.1-d570e181.xsl"/>
   <xsl:import href="nl-core-practitioner-2.0-d570e182.xsl"/>
   <xsl:import href="nl-core-practitionerrole-2.0-d570e183.xsl"/>
   <xsl:import href="nl-core-organization-2.0-d570e184.xsl"/>
   <xsl:import href="nl-core-location-2.0.xsl"/>
   <xsl:import href="nl-core-relatedperson-2.0-d570e186.xsl"/>
   <!-- nl-core datatypes -->
   <xsl:import href="nl-core-address-2.0-d570e187.xsl"/>
   <xsl:import href="nl-core-contactpoint-1.0-d570e188.xsl"/>
   <xsl:import href="nl-core-humanname-2.0-d570e189.xsl"/>
   <!-- mp resources -->
   <xsl:import href="zib-medicationuse-2.2-d570e190.xsl"/>
   <xsl:import href="zib-AdministrationAgreement-2.2.xsl"/>
   <xsl:import href="zib-medicationagreement-2.2-d570e193.xsl"/>
   <xsl:import href="zib-dispense-2.2.xsl"/>
   <xsl:import href="zib-DispenseRequest-2.2.xsl"/>
   <!-- mp datatypes -->
   <xsl:import href="zib-pharmaceuticalproduct-2.0.xsl"/>
   <xsl:import href="zib-instructions-for-use-2.0-d570e197.xsl"/>
   <!-- mp extensions -->
   <xsl:import href="ext-zib-medication-additional-information-2.0-d570e198.xsl"/>
   <xsl:import href="ext-zib-medication-copy-indicator-2.0-d570e199.xsl"/>
   <xsl:import href="ext-zib-medication-use-duration-2.0-d570e200.xsl"/>
   <xsl:import href="ext-zib-medication-period-of-use-2.0-d570e201.xsl"/>
   <xsl:import href="ext-zib-medication-stop-type-2.0-d570e202.xsl"/>
   <!--ext-zib-medication-repeat-period-cyclical-schedule-2.0 is included in zib-instructions-for-use-2.0-->
   <!-- zibs -->
   <xsl:import href="zib-problem-2.1-d570e203.xsl"/>
   <xsl:import href="zib-body-height-2.1-d570e205.xsl"/>
   <xsl:import href="zib-body-weight-2.1-d570e206.xsl"/>
   <!-- ================================================================== -->
</xsl:stylesheet>