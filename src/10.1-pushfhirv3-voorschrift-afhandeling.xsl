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
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" 
    xmlns:hl7="urn:hl7-org:v3"
    xmlns:vf="http://www.vzvz.nl/functions" 
    xmlns="urn:hl7-org:v3" 
    exclude-result-prefixes="#all"
    version="3.0">
    
    <xsl:import href="vf.includes/vf.transformation-utils-v3.xsl"/>
    
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>Transformatie voor sturen afhandelen medicatieVoorschrift</xd:p>
            
            <xd:p><xd:b>Created on:</xd:b> 2023-07-07</xd:p>
            <xd:p><xd:b>Author:</xd:b> VZVZ</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    
    <xsl:output indent="yes"/>
    
    <!-- pass the metaData object -->
    <xsl:param name="metaData"/>
    
    <xsl:param name="xslDebug" select="false()" as="xs:boolean"/>
    <xsl:param name="logLevel" select="$logDEBUG"/>
    
    <!-- versionXSLT = versienummer van DEZE combo -->
    <xsl:variable name="versionXSLT" as="xs:string">0.2.2</xsl:variable>
    <xsl:variable name="transformationCode" as="xs:string" select="'10.1'"/>
    
    <xsl:variable name="buildingBlock" select="'PAMV'"/>
    <xsl:variable name="schematronRef" select="concat('file:', $svnAortaMP9, '/schematron_closed_warnings/mp-vzvz-afhandelenMedicatievoorschrift.sch')"/>
    <xsl:variable name="schematronRefZT" select="concat('file:', $svnAortaZTMP, '/mp-runtime-develop/mp-mp93_av.sch')"/>
    
    <xd:doc>
        <xd:desc>Main template</xd:desc>
    </xd:doc>
    <xsl:template match="/">
        <xsl:variable name="payload">
            <organizer classCode="CLUSTER" moodCode="EVN">
                <xsl:apply-templates select="./hl7:organizer/*" mode="wrapper"/>
            </organizer>
        </xsl:variable>        
        
        <xsl:if test="$xslDebug">
            <xsl:processing-instruction name="xml-model">phase="#ALL" href="<xsl:value-of select="$schematronRef"/>" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:processing-instruction>
            <xsl:processing-instruction name="xml-model">phase="#ALL" href="<xsl:value-of select="$schematronRefZT"/>" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:processing-instruction>
        </xsl:if>
        
        <xsl:variable name="interactionId" select="$mapAORTAWrapper[@buildingblock=$buildingBlock]/@interactionId" as="xs:string"/>
        
        <xsl:element name="{$interactionId}" namespace="urn:hl7-org:v3">
            <xsl:if test="$xslDebug">
                <xsl:variable name="schemaRef" select="concat('file:', $svnAortaMP9, '/schemas/', $mapAORTAWrapper[@buildingblock=$buildingBlock]/@interactionId, '.xsd')"/>
                <xsl:attribute name="xsi:schemaLocation">urn:hl7-org:v3 <xsl:value-of select="$schemaRef"/></xsl:attribute>
            </xsl:if>
            
            <xsl:call-template name="buildWrapperElements">
                <xsl:with-param name="buildingBlock" select="$buildingBlock"/>
                <xsl:with-param name="hasOverseer" select="true()"/>
                <xsl:with-param name="metaData" select="$metaData"/>
                <!-- 2025-01-21 remove original query param because the necessary ids are part of the metadata -->
<!--                <xsl:with-param name="originalQuery" select="''"/>-->
                <xsl:with-param name="payload" select="$payload"/>
                <xsl:with-param name="transformationCode" select="$transformationCode"/>
                <xsl:with-param name="versionXSLT" select="$versionXSLT"/>
            </xsl:call-template>            
        </xsl:element>
    </xsl:template>    
</xsl:stylesheet>
