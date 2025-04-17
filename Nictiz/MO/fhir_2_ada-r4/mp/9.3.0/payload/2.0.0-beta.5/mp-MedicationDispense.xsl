<?xml version="1.0" encoding="UTF-8"?>

<!-- == Provenance: YATC-internal/fhir-2-ada-r4/env/mp/9.3.0/payload/2.0.0-beta.5/mp-MedicationDispense.xsl == -->
<!-- == Distribution: MP9-Medicatieproces-9.3.0; 1.0.10; 2025-04-16T18:06:20.52+02:00 == -->
<xsl:stylesheet exclude-result-prefixes="#all"
                version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:util="urn:hl7:utilities"
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
   <xsl:template match="f:MedicationDispense"
                 mode="nl-core-MedicationDispense">
      <!-- Template to convert f:MedicationDispense/f:category/f:coding/f:code/@value = '373784005' to ADA medicatieverstrekking (MVE) -->
      <medicatieverstrekking>
         <!-- identificatie direct -->
         <xsl:apply-templates select="f:identifier"
                              mode="#current"/>
         <!--medicatieverstrekkings_datum_tijd-->
         <xsl:apply-templates select="f:whenHandedOver"
                              mode="#current"/>
         <!--aanschrijf_datum-->
         <xsl:apply-templates select="f:extension[@url = 'http://nictiz.nl/fhir/StructureDefinition/ext-MedicationDispense.RequestDate']/f:valueDateTime"
                              mode="#current"/>
         <!--verstrekker/zorgaanbieder-->
         <xsl:apply-templates select="f:performer"
                              mode="#current"/>
         <!--verstrekte_hoeveelheid-->
         <xsl:apply-templates select="f:quantity[f:extension/@url = 'http://hl7.org/fhir/StructureDefinition/iso21090-PQ-translation']"
                              mode="#current"/>
         <!-- verstrekt_geneesmiddel -->
         <xsl:apply-templates select="f:medicationReference"
                              mode="#current"/>
         <!-- verbruiksduur -->
         <xsl:apply-templates select="f:daysSupply"
                              mode="#current"/>
         <!--afleverlocatie-->
         <xsl:apply-templates select="f:destination/f:reference"
                              mode="#current"/>
         <!--distributievorm-->
         <xsl:apply-templates select="f:extension[@url = $urlExtMedicationMedicationDispenseDistributionForm]"
                              mode="#current"/>
         <!-- medicatieverstrekking_aanvullende_informatie -->
         <xsl:apply-templates select="f:extension[@url eq 'http://nictiz.nl/fhir/StructureDefinition/ext-MedicationDispense.MedicationDispenseAdditionalInformation']"
                              mode="#current"/>
         <!-- toelichting -->
         <xsl:apply-templates select="f:note"
                              mode="nl-core-Note"/>
         <!-- relatie_verstrekkingsverzoek -->
         <xsl:apply-templates select="f:authorizingPrescription"
                              mode="#current"/>
      </medicatieverstrekking>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:extension[@url eq $urlExtPharmaceuticalTreatmentIdentifier]"
                 mode="nl-core-MedicationDispense">
      <!-- Template to f:extension[@url eq $urlExtPharmaceuticalTreatmentIdentifier] to identificatie indirect -->
      <identificatie value="{replace(f:valueIdentifier/f:value/@value, 'urn:oid:', '')}"
                     root="{replace(f:valueIdentifier/f:system/@value, 'urn:oid:', '')}"/>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:authorizingPrescription"
                 mode="nl-core-MedicationDispense">
      <!-- Template to convert f:authorizingPrescription to relatie_medicatieafspraak -->
      <relatie_verstrekkingsverzoek>
         <xsl:call-template name="Reference-to-identificatie"/>
      </relatie_verstrekkingsverzoek>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:extension[@url eq 'http://nictiz.nl/fhir/StructureDefinition/ext-MedicationDispense.MedicationDispenseAdditionalInformation']"
                 mode="nl-core-MedicationDispense">
      <!-- Template to convert f:extension[@url eq 'http://nictiz.nl/fhir/StructureDefinition/ext-MedicationDispense.MedicationDispenseAdditionalInformation'] to aanvullende_informatie -->
      <xsl:call-template name="CodeableConcept-to-code">
         <xsl:with-param name="in"
                         select="f:valueCodeableConcept"/>
         <xsl:with-param name="adaElementName"
                         select="'medicatieverstrekking_aanvullende_informatie'"/>
      </xsl:call-template>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:extension[@url = $urlExtMedicationMedicationDispenseDistributionForm]"
                 mode="nl-core-MedicationDispense">
      <!-- Template to convert f:extension[@url eq 'http://nictiz.nl/fhir/StructureDefinition/ext-MedicationDispense.DistributionForm' to distributievorm -->
      <xsl:for-each select="f:valueCodeableConcept">
         <xsl:call-template name="CodeableConcept-to-code">
            <xsl:with-param name="adaElementName">distributievorm</xsl:with-param>
         </xsl:call-template>
      </xsl:for-each>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:destination/f:reference"
                 mode="nl-core-MedicationDispense">
      <!-- Template to convert f:destination/f:reference to afleverlocatie -->
      <xsl:variable name="resource"
                    select="nf:resolveRefInBundle(..)"/>
      <afleverlocatie value="{$resource/f:*/f:name/@value}"/>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:daysSupply"
                 mode="nl-core-MedicationDispense">
      <!-- Template to f:daysSupply convert to verbruiksduur -->
      <verbruiksduur value="{f:value/@value}"
                     unit="{f:unit/@value}"/>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:medicationReference"
                 mode="nl-core-MedicationDispense">
      <!-- Template to convert f:medicationReference to verstrekt_geneesmiddel -->
      <verstrekt_geneesmiddel>
         <farmaceutisch_product value="{nf:process-reference-2NCName(f:reference/@value,ancestor::f:entry/f:fullUrl/@value)}"
                                datatype="reference"/>
      </verstrekt_geneesmiddel>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:quantity[f:extension/@url = 'http://hl7.org/fhir/StructureDefinition/iso21090-PQ-translation']"
                 mode="nl-core-MedicationDispense">
      <!-- Template to convert to verstrekte_hoeveelheid -->
      <verstrekte_hoeveelheid>
         <aantal value="{f:extension/f:valueQuantity/f:value/@value}"/>
         <eenheid code="{f:extension/f:valueQuantity/f:code/@value}"
                  codeSystem="{replace(f:extension/f:valueQuantity/f:system/@value, 'urn:oid:', '')}"
                  displayName="{f:unit/@value}"/>
      </verstrekte_hoeveelheid>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:performer"
                 mode="nl-core-MedicationDispense">
      <!-- Template to convert f:performer to verstrekker/zorgaanbieder  -->
      <verstrekker>
         <zorgaanbieder datatype="reference"
                        value="{nf:process-reference-2NCName(f:actor/f:reference/@value, ancestor::f:entry/f:fullUrl/@value)}"/>
      </verstrekker>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:extension[@url = 'http://nictiz.nl/fhir/StructureDefinition/ext-MedicationDispense.RequestDate']/f:valueDateTime"
                 mode="nl-core-MedicationDispense">
      <!-- Template to convert f:extension[@url = 'http://nictiz.nl/fhir/StructureDefinition/ext-MedicationDispense.RequestDate']/f:valueDateTime to aanschrijf_datum -->
      <aanschrijf_datum datatype="datetime">
         <xsl:attribute name="value">
            <xsl:call-template name="format2ADADate">
               <xsl:with-param name="dateTime"
                               select="./@value">
               </xsl:with-param>
            </xsl:call-template>
         </xsl:attribute>
      </aanschrijf_datum>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:whenHandedOver"
                 mode="nl-core-MedicationDispense">
      <!-- Template to convert f:whenHandedOver to medicatieverstrekkings_datum_tijd -->
      <medicatieverstrekkings_datum_tijd datatype="datetime">
         <xsl:attribute name="value">
            <xsl:call-template name="format2ADADate">
               <xsl:with-param name="dateTime"
                               select="./@value">
               </xsl:with-param>
            </xsl:call-template>
         </xsl:attribute>
      </medicatieverstrekkings_datum_tijd>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:identifier"
                 mode="nl-core-MedicationDispense">
      <!-- Template to convert f:identifier to identificatie -->
      <xsl:call-template name="Identifier-to-identificatie"/>
   </xsl:template>
</xsl:stylesheet>