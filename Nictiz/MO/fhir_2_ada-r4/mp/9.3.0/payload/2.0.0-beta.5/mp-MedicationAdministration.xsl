<?xml version="1.0" encoding="UTF-8"?>

<!-- == Provenance: YATC-internal/fhir-2-ada-r4/env/mp/9.3.0/payload/2.0.0-beta.5/mp-MedicationAdministration.xsl == -->
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
   <xsl:variable name="urlMpMedicationAdministration"
                 select="concat($urlBaseNictizProfile, 'mp-MedicationAdministration')"/>
   <!-- MP-1392 LR: medicatie_toediening_status nolonger supported from MP 9.3 beta.3 onwards but due to its cardinality in FHIR (1..1) the value 'unknown' will result in medicatie_toediening_status being absent in ada -->
   <!-- MP-1408 LR: afgesproken_datum_tijd no longer part of the transactions from MP 9.3 beta.3 onwards but kept in stylesheet due to backwards compatibility-->
   <!-- ================================================================== -->
   <xsl:template match="f:MedicationAdministration"
                 mode="mp-MedicationAdministration">
      <!-- Template to convert f:MedicationAdministration to ADA medicatietoediening -->
      <medicatietoediening>
         <!-- identificatie -->
         <xsl:apply-templates select="f:identifier"
                              mode="#current"/>
         <!-- toedienings_product -->
         <xsl:apply-templates select="f:medicationReference"
                              mode="#current"/>
         <!-- registratiedatumtijd -->
         <xsl:apply-templates select="f:extension[@url = $urlExtRegistrationDateTime]"
                              mode="urlExtRegistrationDateTime"/>
         <!-- toedienings_datum_tijd -->
         <xsl:apply-templates select="f:effectiveDateTime"
                              mode="#current"/>
         <!-- afgesproken_datum_tijd -->
         <!-- MP-1408 LR: afgesproken_datum_tijd no longer part of the transactions from MP 9.3 beta.3 onwards but kept in stylesheet due to backwards compatibility-->
         <xsl:apply-templates select="f:extension[@url = $urlExtMedicationAdministration2AgreedDateTime]"
                              mode="#current"/>
         <!-- geannuleerd_indicator -->
         <xsl:if test="f:status/@value = 'entered-in-error'">
            <geannuleerd_indicator value="true"/>
         </xsl:if>
         <!-- toegediende_hoeveelheid -->
         <xsl:apply-templates select="f:dosage/f:dose"
                              mode="#current"/>
         <!-- volgens_afspraak_indicator -->
         <!-- TODO: should be updated in FHIR profile -->
         <xsl:apply-templates select="f:extension[@url = $urlExtAsAgreedIndicator]"
                              mode="#current"/>
         <!-- toedieningsweg -->
         <xsl:apply-templates select="f:dosage/f:route"
                              mode="mp-InstructionsForUse"/>
         <!-- toedieningssnelheid -->
         <xsl:apply-templates select="f:dosage/f:rateQuantity"
                              mode="#current"/>
         <!-- prik_plak_locatie -->
         <xsl:apply-templates select="f:extension[@url = $urlExtMedicationAdministration2InjectionPatchSite]"
                              mode="#current"/>
         <!-- prik_plak_locatie legacy -->
         <xsl:if test="not(f:extension[@url = $urlExtMedicationAdministration2InjectionPatchSite])">
            <xsl:apply-templates select="f:dosage/f:site/f:text"
                                 mode="#current"/>
         </xsl:if>
         <!-- relatie medicatieafspraak -->
         <xsl:apply-templates select="f:request"
                              mode="#current">
            <xsl:with-param name="outputMaOrWds">ma</xsl:with-param>
         </xsl:apply-templates>
         <!-- relatie_toedieningsafspraak -->
         <xsl:apply-templates select="f:supportingInformation"
                              mode="#current"/>
         <!-- relatie_wisselend_doseerschema -->
         <xsl:apply-templates select="f:request"
                              mode="#current">
            <xsl:with-param name="outputMaOrWds">wds</xsl:with-param>
         </xsl:apply-templates>
         <!-- relatie_contact of relatie_zorgepisode -->
         <xsl:apply-templates select="f:context[f:reference | f:identifier]"
                              mode="contextContactEpisodeOfCare"/>
         <!-- toediener -->
         <xsl:apply-templates select="f:performer"
                              mode="#current"/>
         <!-- medicatietoediening_reden_van_afwijken -->
         <xsl:apply-templates select="f:extension[@url = $urlExtMedicationAdministration2ReasonForDeviation]"
                              mode="#current"/>
         <!-- medicatie_toediening_status  -->
         <!-- MP-1392 LR: medicatie_toediening_status no longer part of the transactions from MP 9.3 beta.3 onwards but kept in stylesheet due to backwards compatibility -->
         <xsl:apply-templates select="f:status[@value ne 'entered-in-error']"
                              mode="#current"/>
         <!-- toelichting -->
         <xsl:apply-templates select="f:note"
                              mode="nl-core-Note"/>
      </medicatietoediening>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:extension[@url = $urlExtAsAgreedIndicator]"
                 mode="mp-MedicationAdministration">
      <!-- Template to convert f:extension $urlExtAsAgreedIndicator to volgens_afspraak_indicator element. -->
      <volgens_afspraak_indicator>
         <xsl:call-template name="boolean-to-boolean">
            <xsl:with-param name="in"
                            select="f:valueBoolean"/>
         </xsl:call-template>
      </volgens_afspraak_indicator>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:extension[@url = $urlExtMedicationAdministration2InjectionPatchSite]"
                 mode="mp-MedicationAdministration">
      <!-- Template to convert f:extension injection patch site to prik_plak_locatie element. -->
      <prik_plak_locatie>
         <anatomische_locatie>
            <xsl:call-template name="CodeableConcept-to-code">
               <xsl:with-param name="in"
                               select="f:valueCodeableConcept"/>
               <xsl:with-param name="adaElementName">locatie</xsl:with-param>
               <xsl:with-param name="originalText"
                               select="f:valueCodeableConcept/f:text/@value"/>
            </xsl:call-template>
            <xsl:for-each select="f:valueCodeableConcept/f:extension[@url = $urlExtAnatomicalLocationLaterality]">
               <xsl:call-template name="CodeableConcept-to-code">
                  <xsl:with-param name="in"
                                  select="f:valueCodeableConcept"/>
                  <xsl:with-param name="adaElementName">lateraliteit</xsl:with-param>
                  <xsl:with-param name="originalText"
                                  select="f:valueCodeableConcept/f:text/@value"/>
               </xsl:call-template>
            </xsl:for-each>
         </anatomische_locatie>
      </prik_plak_locatie>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:extension[@url = $urlExtMedicationAdministration2ReasonForDeviation]"
                 mode="mp-MedicationAdministration">
      <!-- Template to convert f:extension reason for deviation to medicatie_toediening_reden_van_afwijken element. -->
      <xsl:call-template name="CodeableConcept-to-code">
         <xsl:with-param name="in"
                         select="f:valueCodeableConcept"/>
         <xsl:with-param name="adaElementName">medicatietoediening_reden_van_afwijken</xsl:with-param>
         <xsl:with-param name="originalText"
                         select="f:valueCodeableConcept/f:text/@value"/>
      </xsl:call-template>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:identifier"
                 mode="mp-MedicationAdministration">
      <!-- Template to convert f:identifier to identificatie -->
      <xsl:call-template name="Identifier-to-identificatie"/>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:medicationReference"
                 mode="mp-MedicationAdministration">
      <!-- Template to convert f:medicationReference to afgesproken_geneesmiddel -->
      <xsl:variable name="referenceValue"
                    select="f:reference/@value"/>
      <toedienings_product>
         <farmaceutisch_product value="{nf:process-reference-2NCName(f:reference/@value, ancestor::f:entry/f:fullUrl/@value)}"
                                datatype="reference"/>
      </toedienings_product>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:dosage/f:dose"
                 mode="mp-MedicationAdministration">
      <!-- Template to convert f:dosage/f:dose to toegediende_hoeveelheid aantal and eenheid element. -->
      <toegediende_hoeveelheid>
         <xsl:call-template name="GstdQuantity2ada"/>
      </toegediende_hoeveelheid>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:dosage/f:site/f:text"
                 mode="mp-MedicationAdministration">
      <!-- Template to convert f:dosage/f:site/f:text to prik_plak_locatie -->
      <prik_plak_locatie value="{@value}"/>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:effectiveDateTime"
                 mode="mp-MedicationAdministration">
      <!-- Template to convert f:effectiveDateTime to toedienings_datum_tijd -->
      <xsl:call-template name="datetime-to-datetime">
         <xsl:with-param name="adaElementName">toedienings_datum_tijd</xsl:with-param>
         <xsl:with-param name="adaDatatype">datetime</xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:status"
                 mode="mp-MedicationAdministration">
      <!-- Template to convert f:status to geannuleerd_indicator. Only the FHIR status value 'entered-in-error' is used in this mapping. -->
      <xsl:choose>
         <xsl:when test="@value = 'entered-in-error'">
            <geannuleerd_indicator value="true"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:variable name="mapMtdStatus"
                          as="element()*">
               <map inValue="in-progress"
                    code="active"
                    codeSystem="{$oidHL7ActStatus}"
                    codeSystemName="{$oidMap[@oid=$oidHL7ActStatus]/@displayName}"
                    displayName="{$hl7ActStatusMap[@hl7Code='active']/@displayName}"/>
               <map inValue="on-hold"
                    code="suspended"
                    codeSystem="{$oidHL7ActStatus}"
                    codeSystemName="{$oidMap[@oid=$oidHL7ActStatus]/@displayName}"
                    displayName="{$hl7ActStatusMap[@hl7Code='suspended']/@displayName}"/>
               <map inValue="stopped"
                    code="aborted"
                    codeSystem="{$oidHL7ActStatus}"
                    codeSystemName="{$oidMap[@oid=$oidHL7ActStatus]/@displayName}"
                    displayName="{$hl7ActStatusMap[@hl7Code='aborted']/@displayName}"/>
               <map inValue="completed"
                    code="completed"
                    codeSystem="{$oidHL7ActStatus}"
                    codeSystemName="{$oidMap[@oid=$oidHL7ActStatus]/@displayName}"
                    displayName="{$hl7ActStatusMap[@hl7Code='completed']/@displayName}"/>
               <map inValue="not-done"
                    code="cancelled"
                    codeSystem="{$oidHL7ActStatus}"
                    codeSystemName="{$oidMap[@oid=$oidHL7ActStatus]/@displayName}"
                    displayName="{$hl7ActStatusMap[@hl7Code='cancelled']/@displayName}"/>
            </xsl:variable>
            <xsl:if test="@value = $mapMtdStatus/@inValue">
               <medicatie_toediening_status>
                  <xsl:call-template name="fhircode-to-adacode">
                     <xsl:with-param name="value"
                                     select="@value"/>
                     <xsl:with-param name="codeMap"
                                     as="element()*"
                                     select="$mapMtdStatus"/>
                  </xsl:call-template>
               </medicatie_toediening_status>
            </xsl:if>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:performer"
                 mode="mp-MedicationAdministration">
      <!-- Template to convert f:performer to toediener -->
      <toediener>
         <xsl:for-each select="f:actor">
            <xsl:variable name="resource"
                          select="nf:resolveRefInBundle(.)"/>
            <xsl:choose>
               <xsl:when test="f:type/@value = 'Patient' or $resource[f:Patient]">
                  <patient>
                     <toediener_is_patient value="true"/>
                  </patient>
               </xsl:when>
               <xsl:when test="$resource[f:PractitionerRole[not(f:practitioner | f:specialty)]]">
                  <!-- pre MP9 3.0 beta3 it was possible to convey zorgaanbieder -->
                  <zorgaanbieder>
                     <zorgaanbieder value="{nf:process-reference-2NCName(($resource/f:PractitionerRole/(f:organization|f:location)[f:reference])[1]/f:reference/@value, ancestor::f:entry/f:fullUrl/@value)}"
                                    datatype="reference"/>
                  </zorgaanbieder>
               </xsl:when>
               <xsl:when test="f:type/@value = ('RelatedPerson') or $resource[f:RelatedPerson]">
                  <mantelzorger>
                     <contactpersoon value="{nf:process-reference-2NCName(f:reference/@value, ancestor::f:entry/f:fullUrl/@value)}"
                                     datatype="reference"/>
                  </mantelzorger>
               </xsl:when>
               <!-- From version MP9 3.0 beta3, performer is mapped to zorgverlener -->
               <xsl:when test="f:type/@value = ('Practitioner') or $resource[f:Practitioner | f:PractitionerRole[f:practitioner | f:specialty]]">
                  <zorgverlener>
                     <zorgverlener value="{nf:process-reference-2NCName(f:reference/@value, ancestor::f:entry/f:fullUrl/@value)}"
                                   datatype="reference"/>
                  </zorgverlener>
               </xsl:when>
            </xsl:choose>
         </xsl:for-each>
      </toediener>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:rateQuantity"
                 mode="mp-MedicationAdministration">
      <!-- Template to convert f:rateQuantity to toedieningssnelheid -->
      <toedieningssnelheid>
         <xsl:apply-templates select="."
                              mode="mp-InstructionsForUse"/>
      </toedieningssnelheid>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:request"
                 mode="mp-MedicationAdministration">
      <!-- Template to convert f:request to relatie_medicatieafspraak or relatie_wisselend_doseerschema. Due to sequence in dataset we output one based on param -->
      <xsl:param name="outputMaOrWds"
                 as="xs:string"
                 select="'ma'">
         <!-- Whether to output relatie_medicatieafspraak ('ma') or relatie_wisselend_doseerschema ('wds'). Defaults to 'ma' -->
      </xsl:param>
      <xsl:variable name="resourceCategory"
                    select="f:extension[@url = $urlExtResourceCategory]/f:valueCodeableConcept/f:coding[f:system/@value = $oidMap[@oid = $oidSNOMEDCT]/@uri]/f:code/@value"/>
      <xsl:choose>
         <xsl:when test="$outputMaOrWds = 'ma' and $resourceCategory = $maCode">
            <relatie_medicatieafspraak>
               <xsl:call-template name="Reference-to-identificatie"/>
            </relatie_medicatieafspraak>
         </xsl:when>
         <xsl:when test="$outputMaOrWds = 'wds' and $resourceCategory = $wdsCode">
            <relatie_wisselend_doseerschema>
               <xsl:call-template name="Reference-to-identificatie"/>
            </relatie_wisselend_doseerschema>
         </xsl:when>
         <xsl:when test="$outputMaOrWds = 'ma' and empty($resourceCategory)">
            <!-- default to MA -->
            <relatie_medicatieafspraak>
               <xsl:call-template name="Reference-to-identificatie"/>
            </relatie_medicatieafspraak>
         </xsl:when>
         <xsl:when test="$outputMaOrWds = 'ma' and $resourceCategory = $wdsCode"/>
         <xsl:when test="$outputMaOrWds = 'wds' and $resourceCategory = $maCode"/>
         <xsl:otherwise>
            <xsl:call-template name="util:logMessage">
               <xsl:with-param name="level"
                               select="$logWARN"/>
               <xsl:with-param name="msg">Encountered a medicationAdministration.request that could not be mapped to an ada element. Please investigate.</xsl:with-param>
               <xsl:with-param name="terminate"
                               select="false()"/>
            </xsl:call-template>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:supportingInformation"
                 mode="mp-MedicationAdministration">
      <!-- Template to convert f:supportingInformation to relatie_toedieningsafspraak -->
      <relatie_toedieningsafspraak>
         <xsl:call-template name="Reference-to-identificatie"/>
      </relatie_toedieningsafspraak>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:extension[@url = $urlExtMedicationAdministration2AgreedDateTime]"
                 mode="mp-MedicationAdministration">
      <!-- Template to convert f:extension with extension url "$extMedicationAdministration2AgreedDateTime" to afgesproken_datum_tijd -->
      <xsl:for-each select="f:valueDateTime">
         <xsl:call-template name="datetime-to-datetime">
            <xsl:with-param name="adaElementName">afgesproken_datum_tijd</xsl:with-param>
            <xsl:with-param name="adaDatatype">datetime</xsl:with-param>
         </xsl:call-template>
      </xsl:for-each>
   </xsl:template>
</xsl:stylesheet>