<?xml version="1.0" encoding="UTF-8"?>

<!-- == Provenance: YATC-internal/fhir-2-ada-r4/env/mp/9.3.0/payload/2.0.0-beta.5/mp-MedicationUse2.xsl == -->
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
   <xsl:template match="f:MedicationStatement"
                 mode="mp-MedicationUse2">
      <!-- Template to convert f:MedicationStatement to ADA medicatie_gebruik -->
      <medicatiegebruik>
         <!-- identificatie  -->
         <xsl:apply-templates select="f:identifier"
                              mode="#current"/>
         <!-- medicatiegebruik_datum_tijd -->
         <xsl:apply-templates select="f:dateAsserted"
                              mode="#current"/>
         <!-- gebruik_indicator -->
         <xsl:apply-templates select="f:status"
                              mode="#current"/>
         <!-- volgens_afspraak_indicator -->
         <xsl:apply-templates select="f:extension[@url = $urlExtAsAgreedIndicator]"
                              mode="#current"/>
         <!-- stoptype -->
         <xsl:choose>
            <xsl:when test="f:modifierExtension[@url = $urlExtStoptype]/f:valueCodeableConcept">
               <!-- do not use the nl-core stoptype, outputs a wrongly named ada element, since the IA's chose to update the dataset name in MP9 3.0 -->
               <xsl:apply-templates select="f:modifierExtension[@url = $urlExtStoptype]/f:valueCodeableConcept"
                                    mode="#current"/>
            </xsl:when>
            <xsl:otherwise>
               <!-- fall back on status, maybe it is on-hold or stopped -->
               <xsl:apply-templates select="f:status"
                                    mode="mp-MedUseStopType"/>
            </xsl:otherwise>
         </xsl:choose>
         <!-- gebruiksperiode -->
         <xsl:apply-templates select="f:effectivePeriod"
                              mode="#current"/>
         <!-- gebruiks_product -->
         <xsl:apply-templates select="f:medicationReference"
                              mode="#current"/>
         <!-- gebruiksinstructie -->
         <xsl:call-template name="mp-InstructionsForUse"/>
         <!-- relatie_medicatieafspraak, toedieningsafspraak, medicatieverstrekking -->
         <xsl:apply-templates select="f:derivedFrom"
                              mode="#current"/>
         <!-- relatie_contact en zorgepisode -->
         <xsl:apply-templates select="f:context"
                              mode="contextContactEpisodeOfCare"/>
         <!-- voorschrijver -->
         <xsl:apply-templates select="f:extension[@url = $urlExtMedicationUse2Prescriber]"
                              mode="#current"/>
         <!-- informant -->
         <xsl:apply-templates select="f:informationSource"
                              mode="#current"/>
         <!-- auteur -->
         <xsl:apply-templates select="f:extension[@url = $urlExtMedicationUseAuthor]"
                              mode="#current"/>
         <!-- reden_gebruik -->
         <xsl:apply-templates select="f:reasonCode"
                              mode="#current"/>
         <!-- reden_wijzigen_of_stoppen_gebruik -->
         <xsl:apply-templates select="f:statusReason"
                              mode="#current"/>
         <!-- kopie_indicator -->
         <xsl:apply-templates select="f:extension[@url = $urlExtCopyIndicator]"
                              mode="ext-CopyIndicator"/>
         <!-- toelichting -->
         <xsl:apply-templates select="f:note"
                              mode="#current"/>
      </medicatiegebruik>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:identifier"
                 mode="mp-MedicationUse2">
      <!-- Template to convert f:identifier to identificatie -->
      <xsl:call-template name="Identifier-to-identificatie"/>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:effectivePeriod"
                 mode="mp-MedicationUse2">
      <!-- Template to convert f:effectivePeriod to gebruiksperiode -->
      <gebruiksperiode>
         <xsl:apply-templates select="f:start"
                              mode="#current"/>
         <xsl:apply-templates select="f:end"
                              mode="#current"/>
         <xsl:apply-templates select="(. | parent::f:MedicationStatement)/f:extension[@url eq $urlExtTimeIntervalDuration]"
                              mode="mp-MedicationUse2"/>
      </gebruiksperiode>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:extension[@url eq $urlExtTimeIntervalDuration]"
                 mode="mp-MedicationUse2">
      <!-- Template to convert urlExtTimeInterval-Duration to tijds_duur -->
      <xsl:variable name="code-value"
                    select="f:valueDuration/f:code/@value"/>
      <tijds_duur value="{f:valueDuration/f:value/@value}"
                  unit="{nf:convertTime_UCUM_FHIR2ADA_unit($code-value)}"/>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:start"
                 mode="mp-MedicationUse2">
      <!-- Template to convert f:start to gebruiksperiode_start -->
      <xsl:call-template name="datetime-to-datetime">
         <xsl:with-param name="adaElementName">start_datum_tijd</xsl:with-param>
         <xsl:with-param name="adaDatatype">datetime</xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:end"
                 mode="mp-MedicationUse2">
      <!-- Template to convert f:end to gebruiksperiode_eind -->
      <xsl:call-template name="datetime-to-datetime">
         <xsl:with-param name="adaElementName">eind_datum_tijd</xsl:with-param>
         <xsl:with-param name="adaDatatype">datetime</xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:dateAsserted"
                 mode="mp-MedicationUse2">
      <!-- Template to convert f:dateAsserted to registratiedatum -->
      <xsl:call-template name="datetime-to-datetime">
         <xsl:with-param name="adaElementName">medicatiegebruik_datum_tijd</xsl:with-param>
         <xsl:with-param name="adaDatatype">datetime</xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:status"
                 mode="mp-MedicationUse2">
      <!--  Template to convert f:status to stoptype. 
            Only the FHIR status values that map to a ADA stoptype value are mapped. 
            Template to convert f:status to gebruik_indicator Note: the values below are not fully implemented in the xml schema. 
            See MedicationStatement.status documentation. not-taken > false on-hold > false stopped > false completed > false active > true unknown > unknown (invalid ADA)  -->
      <xsl:choose>
         <xsl:when test="@value eq 'on-hold'">
            <gebruik_indicator>
               <xsl:attribute name="value"
                              select="'false'"/>
            </gebruik_indicator>
         </xsl:when>
         <xsl:when test="@value eq 'stopped'">
            <gebruik_indicator>
               <xsl:attribute name="value"
                              select="'false'"/>
            </gebruik_indicator>
         </xsl:when>
         <xsl:when test="                     some $val in ('not-taken', 'completed')                         satisfies $val eq string(./@value)">
            <gebruik_indicator>
               <xsl:attribute name="value"
                              select="'false'"/>
            </gebruik_indicator>
         </xsl:when>
         <xsl:when test="@value = 'active'">
            <gebruik_indicator>
               <xsl:attribute name="value"
                              select="'true'"/>
            </gebruik_indicator>
         </xsl:when>
         <xsl:otherwise>
            <xsl:comment select="concat('unhandled FHIR value: ', @value)"/>
            <xsl:call-template name="util:logMessage">
               <xsl:with-param name="level"
                               select="$logERROR"/>
               <xsl:with-param name="msg">
                  <xsl:value-of select="./local-name()"/>
                  <xsl:text> with @value '</xsl:text>
                  <xsl:value-of select="@value"/>
                  <xsl:text>'is an unhandled FHIR value</xsl:text>
               </xsl:with-param>
            </xsl:call-template>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:status"
                 mode="mp-MedUseStopType">
      <!--  Template to convert f:status to stoptype when the modifierExtension for stoptype is not present. 
            It uses the stoptypeMap-mapping for version 930 and is done for only two status: on-hold > onderbroken stopped > stopgezet  -->
      <xsl:choose>
         <xsl:when test="@value eq 'on-hold'">
            <medicatiegebruik_stop_type code="{$stoptypeMap[@stoptype = 'onderbroken' and @version='930']/@code}"
                                        codeSystem="{$stoptypeMap[@stoptype = 'onderbroken' and @version='930']/@codeSystem}"
                                        displayName="{$stoptypeMap[@stoptype = 'onderbroken' and @version='930']/@displayName}"/>
         </xsl:when>
         <xsl:when test="@value eq 'stopped'">
            <medicatiegebruik_stop_type code="{$stoptypeMap[@stoptype = 'stopgezet' and @version='930']/@code}"
                                        codeSystem="{$stoptypeMap[@stoptype = 'stopgezet' and @version='930']/@codeSystem}"
                                        displayName="{$stoptypeMap[@stoptype = 'stopgezet' and @version='930']/@displayName}"
                                        version="{$stoptypeMap[@stoptype = 'stopgezet' and @version='930']/@version}"/>
         </xsl:when>
      </xsl:choose>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:statusReason"
                 mode="mp-MedicationUse2">
      <!--  Template to convert f:statusReason to reden_wijzigen_of_stoppen_gebruik.  -->
      <reden_wijzigen_of_stoppen_gebruik code="{f:coding/f:code/@value}"
                                         codeSystem="2.16.840.1.113883.6.96"
                                         displayName="{f:coding/f:display/@value}"/>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:valueCodeableConcept"
                 mode="mp-MedicationUse2">
      <!-- Template to convert f:valueCodeableConcept to stoptype. -->
      <xsl:call-template name="CodeableConcept-to-code">
         <xsl:with-param name="in"
                         select="."/>
         <xsl:with-param name="adaElementName">medicatiegebruik_stop_type</xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:medicationReference"
                 mode="mp-MedicationUse2">
      <!-- Template to convert f:medicationReference to gebruiks_product -->
      <gebruiksproduct>
         <farmaceutisch_product value="{nf:process-reference-2NCName(f:reference/@value,ancestor::f:entry/f:fullUrl/@value)}"
                                datatype="reference"/>
      </gebruiksproduct>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:informationSource"
                 mode="mp-MedicationUse2">
      <!-- Template to convert f:informationSource to informant -->
      <xsl:variable name="referenceValue"
                    select="nf:process-reference(f:reference/@value, ancestor::f:entry/f:fullUrl/@value)"/>
      <xsl:variable name="referenceValuePractitionerRole"
                    select="f:extension/f:valueReference/f:reference/@value"/>
      <xsl:variable name="resource"
                    select="(ancestor::f:Bundle/f:entry[f:fullUrl/@value = $referenceValue]/f:resource/f:*)[1]"/>
      <informant>
         <xsl:choose>
            <xsl:when test="ancestor::f:Bundle/f:entry[f:fullUrl/@value = $referenceValue]/f:resource/f:Patient">
               <informant_is_patient>
                  <xsl:attribute name="value"
                                 select="'true'"/>
               </informant_is_patient>
            </xsl:when>
            <xsl:when test="$resource/local-name() = 'Practitioner'">
               <informant_is_zorgverlener>
                  <zorgverlener datatype="reference"
                                value="{nf:convert2NCName(f:reference/@value)}"/>
               </informant_is_zorgverlener>
            </xsl:when>
            <xsl:when test="$resource/local-name() = 'PractitionerRole'">
               <informant_is_zorgverlener>
                  <xsl:variable name="practitionerRole"
                                select="string(f:reference/@value)"/>
                  <zorgverlener datatype="reference"
                                value="{nf:convert2NCName($practitionerRole)}"/>
               </informant_is_zorgverlener>
            </xsl:when>
            <xsl:when test="$resource/local-name() = 'RelatedPerson'">
               <persoon>
                  <contactpersoon datatype="reference"
                                  value="{nf:convert2NCName(f:reference/@value)}"/>
               </persoon>
            </xsl:when>
         </xsl:choose>
      </informant>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:derivedFrom"
                 mode="mp-MedicationUse2">
      <!-- Template to convert f:derivedFrom 
            Try to resolve reference within Bundle using nf:resolveRefInBundle and 
            first use the resolved reference to determine the type of reference
            then try to use the reference.identifier based on identifier.type and/or the extension for the category 
            finally we may have to assume a type of reference, which we think is better than to delete whatever was in derivedFrom/identifier -->
      <xsl:variable name="resolvedResource"
                    select="nf:resolveRefInBundle(.)"/>
      <xsl:choose>
         <xsl:when test="$resolvedResource[f:MedicationRequest[f:identifier][f:category/f:coding/f:code/@value = $maCode]]">
            <!-- MA -->
            <relatie_medicatieafspraak>
               <xsl:call-template name="Identifier-to-identificatie">
                  <xsl:with-param name="in"
                                  select="($resolvedResource/f:MedicationRequest/f:identifier)[1]"/>
                  <xsl:with-param name="adaElementName">identificatie</xsl:with-param>
               </xsl:call-template>
            </relatie_medicatieafspraak>
         </xsl:when>
         <xsl:when test="$resolvedResource[f:MedicationDispense[f:identifier][f:category/f:coding/f:code/@value = $taCode]]">
            <!-- TA -->
            <relatie_toedieningsafspraak>
               <xsl:call-template name="Identifier-to-identificatie">
                  <xsl:with-param name="in"
                                  select="($resolvedResource/f:MedicationDispense/f:identifier)[1]"/>
                  <xsl:with-param name="adaElementName">identificatie</xsl:with-param>
               </xsl:call-template>
            </relatie_toedieningsafspraak>
         </xsl:when>
         <xsl:when test="$resolvedResource[f:MedicationDispense[f:identifier][f:category/f:coding/f:code/@value = $mveCode]]">
            <!-- MVE -->
            <relatie_medicatieverstrekking>
               <xsl:call-template name="Identifier-to-identificatie">
                  <xsl:with-param name="in"
                                  select="($resolvedResource/f:MedicationDispense/f:identifier)[1]"/>
                  <xsl:with-param name="adaElementName">identificatie</xsl:with-param>
               </xsl:call-template>
            </relatie_medicatieverstrekking>
         </xsl:when>
         <xsl:when test="(f:identifier and (f:type/@value = 'MedicationRequest' or f:extension/f:valueCodeableConcept/f:coding/f:code/@value = $maCode)) or $resolvedResource[f:MedicationRequest/f:identifier]">
            <relatie_medicatieafspraak>
               <xsl:call-template name="Identifier-to-identificatie">
                  <xsl:with-param name="in"
                                  select="(f:identifier | $resolvedResource/f:MedicationRequest/f:identifier)[1]"/>
                  <xsl:with-param name="adaElementName">identificatie</xsl:with-param>
               </xsl:call-template>
            </relatie_medicatieafspraak>
         </xsl:when>
         <xsl:when test="(f:identifier and f:extension/f:valueCodeableConcept/f:coding/f:code/@value = $taCode)">
            <relatie_toedieningsafspraak>
               <xsl:call-template name="Identifier-to-identificatie">
                  <xsl:with-param name="in"
                                  select="(f:identifier | $resolvedResource/f:MedicationDispense/f:identifier)[1]"/>
                  <xsl:with-param name="adaElementName">identificatie</xsl:with-param>
               </xsl:call-template>
            </relatie_toedieningsafspraak>
         </xsl:when>
         <xsl:when test="(f:identifier and f:extension/f:valueCodeableConcept/f:coding/f:code/@value = $mveCode)">
            <relatie_medicatieverstrekking>
               <xsl:call-template name="Identifier-to-identificatie">
                  <xsl:with-param name="in"
                                  select="(f:identifier | $resolvedResource/f:MedicationDispense/f:identifier)[1]"/>
                  <xsl:with-param name="adaElementName">identificatie</xsl:with-param>
               </xsl:call-template>
            </relatie_medicatieverstrekking>
         </xsl:when>
         <xsl:when test="(f:identifier and f:type/@value = 'MedicationDispense') or $resolvedResource[f:MedicationDispense/f:identifier]">
            <!-- we don't know if this is a TA or a MVE, let's find out using the extension -->
            <xsl:choose>
               <xsl:when test="f:extension/f:valueCodeableConcept/f:coding/f:code/@value = $taCode">
                  <relatie_toedieningsafspraak>
                     <xsl:call-template name="Identifier-to-identificatie">
                        <xsl:with-param name="in"
                                        select="(f:identifier | $resolvedResource/f:MedicationDispense/f:identifier)[1]"/>
                        <xsl:with-param name="adaElementName">identificatie</xsl:with-param>
                     </xsl:call-template>
                  </relatie_toedieningsafspraak>
               </xsl:when>
               <xsl:when test="f:extension/f:valueCodeableConcept/f:coding/f:code/@value = $mveCode">
                  <relatie_medicatieverstrekking>
                     <xsl:call-template name="Identifier-to-identificatie">
                        <xsl:with-param name="in"
                                        select="(f:identifier | $resolvedResource/f:MedicationDispense/f:identifier)[1]"/>
                        <xsl:with-param name="adaElementName">identificatie</xsl:with-param>
                     </xsl:call-template>
                  </relatie_medicatieverstrekking>
               </xsl:when>
               <xsl:otherwise>
                  <!-- assume TA, but we don't like this -->
                  <xsl:variable name="message"
                                as="xs:string*">
                     <xsl:value-of select="ancestor::f:resource/f:*/local-name()"/>
                     <xsl:text> with fullUrl '</xsl:text>
                     <xsl:value-of select="ancestor::f:resource/preceding-sibling::f:fullUrl/@value"/>
                     <xsl:text>' has a derivedFrom. We could not determine if the reference was to administration agreement or medication dispense, we have assumed administration agreement (relatie_toedieningsafspraak), that assumption may not be correct. Please investigate: maybe the extension stating the resourceCategory is missing.</xsl:text>
                  </xsl:variable>
                  <xsl:comment>
                     <xsl:value-of select="$message"/>
                  </xsl:comment>
                  <relatie_toedieningsafspraak>
                     <xsl:call-template name="Identifier-to-identificatie">
                        <xsl:with-param name="in"
                                        select="(f:identifier | $resolvedResource/f:MedicationDispense/f:identifier)[1]"/>
                        <xsl:with-param name="adaElementName">identificatie</xsl:with-param>
                     </xsl:call-template>
                  </relatie_toedieningsafspraak>
                  <xsl:call-template name="util:logMessage">
                     <xsl:with-param name="level"
                                     select="$logERROR"/>
                     <xsl:with-param name="msg"
                                     select="$message"/>
                  </xsl:call-template>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:when test="f:identifier">
            <!-- assume MA, but we don't like this -->
            <xsl:variable name="message"
                          as="xs:string*">
               <xsl:value-of select="ancestor::f:resource/f:*/local-name()"/>
               <xsl:text> with fullUrl '</xsl:text>
               <xsl:value-of select="ancestor::f:resource/preceding-sibling::f:fullUrl/@value"/>
               <xsl:text>' has a derivedFrom. The derivedFrom reference cannot be resolved within the Bundle nor can the type of reference be determined. We have however assumed a medication agreement (relatie_medicatieafspraak), that assumption may not be correct.</xsl:text>
            </xsl:variable>
            <xsl:comment>
               <xsl:value-of select="$message"/>
            </xsl:comment>
            <relatie_medicatieafspraak>
               <xsl:call-template name="Identifier-to-identificatie">
                  <xsl:with-param name="in"
                                  select="f:identifier"/>
                  <xsl:with-param name="adaElementName">identificatie</xsl:with-param>
               </xsl:call-template>
            </relatie_medicatieafspraak>
            <xsl:call-template name="util:logMessage">
               <xsl:with-param name="level"
                               select="$logERROR"/>
               <xsl:with-param name="msg">
                  <xsl:value-of select="$message"/>
                  <xsl:text> derivedFrom identifier system: '</xsl:text>
                  <xsl:value-of select="f:identifier/f:system/@value"/>
                  <xsl:text>' and value '</xsl:text>
                  <xsl:value-of select="f:identifier/f:value/@value"/>
                  <xsl:text>'.</xsl:text>
               </xsl:with-param>
            </xsl:call-template>
         </xsl:when>
         <xsl:otherwise>
            <xsl:call-template name="util:logMessage">
               <xsl:with-param name="level"
                               select="$logERROR"/>
               <xsl:with-param name="msg">
                  <xsl:value-of select="ancestor::f:resource/f:*/local-name()"/>
                  <xsl:text> with fullUrl '</xsl:text>
                  <xsl:value-of select="ancestor::f:resource/preceding-sibling::f:fullUrl/@value"/>
                  <xsl:text>' has a derivedFrom. The derivedFrom reference cannot be resolved within the Bundle nor can the type of reference be determined. Therefore information (potentially the relation to medication agreeement, administration agreement or medication dispense) will be lost.</xsl:text>
               </xsl:with-param>
            </xsl:call-template>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:extension[@url = $urlExtMedicationUseAuthor]"
                 mode="mp-MedicationUse2">
      <!-- Template to convert f:extension with extension url ext-MedicationUse.Author to auteur -->
      <xsl:variable name="referenceValue"
                    select="nf:process-reference(f:valueReference/f:reference/@value, ancestor::f:entry/f:fullUrl/@value)"
                    as="xs:string"/>
      <xsl:variable name="resource"
                    select="(ancestor::f:Bundle/f:entry[f:fullUrl/@value = $referenceValue]/f:resource/f:*)[1]"/>
      <auteur>
         <xsl:choose>
            <xsl:when test="$resource/local-name() = 'Patient'">
               <auteur_is_patient>
                  <xsl:attribute name="value"
                                 select="'true'"/>
               </auteur_is_patient>
            </xsl:when>
            <xsl:when test="$resource/local-name() = ('PractitionerRole', 'Practitioner')">
               <auteur_is_zorgverlener>
                  <zorgverlener value="{nf:process-reference-2NCName(f:valueReference/f:reference/@value,ancestor::f:entry/f:fullUrl/@value)}"
                                datatype="reference"/>
               </auteur_is_zorgverlener>
            </xsl:when>
            <xsl:when test="$resource/local-name() = ('Organization', 'Location')">
               <auteur_is_zorgaanbieder>
                  <zorgaanbieder value="{nf:process-reference-2NCName(f:valueReference/f:reference/@value,ancestor::f:entry/f:fullUrl/@value)}"
                                 datatype="reference"/>
               </auteur_is_zorgaanbieder>
            </xsl:when>
            <!-- LR: added errormessage for empty $resource -->
            <xsl:when test="not($resource)">
               <xsl:call-template name="util:logMessage">
                  <xsl:with-param name="level"
                                  select="$logERROR"/>
                  <xsl:with-param name="msg">
                     <xsl:value-of select="ancestor::f:resource/f:*/local-name()"/>
                     <xsl:text> with fullUrl '</xsl:text>
                     <xsl:value-of select="ancestor::f:resource/preceding-sibling::f:fullUrl/@value"/>
                     <xsl:text>' .</xsl:text>
                     <xsl:choose>
                        <xsl:when test="../parent::f:extension">
                           <xsl:value-of select="concat('extensie ', ../parent::f:extension/tokenize(@url, '/')[last()])"/>
                        </xsl:when>
                        <xsl:otherwise>
                           <xsl:value-of select="f:*/local-name()"/>
                        </xsl:otherwise>
                     </xsl:choose>
                     <xsl:text> reference author: </xsl:text>
                     <xsl:value-of select="$referenceValue"/>
                     <xsl:text> cannot be resolved within the Bundle. Therefore information will be lost.</xsl:text>
                  </xsl:with-param>
               </xsl:call-template>
            </xsl:when>
         </xsl:choose>
      </auteur>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:extension[@url = $urlExtMedicationUse2Prescriber]"
                 mode="mp-MedicationUse2">
      <!-- Template to convert f:extension with f:extension ext-MedicationUse2.Prescriber to voorschrijver -->
      <voorschrijver>
         <zorgverlener value="{nf:process-reference-2NCName(f:valueReference/f:reference/@value,ancestor::f:entry/f:fullUrl/@value)}"
                       datatype="reference"/>
      </voorschrijver>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:extension[@url = $urlExtAsAgreedIndicator]"
                 mode="mp-MedicationUse2">
      <!-- Template to convert f:extension with extension url "$asAgreedIndicator-url" to volgens_afspraak_indicator -->
      <volgens_afspraak_indicator>
         <xsl:attribute name="value"
                        select="f:valueBoolean/@value"/>
      </volgens_afspraak_indicator>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:reasonCode"
                 mode="mp-MedicationUse2">
      <!-- Template to convert f:reasonCode to reden_gebruik -->
      <reden_gebruik value="{f:text/@value}"/>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:note"
                 mode="mp-MedicationUse2">
      <!-- Template to convert f:note to toelichting. -->
      <toelichting value="{f:text/@value}"/>
   </xsl:template>
</xsl:stylesheet>