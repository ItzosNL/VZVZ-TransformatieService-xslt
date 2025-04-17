<?xml version="1.0" encoding="UTF-8"?>

<!-- == Provenance: YATC-internal/fhir-2-ada-r4/env/mp/9.3.0/payload/2.0.0-beta.5/mp-AdministrationAgreement.xsl == -->
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
   <xsl:variable name="mpAdministrationAgreement"
                 select="concat($urlBaseNictizProfile, 'mp-AdministrationAgreement')"/>
   <xsl:variable name="extAdministrationAgreementDateTime"
                 select="concat($urlBaseNictizProfile, 'ext-AdministrationAgreement.AdministrationAgreementDateTime')"/>
   <xsl:variable name="extAdministrationAgreementAgreementReason"
                 select="concat($urlBaseNictizProfile, 'ext-AdministrationAgreement.AgreementReason')"/>
   <xsl:variable name="extAdministrationAgreementModificationDiscontinuationReason"
                 select="concat($urlBaseNictizProfile, 'ext-AdministrationAgreement.ReasonModificationOrDiscontinuation')"/>
   <!-- ================================================================== -->
   <xsl:template match="f:MedicationDispense"
                 mode="mp-AdministrationAgreement">
      <!-- Template to convert f:MedicationRequest to ADA toedieningsafspraak -->
      <toedieningsafspraak>
         <!-- identificatie -->
         <xsl:apply-templates select="f:identifier"
                              mode="#current"/>
         <!-- registratiedatumtijd -->
         <xsl:apply-templates select="f:extension[@url = $urlExtRegistrationDateTime]"
                              mode="urlExtRegistrationDateTime"/>
         <!-- toedieningsafspraak_datum_tijd -->
         <xsl:apply-templates select="f:extension[@url = $extAdministrationAgreementDateTime]"
                              mode="#current"/>
         <!-- gebruiksperiode -->
         <xsl:if test="f:extension[@url = ($urlExtTimeInterval-Period, $urlExtTimeIntervalPeriod)] or f:extension[@url = ($urlExtTimeInterval-Duration, $urlExtTimeIntervalDuration)]">
            <gebruiksperiode>
               <xsl:apply-templates select="f:extension[@url = ($urlExtTimeInterval-Period, $urlExtTimeIntervalPeriod)]"
                                    mode="urlExtTimeInterval-Period"/>
               <!-- MP9 2.0.0-bèta version -->
               <xsl:apply-templates select="f:extension[@url = ($urlExtTimeInterval-Duration, $urlExtTimeIntervalDuration)]"
                                    mode="urlExtTimeInterval-Duration"/>
               <!-- MP9 2.0.0 version -->
               <xsl:apply-templates select="f:extension[@url = ($urlExtTimeInterval-Period, $urlExtTimeIntervalPeriod)]/f:valuePeriod/f:extension[@url = ($urlExtTimeInterval-Duration, $urlExtTimeIntervalDuration)]"
                                    mode="urlExtTimeInterval-Duration"/>
            </gebruiksperiode>
         </xsl:if>
         <!-- geannuleerd_indicator  -->
         <xsl:apply-templates select="f:status"
                              mode="#current"/>
         <!-- toedieningsafspraak_stop_type -->
         <xsl:apply-templates select="f:modifierExtension[@url = $urlExtStoptype]"
                              mode="ext-StopType"/>
         <!-- verstrekker -->
         <xsl:apply-templates select="f:performer"
                              mode="#current"/>
         <!-- reden_afspraak -->
         <!-- Issue MP-370 dataset concept type change from string to codelist -->
         <xsl:apply-templates select="f:extension[@url = ($extAdministrationAgreementAgreementReason, $extAdministrationAgreementModificationDiscontinuationReason)]"
                              mode="#current"/>
         <!-- geneesmiddel_bij_toedieningsafspraak -->
         <xsl:apply-templates select="f:medicationReference"
                              mode="#current"/>
         <!-- gebruiksinstructie -->
         <xsl:call-template name="mp-InstructionsForUse"/>
         <!-- distributievorm, added as part of MP-257, borrowed from MedicationDispense -->
         <xsl:apply-templates select="f:extension[@url = $urlExtMedicationMedicationDispenseDistributionForm]"
                              mode="nl-core-MedicationDispense"/>
         <!-- aanvullende_informatie -->
         <!-- MP-1176 aanvullende_informatie nolonger supported in MP9.3.0.0 beta.3 but is kept in the stylesheet to ensure backwards compatibility-->
         <xsl:apply-templates select="f:extension[@url = $urlExtAdministrationAgreementAdditionalInformation]"
                              mode="#current"/>
         <!-- toelichting -->
         <xsl:apply-templates select="f:note"
                              mode="nl-core-Note"/>
         <!-- kopie indicator -->
         <xsl:apply-templates select="f:extension[@url = $urlExtCopyIndicator]"
                              mode="ext-CopyIndicator"/>
         <!-- relatie medicatieafspraak -->
         <xsl:apply-templates select="f:authorizingPrescription"
                              mode="#current"/>
         <!-- relatie toedieningsafspraak -->
         <xsl:apply-templates select="f:extension[@url = $urlExtRelationAdministrationAgreement]"
                              mode="#current"/>
      </toedieningsafspraak>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:identifier"
                 mode="mp-AdministrationAgreement">
      <!-- Template to convert f:identifier to identificatie -->
      <xsl:call-template name="Identifier-to-identificatie"/>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:medicationReference"
                 mode="mp-AdministrationAgreement">
      <!-- Template to convert f:medicationReference to afgesproken_geneesmiddel -->
      <xsl:variable name="referenceValue"
                    select="f:reference/@value"/>
      <geneesmiddel_bij_toedieningsafspraak>
         <farmaceutisch_product datatype="reference"
                                value="{nf:process-reference-2NCName(f:reference/@value, ancestor::f:entry/f:fullUrl/@value)}"/>
      </geneesmiddel_bij_toedieningsafspraak>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:extension[@url = $extAdministrationAgreementDateTime]"
                 mode="mp-AdministrationAgreement">
      <!-- Template to convert f:extension[@url = $extAdministrationAgreementDateTime] to toedieningsafspraak_datum_tijd -->
      <xsl:for-each select="f:valueDateTime">
         <xsl:call-template name="datetime-to-datetime">
            <xsl:with-param name="adaDatatype">datetime</xsl:with-param>
            <xsl:with-param name="adaElementName">toedieningsafspraak_datum_tijd</xsl:with-param>
         </xsl:call-template>
      </xsl:for-each>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:extension[@url = $urlExtAdministrationAgreementAdditionalInformation]"
                 mode="mp-AdministrationAgreement">
      <!-- Template to convert f:extension[@url = $urlExtAdministrationAgreementAdditionalInformation] to toedieningsafspraak_aanvullende_informatie -->
      <!-- Issue MP-536 dataset concept type change from codelist to string -->
      <xsl:for-each select="f:valueString">
         <toedieningsafspraak_aanvullende_informatie value="{@value}"/>
      </xsl:for-each>
      <!-- support for legacy instances -->
      <xsl:for-each select="f:valueCoding">
         <toedieningsafspraak_aanvullende_informatie>
            <xsl:call-template name="Coding-to-code"/>
         </toedieningsafspraak_aanvullende_informatie>
      </xsl:for-each>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:modifierExtension[@url = $urlExtStoptype]"
                 mode="mp-AdministrationAgreement">
      <!-- Template to convert f:extension[@url = $urlExtStoptype] to stop -->
      <xsl:for-each select="f:valueCodeableConcept">
         <xsl:call-template name="CodeableConcept-to-code">
            <xsl:with-param name="adaElementName">toedieningsafspraak_stop_type</xsl:with-param>
         </xsl:call-template>
      </xsl:for-each>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:status"
                 mode="mp-AdministrationAgreement">
      <!-- Template to convert f:status to geannuleerd_indicator. Only the FHIR status value 'entered-in-error' is used in this mapping. -->
      <xsl:if test="@value = 'entered-in-error'">
         <geannuleerd_indicator value="true"/>
      </xsl:if>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:performer"
                 mode="mp-AdministrationAgreement">
      <!-- Template to convert f:performer to verstrekker -->
      <verstrekker>
         <zorgaanbieder datatype="reference"
                        value="{nf:process-reference-2NCName(f:actor[f:type/@value='Organization']/f:reference/@value, ancestor::f:entry/f:fullUrl/@value)}"/>
      </verstrekker>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:extension[@url = $extAdministrationAgreementAgreementReason]"
                 mode="mp-AdministrationAgreement">
      <!-- Template to convert f:extension[@url=$extAdministrationAgreementAgreementReason] to reden_afspraak -->
      <reden_afspraak value="{f:valueString/@value}"/>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:extension[@url = $extAdministrationAgreementModificationDiscontinuationReason]"
                 mode="mp-AdministrationAgreement">
      <!-- Template to convert f:extension[@url=$extAdministrationAgreementModificationDiscontinuationReason] to toedieningsafspraak_reden_wijzigen_of_staken -->
      <xsl:for-each select="f:valueCodeableConcept">
         <xsl:call-template name="CodeableConcept-to-code">
            <xsl:with-param name="adaElementName">toedieningsafspraak_reden_wijzigen_of_staken</xsl:with-param>
         </xsl:call-template>
      </xsl:for-each>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:extension[@url = $urlExtRelationAdministrationAgreement]"
                 mode="mp-AdministrationAgreement">
      <!-- Template to convert f:authorizingPrescription to relatie_medicatieafspraak -->
      <xsl:for-each select="f:valueReference">
         <relatie_toedieningsafspraak>
            <xsl:call-template name="Reference-to-identificatie"/>
         </relatie_toedieningsafspraak>
      </xsl:for-each>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:authorizingPrescription"
                 mode="mp-AdministrationAgreement">
      <!-- Template to convert f:authorizingPrescription to relatie_medicatieafspraak -->
      <relatie_medicatieafspraak>
         <xsl:call-template name="Reference-to-identificatie"/>
      </relatie_medicatieafspraak>
   </xsl:template>
</xsl:stylesheet>