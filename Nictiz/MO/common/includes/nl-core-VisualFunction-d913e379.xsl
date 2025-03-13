<?xml version="1.0" encoding="UTF-8"?>

<!-- == Provenance: HL7-mappings/ada_2_fhir-r4/zibs2020/payload/0.5-beta1/nl-core-VisualFunction.xsl == -->
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
                xmlns:uuid="http://www.uuid.org">
   <xsl:output method="xml"
               indent="yes"/>
   <xsl:strip-space elements="*"/>
   <xd:doc scope="stylesheet">
      <xd:desc>Converts ADA functie_zien to FHIR Observation resource conforming to profile nl-core-VisualFunction, FHIR DeviceUseStatement resource conforming to profile nl-core-VisualFunction.VisualAid and FHIR Device resource conforming to profile nl-core-VisualFunction.VisualAid.Product.</xd:desc>
   </xd:doc>
   <xsl:variable name="profileNameVisualFunction">nl-core-VisualFunction</xsl:variable>
   <xsl:variable name="profileNameVisualFunctionVisualAid">nl-core-VisualFunction.VisualAid</xsl:variable>
   <xsl:variable name="profileNameVisualFunctionVisualAidProduct">nl-core-VisualFunction.VisualAid.Product</xsl:variable>
   <xd:doc>
      <xd:desc>Creates an nl-core-VisualFunction instance as an Observation FHIR instance from ADA functie_zien element.</xd:desc>
      <xd:param name="in">ADA element as input. Defaults to self.</xd:param>
      <xd:param name="subject">Optional ADA instance or ADA reference element for the patient.</xd:param>
   </xd:doc>
   <xsl:template match="functie_zien"
                 name="nl-core-VisualFunction"
                 mode="nl-core-VisualFunction"
                 as="element(f:Observation)?">
      <xsl:param name="in"
                 select="."
                 as="element()?"/>
      <xsl:param name="subject"
                 select="patient/*"
                 as="element()?"/>
      <xsl:for-each select="$in">
         <Observation>
            <xsl:call-template name="insertLogicalId">
               <xsl:with-param name="profile"
                               select="$profileNameVisualFunction"/>
            </xsl:call-template>
            <meta>
               <profile value="{nf:get-full-profilename-from-adaelement(.)}"/>
            </meta>
            <status value="final"/>
            <code>
               <coding>
                  <system value="{$oidMap[@oid=$oidSNOMEDCT]/@uri}"/>
                  <code value="281004000"/>
                  <display value="visuele functie"/>
               </coding>
            </code>
            <xsl:call-template name="makeReference">
               <xsl:with-param name="in"
                               select="$subject"/>
               <xsl:with-param name="wrapIn"
                               select="'subject'"/>
            </xsl:call-template>
            <xsl:for-each select="visuele_functie">
               <valueCodeableConcept>
                  <xsl:call-template name="code-to-CodeableConcept">
                     <xsl:with-param name="in"
                                     select="."/>
                  </xsl:call-template>
               </valueCodeableConcept>
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
         </Observation>
      </xsl:for-each>
   </xsl:template>
   <xd:doc>
      <xd:desc>Creates an nl-core-VisualFunction.VisualAid instance as a DeviceUseStatement FHIR instance from ADA zien_hulpmiddel/medisch_hulpmiddel element.</xd:desc>
      <xd:param name="in">ADA element as input. Defaults to self.</xd:param>
      <xd:param name="subject">Optional ADA instance or ADA reference element for the patient.</xd:param>
      <xd:param name="reasonReference">ADA instance used to populate the reasonReference element in the MedicalDevice.</xd:param>
   </xd:doc>
   <xsl:template match="zien_hulpmiddel/medisch_hulpmiddel"
                 name="nl-core-VisualFunction.VisualAid"
                 mode="nl-core-VisualFunction.VisualAid"
                 as="element(f:DeviceUseStatement)?">
      <xsl:param name="in"
                 select="."
                 as="element()?"/>
      <xsl:param name="subject"
                 select="patient/*"
                 as="element()?"/>
      <xsl:param name="reasonReference"
                 select="ancestor::functie_zien"/>
      <xsl:call-template name="nl-core-MedicalDevice">
         <xsl:with-param name="subject"
                         select="$subject"/>
         <xsl:with-param name="profile"
                         select="$profileNameVisualFunctionVisualAid"/>
         <xsl:with-param name="reasonReference"
                         select="$reasonReference"/>
      </xsl:call-template>
   </xsl:template>
   <xd:doc>
      <xd:desc>Creates an nl-core-VisualFunction.VisualAid.Product instance as a Device FHIR instance from ADA product element.</xd:desc>
      <xd:param name="in">ADA element as input. Defaults to self.</xd:param>
      <xd:param name="subject">Optional ADA instance or ADA reference element for the patient.</xd:param>
   </xd:doc>
   <xsl:template match="product"
                 name="nl-core-VisualFunction.VisualAid.Product"
                 mode="nl-core-VisualFunction.VisualAid.Product"
                 as="element(f:Device)?">
      <xsl:param name="in"
                 select="."
                 as="element()?"/>
      <xsl:param name="subject"
                 select="patient/*"
                 as="element()?"/>
      <xsl:call-template name="nl-core-MedicalDevice.Product">
         <xsl:with-param name="subject"
                         select="$subject"/>
         <xsl:with-param name="profile"
                         select="$profileNameVisualFunctionVisualAidProduct"/>
      </xsl:call-template>
   </xsl:template>
   <xd:doc>
      <xd:desc>Template to generate a display that can be shown when referencing this instance.</xd:desc>
   </xd:doc>
   <xsl:template match="functie_zien"
                 mode="_generateDisplay">
      <xsl:variable name="parts"
                    as="item()*">
         <xsl:text>Visual function observation</xsl:text>
         <xsl:if test="visuele_functie[@displayName]">
            <xsl:value-of select="visuele_functie/@displayName"/>
         </xsl:if>
      </xsl:variable>
      <xsl:value-of select="string-join($parts[. != ''], ', ')"/>
   </xsl:template>
</xsl:stylesheet>