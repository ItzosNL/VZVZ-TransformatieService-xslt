<?xml version="1.0" encoding="UTF-8"?>

<!-- == Provenance: YATC-internal/ada-2-fhir-r4/env/mp/9.2.0/payload/1.0/mp-MedicationDispense.xsl == -->
<!-- == Distribution: MP9-Medicatieproces-9.3.0; 1.0.10; 2025-04-16T18:06:20.52+02:00 == -->
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
                xmlns:local="#local.2024101709035007911060200"
                xmlns:nm="http://www.nictiz.nl/mappings">
   <!-- ================================================================== -->
   <!--
        Converts ADA medicatieverstrekking to FHIR MedicationDispense conforming to profile mp-MedicationDispense
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
   <xsl:variable name="mveCode920"
                 select="$mveCode[1]"/>
   <!-- ================================================================== -->
   <xsl:template name="mp-MedicationDispense"
                 mode="mp-MedicationDispense"
                 match="medicatieverstrekking"
                 as="element(f:MedicationDispense)?">
      <!-- Create an mp-MedicationDispense instance as a MedicationDispense FHIR instance from ADA medicatieverstrekking. -->
      <xsl:param name="in"
                 as="element()?"
                 select=".">
         <!-- ADA element as input. Defaults to self. -->
      </xsl:param>
      <xsl:param name="metaTag"
                 as="xs:string?">
         <!-- The meta tag to be added. Optional. Typical use case is 'actionable' for prescriptions or proposals. Empty for informational purposes. -->
      </xsl:param>
      <xsl:param name="subject"
                 select="patient/*"
                 as="element()?">
         <!-- The MedicationDispense.subject as ADA element or reference. -->
      </xsl:param>
      <xsl:param name="medicationReference"
                 select="verstrekt_geneesmiddel/farmaceutisch_product"
                 as="element()?">
         <!-- The MedicationDispense.medicationReference as ADA element or reference. -->
      </xsl:param>
      <xsl:param name="performer"
                 select="verstrekker/zorgaanbieder"
                 as="element()?">
         <!-- The MedicationDispense.requester as ADA element or reference. -->
      </xsl:param>
      <xsl:param name="authorizingPrescription"
                 select="verstrekkingsverzoek/verstrekkingsverzoek"
                 as="element()?">
         <!-- The MedicationDispense.authorizingPrescription as ADA element or reference. -->
      </xsl:param>
      <xsl:for-each select="$in">
         <MedicationDispense>
            <xsl:call-template name="insertLogicalId"/>
            <meta>
               <profile value="{nf:get-full-profilename-from-adaelement(.)}"/>
               <xsl:if test="string-length($metaTag) gt 0">
                  <tag>
                     <system value="http://terminology.hl7.org/CodeSystem/common-tags"/>
                     <code value="{$metaTag}"/>
                  </tag>
               </xsl:if>
            </meta>
            <xsl:for-each select="medicatieverstrekking_aanvullende_informatie">
               <extension url="http://nictiz.nl/fhir/StructureDefinition/ext-MedicationDispense.MedicationDispenseAdditionalInformation">
                  <valueCodeableConcept>
                     <xsl:call-template name="code-to-CodeableConcept"/>
                  </valueCodeableConcept>
               </extension>
            </xsl:for-each>
            <xsl:for-each select="aanschrijf_datum">
               <extension url="http://nictiz.nl/fhir/StructureDefinition/ext-MedicationDispense.RequestDate">
                  <valueDateTime>
                     <xsl:attribute name="value">
                        <xsl:call-template name="format2FHIRDate">
                           <xsl:with-param name="dateTime"
                                           select="./@value"/>
                        </xsl:call-template>
                     </xsl:attribute>
                  </valueDateTime>
               </extension>
            </xsl:for-each>
            <xsl:for-each select="distributievorm[@code]">
               <extension url="http://nictiz.nl/fhir/StructureDefinition/ext-MedicationDispense.DistributionForm">
                  <valueCodeableConcept>
                     <xsl:call-template name="code-to-CodeableConcept"/>
                  </valueCodeableConcept>
               </extension>
            </xsl:for-each>
            <!-- pharmaceuticalTreatmentIdentifier -->
            <xsl:for-each select="../identificatie">
               <xsl:call-template name="ext-PharmaceuticalTreatmentIdentifier">
                  <xsl:with-param name="in"
                                  select="."/>
               </xsl:call-template>
            </xsl:for-each>
            <xsl:for-each select="identificatie[@value | @root | @nullFlavor]">
               <identifier>
                  <xsl:call-template name="id-to-Identifier"/>
               </identifier>
            </xsl:for-each>
            <!-- It is expected that in most use cases only actual, executed, medication dispenses are exchanged which result in a _completed_ value. We use completed as a default value. 
                    See https://github.com/Nictiz/Nictiz-R4-zib2020/issues/122 -->
            <status value="completed"/>
            <category>
               <coding>
                  <system value="{$oidMap[@oid=$oidSNOMEDCT]/@uri}"/>
                  <code value="{$mveCode920}"/>
                  <display value="verstrekken van medicatie"/>
               </coding>
            </category>
            <xsl:for-each select="$medicationReference">
               <medicationReference>
                  <xsl:call-template name="makeReference"/>
               </medicationReference>
            </xsl:for-each>
            <xsl:for-each select="$subject">
               <subject>
                  <xsl:call-template name="makeReference"/>
               </subject>
            </xsl:for-each>
            <xsl:for-each select="$performer">
               <performer>
                  <actor>
                     <xsl:call-template name="makeReference">
                        <xsl:with-param name="profile"
                                        select="$profileNameHealthcareProviderOrganization"/>
                     </xsl:call-template>
                  </actor>
               </performer>
            </xsl:for-each>
            <!-- zib ada dataset, but this won't work in real live because the FHIR server that is source system for a dispense (AIS) is typically not source system for a dispenseRequest (EVS) -->
            <xsl:for-each select="$authorizingPrescription">
               <authorizingPrescription>
                  <xsl:call-template name="makeReference"/>
               </authorizingPrescription>
            </xsl:for-each>
            <!-- mp9 ada dataset, a reference using business identifier, id est: loosely coupled -->
            <xsl:for-each select="relatie_verstrekkingsverzoek/identificatie[@value | @root]">
               <authorizingPrescription>
                  <type value="MedicationRequest"/>
                  <identifier>
                     <xsl:call-template name="id-to-Identifier"/>
                  </identifier>
                  <display value="relatie naar verstrekkingsverzoek met identificatie: {string-join((@value, @root), ' || ')}"/>
               </authorizingPrescription>
            </xsl:for-each>
            <!-- zib ada dataset -->
            <xsl:for-each select="verstrekte_hoeveelheid[@value]">
               <quantity>
                  <xsl:call-template name="hoeveelheid-to-Quantity"/>
               </quantity>
            </xsl:for-each>
            <!-- MP9 ada dataset -->
            <xsl:for-each select="verstrekte_hoeveelheid/aantal[@value]">
               <quantity>
                  <xsl:call-template name="_buildMedicationQuantity">
                     <xsl:with-param name="adaValue"
                                     select="."/>
                     <xsl:with-param name="adaUnit"
                                     select="../eenheid[@codeSystem = $oidGStandaardBST902THES2]"/>
                  </xsl:call-template>
               </quantity>
            </xsl:for-each>
            <xsl:for-each select="verbruiksduur">
               <daysSupply>
                  <xsl:call-template name="hoeveelheid-to-Quantity"/>
               </daysSupply>
            </xsl:for-each>
            <xsl:for-each select="medicatieverstrekkings_datum_tijd">
               <whenHandedOver>
                  <xsl:attribute name="value">
                     <xsl:call-template name="format2FHIRDate">
                        <xsl:with-param name="dateTime"
                                        select="./@value"/>
                     </xsl:call-template>
                  </xsl:attribute>
               </whenHandedOver>
            </xsl:for-each>
            <!-- DispenseLocation is a string in the zib, mapped to a Location reference in FHIR. A FHIR Location resource is created from just the string -->
            <xsl:for-each select="afleverlocatie[@value]">
               <destination>
                  <xsl:call-template name="makeReference">
                     <xsl:with-param name="in"
                                     select="."/>
                  </xsl:call-template>
               </destination>
            </xsl:for-each>
            <xsl:for-each select="toelichting">
               <note>
                  <text>
                     <xsl:call-template name="string-to-string"/>
                  </text>
               </note>
            </xsl:for-each>
         </MedicationDispense>
      </xsl:for-each>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="medicatieverstrekking/afleverlocatie"
                 mode="_generateId">
      <!-- Specific template for generating an id for afleverlocatie. -->
      <xsl:param name="in"
                 select=".">
         <!-- The ADA element to generate the id for. -->
      </xsl:param>
      <xsl:variable name="uniqueString"
                    as="xs:string?">
         <xsl:choose>
            <xsl:when test="@value">
               <xsl:value-of select="@value"/>
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
   <xsl:template match="medicatieverstrekking"
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
   <xsl:template match="medicatieverstrekking"
                 mode="_generateDisplay">
      <!-- Template to generate a display that can be shown when referencing this instance. -->
      <xsl:variable name="parts">
         <xsl:text>Medication dispense</xsl:text>
         <xsl:if test="medicatieverstrekking_datum_tijd/@value">
            <xsl:value-of select="concat('dispense date', medicatieverstrekking_datum_tijd/@value)"/>
         </xsl:if>
         <xsl:value-of select="afleverlocatie/@value"/>
         <xsl:value-of select="toelichting/@value"/>
      </xsl:variable>
      <xsl:value-of select="string-join($parts, ', ')"/>
   </xsl:template>
</xsl:stylesheet>