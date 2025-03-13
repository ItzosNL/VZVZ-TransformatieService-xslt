<?xml version="1.0" encoding="UTF-8"?>
<!--
Copyright © VZVZ (standaardisatie@vzvz.nl)

This program is free software; you can redistribute it and/or modify it under the terms of the
GNU Lesser General Public License as published by the Free Software Foundation; either version
2.1 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Lesser General Public License for more details.

The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
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
            <xd:p>Transformatie voor opleveren MedicatieVerstrekking</xd:p>
            
            <xd:p><xd:b>Created on:</xd:b> 2023-07-04</xd:p>
            <xd:p><xd:b>Author:</xd:b> VZVZ</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    
    <xsl:output indent="yes"/>
    
    <!-- pass originalQuery message -->
    <!-- 2025-01-21 remove original query param because the necessary ids are part of the metadata -->
<!--    <xsl:param name="originalQuery"/>-->
    <!-- pass the metaData object -->
    <xsl:param name="metaData"/>
    
    <xsl:param name="xslDebug" select="false()" as="xs:boolean"/>
    <xsl:param name="logLevel" select="$logDEBUG"/>
    
    <!-- versionXSLT = versienummer van DEZE combo -->
    <xsl:variable name="versionXSLT" as="xs:string">1.0.0</xsl:variable>
    <xsl:variable name="transformationCode" as="xs:string" select="'6.4'"/>
    
    <xsl:variable name="buildingBlock" select="'MVE'"/>
    <xsl:variable name="schematronRef" select="concat('file:', $svnAortaMP9, '/schematron_closed_warnings/mp-vzvz-opleverenMedicatieverstrekkingen.sch')"/>
    <xsl:variable name="schematronRefZT" select="concat('file:', $svnAortaZTMP, '/mp-runtime-develop/mp-mp93_mg_mve.sch')"/>
        
    <xd:doc>
        <xd:desc>Main template</xd:desc>
    </xd:doc>
    <xsl:template match="/">
        <xsl:variable name="payload">
            <organizer classCode="CLUSTER" moodCode="EVN">
                <xsl:apply-templates select="./hl7:organizer/*" mode="wrapper"/>
            </organizer>
        </xsl:variable>        
        
        <xsl:call-template name="buildV3message">
            <xsl:with-param name="xslDebug" select="$xslDebug"/>
            <xsl:with-param name="schematronRef" select="$schematronRef"/>
            <xsl:with-param name="schematronRefZT" select="$schematronRefZT"/>
            <xsl:with-param name="buildingBlock" select="$buildingBlock"/>
            <xsl:with-param name="metaData" select="$metaData"/>
            <!-- 2025-01-21 remove original query param because the necessary ids are part of the metadata -->
<!--            <xsl:with-param name="originalQuery" select="$originalQuery"/>-->
            <xsl:with-param name="payload" select="$payload"/>
            <xsl:with-param name="transformationCode" select="$transformationCode"/>
            <xsl:with-param name="versionXSLT" select="$versionXSLT"/>
        </xsl:call-template>
        
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Replace the code</xd:desc>
    </xd:doc>
    <xsl:template match="hl7:code[parent::hl7:organizer]" mode="wrapper">
        <code code="419891008"
            displayName="Gegevensobject"
            codeSystem="2.16.840.1.113883.6.96"
            codeSystemName="SNOMED CT"/>        
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Replace the statusCode</xd:desc>
    </xd:doc>
    <xsl:template match="hl7:statusCode[parent::hl7:organizer]" mode="wrapper">
        <statusCode code="completed"/>        
    </xsl:template>
</xsl:stylesheet>
