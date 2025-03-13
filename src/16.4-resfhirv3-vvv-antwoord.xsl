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
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" 
    xmlns:hl7="urn:hl7-org:v3"
    xmlns:hl7nl="urn:hl7-nl:v3" 
    xmlns:f="http://hl7.org/fhir"
    xmlns:vf="http://www.vzvz.nl/functions"
    xmlns:util="urn:hl7:utilities" 
    xmlns:saxon="http://saxon.sf.net/" 
    xmlns="urn:hl7-org:v3"
    exclude-result-prefixes="#all" version="3.0">
    
    <xsl:import href="vf.includes/vf.transformation-utils-v3.xsl"/>
    
    <!-- pass the fhir result  -->
    <xsl:param name="ackResult"/>
    
    <!-- pass the BSN as parameter -->
    <xsl:param name="patID"/>
    
    <!-- pass the metaData object -->
    <xsl:param name="metaData"/>
    
    <xsl:param name="xslDebug" select="false()" as="xs:boolean"/>
    <xsl:param name="logLevel" select="$logDEBUG"/>
    
    <!-- versionXSLT = versienummer van DEZE combo -->
    
    <xsl:variable name="versionXSLT" as="xs:string">0.2.0</xsl:variable>
    <xsl:variable name="transformationCode" as="xs:string" select="'16.4'"/>
    <xsl:variable name="buildingBlock" as="xs:string" select="'PAVV'"/>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Main template</xd:p>
            <xd:p>Document = original v3 push message</xd:p>
            <xd:p>Parameter = response fhir transaction-response bundle</xd:p>
            <xd:p>Response should be:<br/>
                <ul>
                    <li>if bundle with type=transaction-response then output is ACK</li>
                    <li>if OperationOutcome then output is NOK</li>
                </ul>
            </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="/">
        
        <xsl:variable name="payload">
            <xsl:apply-templates select="." mode="wrapper"/>
        </xsl:variable>
        
        <xsl:call-template name="buildV3AcknowledgementMessage">
            <xsl:with-param name="buildingBlock" select="$buildingBlock"/>
            <xsl:with-param name="payload" select="$payload"/>
            <xsl:with-param name="ackResult" select="$ackResult"/>
            <xsl:with-param name="transformationCode" select="$transformationCode"/>
            <xsl:with-param name="versionXSLT" select="$versionXSLT"/>
            <xsl:with-param name="metaData" select="$metaData"/>
        </xsl:call-template>
    </xsl:template>
</xsl:stylesheet>
