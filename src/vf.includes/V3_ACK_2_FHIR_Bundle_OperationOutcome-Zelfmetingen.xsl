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
<xsl:stylesheet xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:hl7="urn:hl7-org:v3"
    xmlns:hl7nl="urn:hl7-nl:v3" xmlns:fhir="http://hl7.org/fhir"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:math="http://exslt.org/math" xmlns:func="http://exslt.org/functions"
    xmlns:vf="http://www.vzvz.nl/functions" extension-element-prefixes="func math vf hl7 hl7nl xd">

    <xsl:include href="./vf.transformation-utils-fhir.xsl"/>
    <xsl:import href="BATCH_LSP_to_FHIR_OperationOutcome.xsl"/>

    <xsl:output method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/>

    <xsl:variable name="versionXSLT" as="xs:string">3.2.1</xsl:variable>
    <xd:doc>
        <xd:desc>
            <xd:p>Dit is een conversie van een ACK van de V3 interactie delenZelfmetingen naar een
                FHIR response.</xd:p>
            <xd:p>Versie: zie variabele $versionXSLT</xd:p>
        </xd:desc>

        <xd:param name="EntryList">De oorspronkelijke Bundle waar antwoord op wordt
            gegeven</xd:param>
        <xd:param name="AckMessage">Het V3 ACK message dat als antwoord moet worden
            doorgegeven</xd:param>
        <xd:param name="patientID">Het nummer (BSN) van de patiënt waar het bericht betrekking op
            heeft</xd:param>
    </xd:doc>
    <xsl:template name="buildbatchResponseBundle">
        <xsl:param name="EntryList"/>
        <xsl:param name="AckMessage"/>
        <xsl:param name="patientID"/>

        <!-- <xsl:variable name="EntryCount" select="count($EntryList)"/> -->
        <xsl:variable name="EntryBaseID">
            <xsl:value-of select="vf:UUID4()"/>
        </xsl:variable>
        <!-- het antwoord is, op de location na, vrijwel altijd hetzelfde, dus dan kan hij net zo goed in 1x gebouwd worden -->
        <xsl:variable name="defaultResponse">
            <xsl:call-template name="buildTransactionResponse">
                <xsl:with-param name="ack" select="$AckMessage"/>
                <xsl:with-param name="patientID" select="$patientID"/>
            </xsl:call-template>
        </xsl:variable>

        <!-- maak een antwoord dat de resource niet is opgeslagen -->
        <xsl:variable name="noStoreResponse">
            <xsl:call-template name="buildTransactionNoStoreResponse">
                <xsl:with-param name="statusCode" select="202"/>
            </xsl:call-template>
        </xsl:variable>

        <!-- maak een antwoord dat de resource (zelfmeting) niet gesupport wordt -->
        <xsl:variable name="notSupportedResponse">
            <xsl:call-template name="buildNotSupportedResponse"/>
        </xsl:variable>


        <Bundle xmlns="http://hl7.org/fhir">
                <xsl:if test="$xslDebug">
                    <xsl:attribute name="xsi:schemaLocation">http://hl7.org/fhir http://hl7.org/fhir/STU3/fhir-all.xsd</xsl:attribute>
                </xsl:if>
                
            <xsl:comment> getransformeerd met versie <xsl:value-of select="$versionXSLT"/> </xsl:comment>
            <id value="{vf:UUID4()}"/>
            <xsl:sequence select="$metaStructure"/>
            <type value="batch-response"/>

            <xsl:for-each select="$EntryList">
                <!-- define response -->
                <xsl:variable name="response">
                    <xsl:choose>
                        <xsl:when
                            test="contains($defaultResponse//status/@value, '201') and exists(fhir:resource/fhir:Patient)">
                            <!-- deze gaan we niet opslaan, dus 'nostore' teruggeven -->
                            <xsl:copy-of select="$noStoreResponse"/>
                        </xsl:when>
                        <xsl:when
                            test="contains($defaultResponse//status/@value, '201') and not(vf:isAllowedLab(fhir:resource/fhir:Observation/fhir:code))">
                            <!-- deze is niet doorgegeven, dus 'not supported' doorgeven -->
                            <xsl:copy-of select="$notSupportedResponse"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of select="$defaultResponse"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>

                <entry>

                    <xsl:variable name="elementRoot" select="local-name(fhir:resource/node())"/>
                    
                    <!-- bepaal de resource.id -->
                    <xsl:variable name="ResourceId">
                        <xsl:choose>
                            <xsl:when test="$elementRoot = 'Observation'">
                                <xsl:value-of select="vf:UUID4()"/>
                            </xsl:when>
                            <xsl:when test="$elementRoot = 'Patient'">
                                <xsl:choose>
                                    <xsl:when test="exists(fhir:resource/fhir:Patient/fhir:id)">
                                        <xsl:value-of
                                            select="fhir:resource/fhir:Patient/fhir:id/@value"/>
                                    </xsl:when>
