<?xml version="1.0" encoding="UTF-8"?>

<!-- == Provenance: YATC-internal/ada-2-fhir-r4/env/zibs/2020/payload/0.5-beta1/nl-core-CareTeam.xsl == -->
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
                xmlns:local="#local.2024111408213011051530100"
                xmlns:nm="http://www.nictiz.nl/mappings">
   <!-- ================================================================== -->
   <!--
        Converts ADA zorg_team to FHIR CareTeam resource conforming to profile nl-core-CareTeam.
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
   <xsl:variable name="profileNameCareTeam"
                 select="'nl-core-CareTeam'"/>
   <!-- ================================================================== -->
   <xsl:template match="zorg_team"
                 name="nl-core-CareTeam"
                 mode="nl-core-CareTeam"
                 as="element(f:CareTeam)">
      <!-- Creates an nl-core-CareTeam instance as a CareTeam FHIR instance from ADA zorg_team element. -->
      <xsl:param name="in"
                 as="element()?"
                 select=".">
         <!-- ADA element as input. Defaults to self. -->
      </xsl:param>
      <xsl:param name="subject"
                 as="element()?">
         <!-- Optional ADA instance or ADA reference element for the patient. -->
      </xsl:param>
      <xsl:for-each select="$in">
         <CareTeam>
            <xsl:call-template name="insertLogicalId">
               <xsl:with-param name="profile"
                               select="$profileNameCareTeam"/>
            </xsl:call-template>
            <meta>
               <profile value="{nf:get-full-profilename-from-adaelement(.)}"/>
            </meta>
            <xsl:for-each select="zorg_team_naam">
               <name value="{normalize-space(@value)}"/>
            </xsl:for-each>
            <xsl:for-each select="zorg_team_lid/contactpersoon">
               <participant>
                  <member>
                     <xsl:call-template name="makeReference">
                        <xsl:with-param name="in"
                                        select="contactpersoon"/>
                        <xsl:with-param name="profile"
                                        select="$profileNameContactPerson"/>
                     </xsl:call-template>
                  </member>
               </participant>
            </xsl:for-each>
            <xsl:for-each select="zorg_team_lid/patient">
               <participant>
                  <member>
                     <xsl:call-template name="makeReference">
                        <xsl:with-param name="in"
                                        select="patient"/>
                        <xsl:with-param name="profile"
                                        select="$profileNamePatient"/>
                     </xsl:call-template>
                  </member>
               </participant>
            </xsl:for-each>
            <xsl:for-each select="zorg_team_lid/zorgverlener">
               <participant>
                  <member>
                     <xsl:call-template name="makeReference">
                        <xsl:with-param name="in"
                                        select="zorgverlener"/>
                        <xsl:with-param name="profile"
                                        select="$profileNameHealthProfessionalPractitionerRole"/>
                     </xsl:call-template>
                  </member>
               </participant>
            </xsl:for-each>
            <xsl:for-each select="probleem">
               <reasonReference>
                  <xsl:call-template name="makeReference">
                     <xsl:with-param name="in"
                                     select="probleem"/>
                     <xsl:with-param name="profile"
                                     select="$profileNameProblem"/>
                  </xsl:call-template>
               </reasonReference>
            </xsl:for-each>
         </CareTeam>
      </xsl:for-each>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="zorg_team"
                 mode="_generateDisplay">
      <!-- Template to generate a display that can be shown when referencing this instance. -->
      <xsl:variable name="parts"
                    as="item()*">
         <xsl:text>Care team</xsl:text>
         <xsl:value-of select="zorg_team_naam/@value"/>
      </xsl:variable>
      <xsl:value-of select="string-join($parts[. != ''], ', ')"/>
   </xsl:template>
</xsl:stylesheet>