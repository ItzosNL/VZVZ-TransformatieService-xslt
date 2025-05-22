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
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" 
    xmlns:f="http://hl7.org/fhir"
    xmlns="urn:hl7-org:v3"
    exclude-result-prefixes="#all"
    version="3.0">
    
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>opleveren WisselendDoseerSchema in FHIR</xd:p>
            
            <xd:p><xd:b>Created on:</xd:b> 2023-05-25</xd:p>
            <xd:p><xd:b>Author:</xd:b> VZVZ</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    
    <xsl:import href="vf.includes/vf.transformation-utils-fhir.xsl"/>
    
    <!-- transformationCode: zie https://vzvz.atlassian.net/wiki/spaces/UBEBVLEL/pages/27997299/Interfaces+Transformatie+Server+-+0.8.x -->
    <xsl:variable name="transformationCode" as="xs:string" select="'7.2'"/>
    
    <xsl:param name="xslDebug" select="false()" as="xs:boolean"/>
    
    <!-- pass originalMessage message -->
    <xsl:param name="originalMessage"/>
    
    <!-- pass the metaData object -->
    <xsl:param name="metaData"/>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Main template</xd:p>
            <xd:p>Document = transformed v3-message to fhir bundle, aka a fhir bundle</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="/f:Bundle">
        <xsl:call-template name="update-bundle">
            <xsl:with-param name="in" select="."/>
            <xsl:with-param name="originalMessage" select="$originalMessage"/>
            <xsl:with-param name="metaData" select="$metaData"/>
        </xsl:call-template>
    </xsl:template>
    
</xsl:stylesheet>