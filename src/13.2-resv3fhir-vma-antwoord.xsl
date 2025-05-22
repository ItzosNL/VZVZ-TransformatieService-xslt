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
    xmlns:vf="http://www.vzvz.nl/functions"
    xmlns:hl7="urn:hl7-org:v3"
    xmlns="http://hl7.org/fhir"
    exclude-result-prefixes="#all"
    version="3.0">
    
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>antwoord voorstel medicatieafspraak afhandeling in FHIR</xd:p>
            
            <xd:p><xd:b>Created on:</xd:b> 2023-08-07</xd:p>
            <xd:p><xd:b>Author:</xd:b> VZVZ</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    
    <xsl:import href="vf.includes/vf.transformation-utils-fhir.xsl"/>
    <xsl:import href="vf.includes/BATCH_LSP_to_FHIR_OperationOutcome.xsl"/>
    
    <xsl:output method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/>
    
    <xsl:variable name="versionXSLT" as="xs:string">0.1.0</xsl:variable>
    <xsl:variable name="transformationCode" as="xs:string" select="'13.2'"/>
    
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
