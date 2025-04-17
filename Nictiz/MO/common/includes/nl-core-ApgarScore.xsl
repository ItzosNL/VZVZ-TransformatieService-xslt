<?xml version="1.0" encoding="UTF-8"?>

<!-- == Provenance: YATC-internal/ada-2-fhir-r4/env/zibs/2020/payload/0.8.0-beta.1/nl-core-ApgarScore.xsl == -->
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
                xmlns:local="urn:fhir:stu3:functions">
   <!-- ================================================================== -->
   <!--
        Converts ADA apgar_score to FHIR Observation resource conforming to profiles nl-core-ApgarScore-1Minute, nl-core-ApgarScore-5Minute and nl-core-ApgarScore-10Minute.
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
   <xsl:variable name="profileNameApgarScore1Minute"
                 select="'nl-core-ApgarScore-1Minute'"/>
   <xsl:variable name="profileNameApgarScore5Minute"
                 select="'nl-core-ApgarScore-5Minute'"/>
   <xsl:variable name="profileNameApgarScore10Minute"
                 select="'nl-core-ApgarScore-10Minute'"/>
   <!-- ================================================================== -->
   <xsl:template match="apgar_score"
                 name="nl-core-ApgarScore"
                 mode="nl-core-ApgarScore"
                 as="element(f:Observation)?">
      <!-- Creates an nl-core-ApgarScore instance as an Observation FHIR instance from ADA apgar_score element. -->
      <xsl:param name="in"
                 select="."
                 as="element()?">
         <!-- ADA element as input. Defaults to self. -->
      </xsl:param>
      <xsl:param name="subject"
                 select="patient/*"
                 as="element()?">
         <!-- Optional ADA instance or ADA reference element for the patient. -->
      </xsl:param>
      <xsl:param name="profile"
                 select="$profileNameApgarScore1Minute"
                 as="xs:string">
         <!-- Optional string that represents the profile of which a FHIR resource should be created. Defaults to 'nl-core-ApgarScore-1Minute'. -->
      </xsl:param>
      <xsl:variable name="apgarScoreCode">
         <xsl:choose>
            <xsl:when test="$profile = $profileNameApgarScore1Minute">
               <xsl:value-of select="'9272-6'"/>
            </xsl:when>
            <xsl:when test="$profile = $profileNameApgarScore5Minute">
               <xsl:value-of select="'9274-2'"/>
            </xsl:when>
            <xsl:when test="$profile = $profileNameApgarScore10Minute">
               <xsl:value-of select="'9271-8'"/>
            </xsl:when>
         </xsl:choose>
      </xsl:variable>
      <xsl:variable name="apgarScoreCodeDisplay">
         <xsl:choose>
            <xsl:when test="$profile = $profileNameApgarScore1Minute">
               <xsl:value-of select="'1 minute Apgar Score'"/>
            </xsl:when>
            <xsl:when test="$profile = $profileNameApgarScore5Minute">
               <xsl:value-of select="'5 minute Apgar Score'"/>
            </xsl:when>
            <xsl:when test="$profile = $profileNameApgarScore10Minute">
               <xsl:value-of select="'10 minute Apgar Score'"/>
            </xsl:when>
         </xsl:choose>
      </xsl:variable>
      <xsl:variable name="apgarRespiratoryScoreCode">
         <xsl:choose>
            <xsl:when test="$profile = $profileNameApgarScore1Minute">
               <xsl:value-of select="'32410-3'"/>
            </xsl:when>
            <xsl:when test="$profile = $profileNameApgarScore5Minute">
               <xsl:value-of select="'32415-2'"/>
            </xsl:when>
            <xsl:when test="$profile = $profileNameApgarScore10Minute">
               <xsl:value-of select="'32405-3'"/>
            </xsl:when>
         </xsl:choose>
      </xsl:variable>
      <xsl:variable name="apgarRespiratoryScoreCodeDisplay">
         <xsl:choose>
            <xsl:when test="$profile = $profileNameApgarScore1Minute">
               <xsl:value-of select="'1 minute Apgar Respiratory effort'"/>
            </xsl:when>
            <xsl:when test="$profile = $profileNameApgarScore5Minute">
               <xsl:value-of select="'5 minute Apgar Respiratory effort'"/>
            </xsl:when>
            <xsl:when test="$profile = $profileNameApgarScore10Minute">
               <xsl:value-of select="'10 minute Apgar Respiratory effort'"/>
            </xsl:when>
         </xsl:choose>
      </xsl:variable>
      <xsl:variable name="apgarAppearanceScoreCode">
         <xsl:choose>
            <xsl:when test="$profile = $profileNameApgarScore1Minute">
               <xsl:value-of select="'32406-1'"/>
            </xsl:when>
            <xsl:when test="$profile = $profileNameApgarScore5Minute">
               <xsl:value-of select="'32411-1'"/>
            </xsl:when>
            <xsl:when test="$profile = $profileNameApgarScore10Minute">
               <xsl:value-of select="'32401-2'"/>
            </xsl:when>
         </xsl:choose>
      </xsl:variable>
      <xsl:variable name="apgarAppearanceScoreCodeDisplay">
         <xsl:choose>
            <xsl:when test="$profile = $profileNameApgarScore1Minute">
               <xsl:value-of select="'1 minute Apgar Color'"/>
            </xsl:when>
            <xsl:when test="$profile = $profileNameApgarScore5Minute">
               <xsl:value-of select="'5 minute Apgar Color'"/>
            </xsl:when>
            <xsl:when test="$profile = $profileNameApgarScore10Minute">
               <xsl:value-of select="'10 minute Apgar Color'"/>
            </xsl:when>
         </xsl:choose>
      </xsl:variable>
      <xsl:variable name="apgarPulseScoreCode">
         <xsl:choose>
            <xsl:when test="$profile = $profileNameApgarScore1Minute">
               <xsl:value-of select="'32407-9'"/>
            </xsl:when>
            <xsl:when test="$profile = $profileNameApgarScore5Minute">
               <xsl:value-of select="'32412-9'"/>
            </xsl:when>
            <xsl:when test="$profile = $profileNameApgarScore10Minute">
               <xsl:value-of select="'32402-0'"/>
            </xsl:when>
         </xsl:choose>
      </xsl:variable>
      <xsl:variable name="apgarPulseScoreCodeDisplay">
         <xsl:choose>
            <xsl:when test="$profile = $profileNameApgarScore1Minute">
               <xsl:value-of select="'1 minute Apgar Heart rate'"/>
            </xsl:when>
            <xsl:when test="$profile = $profileNameApgarScore5Minute">
               <xsl:value-of select="'5 minute Apgar Heart rate'"/>
            </xsl:when>
            <xsl:when test="$profile = $profileNameApgarScore10Minute">
               <xsl:value-of select="'10 minute Apgar Heart rate'"/>
            </xsl:when>
         </xsl:choose>
      </xsl:variable>
      <xsl:variable name="apgarGrimaceScoreCode">
         <xsl:choose>
            <xsl:when test="$profile = $profileNameApgarScore1Minute">
               <xsl:value-of select="'32409-5'"/>
            </xsl:when>
            <xsl:when test="$profile = $profileNameApgarScore5Minute">
               <xsl:value-of select="'32414-5'"/>
            </xsl:when>
            <xsl:when test="$profile = $profileNameApgarScore10Minute">
               <xsl:value-of select="'32404-6'"/>
            </xsl:when>
         </xsl:choose>
      </xsl:variable>
      <xsl:variable name="apgarGrimaceScoreCodeDisplay">
         <xsl:choose>
            <xsl:when test="$profile = $profileNameApgarScore1Minute">
               <xsl:value-of select="'1 minute Apgar Reflex irritability'"/>
            </xsl:when>
            <xsl:when test="$profile = $profileNameApgarScore5Minute">
               <xsl:value-of select="'5 minute Apgar Reflex irritability'"/>
            </xsl:when>
            <xsl:when test="$profile = $profileNameApgarScore10Minute">
               <xsl:value-of select="'10 minute Apgar Reflex irritability'"/>
            </xsl:when>
         </xsl:choose>
      </xsl:variable>
      <xsl:variable name="apgarMuscleToneScoreCode">
         <xsl:choose>
            <xsl:when test="$profile = $profileNameApgarScore1Minute">
               <xsl:value-of select="'32408-7'"/>
            </xsl:when>
            <xsl:when test="$profile = $profileNameApgarScore5Minute">
               <xsl:value-of select="'32413-7'"/>
            </xsl:when>
            <xsl:when test="$profile = $profileNameApgarScore10Minute">
               <xsl:value-of select="'32403-8'"/>
            </xsl:when>
         </xsl:choose>
      </xsl:variable>
      <xsl:variable name="apgarMuscleToneScoreCodeDisplay">
         <xsl:choose>
            <xsl:when test="$profile = $profileNameApgarScore1Minute">
               <xsl:value-of select="'1 minute Apgar Muscle tone'"/>
            </xsl:when>
            <xsl:when test="$profile = $profileNameApgarScore5Minute">
               <xsl:value-of select="'5 minute Apgar Muscle tone'"/>
            </xsl:when>
            <xsl:when test="$profile = $profileNameApgarScore10Minute">
               <xsl:value-of select="'10 minute Apgar Muscle tone'"/>
            </xsl:when>
         </xsl:choose>
      </xsl:variable>
      <xsl:for-each select="$in">
         <Observation>
            <xsl:call-template name="insertLogicalId">
               <xsl:with-param name="profile"
                               select="$profile"/>
            </xsl:call-template>
            <meta>
               <profile value="{concat($urlBaseNictizProfile, $profile)}"/>
            </meta>
            <status value="final"/>
            <code>
               <coding>
                  <system value="{$oidMap[@oid=$oidLOINC]/@uri}"/>
                  <code value="{$apgarScoreCode}"/>
                  <display value="{$apgarScoreCodeDisplay}"/>
               </coding>
            </code>
            <xsl:call-template name="makeReference">
               <xsl:with-param name="in"
                               select="$subject"/>
               <xsl:with-param name="wrapIn"
                               select="'subject'"/>
            </xsl:call-template>
            <xsl:for-each select="apgar_score_datum_tijd">
               <effectiveDateTime>
                  <xsl:call-template name="date-to-datetime">
                     <xsl:with-param name="in"
                                     select="."/>
                  </xsl:call-template>
               </effectiveDateTime>
            </xsl:for-each>
            <xsl:for-each select="apgar_score_totaal">
               <valueInteger>
                  <xsl:attribute name="value">
                     <xsl:value-of select="@value"/>
                  </xsl:attribute>
               </valueInteger>
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
            <xsl:for-each select="ademhaling_score">
               <component>
                  <code>
                     <coding>
                        <system value="{$oidMap[@oid=$oidLOINC]/@uri}"/>
                        <code value="{$apgarRespiratoryScoreCode}"/>
                        <display value="{$apgarRespiratoryScoreCodeDisplay}"/>
                     </coding>
                  </code>
                  <valueCodeableConcept>
                     <xsl:call-template name="code-to-CodeableConcept">
                        <xsl:with-param name="in"
                                        select="."/>
                     </xsl:call-template>
                  </valueCodeableConcept>
               </component>
            </xsl:for-each>
            <xsl:for-each select="huidskleur_score">
               <component>
                  <code>
                     <coding>
                        <system value="{$oidMap[@oid=$oidLOINC]/@uri}"/>
                        <code value="{$apgarAppearanceScoreCode}"/>
                        <display value="{$apgarAppearanceScoreCodeDisplay}"/>
                     </coding>
                  </code>
                  <valueCodeableConcept>
                     <xsl:call-template name="code-to-CodeableConcept">
                        <xsl:with-param name="in"
                                        select="."/>
                     </xsl:call-template>
                  </valueCodeableConcept>
               </component>
            </xsl:for-each>
            <xsl:for-each select="hartslag_score">
               <component>
                  <code>
                     <coding>
                        <system value="{$oidMap[@oid=$oidLOINC]/@uri}"/>
                        <code value="{$apgarPulseScoreCode}"/>
                        <display value="{$apgarPulseScoreCodeDisplay}"/>
                     </coding>
                  </code>
                  <valueCodeableConcept>
                     <xsl:call-template name="code-to-CodeableConcept">
                        <xsl:with-param name="in"
                                        select="."/>
                     </xsl:call-template>
                  </valueCodeableConcept>
               </component>
            </xsl:for-each>
            <xsl:for-each select="reflexen_score">
               <component>
                  <code>
                     <coding>
                        <system value="{$oidMap[@oid=$oidLOINC]/@uri}"/>
                        <code value="{$apgarGrimaceScoreCode}"/>
                        <display value="{$apgarGrimaceScoreCodeDisplay}"/>
                     </coding>
                  </code>
                  <valueCodeableConcept>
                     <xsl:call-template name="code-to-CodeableConcept">
                        <xsl:with-param name="in"
                                        select="."/>
                     </xsl:call-template>
                  </valueCodeableConcept>
               </component>
            </xsl:for-each>
            <xsl:for-each select="spierspanning_score">
               <component>
                  <code>
                     <coding>
                        <system value="{$oidMap[@oid=$oidLOINC]/@uri}"/>
                        <code value="{$apgarMuscleToneScoreCode}"/>
                        <display value="{$apgarMuscleToneScoreCodeDisplay}"/>
                     </coding>
                  </code>
                  <valueCodeableConcept>
                     <xsl:call-template name="code-to-CodeableConcept">
                        <xsl:with-param name="in"
                                        select="."/>
                     </xsl:call-template>
                  </valueCodeableConcept>
               </component>
            </xsl:for-each>
         </Observation>
      </xsl:for-each>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="apgar_score"
                 mode="_generateDisplay">
      <!-- Template to generate a display that can be shown when referencing this instance. -->
      <xsl:variable name="parts"
                    as="item()*">
         <xsl:text>Apgar score observation</xsl:text>
         <xsl:if test="apgar_score_datum_tijd[@value]">
            <xsl:value-of select="concat('measurement date ', apgar_score_datum_tijd/@value)"/>
         </xsl:if>
         <xsl:if test="apgar_score_totaal[@value]">
            <xsl:value-of select="concat('score ', apgar_score_totaal/@value)"/>
         </xsl:if>
      </xsl:variable>
      <xsl:value-of select="string-join($parts[. != ''], ', ')"/>
   </xsl:template>
</xsl:stylesheet>