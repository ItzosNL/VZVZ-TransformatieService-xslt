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
    
    <xsl:import href="vf.includes/V3_ACK_2_FHIR_Bundle_OperationOutcome-Zelfmetingen.xsl"/>
    
    <xsl:output method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/>

    <!-- pass the ACK result parameter as string -->
    <xsl:param name="ackResult"/>
    <!-- pass the BSN as parameter -->
    <xsl:param name="patID"/>
    
    <xsl:param name="xslDebug" select="false()" as="xs:boolean"/>
        
    <xsl:variable name="transformationCode" as="xs:string" select="'1.2'"/>
    <xsl:variable name="versionXSLT" as="xs:string" select="'4.2.0'"/>
    
    <!-- create the same variable here to overrule the one in the imported file -->
    
    <xsl:variable name="metaStructure">
        <xsl:call-template name="addTransformationCode">
            <xsl:with-param name="type" select="'fhir'"/>
            <xsl:with-param name="transformationCode" select="$transformationCode"/>
            <xsl:with-param name="versionXSLT" select="$versionXSLT"/>
        </xsl:call-template>
    </xsl:variable>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Main template</xd:p>
            <xd:p>Document = original fhir transaction bundle</xd:p>
            <xd:p>Parameter = response v3 ACK message</xd:p>
            <xd:p>Response should be:<br/>
                <ul>
                    <li>if ACK = OK then output is fhir bundle type=transaction.response</li>
                    <li>if ACK = NOK then output is OperationOutcome</li>
                </ul>
            </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="/">
        <xsl:variable name="ackResultObj">            
            <xsl:call-template name="convertToDocumentNode">
                <xsl:with-param name="xml" select="$ackResult"/>
                <xsl:with-param name="msg">Ack bericht niet beschikbaar</xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:call-template name="buildbatchResponseBundle">
            <xsl:with-param name="EntryList" select="//f:entry"/>
            <xsl:with-param name="AckMessage" select="$ackResultObj//hl7:MCCI_IN000002"/>
            <xsl:with-param name="patientID" select="$patID"/>
        </xsl:call-template>
    </xsl:template>
            
</xsl:stylesheet>
