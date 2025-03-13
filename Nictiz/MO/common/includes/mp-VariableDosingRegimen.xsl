<?xml version="1.0" encoding="UTF-8"?>

<!-- == Provenance: YATC-internal/ada-2-fhir-r4/env/mp/9.3.0/payload/2.0.0-beta.5/mp-VariableDosingRegimen.xsl == -->
<!-- == Distribution: MP9-Medicatieproces-9.3.0; 1.0.7; 2025-01-17T18:03:28.04+01:00 == -->
<xsl:stylesheet exclude-result-prefixes="#all"
                version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://hl7.org/fhir"
                xmlns:util="urn:hl7:utilities"
                xmlns:f="http://hl7.org/fhir"
                xmlns:nf="http://www.nictiz.nl/functions"
                xmlns:yatcs="https://nictiz.nl/ns/YATC-shared"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
                xmlns:uuid="http://www.uuid.org"
                xmlns:local="#local.2024102208231515289120200"
                xmlns:nm="http://www.nictiz.nl/mappings">
   <!-- ================================================================== -->
   <!--
        Converts ADA wisselend_doseerschema to FHIR MedicationRequest conforming to profile mp-VariableDosingRegimen
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
   <xsl:output method="xml"
               indent="yes"/>
   <xsl:strip-space elements="*"/>
   <!-- ================================================================== -->
   <xsl:template name="mp-VariableDosingRegimen"
                 mode="mp-VariableDosingRegimen"
                 match="wisselend_doseerschema"
                 as="element(f:MedicationRequest)?">
      <!-- Create an mp-VariableDosingRegimen instance as a MedicationRequest FHIR instance from ADA wisselend_doseerschema. -->
      <xsl:param name="in"
                 as="element()?"
                 select=".">
         <!-- ADA element as input. Defaults to self. -->
      </xsl:param>
      <xsl:param name="subject"
                 select="patient/*"
                 as="element()?">
         <!-- The MedicationRequest.subject as ADA element or reference. -->
      </xsl:param>
      <xsl:param name="medicationReference"
                 select="(afgesprokengeneesmiddel | afgesproken_geneesmiddel)/farmaceutisch_product"
                 as="element()?">
         <!-- The MedicationRequest.medicationReference as ADA element or reference. -->
      </xsl:param>
      <xsl:param name="requester"
                 select="auteur"
                 as="element()?">
         <!-- The MedicationRequest.requester as ADA element or reference. -->
      </xsl:param>
      <xsl:for-each select="$in">
         <MedicationRequest>
            <xsl:call-template name="insertLogicalId"/>
            <meta>
               <profile value="{nf:get-full-profilename-from-adaelement(.)}"/>
            </meta>
            <!-- pharmaceuticalTreatmentIdentifier -->
            <xsl:for-each select="../identificatie[@value | @root | @nullFlavor]">
               <xsl:call-template name="ext-PharmaceuticalTreatmentIdentifier">
                  <xsl:with-param name="in"
                                  select="."/>
               </xsl:call-template>
            </xsl:for-each>
            <!-- MP-1406 added registrationdatetime to MA/TA/WDS/MTD -->
            <xsl:for-each select="registratie_datum_tijd[@value | @nullFlavor]">
               <xsl:call-template name="ext-RegistrationDateTime"/>
            </xsl:for-each>
            <xsl:for-each select="relatie_zorgepisode/(identificatie | identificatienummer)[@value | @root]">
               <xsl:call-template name="ext-Context-EpisodeOfCare"/>
            </xsl:for-each>
            <xsl:for-each select="gebruiksinstructie">
               <xsl:call-template name="ext-RenderedDosageInstruction"/>
            </xsl:for-each>
            <xsl:for-each select="gebruiksperiode">
               <xsl:call-template name="ext-TimeInterval.Period"/>
            </xsl:for-each>
            <!--herhaalperiode_cyclisch_schema-->
            <xsl:for-each select="gebruiksinstructie">
               <xsl:call-template name="ext-InstructionsForUse.RepeatPeriodCyclicalSchedule"/>
            </xsl:for-each>
            <xsl:for-each select="wisselend_doseerschema_stop_type[@code]">
               <modifierExtension url="http://nictiz.nl/fhir/StructureDefinition/ext-StopType">
                  <valueCodeableConcept>
                     <xsl:call-template name="code-to-CodeableConcept"/>
                  </valueCodeableConcept>
               </modifierExtension>
            </xsl:for-each>
            <xsl:for-each select="identificatie[@value | @root]">
               <identifier>
                  <xsl:call-template name="id-to-Identifier"/>
               </identifier>
            </xsl:for-each>
            <!-- we do not know the current status of this instance -->
            <status value="unknown"/>
            <intent value="order"/>
            <category>
               <coding>
                  <system value="{$oidMap[@oid=$oidSNOMEDCT]/@uri}"/>
                  <code value="395067002"/>
                  <display value="optimaliseren van dosering van medicatie"/>
               </coding>
            </category>
            <xsl:choose>
               <xsl:when test="$medicationReference">
                  <xsl:for-each select="$medicationReference">
                     <medicationReference>
                        <xsl:call-template name="makeReference"/>
                     </medicationReference>
                  </xsl:for-each>
               </xsl:when>
               <xsl:otherwise>
                  <!-- no medication available in input, but required element in FHIR
                            the source system really knows it, so unknown seems unfair, chose 'masked' -->
                  <medicationCodeableConcept>
                     <coding>
                        <code>
                           <extension url="http://hl7.org/fhir/StructureDefinition/data-absent-reason">
                              <valueCode value="masked"/>
                           </extension>
                        </code>
                     </coding>
                     <text value="zie bijbehorende medicatiebouwstenen in deze medicamenteuze behandeling"/>
                  </medicationCodeableConcept>
               </xsl:otherwise>
            </xsl:choose>
            <xsl:for-each select="$subject">
               <subject>
                  <xsl:call-template name="makeReference"/>
               </subject>
            </xsl:for-each>
            <xsl:for-each select="relatie_contact/(identificatie | identificatienummer)[@value | @root | @nullFlavor]">
               <encounter>
                  <xsl:apply-templates select="."
                                       mode="nl-core-Encounter-RefIdentifier"/>
               </encounter>
            </xsl:for-each>
            <xsl:for-each select="wisselend_doseerschema_datum_tijd[@value | @nullFlavor]">
               <authoredOn>
                  <xsl:attribute name="value">
                     <xsl:call-template name="format2FHIRDate">
                        <xsl:with-param name="dateTime"
                                        select="./@value"/>
                     </xsl:call-template>
                  </xsl:attribute>
               </authoredOn>
            </xsl:for-each>
            <xsl:for-each select="$requester">
               <requester>
                  <xsl:call-template name="makeReference">
                     <xsl:with-param name="profile">nl-core-HealthProfessional-PractitionerRole</xsl:with-param>
                  </xsl:call-template>
               </requester>
            </xsl:for-each>
            <xsl:for-each select="reden_wijzigen_of_staken[@code]">
               <reasonCode>
                  <xsl:call-template name="code-to-CodeableConcept">
                     <xsl:with-param name="treatNullFlavorAsCoding"
                                     select="true()"/>
                  </xsl:call-template>
               </reasonCode>
            </xsl:for-each>
            <xsl:for-each select="relatie_medicatieafspraak/identificatie[@value | @root | @nullFlavor]">
               <basedOn>
                  <type value="MedicationRequest"/>
                  <identifier>
                     <xsl:call-template name="id-to-Identifier"/>
                  </identifier>
                  <display value="relatie naar medicatieafspraak met identificatie: {string-join((@value, @root), ' || ')}"/>
               </basedOn>
            </xsl:for-each>
            <xsl:for-each select="toelichting">
               <note>
                  <text>
                     <xsl:call-template name="string-to-string"/>
                  </text>
               </note>
            </xsl:for-each>
            <xsl:for-each select="gebruiksinstructie">
               <xsl:call-template name="mp-InstructionsForUse.DosageInstruction">
                  <xsl:with-param name="wrapIn">dosageInstruction</xsl:with-param>
               </xsl:call-template>
            </xsl:for-each>
            <xsl:for-each select="relatie_wisselend_doseerschema/identificatie[@value | @root | @nullFlavor]">
               <priorPrescription>
                  <type value="MedicationRequest"/>
                  <identifier>
                     <xsl:call-template name="id-to-Identifier"/>
                  </identifier>
                  <display value="relatie naar wisselend doseerschema met identificatie: {string-join((@value, @root), ' || ')}"/>
               </priorPrescription>
            </xsl:for-each>
         </MedicationRequest>
      </xsl:for-each>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="wisselend_doseerschema"
                 mode="_generateId">
      <!-- Template to generate a unique id to identify this instance. -->
      <xsl:variable name="uniqueString"
                    as="xs:string?">
         <xsl:choose>
            <xsl:when test="identificatie[@root][@value]">
               <xsl:for-each select="(identificatie[@root][@value])[1]">
                  <!-- we remove '.' in root oid and '_' in extension to enlarge the chance of staying in 64 chars -->
                  <xsl:value-of select="concat(replace(@root, '\.', ''), '-', replace(@value, '_', ''))"/>
               </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
               <!-- we do not have anything to create a stable logicalId, lets return a UUID -->
               <xsl:value-of select="uuid:get-uuid(.)"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:call-template name="generateLogicalId">
         <xsl:with-param name="uniqueString"
                         select="$uniqueString"/>
      </xsl:call-template>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="wisselend_doseerschema"
                 mode="_generateDisplay">
      <!-- Template to generate a display that can be shown when referencing this instance. -->
      <xsl:variable name="parts">
         <xsl:value-of select="'Variable dosing regimen '"/>
         <xsl:value-of select="afgesprokengeneesmiddel/@displayName"/>
         <xsl:value-of select="wisselend_doseerschema_datum_tijd/@value"/>
         <xsl:value-of select="wisselend_doseerschema_stop_type/@displayName"/>
      </xsl:variable>
      <xsl:value-of select="string-join($parts, ' - ')"/>
   </xsl:template>
</xsl:stylesheet>