<!-- dit levert geen geldige fullUrl vs id op
                                    <xsl:when test="exists(fhir:resource/fhir:Patient/fhir:identifier)">
                                        <xsl:value-of
                                            select="fhir:resource/fhir:Patient/fhir:identifier/fhir:value/@value"/>
                                    </xsl:when>
-->
                                    <xsl:otherwise>
                                        <!-- ik ga er maar even van uit dat er altijd een fullUrl is -->
                                        <xsl:value-of>
                                            <xsl:choose>
                                                <xsl:when test="starts-with(fhir:fullUrl/@value,'urn:oid:')">
                                                    <xsl:value-of select="substring(fhir:fullUrl/@value, 9)"/>
                                                </xsl:when>
                                                <xsl:when test="starts-with(fhir:fullUrl/@value,'urn:uuid:')">
                                                    <xsl:value-of select="substring(fhir:fullUrl/@value, 10)"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="fhir:fullUrl/@value"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:value-of>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:variable>
                    
                    <!-- fullUrl MOET dezelfde ID bevatten als de resource.id -->
                    <xsl:variable name="resourceFullUrl">
                        <xsl:choose>
                            <xsl:when test="$elementRoot = 'Observation'">
                                <xsl:value-of select="concat('urn:uuid:', $ResourceId)"/>
                            </xsl:when>
                            <xsl:when test="$elementRoot = 'Patient'">
                                <xsl:value-of select="fhir:fullUrl/@value"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:variable>
                    
                    <fullUrl value="{$resourceFullUrl}"/>

                    <resource>
                        <xsl:call-template name="transformResource">
                            <xsl:with-param name="originalResource" select="./fhir:resource"/>
                            <xsl:with-param name="resourceID" select="$ResourceId"/>
                            <xsl:with-param name="metaTransformationCode" select="$metaStructure"/>
                        </xsl:call-template>
                    </resource>
                    <response>
                        <status value="{$response/response/status/@value}"/>
                        <xsl:if test="not(exists($response/response/fhir:outcome))">
                            <!-- een location geeft de locatie van het nieuw aangemaakte object aan.
                                dat is er niet bij een fout.
                                location is gelijk aan location header = vergelijkbaar met fullUrl
                            -->
                            <location value="{$resourceFullUrl}"/>
                        </xsl:if>
                        <xsl:if test="exists($response/response/fhir:outcome)">
                            <xsl:copy-of select="$response/response/fhir:outcome"/>
                        </xsl:if>
                    </response>
                </entry>
            </xsl:for-each>
        </Bundle>
    </xsl:template>



    <xd:doc>
        <xd:desc>
            <xd:p>Is het een toegestane labcode?</xd:p>
            <xd:p>Toegestane loinc codes</xd:p>
            <xd:ul>
                <xd:li>14743-9</xd:li>
                <xd:li>14760-3</xd:li>
                <xd:li>14770-2</xd:li>
                <xd:li>29463-7</xd:li>
                <xd:li>85354-9</xd:li>
                <xd:li>8867-4</xd:li>
            </xd:ul>
        </xd:desc>
        <xd:param name="fhirCode">fhir/code element dat getoetst moet worden</xd:param>
    </xd:doc>
    <xsl:function name="vf:isAllowedLab">
        <xsl:param name="fhirCode"/>

        <xsl:variable name="LOINC-code" select="$fhirCode/fhir:coding/fhir:code/@value"/>
        <xsl:sequence
            select="contains('85354-9/29463-7/8867-4/14770-2/14743-9/14760-3', $LOINC-code)"/>
    </xsl:function>

</xsl:stylesheet>
