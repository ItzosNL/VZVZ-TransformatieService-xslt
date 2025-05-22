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
            <xd:p>Transformatie voor sturen medicatieVoorschrift</xd:p>
            
            <xd:p><xd:b>Created on:</xd:b> 2023-06-28</xd:p>
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
    <xsl:variable name="versionXSLT" as="xs:string">0.5.2</xsl:variable>
    <xsl:variable name="transformationCode" as="xs:string" select="'9.1'"/>
        
    <xsl:variable name="buildingBlock" select="'PVMV'"/>
    <xsl:variable name="schematronRef" select="concat('file:', $svnAortaMP9, '/schematron_closed_warnings/mp-vzvz-verzendenMedicatievoorschrift.sch')"/>
    <xsl:variable name="schematronRefZT" select="concat('file:', $svnAortaZTMP, '/mp-runtime-develop/mp-mp93_vos.sch')"/>
    
    <xd:doc>
        <xd:desc>Main template</xd:desc>
    </xd:doc>
    <xsl:template match="/">
        <xsl:variable name="payload">
            <xsl:choose>
                <xsl:when test="exists(./hl7:organizer/hl7:organizer)">
                    <xsl:for-each select="./hl7:organizer/hl7:organizer">
                        <xsl:comment> dubbele organizer</xsl:comment>
                        <xsl:apply-templates select="." mode="wrapper"/>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <organizer classCode="CLUSTER" moodCode="EVN">
                        <xsl:comment> enkele organizer</xsl:comment>
                        <xsl:apply-templates select="./hl7:organizer/*" mode="wrapper"/>
                    </organizer>                    
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>        
                
        <xsl:call-template name="buildV3message">
            <xsl:with-param name="xslDebug" select="$xslDebug"/>
            <xsl:with-param name="schematronRef" select="$schematronRef"/>
            <xsl:with-param name="schematronRefZT" select="$schematronRefZT"/>
            <xsl:with-param name="buildingBlock" select="$buildingBlock"/>
            <xsl:with-param name="metaData" select="$metaData"/>
            <xsl:with-param name="hasOverseer" select="true()"/>
            <!-- 2025-01-21 remove original query param because the necessary ids are part of the metadata -->
<!--            <xsl:with-param name="originalQuery" select="''"/>-->
            <xsl:with-param name="payload" select="$payload"/>
            <xsl:with-param name="transformationCode" select="$transformationCode"/>
            <xsl:with-param name="versionXSLT" select="$versionXSLT"/>
        </xsl:call-template>
        
    </xsl:template>    
        
</xsl:stylesheet>
