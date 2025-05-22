<?xml version="1.0" encoding="UTF-8"?>
<!--
Copyright © VZVZ

This program is free software; you can redistribute and/or modify it under the terms of 
the GNU General Public License as published by the Free Software Foundation; version 3 
of the License, and no later version.

We make every effort to ensure the files are as error-free as possible, but we take 
no responsibility for any consequences arising from errors during usage.

The full text of the license is available at http://www.gnu.org/licenses/gpl-3.0.html
-->
<xsl:stylesheet xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="#all"
    xmlns:nf="http://www.nictiz.nl/functions"
    xmlns:hl7="urn:hl7-org:v3"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:vf="http://www.vzvz.nl/functions" 
    version="3.0">

    <xsl:import href="vf.includes/vf.transformation-utils-fhir.xsl"/>

    <xsl:output method="xml" indent="yes"/>
    <!-- Dit is een conversie van query response batches van het LSP naar FHIR -->
    
    <xsl:variable name="transformationCode" as="xs:string" select="'28.2'"/>
    <xsl:variable name="zorgToepassing" as="xs:string" select="'medmij'"/>
    <xsl:variable name="fhirVersion" as="xs:string" select="'STU3'"/>

    <xsl:param name="xslDebug" select="false()" as="xs:boolean"/>

    <!--
    versionXSLT = versienummer van DEZE transformatie, default de versie van dit bestand
    -->

    <xsl:variable name="vf:versionXSLT" as="xs:string">0.1.0</xsl:variable>

    <xsl:template match="/">
        <xsl:variable name="BSN" select="//hl7:organizer[1]/hl7:recordTarget/hl7:patientRole/hl7:id"/>
        <xsl:variable name="AppID" select="//hl7:sender/hl7:device/hl7:id/@extension"/>
        <xsl:variable name="DocRefRoot"
            select="//hl7:organizer[1]/hl7:component[1]/hl7:act/hl7:reference/hl7:externalDocument/hl7:id/@root"/>
        <xsl:variable name="DocRefExt"
            select="//hl7:organizer[1]/hl7:component[1]/hl7:act/hl7:reference/hl7:externalDocument/hl7:id/@extension"/>
        <xsl:variable name="DocData"
            select="//hl7:organizer[1]/hl7:component[1]/hl7:act/hl7:reference/hl7:externalDocument/hl7:text"/>

        <xsl:if test="$BSN">
            <Binary xmlns="http://hl7.org/fhir">
                <id
                    value="{$AppID}.R.{replace($DocRefRoot, '2.16.840.1.113883.2.4', 'HL7NL')}.E.{$DocRefExt}"/>
                <xsl:call-template name="addTransformationCode">
                    <xsl:with-param name="transformationCode" select="$transformationCode"/>
                    <xsl:with-param name="versionXSLT" select="$versionXSLT"/>
                    <xsl:with-param name="type" select="'fhir'"/>
                </xsl:call-template>
                <contentType value="application/pdf"/>
                <content value="{$DocData}"/>
            </Binary>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
