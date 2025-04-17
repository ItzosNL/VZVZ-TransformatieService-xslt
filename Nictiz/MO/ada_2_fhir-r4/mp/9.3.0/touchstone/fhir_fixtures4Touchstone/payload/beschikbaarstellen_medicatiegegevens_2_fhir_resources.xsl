<?xml version="1.0" encoding="UTF-8"?>

<!-- == Provenance: YATC-internal/ada-2-fhir-r4/env/mp/9.3.0/touchstone/fhir_fixtures4Touchstone/payload/beschikbaarstellen_medicatiegegevens_2_fhir_resources.xsl == -->
<!-- == Distribution: MP9-Medicatieproces-9.3.0; 1.0.10; 2025-04-16T18:06:20.52+02:00 == -->
<xsl:stylesheet exclude-result-prefixes="#all"
                version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://hl7.org/fhir"
                xmlns:f="http://hl7.org/fhir"
                xmlns:nf="http://www.nictiz.nl/functions"
                xmlns:yatcs="https://nictiz.nl/ns/YATC-shared"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
                xmlns:local="urn:fhir:stu3:functions"
                xmlns:nm="http://www.nictiz.nl/mappings"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
   <!-- ================================================================== -->
   <!--
        
            Author: Nictiz
            Purpose: This XSL was created to facilitate mapping from ADA MP9-transaction, to HL7 FHIR profiles .
            
                History:
                
                    2021-12-12 version 0.1 Initial version
                
            
        
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
   <xsl:import href="../../../2_fhir_mp93_include.xsl"/>
   <!-- The order of the imports above is important, the 2_fhir_fixtures.xsl does specific handling for Touchstone which is what we need here, 
    it therefore needs to overwrite the templates/functions in the generic XSLT code. So the 2_fhir_fixtures.xsl must be imported last.-->
   <xsl:import href="../../../../../../common/includes/2_fhir_fixtures.xsl"/>
   <xsl:import href="../../../../../../common/includes/mp-4testinstances.xsl"/>
   <xsl:output method="xml"
               indent="yes"
               omit-xml-declaration="yes"/>
   <xsl:strip-space elements="*"/>
   <!-- pass an appropriate macAddress to ensure uniqueness of the UUID -->
   <!-- 02-00-00-00-00-00 may not be used in a production situation -->
   <xsl:param name="macAddress">02-00-00-00-00-00</xsl:param>
   <!-- parameter to determine whether to refer by resource/id -->
   <!-- should be false when there is no FHIR server available to retrieve the resources -->
   <xsl:param name="referById"
              as="xs:boolean"
              select="true()"/>
   <!-- select="$oidBurgerservicenummer" zorgt voor maskeren BSN -->
   <xsl:param name="mask-ids"
              as="xs:string?"
              select="$oidBurgerservicenummer"/>
   <xsl:param name="logLevel"
              select="$logDEBUG"
              as="xs:string"/>
   <!-- whether or not to output kopie bouwstenen -->
   <xsl:param name="outputKopieBouwstenen"
              as="xs:boolean?"
              select="false()"/>
   <!-- only give dateT a value if you want conversion of relative T dates to actual dates, otherwise a Touchstone relative T-date string will be generated -->
   <!--    <xsl:param name="dateT" as="xs:date?" select="current-date()"/>-->
   <!--    <xsl:param name="dateT" as="xs:date?" select="xs:date('2020-03-24')"/>-->
   <xsl:param name="dateT"
              as="xs:date?"/>
   <!-- whether to generate a user instruction description text from the structured information, typically only needed for test instances  -->
   <!--    <xsl:param name="generateInstructionText" as="xs:boolean?" select="true()"/>-->
   <xsl:param name="generateInstructionText"
              as="xs:boolean?"
              select="false()"/>
   <!-- output dir for our result doc(s) -->
   <xsl:param name="outputDir"
              select="'.'"/>
   <xsl:param name="usecase">mp9</xsl:param>
   <xsl:param name="referencingStrategy"
              as="xs:string">logicalId</xsl:param>
   <!-- ================================================================== -->
   <xsl:template match="/">
      <!-- Start conversion. Handle interaction specific stuff for "beschikbaarstellen medicatiegegevens". -->
      <xsl:call-template name="Medicatiegegevens_90_resources">
         <xsl:with-param name="mbh"
                         select="//beschikbaarstellen_medicatiegegevens/medicamenteuze_behandeling"/>
      </xsl:call-template>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template name="Medicatiegegevens_90_resources">
      <!-- Build the individual FHIR resources. -->
      <xsl:param name="mbh">
         <!-- ada medicamenteuze behandeling -->
      </xsl:param>
      <xsl:variable name="entries"
                    as="element(f:entry)*">
         <xsl:copy-of select="$bouwstenen-930"/>
         <!-- common entries (patient, practitioners, organizations, practitionerroles, relatedpersons, products, locations, gewichten, lengtes, reden van voorschrijven,  bouwstenen -->
         <xsl:copy-of select="$commonEntries"/>
      </xsl:variable>
      <!-- and output the resource in a file -->
      <xsl:apply-templates select="($entries)//f:resource/*"
                           mode="doResourceInResultdoc">
         <xsl:with-param name="outputDir"
                         select="$outputDir"/>
      </xsl:apply-templates>
   </xsl:template>
</xsl:stylesheet>