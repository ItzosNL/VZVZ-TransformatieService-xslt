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
    
    <xsl:variable name="versionXSLT" as="xs:string">0.3.1</xsl:variable>
    <xsl:variable name="transformationCode" as="xs:string" select="'14.4'"/>
    
    
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
        <xsl:variable name="ackResultObj">            
            <xsl:call-template name="convertToDocumentNode">
                <xsl:with-param name="xml" select="$ackResult"/>
                <xsl:with-param name="msg">Fhir response bericht niet beschikbaar</xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:variable name="payload">
            <xsl:apply-templates select="." mode="wrapper"/>
        </xsl:variable>
        
        <xsl:variable name="metaDataObj">
            <xsl:call-template name="convertToDocumentNode">
                <xsl:with-param name="xml" select="$metaData"/>
                <xsl:with-param name="msg">
                    <xsl:text>Metadata object niet beschikbaar</xsl:text>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        
        <!-- id of the message we respond to -->
        <xsl:variable name="targetMessageID">
            <xsl:choose>
                <xsl:when test="not($payload//hl7:PVMG_IN000001NL01)">
                    <!-- dummy id -->
                    <id extension="0012345678" root="2.16.840.1.113883.2.4.6.6.1.1" xsl:exclude-result-prefixes="#all"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="$payload//hl7:PVMG_IN000001NL01/hl7:id"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <!-- receiver -->
        <xsl:variable name="receiverDevice">
            <device>
                <xsl:call-template name="splitMetaOID">
                    <xsl:with-param name="oid" select="$metaDataObj/Meta/Receiver"/>
                </xsl:call-template>
            </device>
        </xsl:variable>
        
        <!-- sender -->
        <xsl:variable name="senderDevice">
            <device>
                <xsl:call-template name="splitMetaOID">
                    <xsl:with-param name="oid" select="$metaDataObj/Meta/Sender"/>
                </xsl:call-template>
            </device>
        </xsl:variable>
        
        <!-- find out if it's an OK message or an error -->
        <xsl:variable name="acknowledgement">
            <xsl:choose>
                <xsl:when test="local-name($ackResultObj/node()) = 'Bundle' and $ackResultObj/node()/f:type[@value='transaction-response']">
                    <!-- it's ok -->
                    <acknowledgement typeCode="AA">
                        <targetMessage>
                            <xsl:sequence select="$targetMessageID"/>
                        </targetMessage>
                    </acknowledgement>
                    
                </xsl:when>
                <xsl:when test="local-name($ackResultObj/node()) = 'OperationOutcome'">
                    <xsl:variable name="errorText">
                        <xsl:choose>
                            <xsl:when test="exists($ackResultObj//f:OperationOutcome/f:issue[1]/f:details/f:text)">
                                <xsl:value-of select="$ackResultObj//f:OperationOutcome/f:issue[1]/f:details/f:text/@value"/>
                            </xsl:when>
                            <xsl:when test="exists($ackResultObj//f:OperationOutcome/f:issue[1]/f:diagnostics)">
                                <xsl:value-of select="$ackResultObj//f:OperationOutcome/f:issue[1]/f:diagnostics/@value"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>No error information found</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <acknowledgement typeCode="CE">
                        <acknowledgementDetail>
                            <code xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" code="SYN105" codeSystem="2.16.840.1.113883.5.1100" displayName="Required element missing" xsi:type="CV"/>
                            <text><xsl:value-of select="$errorText"/></text>
                        </acknowledgementDetail>
                        <targetMessage>
                            <xsl:sequence select="$targetMessageID"/>
                        </targetMessage>
                    </acknowledgement>				
                </xsl:when>
                <xsl:otherwise>
                    <!-- TODO: is SYN105 de meest logische fout voor 'het is onduidelijk wat we ontvangen hebben'? -->
                    <acknowledgement typeCode="CE">
                        <acknowledgementDetail>
                            <code xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" code="SYN105" codeSystem="2.16.840.1.113883.5.1100" displayName="Required element missing" xsi:type="CV"/>
                            <text>Een verplicht element is niet aanwezig: Bundle.type of OperationOutcome</text>
                        </acknowledgementDetail>
                        <targetMessage>
                            <xsl:sequence select="$targetMessageID"/>
                        </targetMessage>
                    </acknowledgement>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <MCCI_IN000002 xmlns="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="urn:hl7-org:v3 ../XML/schemas/MCCI_IN000002.xsd">
            <!-- Transport Wrapper -->
            <id extension="{vf:UUID4()}" root="2.16.840.1.113883.2.4.3.111.19.2"/>
            <creationTime value="{vf:dateTimeFHIR_V3(string(current-dateTime()), true())}"/>
            <versionCode code="NICTIZEd2005-Okt"/>
            <interactionId extension="MCCI_IN000002" root="2.16.840.1.113883.1.6"/>
            <profileId root="2.16.840.1.113883.2.4.3.11.1" extension="810"/>
            <processingCode code="P"/>
            <processingModeCode code="T"/>
            <!-- accept acks dienen zelf nooit ge-acked te worden -->
            <acceptAckCode code="NE"/>
            <!-- CA = accept/commit-level ack -->
            <xsl:sequence select="$acknowledgement"/>
            <xsl:call-template name="addTransformationCode">
                <xsl:with-param name="transformationCode" select="$transformationCode"/>
                <xsl:with-param name="type" select="'v3'"/>
                <xsl:with-param name="versionXSLT" select="$versionXSLT"/>
            </xsl:call-template>
            <receiver>
                <xsl:sequence select="$receiverDevice"/>
            </receiver>
            <sender>
                <xsl:sequence select="$senderDevice"/>
            </sender>
        </MCCI_IN000002>
    </xsl:template>
    
</xsl:stylesheet>
