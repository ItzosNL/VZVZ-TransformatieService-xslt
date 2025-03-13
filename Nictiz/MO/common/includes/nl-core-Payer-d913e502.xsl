<?xml version="1.0" encoding="UTF-8"?>

<!-- == Provenance: YATC-internal/ada-2-fhir-r4/env/zibs/2020/payload/0.7-beta1/nl-core-Payer.xsl == -->
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
                xmlns:local="#local.2024111408213062203760100">
   <!-- ================================================================== -->
   <!--
        Converts ADA betaler to FHIR Coverage resource conforming to profile nl-core-Payer.InsuranceCompany, FHIR Coverage resource conforming to profile nl-core-Payer.PayerPerson and FHIR Organization resource conforming to profile nl-core-Payer-Organization.
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
   <xsl:variable name="profileNamePayerInsuranceCompany">nl-core-Payer.InsuranceCompany</xsl:variable>
   <xsl:variable name="profileNamePayerPayerPerson">nl-core-Payer.PayerPerson</xsl:variable>
   <xsl:variable name="profileNamePayerOrganization">nl-core-Payer-Organization</xsl:variable>
   <!-- ================================================================== -->
   <xsl:template name="nl-core-Payer.InsuranceCompany"
                 mode="nl-core-Payer.InsuranceCompany"
                 match="betaler"
                 as="element(f:Coverage)">
      <!-- Creates an nl-core-Payer.InsuranceCompany instance as a Coverage FHIR instance from ADA betaler element. -->
      <xsl:param name="in"
                 select="."
                 as="element()?">
         <!-- ADA element as input. Defaults to self. -->
      </xsl:param>
      <xsl:param name="beneficiary"
                 as="element()?">
         <!-- Optional ADA instance or ADA reference element for the beneficiary, usually the patient. -->
      </xsl:param>
      <xsl:for-each select="$in">
         <Coverage>
            <xsl:variable name="startDate"
                          select="verzekeraar/verzekering/begin_datum_tijd/@value"/>
            <xsl:variable name="endDate"
                          select="verzekeraar/verzekering/eind_datum_tijd/@value"/>
            <xsl:call-template name="insertLogicalId">
               <xsl:with-param name="profile"
                               select="$profileNamePayerInsuranceCompany"/>
            </xsl:call-template>
            <meta>
               <profile value="{concat($urlBaseNictizProfile, $profileNamePayerInsuranceCompany)}"/>
            </meta>
            <status>
               <xsl:choose>
                  <xsl:when test="nf:isFuture($startDate)">
                     <xsl:attribute name="value"
                                    select="'draft'"/>
                  </xsl:when>
                  <xsl:when test="nf:isFuture($endDate)">
                     <xsl:attribute name="value"
                                    select="'active'"/>
                  </xsl:when>
                  <xsl:when test="nf:isPast($endDate)">
                     <xsl:attribute name="value"
                                    select="'cancelled'"/>
                  </xsl:when>
                  <!-- If no status can be derived from the startDate and endDate, the Coverage is assumed to be active. 
                        A status code must be provided and no unknown code exists in the required ValueSet.-->
                  <xsl:otherwise>
                     <xsl:attribute name="value"
                                    select="'active'"/>
                  </xsl:otherwise>
               </xsl:choose>
            </status>
            <xsl:for-each select="verzekeraar/verzekering/verzekeringssoort">
               <type>
                  <xsl:call-template name="code-to-CodeableConcept"/>
               </type>
            </xsl:for-each>
            <xsl:for-each select="verzekeraar/verzekerde_nummer">
               <subscriberId value="{normalize-space(@value)}"/>
            </xsl:for-each>
            <xsl:call-template name="makeReference">
               <xsl:with-param name="in"
                               select="$beneficiary"/>
               <xsl:with-param name="wrapIn">beneficiary</xsl:with-param>
            </xsl:call-template>
            <xsl:if test="$startDate or $endDate">
               <period>
                  <xsl:for-each select="$startDate">
                     <start>
                        <xsl:attribute name="value">
                           <xsl:call-template name="format2FHIRDate">
                              <xsl:with-param name="dateTime"
                                              select="$startDate"/>
                           </xsl:call-template>
                        </xsl:attribute>
                     </start>
                  </xsl:for-each>
                  <xsl:for-each select="$endDate">
                     <end>
                        <xsl:attribute name="value">
                           <xsl:call-template name="format2FHIRDate">
                              <xsl:with-param name="dateTime"
                                              select="$endDate"/>
                           </xsl:call-template>
                        </xsl:attribute>
                     </end>
                  </xsl:for-each>
               </period>
            </xsl:if>
            <xsl:if test="verzekeraar[identificatie_nummer or organisatie_naam] or adresgegevens or contactgegevens">
               <xsl:call-template name="makeReference">
                  <xsl:with-param name="profile"
                                  select="'nl-core-Payer-Organization'"/>
                  <xsl:with-param name="wrapIn">payor</xsl:with-param>
               </xsl:call-template>
            </xsl:if>
         </Coverage>
      </xsl:for-each>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template name="nl-core-Payer.PayerPerson"
                 mode="nl-core-Payer.PayerPerson"
                 match="betaler"
                 as="element(f:Coverage)">
      <!-- Creates an nl-core-Payer.PayerPerson instance as a Coverage FHIR instance from ADA betaler element. -->
      <xsl:param name="in"
                 select="."
                 as="element()?">
         <!-- ADA element as input. Defaults to self. -->
      </xsl:param>
      <xsl:param name="beneficiary"
                 as="element()?">
         <!-- Optional ADA instance or ADA reference element for the beneficiary, usually the patient. -->
      </xsl:param>
      <xsl:for-each select="$in">
         <Coverage>
            <xsl:call-template name="insertLogicalId">
               <xsl:with-param name="profile"
                               select="$profileNamePayerPayerPerson"/>
            </xsl:call-template>
            <meta>
               <profile value="{concat($urlBaseNictizProfile, $profileNamePayerPayerPerson)}"/>
            </meta>
            <xsl:for-each select="betaler_persoon/bankgegevens">
               <extension url="http://nictiz.nl/fhir/StructureDefinition/ext-Payer.BankInformation">
                  <xsl:for-each select="bank_naam">
                     <extension url="bankName">
                        <valueString value="{normalize-space(@value)}"/>
                     </extension>
                  </xsl:for-each>
                  <xsl:for-each select="bankcode">
                     <extension url="bankCode">
                        <valueString value="{normalize-space(@value)}"/>
                     </extension>
                  </xsl:for-each>
                  <xsl:for-each select="rekeningnummer">
                     <extension url="accountNumber">
                        <valueString value="{normalize-space(@value)}"/>
                     </extension>
                  </xsl:for-each>
               </extension>
            </xsl:for-each>
            <!-- The Coverage is assumed to be active. A status code must be provided and no unknown code exists in the required ValueSet.-->
            <status value="active"/>
            <type>
               <coding>
                  <system value="http://terminology.hl7.org/CodeSystem/coverage-selfpay"/>
                  <code value="pay"/>
               </coding>
            </type>
            <xsl:call-template name="makeReference">
               <xsl:with-param name="in"
                               select="$beneficiary"/>
               <xsl:with-param name="wrapIn">beneficiary</xsl:with-param>
            </xsl:call-template>
            <!-- We cannot know for sure if this betaler_persoon truly is an Organization, but ADA currently does not allow a reference to a Patient or ContactPerson -->
            <xsl:if test="betaler_persoon/betaler_naam or adresgegevens or contactgegevens">
               <xsl:call-template name="makeReference">
                  <xsl:with-param name="profile"
                                  select="$profileNamePayerOrganization"/>
                  <xsl:with-param name="wrapIn">payor</xsl:with-param>
               </xsl:call-template>
            </xsl:if>
         </Coverage>
      </xsl:for-each>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="betaler"
                 name="nl-core-Payer-Organization"
                 mode="nl-core-Payer-Organization"
                 as="element(f:Organization)">
      <!-- Creates an nl-core-Payer-Organization instance as an Organization FHIR instance from ADA betaler element. -->
      <xsl:param name="in"
                 select="."
                 as="element()?">
         <!-- ADA element as input. Defaults to self. -->
      </xsl:param>
      <xsl:for-each select="$in">
         <Organization>
            <xsl:call-template name="insertLogicalId">
               <xsl:with-param name="profile"
                               select="$profileNamePayerOrganization"/>
            </xsl:call-template>
            <meta>
               <profile value="{concat($urlBaseNictizProfile, $profileNamePayerOrganization)}"/>
            </meta>
            <xsl:for-each select="verzekeraar/identificatie_nummer">
               <identifier>
                  <xsl:call-template name="id-to-Identifier">
                     <xsl:with-param name="in"
                                     select="."/>
                  </xsl:call-template>
               </identifier>
            </xsl:for-each>
            <xsl:choose>
               <xsl:when test="verzekeraar/organisatie_naam">
                  <name value="{verzekeraar/organisatie_naam/@value}"/>
               </xsl:when>
               <xsl:when test="betaler_persoon/betaler_naam">
                  <name value="{betaler_persoon/betaler_naam/@value}"/>
               </xsl:when>
            </xsl:choose>
            <xsl:call-template name="nl-core-ContactInformation">
               <xsl:with-param name="in"
                               select="contactgegevens"/>
            </xsl:call-template>
            <xsl:call-template name="nl-core-AddressInformation">
               <xsl:with-param name="in"
                               select="adresgegevens"/>
            </xsl:call-template>
         </Organization>
      </xsl:for-each>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="betaler"
                 mode="_generateDisplay">
      <!-- Template to generate a display that can be shown when referencing this instance. -->
      <xsl:param name="profile"
                 required="yes"
                 as="xs:string"/>
      <xsl:variable name="parts"
                    as="item()*">
         <xsl:choose>
            <xsl:when test="$profile = $profileNamePayerInsuranceCompany">
               <xsl:text>Payer as InsuranceCompany</xsl:text>
               <xsl:value-of select="verzekeraar/organisatie_naam/@value"/>
               <xsl:if test="verzekerde_nummer/@value">
                  <xsl:value-of select="concat('nummer: ',verzekerde_nummer/@value)"/>
               </xsl:if>
            </xsl:when>
            <xsl:when test="$profile = $profileNamePayerPayerPerson">
               <xsl:text>Payer as PayerPerson</xsl:text>
               <xsl:value-of select="betaler_persoon/betaler_naam/@value"/>
            </xsl:when>
            <xsl:when test="$profile = $profileNamePayerOrganization">
               <xsl:text>Payer-Organization</xsl:text>
               <xsl:value-of select="verzekeraar/organisatie_naam/@value"/>
               <xsl:value-of select="betaler_persoon/betaler_naam/@value"/>
               <xsl:if test="verzekeraar/identificatie_nummer">
                  <xsl:value-of select="concat('UZOVI ', verzekeraar/identificatie_nummer/@value)"/>
               </xsl:if>
            </xsl:when>
         </xsl:choose>
      </xsl:variable>
      <xsl:value-of select="string-join($parts[. != ''], ', ')"/>
   </xsl:template>
</xsl:stylesheet>