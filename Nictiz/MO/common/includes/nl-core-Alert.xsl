<?xml version="1.0" encoding="UTF-8"?>

<!-- == Provenance: YATC-internal/ada-2-fhir-r4/env/zibs/2020/payload/0.5-beta1/nl-core-Alert.xsl == -->
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
                xmlns:local="#local.2024111408212998574570100">
   <!-- ================================================================== -->
   <!--
        Converts ADA alert to FHIR Flag resource conforming to profile nl-core-Alert.
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
   <xsl:variable name="profileNameAlert"
                 select="'nl-core-Alert'"/>
   <!-- ================================================================== -->
   <xsl:template match="alert"
                 name="nl-core-Alert"
                 mode="nl-core-Alert"
                 as="element(f:Flag)">
      <!-- Creates an nl-core-Alert instance as a Flag FHIR instance from ADA alert element. -->
      <xsl:param name="in"
                 as="element()?"
                 select=".">
         <!-- ADA element as input. Defaults to self. -->
      </xsl:param>
      <xsl:param name="subject"
                 select="patient/*"
                 as="element()?">
         <!-- The subject as ADA element or reference. -->
      </xsl:param>
      <xsl:for-each select="$in">
         <Flag>
            <xsl:call-template name="insertLogicalId">
               <xsl:with-param name="profile"
                               select="$profileNameAlert"/>
            </xsl:call-template>
            <meta>
               <profile value="{concat($urlBaseNictizProfile, $profileNameAlert)}"/>
            </meta>
            <xsl:for-each select="conditie/probleem">
               <extension url="http://hl7.org/fhir/StructureDefinition/flag-detail">
                  <valueReference>
                     <xsl:call-template name="makeReference">
                        <xsl:with-param name="profile"
                                        select="$profileNameProblem"/>
                     </xsl:call-template>
                  </valueReference>
               </extension>
            </xsl:for-each>
            <xsl:for-each select="toelichting">
               <extension url="http://nictiz.nl/fhir/StructureDefinition/ext-Comment">
                  <valueString>
                     <xsl:call-template name="string-to-string">
                        <xsl:with-param name="in"
                                        select="."/>
                     </xsl:call-template>
                  </valueString>
               </extension>
            </xsl:for-each>
            <!--  Guidance as given by the profile:
                    * EndDateTime present and in the past: _inactive_
                    * EndDateTime absent: _active_
                    * EndDateTime present and in the future - goes against both FHIR and zib definitions, but in a case where this might occur: _active_
                -->
            <status>
               <xsl:choose>
                  <xsl:when test="xs:date(eind_datum_tijd/@value) lt current-date() or xs:dateTime(eind_datum_tijd/@value) lt current-dateTime()">
                     <xsl:attribute name="value"
                                    select="'inactive'"/>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:attribute name="value"
                                    select="'active'"/>
                  </xsl:otherwise>
               </xsl:choose>
            </status>
            <xsl:for-each select="alert_type">
               <category>
                  <xsl:call-template name="code-to-CodeableConcept"/>
               </category>
            </xsl:for-each>
            <xsl:choose>
               <xsl:when test="alert_naam">
                  <xsl:for-each select="alert_naam">
                     <code>
                        <xsl:call-template name="code-to-CodeableConcept"/>
                     </code>
                  </xsl:for-each>
               </xsl:when>
               <xsl:when test="not(alert_naam) and conditie/probleem">
                  <code>
                     <coding>
                        <system value="http://terminology.hl7.org/CodeSystem/data-absent-reason"/>
                        <code value="not-applicable"/>
                        <display value="Not Applicable"/>
                     </coding>
                  </code>
               </xsl:when>
            </xsl:choose>
            <xsl:for-each select="$subject">
               <xsl:call-template name="makeReference">
                  <xsl:with-param name="in"
                                  select="$subject"/>
                  <xsl:with-param name="wrapIn"
                                  select="'subject'"/>
               </xsl:call-template>
            </xsl:for-each>
            <xsl:if test="begin_datum_tijd or eind_datum_tijd">
               <period>
                  <xsl:for-each select="begin_datum_tijd">
                     <start>
                        <xsl:attribute name="value">
                           <xsl:call-template name="format2FHIRDate">
                              <xsl:with-param name="dateTime"
                                              select="@value"/>
                           </xsl:call-template>
                        </xsl:attribute>
                     </start>
                  </xsl:for-each>
                  <xsl:for-each select="eind_datum_tijd">
                     <end>
                        <xsl:attribute name="value">
                           <xsl:call-template name="format2FHIRDate">
                              <xsl:with-param name="dateTime"
                                              select="@value"/>
                           </xsl:call-template>
                        </xsl:attribute>
                     </end>
                  </xsl:for-each>
               </period>
            </xsl:if>
         </Flag>
      </xsl:for-each>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="alert"
                 mode="_generateId">
      <!-- Template to generate a unique id to identify this instance. -->
      <xsl:variable name="parts">
         <xsl:text>Alert</xsl:text>
         <xsl:value-of select="alert_type/@displayName"/>
         <xsl:value-of select="alert_naam/@displayName"/>
         <xsl:if test="begin_datum_tijd/@value">
            <xsl:value-of select="concat('start datum', begin_datum_tijd/@value)"/>
         </xsl:if>
         <xsl:if test="eind_datum_tijd/@value">
            <xsl:value-of select="concat('eind datum', eind_datum_tijd/@value)"/>
         </xsl:if>
         <xsl:value-of select="toelichting/@value"/>
      </xsl:variable>
      <xsl:value-of select="substring(replace(string-join($parts, '-'), '[^A-Za-z0-9-.]', ''), 1, 64)"/>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="alert"
                 mode="_generateDisplay">
      <!-- Template to generate a display that can be shown when referencing this instance. -->
      <xsl:variable name="parts">
         <xsl:text>Alert</xsl:text>
         <xsl:value-of select="alert_naam/@displayName"/>
         <xsl:if test="begin_datum_tijd/@value">
            <xsl:value-of select="concat('start datum: ', begin_datum_tijd/@value)"/>
         </xsl:if>
         <xsl:if test="eind_datum_tijd/@value">
            <xsl:value-of select="concat('eind datum: ', eind_datum_tijd/@value)"/>
         </xsl:if>
      </xsl:variable>
      <xsl:value-of select="string-join($parts, ', ')"/>
   </xsl:template>
</xsl:stylesheet>