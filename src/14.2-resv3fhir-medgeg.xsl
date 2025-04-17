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
            <xd:p>antwoord medicatiegegevens in FHIR</xd:p>
            
            <xd:p><xd:b>Created on:</xd:b> 2023-08-17</xd:p>
            <xd:p><xd:b>Author:</xd:b> VZVZ</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    
    <xsl:import href="vf.includes/vf.transformation-utils-fhir.xsl"/>
    <xsl:import href="vf.includes/BATCH_LSP_to_FHIR_OperationOutcome.xsl"/>
    
    <xsl:output method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/>
    
    <xsl:variable name="versionXSLT" as="xs:string">0.1.0</xsl:variable>
    <xsl:variable name="transformationCode" as="xs:string" select="'14.2'"/>
    
    <!-- pass the ACK result parameter as string -->
    <xsl:param name="ackResult"/>
    <!-- pass the BSN as parameter -->
    <xsl:param name="patID"/>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Main template</xd:p>
            <xd:p>Document = original fhir transaction bundle</xd:p>
            <xd:p>Parameter = response v3 ACK message</xd:p>
            <xd:p>Response should be:<br/>
                <ul>
                    <li>if ACK = OK then output is fhir bundle type=transaction-response</li>
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
        <!-- build the default response based on the ACK message -->
        <xsl:variable name="defaultResponse">
            <xsl:call-template name="buildTransactionResponse">
                <xsl:with-param name="ack" select="$ackResultObj//hl7:MCCI_IN000002"/>
                <xsl:with-param name="patientID" select="$patID"/>
            </xsl:call-template>
        </xsl:variable>
        
        <!-- if everything is ok, build a response bundle, if not send the OperationOutcome -->
        <xsl:choose>
            <xsl:when test="contains($defaultResponse//response/status/@value, '201')">
                <xsl:call-template name="buildTransactionResponseBundle">
                    <xsl:with-param name="EntryList" select="."/>
                    <xsl:with-param name="AckMessage" select="$ackResultObj"/>
                    <xsl:with-param name="patientID" select="$patID"/>
                    <xsl:with-param name="defaultResponse" select="$defaultResponse"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$defaultResponse//f:OperationOutcome"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>
