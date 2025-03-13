<?xml version="1.0" encoding="UTF-8"?>

<!-- == Provenance: HL7-mappings/ada_2_fhir-r4/zibs2020/payload/0.5-beta1/nl-core-CareTeam.xsl == -->
<!-- == Distribution: MP9-Medicatieproces-9.3.0; 1.0.7; 2025-01-17T18:03:28.04+01:00 == -->
<xsl:stylesheet exclude-result-prefixes="#all"
                version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://hl7.org/fhir"
                xmlns:util="urn:hl7:utilities"
                xmlns:f="http://hl7.org/fhir"
                xmlns:nf="http://www.nictiz.nl/functions"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
                xmlns:uuid="http://www.uuid.org"
                xmlns:nm="http://www.nictiz.nl/mappings">
   <xsl:output method="xml"
               indent="yes"/>
   <xsl:strip-space elements="*"/>
   <xd:doc scope="stylesheet">
      <xd:desc>Converts ADA zorg_team to FHIR CareTeam resource conforming to profile nl-core-CareTeam.</xd:desc>
   </xd:doc>
   <xsl:variable name="profileNameCareTeam">nl-core-CareTeam</xsl:variable>
   <xd:doc>
      <xd:desc>Creates an nl-core-CareTeam instance as a CareTeam FHIR instance from ADA zorg_team element.</xd:desc>
      <xd:param name="in">ADA element as input. Defaults to self.</xd:param>
      <xd:param name="subject">Optional ADA instance or ADA reference element for the patient.</xd:param>
   </xd:doc>
   <xsl:template match="zorg_team"
                 name="nl-core-CareTeam"
                 mode="nl-core-CareTeam"
                 as="element(f:CareTeam)">
      <xsl:param name="in"
                 as="element()?"
                 select="."/>
      <xsl:param name="subject"
                 as="element()?"/>
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
   <xd:doc>
      <xd:desc>Template to generate a display that can be shown when referencing this instance.</xd:desc>
   </xd:doc>
   <xsl:template match="zorg_team"
                 mode="_generateDisplay">
      <xsl:variable name="parts"
                    as="item()*">
         <xsl:text>Care team</xsl:text>
         <xsl:value-of select="zorg_team_naam/@value"/>
      </xsl:variable>
      <xsl:value-of select="string-join($parts[. != ''], ', ')"/>
   </xsl:template>
</xsl:stylesheet>