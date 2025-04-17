<?xml version="1.0" encoding="UTF-8"?>

<!-- == Provenance: YATC-internal/ada-2-fhir-r4/env/mp/9.3.0/touchstone/fhir_fixtures4Touchstone/payload/sturen_voorstel_verstrekkingsverzoek_2_fhir.xsl == -->
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
                xmlns:local="#local.2024102408112318901710200"
                xmlns:nm="http://www.nictiz.nl/mappings"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
   <!-- ================================================================== -->
   <!--
        
            Author: Nictiz
            Purpose: This XSL was created to facilitate mapping from ADA MP9-transaction, to HL7 FHIR profiles.
            
                History:
                
                    2022-05-16 version 0.1 Initial version
                
            
        
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
   <xsl:import href="../../../sturen_voorstel_verstrekkingsverzoek/payload/sturen_voorstel_verstrekkingsverzoek_2_fhir.xsl"/>
   <xsl:import href="../../../../../../common/includes/2_fhir_fixtures.xsl"/>
   <xsl:import href="../../../../../../common/includes/mp-4testinstances.xsl"/>
   <xsl:output method="xml"
               indent="yes"
               omit-xml-declaration="yes"/>
   <xsl:strip-space elements="*"/>
   <!-- only give dateT a value if you want conversion of relative T dates to actual dates, otherwise a Touchstone relative T-date string will be generated -->
   <!--    <xsl:param name="dateT" as="xs:date?" select="current-date()"/>-->
   <!--        <xsl:param name="dateT" as="xs:date?" select="xs:date('2020-03-24')"/>-->
   <xsl:param name="dateT"
              as="xs:date?"/>
   <!-- pass an appropriate macAddress to ensure uniqueness of the UUID -->
   <!-- 02-00-00-00-00-00 may not be used in a production situation -->
   <xsl:param name="macAddress">02-00-00-00-00-00</xsl:param>
   <!-- parameter for debug level -->
   <xsl:param name="logLevel"
              select="$logWARN"
              as="xs:string"/>
   <!-- select="$oidBurgerservicenummer" zorgt voor maskeren BSN -->
   <xsl:param name="mask-ids"
              as="xs:string?"
              select="$oidBurgerservicenummer"/>
   <!-- parameter to determine whether to refer by resource/id -->
   <!-- should be false when there is no FHIR server available to retrieve the resources -->
   <xsl:param name="referById"
              as="xs:boolean"
              select="false()"/>
   <!-- whether to generate a user instruction description text from the structured information, typically only needed for test instances  -->
   <xsl:param name="generateInstructionText"
              as="xs:boolean?"
              select="true()"/>
   <!--    <xsl:param name="generateInstructionText" as="xs:boolean?" select="false()"/>-->
   <!-- output dir for our result doc(s) -->
   <xsl:param name="outputDir">.</xsl:param>
   <!-- empty searchModeParam, since this is a push message -->
   <xsl:param name="searchModeParam"
              as="xs:string?"/>
   <!-- The meta tag to be added. Optional. Typical use case is 'actionable' for prescriptions or proposals. Empty for informational purposes. -->
   <xsl:param name="metaTag"
              as="xs:string?">actionable</xsl:param>
   <!-- whether or nog to output schema / schematron links -->
   <xsl:param name="schematronXsdLinkInOutput"
              as="xs:boolean?"
              select="false()"/>
   <xsl:param name="usecase">mp9</xsl:param>
   <!-- ================================================================== -->
   <xsl:template match="/">
      <!-- Start conversion. Handle interaction specific stuff for "beschikbaarstellen medicatiegegevens". -->
      <xsl:call-template name="voorstelVerstrekkingsverzoek920"/>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template name="voorstelVerstrekkingsverzoek920">
      <!-- Build a FHIR Bundle -->
      <xsl:variable name="resultBundle">
         <xsl:if test="$schematronXsdLinkInOutput">
            <xsl:processing-instruction name="xml-model">href="http://hl7.org/fhir/R4/bundle.sch" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:processing-instruction>
         </xsl:if>
         <Bundle xsl:exclude-result-prefixes="#all">
            <xsl:if test="$schematronXsdLinkInOutput">
               <xsl:attribute name="xsi:schemaLocation">http://hl7.org/fhir https://hl7.org/fhir/R4/bundle.xsd</xsl:attribute>
            </xsl:if>
            <id value="{nf:removeSpecialCharsAndDotForTouchstone(.//sturen_voorstel_verstrekkingsverzoek[1]/@id)}"/>
            <meta>
               <profile value="{nf:get-full-profilename-from-adaelement(.//sturen_voorstel_verstrekkingsverzoek[1])}"/>
            </meta>
            <type value="transaction"/>
            <xsl:apply-templates select="$bouwstenen-930"
                                 mode="addBundleEntrySearchOrRequest"/>
            <!-- common entries (patient, practitioners, organizations, practitionerroles, products, locations -->
            <xsl:apply-templates select="$commonEntries"
                                 mode="addBundleEntrySearchOrRequest"/>
         </Bundle>
      </xsl:variable>
      <xsl:result-document href="{$outputDir}/{$resultBundle/f:Bundle/f:id/@value}.xml">
         <xsl:copy-of select="$resultBundle"/>
      </xsl:result-document>
   </xsl:template>
</xsl:stylesheet>