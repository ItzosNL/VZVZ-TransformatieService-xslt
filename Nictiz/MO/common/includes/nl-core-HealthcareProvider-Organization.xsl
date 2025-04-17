<?xml version="1.0" encoding="UTF-8"?>

<!-- == Provenance: YATC-internal/fhir-2-ada-r4/env/zibs/2020/payload/0.8.0-beta.1/nl-core-HealthcareProvider-Organization.xsl == -->
<!-- == Distribution: MP9-Medicatieproces-9.3.0; 1.0.10; 2025-04-16T18:06:20.52+02:00 == -->
<xsl:stylesheet exclude-result-prefixes="#all"
                version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:f="http://hl7.org/fhir"
                xmlns:nf="http://www.nictiz.nl/functions"
                xmlns:yatcs="https://nictiz.nl/ns/YATC-shared"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
                xmlns:local="urn:fhir:stu3:functions">
   <!-- ================================================================== -->
   <!--
        TBD
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
   <!-- ================================================================== -->
   <xsl:template match="f:Location"
                 mode="nl-core-HealthcareProvider-Organization">
      <!-- Template to convert f:Location to ADA zorgaanbieder -->
      <xsl:param name="doAdaId"
                 select="true()"
                 as="xs:boolean">
         <!-- whether to output id attribute in ada -->
      </xsl:param>
      <xsl:variable name="entryFullURrlAtValue"
                    select="../../f:fullUrl/@value"/>
      <xsl:variable name="theManagingOrganization"
                    select="nf:resolveRefInBundle(f:managingOrganization)/f:Organization"/>
      <zorgaanbieder>
         <xsl:if test="$doAdaId">
            <xsl:attribute name="id"
                           select="nf:convert2NCName($entryFullURrlAtValue)"/>
         </xsl:if>
         <!-- zorgaanbieder_identificatienummer -->
         <xsl:apply-templates select="$theManagingOrganization/f:identifier"
                              mode="#current"/>
         <!-- organisatie_naam -->
         <xsl:apply-templates select="$theManagingOrganization/f:name"
                              mode="#current"/>
         <!-- afdeling_specialisme -->
         <xsl:apply-templates select="f:type[f:coding/f:system[@value = concat('urn:oid:', $oidAGBSpecialismen) or @value = $oidMap[@oid = $oidAGBSpecialismen]/@uri]]"
                              mode="#current"/>
         <!-- contactgegevens -->
         <xsl:if test="f:telecom">
            <contactgegevens>
               <xsl:apply-templates select="f:telecom"
                                    mode="nl-core-ContactInformation"/>
            </contactgegevens>
         </xsl:if>
         <!-- adresgegevens -->
         <xsl:apply-templates select="f:address"
                              mode="nl-core-AddressInformation"/>
         <!-- organisatie_type -->
         <xsl:apply-templates select="f:type[f:coding/f:system[@value = concat('urn:oid:', $oidRoleCodeNLOrganizations) or @value = $oidMap[@oid = $oidRoleCodeNLOrganizations]/@uri]]"
                              mode="#current"/>
         <!-- organisatie_locatie-->
         <xsl:if test="f:name[@value]">
            <!-- both locatie_naam and _nummer end up in f:name, we don't know which is which, simply append in one name -->
            <organisatie_locatie>
               <locatie_naam value="{string-join(f:name/@value, ' - ')}"/>
            </organisatie_locatie>
         </xsl:if>
      </zorgaanbieder>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:Organization"
                 mode="nl-core-HealthcareProvider-Organization">
      <!-- Template to convert f:Organization to ADA zorgaanbieder -->
      <xsl:param name="doAdaId"
                 select="true()"
                 as="xs:boolean">
         <!-- whether to output id attribute in ada -->
      </xsl:param>
      <xsl:variable name="entryFullURrlAtValue"
                    select="../../f:fullUrl/@value"/>
      <zorgaanbieder>
         <xsl:if test="$doAdaId">
            <xsl:attribute name="id"
                           select="nf:convert2NCName($entryFullURrlAtValue)"/>
         </xsl:if>
         <!-- zorgaanbieder_identificatienummer -->
         <xsl:apply-templates select="f:identifier"
                              mode="#current"/>
         <!-- organisatie_naam -->
         <xsl:apply-templates select="f:name"
                              mode="#current"/>
         <!-- afdeling_specialisme -->
         <xsl:apply-templates select="f:type[f:coding/f:system[@value = concat('urn:oid:', $oidAGBSpecialismen) or @value = $oidMap[@oid = $oidAGBSpecialismen]/@uri]]"
                              mode="#current"/>
         <!-- contactgegevens -->
         <xsl:if test="f:telecom">
            <contactgegevens>
               <xsl:apply-templates select="f:telecom"
                                    mode="nl-core-ContactInformation"/>
            </contactgegevens>
         </xsl:if>
         <!-- adresgegevens -->
         <xsl:apply-templates select="f:address"
                              mode="nl-core-AddressInformation"/>
         <!-- organisatie_type -->
         <xsl:apply-templates select="f:type[f:coding/f:system[@value = concat('urn:oid:', $oidRoleCodeNLOrganizations) or @value = $oidMap[@oid = $oidRoleCodeNLOrganizations]/@uri]]"
                              mode="#current"/>
         <!-- organisatie_locatie TODO -->
      </zorgaanbieder>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:identifier"
                 mode="nl-core-HealthcareProvider-Organization">
      <!-- Template to convert f:identifier to zorgverlener_identificatienummer -->
      <xsl:param name="organizationIdUnderscore"
                 select="false()"
                 tunnel="yes">
         <!-- Optional boolean to create ADA element zorgaanbieder_identificatie_nummer -->
      </xsl:param>
      <xsl:variable name="adaElementName">
         <xsl:choose>
            <xsl:when test="$organizationIdUnderscore = true()">zorgaanbieder_identificatie_nummer</xsl:when>
            <xsl:otherwise>zorgaanbieder_identificatienummer</xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:call-template name="Identifier-to-identificatie">
         <xsl:with-param name="adaElementName"
                         select="$adaElementName"/>
      </xsl:call-template>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:name"
                 mode="nl-core-HealthcareProvider-Organization">
      <!-- Template to convert f:name to organisatie_naam -->
      <organisatie_naam value="{@value}"/>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="f:type"
                 mode="nl-core-HealthcareProvider-Organization">
      <!-- Template to convert f:type to organisatie_type -->
      <xsl:choose>
         <xsl:when test="f:coding/f:system[@value = concat('urn:oid:', $oidAGBSpecialismen) or @value = $oidMap[@oid = $oidAGBSpecialismen]/@uri]">
            <afdeling_specialisme>
               <xsl:call-template name="Coding-to-code">
                  <xsl:with-param name="in"
                                  select="f:coding"/>
               </xsl:call-template>
            </afdeling_specialisme>
         </xsl:when>
         <xsl:when test="f:coding/f:system[@value = concat('urn:oid:', $oidRoleCodeNLOrganizations) or @value = $oidMap[@oid = $oidRoleCodeNLOrganizations]/@uri]">
            <organisatie_type>
               <xsl:call-template name="Coding-to-code">
                  <xsl:with-param name="in"
                                  select="f:coding"/>
               </xsl:call-template>
            </organisatie_type>
         </xsl:when>
      </xsl:choose>
   </xsl:template>
</xsl:stylesheet>