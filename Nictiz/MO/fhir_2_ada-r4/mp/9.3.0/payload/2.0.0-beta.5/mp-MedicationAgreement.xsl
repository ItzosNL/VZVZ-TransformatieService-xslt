<?xml version="1.0" encoding="UTF-8"?>

<!-- == Provenance: YATC-internal/fhir-2-ada-r4/env/mp/9.3.0/payload/2.0.0-beta.5/mp-MedicationAgreement.xsl == -->
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
   <xsl:template match="f:MedicationRequest"
                 mode="mp-MedicationAgreement">
      <!-- Template to convert f:MedicationRequest to ADA medicatieafspraak -->
      <medicatieafspraak>
         <!-- identificatie -->
         <xsl:apply-templates select=".[f:intent/@value = 'order']/f:identifier"
                              mode="#current"/>
         <!-- registratiedatumtijd -->
         <xsl:apply-templates select="f:extension[@url = $urlExtRegistrationDateTime]"
                              mode="urlExtRegistrationDateTime"/>
         <!-- afspraakdatum -->
         <xsl:apply-templates select=".[f:intent/@value = 'order']/f:authoredOn"
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
               <!-- criterium -->
               <xsl:apply-templates select="f:extension[@url = ($urlExtTimeInterval-Period, $urlExtTimeIntervalPeriod)]/f:valuePeriod/f:extension[@url = $urlExtMedicationAgreementPeriodOfUseCondition]"
                                    mode="urlExtMedicationAgreementPeriodOfUseCondition"/>
            </gebruiksperiode>
         </xsl:if>
         <!-- relatie_contact -->
         <xsl:apply-templates select="f:encounter[f:type/@value eq 'Encounter']"
                              mode="contextContactEpisodeOfCare"/>
         <!-- relatie_zorgepisode -->
         <xsl:apply-templates select="f:extension[@url = $urlExtContextEpisodeOfCare]/f:valueReference"
                              mode="contextContactEpisodeOfCare"/>
         <!-- geannuleerd_indicator niet voor MA -->
         <!--			<xsl:apply-templates select="f:status" mode="#current"/>-->
         <!-- stop_type -->
         <xsl:apply-templates select="f:modifierExtension[@url = $urlExtStoptype]"
                              mode="ext-StopType"/>
         <!-- relatie medicatieafspraak -->
         <xsl:apply-templates select="f:priorPrescription"
                              mode="#current"/>
         <!-- relatie_medicatiegebruik -->
         <xsl:apply-templates select="f:extension[@url = $urlExtMedicationAgreementRelationMedicationUse] | f:basedOn/f:extension[@url = $urlExtMedicationAgreementRelationMedicationUse]"
                              mode="#current"/>
         <!-- voorschrijver -->
         <xsl:apply-templates select=".[f:intent/@value = 'order']/f:requester"
                              mode="#current"/>
         <!-- reden_wijzigen_of_staken -->
         <xsl:apply-templates select="f:reasonCode"
                              mode="#current"/>
         <!-- reden_van_voorschrijven -->
         <xsl:apply-templates select="f:reasonReference"
                              mode="#current"/>
         <!-- afgesproken_geneesmiddel -->
         <xsl:apply-templates select="f:medicationReference"
                              mode="#current"/>
         <!-- gebruiksinstructie -->
         <xsl:call-template name="mp-InstructionsForUse"/>
         <!-- volgende behandelaar -->
         <xsl:apply-templates select="f:extension[@url = $urlExtMedicationAgreementNextPractitioner]"
                              mode="#current"/>
         <!-- aanvullende_informatie -->
         <xsl:apply-templates select="f:extension[@url = $urlExtMedicationAgreementAdditionalInformation]"
                              mode="#current"/>
         <!-- kopie indicator -->
         <xsl:apply-templates select="f:extension[@url = $urlExtCopyIndicator] | f:reportedBoolean"
                              mode="ext-CopyIndicator"/>
         <!-- toelichting -->
         <xsl:apply-templates select="f:note"
                              mode="nl-core-Note"/>
      </medicatieafspraak>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:extension[@url = $urlExtMedicationAgreementAdditionalInformation]"
                 mode="mp-MedicationAgreement">
      <!-- Template to convert f:extension medication-AdditionalInformation to aanvullende_informatie element. -->
      <xsl:param name="adaElementName"
                 tunnel="yes"
                 select="'aanvullende_informatie'">
         <!-- Optional alternative ADA element name. -->
      </xsl:param>
      <xsl:call-template name="CodeableConcept-to-code">
         <xsl:with-param name="in"
                         select="f:valueCodeableConcept"/>
         <xsl:with-param name="adaElementName"
                         select="$adaElementName"/>
      </xsl:call-template>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:extension[@url = $urlExtMedicationAgreementNextPractitioner]"
                 mode="mp-MedicationAgreement">
      <!-- Template to convert f:extension/relatedMedicationUse to aanvullende_informatie element. -->
      <volgende_behandelaar>
         <zorgverlener value="{nf:process-reference-2NCName(f:valueReference/f:reference/@value, ancestor::f:entry/f:fullUrl/@value)}"
                       datatype="reference"/>
      </volgende_behandelaar>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:extension[@url = $urlExtMedicationAgreementRelationMedicationUse]"
                 mode="mp-MedicationAgreement">
      <!-- Template to convert f:extension/relatedMedicationUse to aanvullende_informatie element. -->
      <relatie_medicatiegebruik>
         <identificatie value="{f:valueReference/f:identifier/f:value/@value}"
                        root="{f:valueReference/f:identifier/f:system/replace(@value, 'urn:oid:', '')}"/>
      </relatie_medicatiegebruik>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:modifierExtension[@url = $urlExtStoptype]"
                 mode="mp-MedicationAgreement">
      <!-- Template to resolve f:modifierExtension ext-Medication-stop-type. -->
      <xsl:apply-templates select="f:valueCodeableConcept"
                           mode="#current"/>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:valueCodeableConcept"
                 mode="mp-MedicationAgreement">
      <!-- Template to convert f:valueCodeableConcept to stoptype. -->
      <xsl:call-template name="CodeableConcept-to-code">
         <xsl:with-param name="in"
                         select="."/>
         <xsl:with-param name="adaElementName"
                         select="'medicatieafspraak_stop_type'"/>
      </xsl:call-template>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:priorPrescription"
                 mode="mp-MedicationAgreement">
      <!-- Template to convert f:authorizingPrescription to relatie_medicatieafspraak -->
      <relatie_medicatieafspraak>
         <xsl:call-template name="Reference-to-identificatie"/>
      </relatie_medicatieafspraak>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:identifier"
                 mode="mp-MedicationAgreement">
      <!-- Template to convert f:identifier to identificatie -->
      <xsl:call-template name="Identifier-to-identificatie"/>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:medicationReference"
                 mode="mp-MedicationAgreement">
      <!-- Template to convert f:medicationReference to afgesproken_geneesmiddel -->
      <afgesproken_geneesmiddel>
         <farmaceutisch_product value="{nf:process-reference-2NCName(f:reference/@value,ancestor::f:entry/f:fullUrl/@value)}"
                                datatype="reference"/>
      </afgesproken_geneesmiddel>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:authoredOn"
                 mode="mp-MedicationAgreement">
      <!-- Template to convert f:authoredOn to afspraakdatum -->
      <xsl:call-template name="datetime-to-datetime">
         <xsl:with-param name="adaElementName">medicatieafspraak_datum_tijd</xsl:with-param>
         <xsl:with-param name="adaDatatype">datetime</xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:status"
                 mode="mp-MedicationAgreement">
      <!-- Template to convert f:status to geannuleerd_indicator. Only the FHIR status value 'entered-in-error' is used in this mapping. -->
      <xsl:if test="@value = 'entered-in-error'">
         <geannuleerd_indicator value="true"/>
      </xsl:if>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:requester"
                 mode="mp-MedicationAgreement">
      <!-- Template to convert f:requester to voorschrijver -->
      <voorschrijver>
         <zorgverlener value="{nf:process-reference-2NCName(f:reference/@value, ancestor::f:entry/f:fullUrl/@value)}"
                       datatype="reference"/>
      </voorschrijver>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:reasonCode"
                 mode="mp-MedicationAgreement">
      <!-- Template to convert f:reasonCode to reden_wijzigen_of_staken -->
      <xsl:call-template name="CodeableConcept-to-code">
         <xsl:with-param name="in"
                         select="."/>
         <xsl:with-param name="adaElementName"
                         select="'reden_wijzigen_of_staken'"/>
      </xsl:call-template>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:reasonReference"
                 mode="mp-MedicationAgreement">
      <!-- Template to convert f:reasonReference to reden_van_voorschrijven -->
      <xsl:variable name="resource"
                    select="nf:resolveRefInBundle(.)"/>
      <reden_van_voorschrijven>
         <xsl:apply-templates select="$resource/f:*"
                              mode="nl-core-Problem"/>
      </reden_van_voorschrijven>
   </xsl:template>
</xsl:stylesheet>