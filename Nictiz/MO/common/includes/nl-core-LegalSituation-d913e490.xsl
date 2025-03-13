<?xml version="1.0" encoding="UTF-8"?>

<!-- == Provenance: YATC-internal/ada-2-fhir-r4/env/zibs/2020/payload/0.8.0-beta.1/nl-core-LegalSituation.xsl == -->
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
                xmlns:local="#local.2024111408213087023170100"
                xmlns:nm="http://www.nictiz.nl/mappings">
   <!-- ================================================================== -->
   <!--
        Converts ADA juridische_situatie to FHIR Condition resource conforming to profile nl-core-LegalSituation-LegalStatus or nl-core-LegalSituation-Representation.
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
   <xsl:variable name="profileNameLegalSituationLegalStatus">nl-core-LegalSituation-LegalStatus</xsl:variable>
   <xsl:variable name="profileNameLegalSituationRepresentation">nl-core-LegalSituation-Representation</xsl:variable>
   <!-- ================================================================== -->
   <xsl:template match="juridische_situatie"
                 name="nl-core-LegalSituation-LegalStatus"
                 mode="nl-core-LegalSituation-LegalStatus"
                 as="element(f:Condition)?">
      <!-- Creates an nl-core-LegalSituation-LegalStatus instance as a Condition FHIR instance from ADA juridische_situatie element. -->
      <xsl:param name="in"
                 as="element()?"
                 select=".">
         <!-- ADA element as input. Defaults to self. -->
      </xsl:param>
      <xsl:param name="subject"
                 select="patient"
                 as="element()?">
         <!-- The subject as ADA element or reference. -->
      </xsl:param>
      <xsl:for-each select="$in[juridische_status]">
         <Condition>
            <xsl:call-template name="insertLogicalId">
               <xsl:with-param name="profile"
                               select="$profileNameLegalSituationLegalStatus"/>
            </xsl:call-template>
            <meta>
               <profile value="{concat($urlBaseNictizProfile, $profileNameLegalSituationLegalStatus)}"/>
            </meta>
            <xsl:if test="datum_einde">
               <clinicalStatus>
                  <coding>
                     <system value="http://terminology.hl7.org/CodeSystem/condition-clinical"/>
                     <code value="inactive"/>
                     <display value="Inactive"/>
                  </coding>
               </clinicalStatus>
            </xsl:if>
            <category>
               <coding>
                  <system value="{$oidMap[@oid=$oidSNOMEDCT]/@uri}"/>
                  <code value="303186005"/>
                  <display value="juridische status van patiënt"/>
               </coding>
            </category>
            <xsl:for-each select="juridische_status">
               <code>
                  <xsl:call-template name="code-to-CodeableConcept">
                     <xsl:with-param name="in"
                                     select="."/>
                  </xsl:call-template>
               </code>
            </xsl:for-each>
            <xsl:call-template name="makeReference">
               <xsl:with-param name="in"
                               select="$subject"/>
               <xsl:with-param name="wrapIn"
                               select="'subject'"/>
            </xsl:call-template>
            <xsl:for-each select="datum_aanvang">
               <onsetDateTime>
                  <xsl:attribute name="value">
                     <xsl:call-template name="format2FHIRDate">
                        <xsl:with-param name="dateTime"
                                        select="xs:string(./@value)"/>
                     </xsl:call-template>
                  </xsl:attribute>
               </onsetDateTime>
            </xsl:for-each>
            <xsl:for-each select="datum_einde">
               <abatementDateTime>
                  <xsl:attribute name="value">
                     <xsl:call-template name="format2FHIRDate">
                        <xsl:with-param name="dateTime"
                                        select="xs:string(./@value)"/>
                     </xsl:call-template>
                  </xsl:attribute>
               </abatementDateTime>
            </xsl:for-each>
         </Condition>
      </xsl:for-each>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="juridische_situatie"
                 name="nl-core-LegalSituation-Representation"
                 mode="nl-core-LegalSituation-Representation"
                 as="element(f:Condition)?">
      <!-- Creates an nl-core-LegalSituation-Representation instance as a Condition FHIR instance from ADA juridische_situatie element. -->
      <xsl:param name="in"
                 as="element()?"
                 select=".">
         <!-- ADA element as input. Defaults to self. -->
      </xsl:param>
      <xsl:param name="subject"
                 select="patient"
                 as="element()?">
         <!-- Optional ADA instance or ADA reference element for the patient. -->
      </xsl:param>
      <xsl:for-each select="$in[vertegenwoordiging]">
         <Condition>
            <xsl:call-template name="insertLogicalId">
               <xsl:with-param name="profile"
                               select="$profileNameLegalSituationRepresentation"/>
            </xsl:call-template>
            <meta>
               <profile value="{concat($urlBaseNictizProfile, $profileNameLegalSituationRepresentation)}"/>
            </meta>
            <xsl:if test="datum_einde">
               <clinicalStatus>
                  <coding>
                     <system value="http://terminology.hl7.org/CodeSystem/condition-clinical"/>
                     <code value="inactive"/>
                     <display value="Inactive"/>
                  </coding>
               </clinicalStatus>
            </xsl:if>
            <category>
               <coding>
                  <system value="{$oidMap[@oid=$oidSNOMEDCT]/@uri}"/>
                  <code value="151701000146105"/>
                  <display value="type voogd"/>
               </coding>
            </category>
            <xsl:for-each select="vertegenwoordiging">
               <code>
                  <xsl:call-template name="code-to-CodeableConcept">
                     <xsl:with-param name="in"
                                     select="."/>
                  </xsl:call-template>
               </code>
            </xsl:for-each>
            <xsl:call-template name="makeReference">
               <xsl:with-param name="in"
                               select="$subject"/>
               <xsl:with-param name="wrapIn"
                               select="'subject'"/>
            </xsl:call-template>
            <xsl:for-each select="datum_aanvang">
               <onsetDateTime>
                  <xsl:attribute name="value">
                     <xsl:call-template name="format2FHIRDate">
                        <xsl:with-param name="dateTime"
                                        select="xs:string(./@value)"/>
                     </xsl:call-template>
                  </xsl:attribute>
               </onsetDateTime>
            </xsl:for-each>
            <xsl:for-each select="datum_einde">
               <abatementDateTime>
                  <xsl:attribute name="value">
                     <xsl:call-template name="format2FHIRDate">
                        <xsl:with-param name="dateTime"
                                        select="xs:string(./@value)"/>
                     </xsl:call-template>
                  </xsl:attribute>
               </abatementDateTime>
            </xsl:for-each>
         </Condition>
      </xsl:for-each>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="juridische_situatie"
                 mode="_generateDisplay">
      <!-- Template to generate a display that can be shown when referencing this instance. -->
      <xsl:param name="profile"
                 required="yes"
                 as="xs:string">
         <!-- Parameter to indicate for which target profile a display is to be generated. -->
      </xsl:param>
      <xsl:choose>
         <xsl:when test="$profile = $profileNameLegalSituationLegalStatus">
            <xsl:variable name="parts"
                          as="item()*">
               <xsl:text>Legal situation</xsl:text>
               <xsl:if test="juridische_status/@displayName">
                  <xsl:value-of select="concat('legal status: ',juridische_status/@displayName)"/>
               </xsl:if>
               <xsl:if test="datum_aanvang[@value]">
                  <xsl:value-of select="concat('from ', datum_aanvang/@value)"/>
               </xsl:if>
               <xsl:if test="datum_einde[@value]">
                  <xsl:value-of select="concat('until ', datum_einde/@value)"/>
               </xsl:if>
            </xsl:variable>
            <xsl:value-of select="string-join($parts[. != ''], ', ')"/>
         </xsl:when>
         <xsl:when test="$profile = $profileNameLegalSituationRepresentation">
            <xsl:variable name="parts"
                          as="item()*">
               <xsl:text>Legal situation</xsl:text>
               <xsl:if test="vertegenwoordiging/@displayName">
                  <xsl:value-of select="concat('representation: ',vertegenwoordiging/@displayName)"/>
               </xsl:if>
               <xsl:if test="datum_aanvang[@value]">
                  <xsl:value-of select="concat('from ', datum_aanvang/@value)"/>
               </xsl:if>
               <xsl:if test="datum_einde[@value]">
                  <xsl:value-of select="concat('until ', datum_einde/@value)"/>
               </xsl:if>
            </xsl:variable>
            <xsl:value-of select="string-join($parts[. != ''], ', ')"/>
         </xsl:when>
      </xsl:choose>
   </xsl:template>
</xsl:stylesheet>