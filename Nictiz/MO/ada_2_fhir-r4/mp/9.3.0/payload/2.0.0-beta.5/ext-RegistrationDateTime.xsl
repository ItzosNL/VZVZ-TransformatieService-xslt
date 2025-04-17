<?xml version="1.0" encoding="UTF-8"?>

<!-- == Provenance: YATC-internal/ada-2-fhir-r4/env/mp/9.3.0/payload/2.0.0-beta.5/ext-RegistrationDateTime.xsl == -->
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
   <!--    <xsl:import href="../../fhir/2_fhir_fhir_include.xsl"/>-->
   <!-- ================================================================== -->
   <xsl:template name="ext-RegistrationDateTime"
                 match="*"
                 as="element()?"
                 mode="ext-RegistrationDateTime">
      <!-- Template for shared extension http://nictiz.nl/fhir/StructureDefinition/ext-RegistrationDateTime -->
      <extension url="{$urlExtRegistrationDateTime}">
         <valueDateTime>
            <xsl:attribute name="value">
               <xsl:call-template name="format2FHIRDate">
                  <xsl:with-param name="dateTime"
                                  select="./@value"/>
               </xsl:call-template>
            </xsl:attribute>
         </valueDateTime>
      </extension>
   </xsl:template>
</xsl:stylesheet>