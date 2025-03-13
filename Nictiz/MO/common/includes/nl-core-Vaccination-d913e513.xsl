<?xml version="1.0" encoding="UTF-8"?>

<!-- == Provenance: YATC-internal/ada-2-fhir-r4/env/zibs/2020/payload/0.5-beta1/nl-core-Vaccination.xsl == -->
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
                xmlns:local="#local.2024111408213046174750100">
   <!-- ================================================================== -->
   <!--
        Converts ADA vaccination to FHIR Immunization resource conforming to profile nl-core-Vaccination-event or FHIR ImmunizationRecommendation resource conforming to profile nl-core-Vaccination-request.
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
   <xsl:variable name="profileNameVaccinationRequest">nl-core-Vaccination-request</xsl:variable>
   <xsl:variable name="profileNameVaccinationEvent">nl-core-Vaccination-event</xsl:variable>
   <!-- ================================================================== -->
   <xsl:template match="vaccinatie"
                 name="nl-core-Vaccination-event"
                 mode="nl-core-Vaccination-event"
                 as="element(f:Immunization)?">
      <!-- Creates an nl-core-Vaccination-event instance as an Immunization FHIR instance from ADA vaccinatie element. -->
      <xsl:param name="in"
                 select="."
                 as="element()?">
         <!-- ADA element as input. Defaults to self. -->
      </xsl:param>
      <xsl:param name="patient"
                 select="patient/*"
                 as="element()?">
         <!-- Optional ADA instance or ADA reference element for the patient. -->
      </xsl:param>
      <xsl:for-each select="$in">
         <Immunization>
            <xsl:call-template name="insertLogicalId">
               <xsl:with-param name="profile"
                               select="$profileNameVaccinationEvent"/>
            </xsl:call-template>
            <meta>
               <profile value="{concat($urlBaseNictizProfile, $profileNameVaccinationEvent)}"/>
            </meta>
            <status value="completed"/>
            <xsl:for-each select="product_code">
               <vaccineCode>
                  <xsl:call-template name="code-to-CodeableConcept">
                     <xsl:with-param name="in"
                                     select="."/>
                  </xsl:call-template>
               </vaccineCode>
            </xsl:for-each>
            <xsl:call-template name="makeReference">
               <xsl:with-param name="in"
                               select="$patient"/>
               <xsl:with-param name="wrapIn"
                               select="'patient'"/>
            </xsl:call-template>
            <xsl:for-each select="vaccinatie_datum">
               <occurrenceDateTime>
                  <xsl:call-template name="date-to-datetime">
                     <xsl:with-param name="in"
                                     select="."/>
                  </xsl:call-template>
               </occurrenceDateTime>
            </xsl:for-each>
            <xsl:for-each select="dosis">
               <doseQuantity>
                  <xsl:call-template name="hoeveelheid-to-Quantity">
                     <xsl:with-param name="in"
                                     select="."/>
                  </xsl:call-template>
               </doseQuantity>
            </xsl:for-each>
            <xsl:for-each select="toediener">
               <performer>
                  <function>
                     <coding>
                        <system value="http://terminology.hl7.org/CodeSystem/v2-0443"/>
                        <code value="AP"/>
                     </coding>
                  </function>
                  <actor>
                     <xsl:call-template name="makeReference">
                        <xsl:with-param name="in"
                                        select="zorgverlener"/>
                        <xsl:with-param name="profile"
                                        select="$profileNameHealthProfessionalPractitionerRole"/>
                     </xsl:call-template>
                  </actor>
               </performer>
            </xsl:for-each>
            <xsl:for-each select="toelichting">
               <note>
                  <text>
                     <xsl:call-template name="string-to-string">
                        <xsl:with-param name="in"
                                        select="."/>
                     </xsl:call-template>
                  </text>
               </note>
            </xsl:for-each>
         </Immunization>
      </xsl:for-each>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="vaccinatie"
                 name="nl-core-Vaccination-request"
                 mode="nl-core-Vaccination-request"
                 as="element(f:ImmunizationRecommendation)?">
      <!-- Creates an nl-core-Vaccination-request instance as an ImmunizationRecommendation FHIR instance from ADA vaccinatie element. -->
      <xsl:param name="in"
                 select="."
                 as="element()?">
         <!-- ADA element as input. Defaults to self. -->
      </xsl:param>
      <xsl:param name="patient"
                 select="patient/*"
                 as="element()?">
         <!-- Optional ADA instance or ADA reference element for the patient. -->
      </xsl:param>
      <xsl:for-each select="$in">
         <ImmunizationRecommendation>
            <xsl:call-template name="insertLogicalId">
               <xsl:with-param name="profile"
                               select="$profileNameVaccinationRequest"/>
            </xsl:call-template>
            <meta>
               <profile value="{concat($urlBaseNictizProfile, $profileNameVaccinationRequest)}"/>
            </meta>
            <xsl:call-template name="makeReference">
               <xsl:with-param name="in"
                               select="$patient"/>
               <xsl:with-param name="wrapIn"
                               select="'patient'"/>
            </xsl:call-template>
            <date>
               <xsl:attribute name="value">
                  <xsl:value-of select="current-dateTime()"/>
               </xsl:attribute>
            </date>
            <xsl:if test="product_code or vaccinatie_datum or toelichting">
               <recommendation>
                  <xsl:for-each select="product_code">
                     <vaccineCode>
                        <xsl:call-template name="code-to-CodeableConcept">
                           <xsl:with-param name="in"
                                           select="."/>
                        </xsl:call-template>
                     </vaccineCode>
                  </xsl:for-each>
                  <!--Based on the zib it's not possible to deduce the value of forecastStatus with full certainty. The value _due_ seems to be the most suited default.-->
                  <forecastStatus>
                     <coding>
                        <system value="http://terminology.hl7.org/CodeSystem/immunization-recommendation-status"/>
                        <code value="due"/>
                        <display value="Due"/>
                     </coding>
                  </forecastStatus>
                  <xsl:for-each select="vaccinatie_datum">
                     <dateCriterion>
                        <code>
                           <coding>
                              <!--Based on the zib it's not possible to deduce the value of dateCriterion.code with full certainty. The LOINC code 30980-7 (Date vaccin due) seems to be the most suited default.-->
                              <system value="{$oidMap[@oid=$oidLOINC]/@uri}"/>
                              <code value="30980-7"/>
                           </coding>
                        </code>
                        <value>
                           <xsl:call-template name="date-to-datetime">
                              <xsl:with-param name="in"
                                              select="."/>
                           </xsl:call-template>
                        </value>
                     </dateCriterion>
                  </xsl:for-each>
                  <xsl:for-each select="toelichting">
                     <description>
                        <xsl:call-template name="string-to-string">
                           <xsl:with-param name="in"
                                           select="."/>
                        </xsl:call-template>
                     </description>
                  </xsl:for-each>
               </recommendation>
            </xsl:if>
         </ImmunizationRecommendation>
      </xsl:for-each>
   </xsl:template>
</xsl:stylesheet>