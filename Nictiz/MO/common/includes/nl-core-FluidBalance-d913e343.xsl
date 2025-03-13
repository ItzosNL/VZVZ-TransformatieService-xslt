<?xml version="1.0" encoding="UTF-8"?>

<!-- == Provenance: HL7-mappings/ada_2_fhir-r4/zibs2020/payload/0.8.0-beta.1/nl-core-FluidBalance.xsl == -->
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
      <xd:desc>Converts ADA vochtbalans to FHIR Observation resource conforming to profile nl-core-FluidBalance.</xd:desc>
   </xd:doc>
   <xsl:variable name="profileNameFluidBalance">nl-core-FluidBalance</xsl:variable>
   <xd:doc>
      <xd:desc>Creates an nl-core-FluidBalance instance as an Observation FHIR instance from ADA vochtbalans element.</xd:desc>
      <xd:param name="in">ADA element as input. Defaults to self.</xd:param>
      <xd:param name="subject">Optional ADA instance or ADA reference element for the patient.</xd:param>
   </xd:doc>
   <xsl:template match="vochtbalans"
                 name="nl-core-FluidBalance"
                 mode="nl-core-FluidBalance"
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
                               select="$profileNameFluidBalance"/>
            </xsl:call-template>
            <meta>
               <profile value="{nf:get-full-profilename-from-adaelement(.)}"/>
            </meta>
            <status value="final"/>
            <code>
               <coding>
                  <system value="{$oidMap[@oid=$oidSNOMEDCT]/@uri}"/>
                  <code value="710853006"/>
                  <display value="evaluatie van vochtbalans"/>
               </coding>
            </code>
            <xsl:call-template name="makeReference">
               <xsl:with-param name="in"
                               select="$subject"/>
               <xsl:with-param name="wrapIn"
                               select="'subject'"/>
            </xsl:call-template>
            <xsl:if test="vochtbalans_starttijd or vochtbalans_stoptijd">
               <effectivePeriod>
                  <xsl:if test="vochtbalans_starttijd">
                     <start>
                        <xsl:attribute name="value">
                           <xsl:call-template name="format2FHIRDate">
                              <xsl:with-param name="dateTime"
                                              select="xs:string(vochtbalans_starttijd/@value)"/>
                           </xsl:call-template>
                        </xsl:attribute>
                     </start>
                  </xsl:if>
                  <xsl:if test="vochtbalans_stoptijd">
                     <end>
                        <xsl:attribute name="value">
                           <xsl:call-template name="format2FHIRDate">
                              <xsl:with-param name="dateTime"
                                              select="xs:string(vochtbalans_stoptijd/@value)"/>
                           </xsl:call-template>
                        </xsl:attribute>
                     </end>
                  </xsl:if>
               </effectivePeriod>
            </xsl:if>
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
            <xsl:for-each select="vocht_totaal_in">
               <component>
                  <code>
                     <coding>
                        <system value="{$oidMap[@oid=$oidSNOMEDCT]/@uri}"/>
                        <code value="251852001"/>
                        <display value="totale vochtinname"/>
                     </coding>
                  </code>
                  <valueQuantity>
                     <xsl:call-template name="hoeveelheid-to-Quantity">
                        <xsl:with-param name="in"
                                        select="."/>
                     </xsl:call-template>
                  </valueQuantity>
               </component>
            </xsl:for-each>
            <xsl:for-each select="vocht_totaal_uit">
               <component>
                  <code>
                     <coding>
                        <system value="{$oidMap[@oid=$oidSNOMEDCT]/@uri}"/>
                        <code value="251841007"/>
                        <display value="totale vochtuitscheiding"/>
                     </coding>
                  </code>
                  <valueQuantity>
                     <xsl:call-template name="hoeveelheid-to-Quantity">
                        <xsl:with-param name="in"
                                        select="."/>
                     </xsl:call-template>
                  </valueQuantity>
               </component>
            </xsl:for-each>
         </Observation>
      </xsl:for-each>
   </xsl:template>
</xsl:stylesheet>