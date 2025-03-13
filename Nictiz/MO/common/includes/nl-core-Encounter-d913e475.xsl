<?xml version="1.0" encoding="UTF-8"?>

<!-- == Provenance: YATC-internal/ada-2-fhir-r4/env/zibs/2020/payload/0.7-beta1/nl-core-Encounter.xsl == -->
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
                xmlns:local="#local.2024111408213057935150100"
                xmlns:nm="http://www.nictiz.nl/mappings">
   <!-- ================================================================== -->
   <!--
        Converts ADA contact to FHIR Encounter resource conforming to profile nl-core-Encounter.
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
   <xsl:variable name="profileNameEncounter">nl-core-Encounter</xsl:variable>
   <!-- ================================================================== -->
   <xsl:template match="contact"
                 name="nl-core-Encounter"
                 mode="nl-core-Encounter"
                 as="element(f:Encounter)?">
      <!-- Creates an nl-core-Encounter instance as an Encounter FHIR instance from ADA contact element. -->
      <xsl:param name="in"
                 select="."
                 as="element()?">
         <!-- ADA element as input. Defaults to self. -->
      </xsl:param>
      <xsl:param name="participantIndividual"
                 select="contact_met/zorgverlener"/>
      <xsl:param name="location"
                 select="locatie/zorgaanbieder"/>
      <xsl:for-each select="$in">
         <Encounter>
            <xsl:call-template name="insertLogicalId">
               <xsl:with-param name="profile"
                               select="$profileNameEncounter"/>
            </xsl:call-template>
            <meta>
               <profile value="{nf:get-full-profilename-from-adaelement(.)}"/>
            </meta>
            <xsl:comment>.status: Dependent on outcome of https://github.com/Nictiz/Nictiz-R4-zib2020/issues/45</xsl:comment>
            <status value="unknown"/>
            <xsl:for-each select="contact_type[@code]">
               <class>
                  <xsl:call-template name="code-to-Coding">
                     <xsl:with-param name="in"
                                     select="."/>
                  </xsl:call-template>
               </class>
            </xsl:for-each>
            <xsl:for-each select="contact_met">
               <participant>
                  <individual>
                     <xsl:call-template name="makeReference">
                        <xsl:with-param name="in"
                                        select="zorgverlener"/>
                        <xsl:with-param name="profile"
                                        select="$profileNameHealthProfessionalPractitionerRole"/>
                     </xsl:call-template>
                  </individual>
               </participant>
            </xsl:for-each>
            <xsl:if test="begin_datum_tijd or eind_datum_tijd">
               <period>
                  <xsl:if test="begin_datum_tijd">
                     <start>
                        <xsl:attribute name="value">
                           <xsl:call-template name="format2FHIRDate">
                              <xsl:with-param name="dateTime"
                                              select="xs:string(begin_datum_tijd/@value)"/>
                           </xsl:call-template>
                        </xsl:attribute>
                     </start>
                  </xsl:if>
                  <xsl:if test="eind_datum_tijd">
                     <end>
                        <xsl:attribute name="value">
                           <xsl:call-template name="format2FHIRDate">
                              <xsl:with-param name="dateTime"
                                              select="xs:string(eind_datum_tijd/@value)"/>
                           </xsl:call-template>
                        </xsl:attribute>
                     </end>
                  </xsl:if>
               </period>
            </xsl:if>
            <xsl:for-each select="reden_contact[afwijkende_uitslag/@value]">
               <reasonCode>
                  <xsl:for-each select="toelichting_reden_contact">
                     <extension url="http://nictiz.nl/fhir/StructureDefinition/ext-Comment">
                        <valueString>
                           <xsl:call-template name="string-to-string">
                              <xsl:with-param name="in"
                                              select="."/>
                           </xsl:call-template>
                        </valueString>
                     </extension>
                  </xsl:for-each>
                  <text>
                     <xsl:call-template name="string-to-string">
                        <xsl:with-param name="in"
                                        select="./afwijkende_uitslag"/>
                     </xsl:call-template>
                  </text>
               </reasonCode>
            </xsl:for-each>
            <xsl:for-each select="reden_contact[probleem/@value or verrichting/@value]">
               <reasonReference>
                  <xsl:for-each select="./toelichting_reden_contact">
                     <extension url="http://nictiz.nl/fhir/StructureDefinition/ext-Comment">
                        <valueString>
                           <xsl:call-template name="string-to-string">
                              <xsl:with-param name="in"
                                              select="."/>
                           </xsl:call-template>
                        </valueString>
                     </extension>
                  </xsl:for-each>
                  <xsl:for-each select="probleem">
                     <xsl:call-template name="makeReference">
                        <xsl:with-param name="in"
                                        select="."/>
                        <xsl:with-param name="profile"
                                        select="$profileNameProblem"/>
                     </xsl:call-template>
                  </xsl:for-each>
                  <xsl:for-each select="verrichting">
                     <xsl:call-template name="makeReference">
                        <xsl:with-param name="in"
                                        select="."/>
                        <xsl:with-param name="profile"
                                        select="$profileNameProcedureEvent"/>
                     </xsl:call-template>
                  </xsl:for-each>
               </reasonReference>
            </xsl:for-each>
            <xsl:if test="herkomst or bestemming">
               <hospitalization>
                  <xsl:for-each select="herkomst">
                     <admitSource>
                        <xsl:call-template name="code-to-CodeableConcept">
                           <xsl:with-param name="in"
                                           select="."/>
                        </xsl:call-template>
                     </admitSource>
                  </xsl:for-each>
                  <xsl:for-each select="bestemming">
                     <dischargeDisposition>
                        <xsl:call-template name="code-to-CodeableConcept">
                           <xsl:with-param name="in"
                                           select="."/>
                        </xsl:call-template>
                     </dischargeDisposition>
                  </xsl:for-each>
               </hospitalization>
            </xsl:if>
            <xsl:for-each select="locatie">
               <location>
                  <location>
                     <xsl:call-template name="makeReference">
                        <xsl:with-param name="in"
                                        select="zorgaanbieder"/>
                        <xsl:with-param name="profile"
                                        select="$profileNameHealthcareProvider"/>
                     </xsl:call-template>
                  </location>
               </location>
            </xsl:for-each>
         </Encounter>
      </xsl:for-each>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="contact"
                 mode="_generateDisplay">
      <!-- Template to generate a display that can be shown when referencing this instance. -->
      <xsl:variable name="parts"
                    as="item()*">
         <xsl:text>Encounter</xsl:text>
         <xsl:if test="contact_type[@displayName]">
            <xsl:value-of select="concat('type ', contact_type/@displayName)"/>
         </xsl:if>
         <xsl:if test="begin_datum_tijd[@value]">
            <xsl:value-of select="concat('from ', begin_datum_tijd/@value)"/>
         </xsl:if>
         <xsl:if test="eind_datum_tijd[@value]">
            <xsl:value-of select="concat('until ', eind_datum_tijd/@value)"/>
         </xsl:if>
      </xsl:variable>
      <xsl:value-of select="string-join($parts[. != ''], ', ')"/>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template name="nl-core-Encounter-RefIdentifier"
                 match="identificatie | identificatienummer"
                 mode="nl-core-Encounter-RefIdentifier">
      <!-- Creates an Encounter reference based on identifier using ada identificatie element -->
      <type value="Encounter"/>
      <identifier>
         <xsl:call-template name="id-to-Identifier"/>
      </identifier>
      <display value="relatie naar contact met identificatie: {string-join((@value, @root), ' || ')}"/>
   </xsl:template>
</xsl:stylesheet>