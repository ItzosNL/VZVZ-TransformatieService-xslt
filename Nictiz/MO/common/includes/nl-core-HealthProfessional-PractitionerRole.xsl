<?xml version="1.0" encoding="UTF-8"?>

<!-- == Provenance: YATC-internal/fhir-2-ada-r4/env/zibs/2020/payload/0.8.0-beta.1/nl-core-HealthProfessional-PractitionerRole.xsl == -->
<!-- == Distribution: MP9-Medicatieproces-9.3.0; 1.0.10; 2025-04-16T18:06:20.52+02:00 == -->
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
   <!-- ================================================================== -->
   <xsl:template match="f:PractitionerRole"
                 mode="resolve-HealthProfessional-PractitionerRole">
      <!-- Template to resolve f:PractitionerRole and apply f:Practitioner -->
      <xsl:variable name="specialtyReference"
                    select="ancestor::f:entry/f:fullUrl/@value"/>
      <xsl:variable name="organizationReference"
                    select="nf:process-reference(f:organization/f:reference/@value, $specialtyReference)"
                    as="xs:string"/>
      <xsl:variable name="practitionerReference"
                    select="nf:process-reference(f:practitioner/f:reference/@value, $specialtyReference)"
                    as="xs:string"/>
      <xsl:apply-templates select="ancestor::f:Bundle/f:entry[f:fullUrl/@value=$practitionerReference]/f:resource/f:Practitioner"
                           mode="nl-core-HealthProfessional-Practitioner">
         <xsl:with-param name="organizationReference"
                         select="$organizationReference"/>
         <xsl:with-param name="specialtyReference"
                         select="$specialtyReference"/>
      </xsl:apply-templates>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:PractitionerRole"
                 mode="nl-core-HealthProfessional-PractitionerRole">
      <!-- Template to apply f:specialty within f:PractitionerRole -->
      <xsl:apply-templates select="f:specialty"/>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:specialty">
      <!-- Template to convert f:specialty to ADA specialisme -->
      <xsl:call-template name="CodeableConcept-to-code">
         <xsl:with-param name="adaElementName">specialisme</xsl:with-param>
         <xsl:with-param name="in"
                         select="."/>
      </xsl:call-template>
   </xsl:template>
</xsl:stylesheet>