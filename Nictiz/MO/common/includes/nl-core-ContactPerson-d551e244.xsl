<?xml version="1.0" encoding="UTF-8"?>

<!-- == Provenance: YATC-internal/fhir-2-ada-r4/env/zibs/2020/payload/0.8.0-beta.1/nl-core-ContactPerson.xsl == -->
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
   <xsl:variable name="nlcoreContactPerson"
                 select="'http://nictiz.nl/fhir/StructureDefinition/nl-core-ContactPerson'"/>
   <xsl:variable name="rolCodesystem"
                 select="('urn:oid:2.16.840.1.113883.2.4.3.11.22.472', 'urn:oid:2.16.840.1.113883.2.4.3.11.60.40.4.23.1')"
                 as="xs:string*"/>
   <!-- ================================================================== -->
   <xsl:template match="f:RelatedPerson"
                 mode="nl-core-ContactPerson">
      <!-- Template to convert f:RelatedPerson to ADA contactpersoon, currently only support for elements that are part of MP9 2.0 transactions -->
      <contactpersoon>
         <xsl:if test="../../f:fullUrl[@value]">
            <xsl:attribute name="id">
               <xsl:value-of select="nf:convert2NCName(../../f:fullUrl/@value)"/>
            </xsl:attribute>
         </xsl:if>
         <!-- naamgegevens -->
         <xsl:apply-templates select="f:name"
                              mode="nl-core-NameInformation"/>
         <!-- contactgegevens -->
         <xsl:if test="f:telephoneNumbers | f:emailAddresses">
            <contactgegevens>
               <xsl:apply-templates select="f:telephoneNumbers"
                                    mode="nl-core-ContactInformation-TelephoneNumbers"/>
               <xsl:apply-templates select="f:emailAddresses"
                                    mode="nl-core-ContactInformation-EmailAddresses"/>
            </contactgegevens>
         </xsl:if>
         <!-- adresgegevens -->
         <xsl:apply-templates select="f:address"
                              mode="nl-core-AddressInformation"/>
         <!-- rol -->
         <xsl:apply-templates select="f:relationship[f:coding/f:system/@value = $rolCodesystem]"
                              mode="#current"/>
         <!-- relatie -->
         <xsl:apply-templates select="f:relationship[not(f:coding/f:system/@value = $rolCodesystem)]"
                              mode="#current"/>
      </contactpersoon>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:relationship[not(f:coding/f:system/@value = $rolCodesystem)]"
                 mode="nl-core-ContactPerson">
      <!-- Template to convert f:relationship[not(f:system/@value = ('urn:oid:2.16.840.1.113883.2.4.3.11.22.472', 'urn:oid:2.16.840.1.113883.2.4.3.11.60.40.4.23.1'))] to ADA contactpersoon/relatie -->
      <xsl:call-template name="CodeableConcept-to-code">
         <xsl:with-param name="adaElementName">relatie</xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:relationship[f:coding/f:system/@value = $rolCodesystem]"
                 mode="nl-core-ContactPerson">
      <!-- Template to convert f:relationship[f:system/@value = ('urn:oid:2.16.840.1.113883.2.4.3.11.22.472', 'urn:oid:2.16.840.1.113883.2.4.3.11.60.40.4.23.1')] to ADA contactpersoon/rol -->
      <xsl:call-template name="CodeableConcept-to-code">
         <xsl:with-param name="adaElementName">rol</xsl:with-param>
      </xsl:call-template>
   </xsl:template>
</xsl:stylesheet>