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
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" 
    xmlns:f="http://hl7.org/fhir"
    xmlns:vf="http://www.vzvz.nl/functions"
    xmlns:hl7="urn:hl7-org:v3"
    xmlns="http://hl7.org/fhir"
    exclude-result-prefixes="#all"
    version="3.0">
    
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>MedMij gegevensdienst 49 in FHIR</xd:p>
            
            <xd:p><xd:b>Created on:</xd:b> 2024-02-27</xd:p>
            <xd:p><xd:b>Author:</xd:b> VZVZ</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    
    <xsl:import href="vf.includes/vf.transformation-utils-fhir.xsl"/>

    <xsl:variable name="transformationCode" as="xs:string" select="'20.2'"/>
    <xsl:variable name="zorgToepassing" as="xs:string" select="'medmij'"/>
    <xsl:variable name="fhirVersion" as="xs:string" select="'STU3'"/>
    
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
