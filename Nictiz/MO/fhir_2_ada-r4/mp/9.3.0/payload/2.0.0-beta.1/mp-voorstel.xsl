<?xml version="1.0" encoding="UTF-8"?>

<!-- == Provenance: YATC-internal/fhir-2-ada-r4/env/mp/9.3.0/payload/2.0.0-beta.1/mp-voorstel.xsl == -->
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
   <xsl:output indent="yes"
               omit-xml-declaration="yes"/>
   <!-- ================================================================== -->
   <xsl:template match="f:MedicationRequest[f:intent/@value = 'plan']"
                 mode="mp-voorstel">
      <!-- Base template for the main interaction. -->
      <voorstel>
         <xsl:for-each select="f:identifier">
            <xsl:call-template name="Identifier-to-identificatie"/>
         </xsl:for-each>
         <xsl:for-each select="f:authoredOn">
            <xsl:call-template name="datetime-to-datetime">
               <xsl:with-param name="adaElementName">voorstel_datum</xsl:with-param>
               <xsl:with-param name="adaDatatype">datetime</xsl:with-param>
            </xsl:call-template>
         </xsl:for-each>
         <xsl:for-each select="f:requester">
            <xsl:variable name="resolvedRequester"
                          select="nf:resolveRefInBundle(.)"/>
            <auteur>
               <xsl:choose>
                  <xsl:when test="$resolvedRequester/(f:PractitionerRole | f:Practitioner) or f:type/@value = ('PractitionerRole', 'Practitioner')">
                     <auteur_is_zorgverlener>
                        <zorgverlener value="{nf:convert2NCName(f:reference/@value)}"
                                      datatype="reference"/>
                     </auteur_is_zorgverlener>
                  </xsl:when>
                  <xsl:when test="$resolvedRequester/(f:Organization | f:Location) or f:type/@value = ('Organization', 'Location')">
                     <auteur_is_zorgaanbieder>
                        <zorgaanbieder value="{nf:convert2NCName(f:reference/@value)}"
                                       datatype="reference"/>
                     </auteur_is_zorgaanbieder>
                  </xsl:when>
                  <xsl:when test="$resolvedRequester/f:Patient or f:type/@value = 'Patient'">
                     <auteur_is_patient value="true"/>
                  </xsl:when>
               </xsl:choose>
            </auteur>
         </xsl:for-each>
         <!-- medicamenteuze_behandeling -->
         <xsl:choose>
            <xsl:when test="f:extension[@url=$urlExtPharmaceuticalTreatmentIdentifier]">
               <xsl:for-each select="f:extension[@url=$urlExtPharmaceuticalTreatmentIdentifier]">
                  <medicamenteuze_behandeling value="{f:valueIdentifier/f:value/@value}"
                                              datatype="reference"/>
               </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
               <medicamenteuze_behandeling value="NIEUW"
                                           datatype="reference"/>
            </xsl:otherwise>
         </xsl:choose>
         <!-- toelichting -->
         <xsl:for-each select="f:extension[@url=$urlExtComment]">
            <toelichting value="{f:valueString/@value}"/>
         </xsl:for-each>
      </voorstel>
   </xsl:template>
</xsl:stylesheet>