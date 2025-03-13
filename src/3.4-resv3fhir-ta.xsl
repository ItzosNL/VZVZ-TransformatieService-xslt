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
    xmlns="urn:hl7-org:v3"
    exclude-result-prefixes="#all"
    version="3.0">

    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>opleveren Toedieningsafspraak in FHIR</xd:p>

            <xd:p><xd:b>Created on:</xd:b> 2023-05-09</xd:p>
            <xd:p><xd:b>Author:</xd:b> VZVZ</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>

    <xsl:import href="vf.includes/vf.transformation-utils-fhir.xsl"/>

    <xsl:param name="xslDebug" select="false()" as="xs:boolean"/>
    
    <!-- transformationCode: zie https://vzvz.atlassian.net/wiki/spaces/UBEBVLEL/pages/27997299/Interfaces+Transformatie+Server+-+0.8.x -->
    <xsl:variable name="transformationCode" as="xs:string" select="'3.4'"/>

    <xd:doc>
        <xd:desc>
            <xd:p>Main template</xd:p>
            <xd:p>Document = transformed v3-message to fhir bundle, aka a fhir bundle</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="/f:Bundle">
        <xsl:call-template name="update-bundle">
            <xsl:with-param name="in" select="."/>
        </xsl:call-template>
    </xsl:template>

</xsl:stylesheet>
