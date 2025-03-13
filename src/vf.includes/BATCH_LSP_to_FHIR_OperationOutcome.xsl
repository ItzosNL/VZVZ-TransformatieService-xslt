<?xml version="1.0" encoding="UTF-8"?>
<!--
Copyright © VZVZ (Tom de Jong)

This program is free software; you can redistribute it and/or modify it under the terms of the
GNU Lesser General Public License as published by the Free Software Foundation; either version
2.1 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Lesser General Public License for more details.

The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
-->
<xsl:stylesheet xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="#all"
    xmlns:vf="http://www.vzvz.nl/functions" xmlns:pharm="urn:ihe:pharm:medication"
    xmlns:hl7="urn:hl7-org:v3" xmlns:hl7nl="urn:hl7-nl:v3"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <xsl:output method="xml" indent="yes"/>

    <xsl:import href="vf.transformation-utils.xsl"/>
    
    <!-- errorVersionXSLT = versienummer van DEZE transformatie -->
    <xsl:variable name="errorVersionXSLT" as="xs:string" select="'4.2.2'"/>
    <xsl:variable name="transformationCode"/>
    
    <xsl:variable name="metaStructure">
        <xsl:call-template name="addTransformationCode">
            <xsl:with-param name="type" select="'fhir'"/>
            <xsl:with-param name="transformationCode" select="$transformationCode"/>
            <xsl:with-param name="versionXSLT" select="$errorVersionXSLT"/>
        </xsl:call-template>
    </xsl:variable>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Dit is een conversie van query response batches met foutmeldingen van het LSP naar
                FHIR</xd:p>
            <xd:p>Omdat de statuscode buiten de outcome/OperationOutcome doorgegeven wordt, is hier
                een truc toegepast. Alle foutmeldingen incl. http status staan bij elkaar in een
                variabele ($error_mapping) onder in het bestand, zodat die gemakkelijk is aan te
                passen en uit te breiden. in het template vf:Error_translate wordt de status BINNEN
                de <outcome/> element doorgegeven. </xd:p>
            <xd:p>Dit betekent dat de aanroepende templates hier rekening mee moeten houden en de
                status weer uit het <outcome/> element moeten halen! </xd:p>
            <xd:p>Versie: zie variabele $errorVersionXSLT</xd:p>
        </xd:desc>
    </xd:doc>

    <xd:doc>
        <xd:desc>
            <xd:p>Algemene controle op fouten</xd:p>
            <xd:p>Deze versie geeft de fouten terug als OperationOutcome in een bundle response</xd:p>
            <xd:p/>
            <xd:p>2022-02-11 op dit moment zie ik geen verschil tussen deze template en de volgende.
                Dus voorlopig roep ik de volgende gewoon aan om te voorkomen dat ik code
                dubbel moet bijhouden.
            </xd:p>
        </xd:desc>
        <xd:param name="patientID"/>
    </xd:doc>
    <xsl:template match="//hl7:MCCI_IN000002" mode="error-detect-bundle">
        <xsl:param name="patientID"/>
            
        <xsl:apply-templates select="node()" mode="error-detect">
            <xsl:with-param name="patientID" select="$patientID"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Algemene controle op fouten</xd:p>
            <xd:p>Deze versie geeft alleen de fouten terug als OperationOutcome</xd:p>
        </xd:desc>
        <xd:param name="patientID"/>
    </xd:doc>
    <xsl:template match="//*[hl7:interactionId]" mode="error-detect">
        <xsl:param name="patientID"/>
        
        <xsl:variable name="Transmission_error"
            select="//hl7:acknowledgement/hl7:acknowledgementDetail"/>
        <xsl:variable name="Control_error"
            select="//hl7:ControlActProcess/hl7:reasonOf/hl7:justifiedDetectedIssue"/>
        <xsl:variable name="Query_response"
            select="//hl7:ControlActProcess/hl7:queryAck/hl7:queryResponseCode"/>

        <xsl:choose>
            <xsl:when test="$Transmission_error or $Control_error">
                <!-- alleen conversie naar OperationOutcome als er ook fouten zijn -->

                <xsl:variable name="PatID">
                    <xsl:choose>
                        <xsl:when test="not(empty($patientID))">
                            <xsl:value-of select="$patientID"/>
                        </xsl:when>
                        <xsl:when test="$Transmission_error">
                            <xsl:analyze-string select="$Transmission_error/hl7:text" regex="([0-9]{{9}})">
                                <xsl:matching-substring>
                                    <xsl:value-of select="."/>
                                </xsl:matching-substring>
                            </xsl:analyze-string>                            
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="0"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="prefixedPatID"
                    select="format-number(number($PatID), '000000000')"/>
                <xsl:call-template name="vf:Error_translate">
                    <xsl:with-param name="error_list" select="$Transmission_error"/>
                    <xsl:with-param name="PatID" select="$prefixedPatID"/>
                </xsl:call-template>
                <xsl:call-template name="vf:Error_translate">
                    <xsl:with-param name="error_list" select="$Control_error"/>
                    <xsl:with-param name="PatID" select="$prefixedPatID"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="vf:Query_response_translate">
                    <xsl:with-param name="Query_response_list" select="$Query_response"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xd:doc>
        <xd:desc>Bouw een Operation outcome op basis van een errorlist</xd:desc>
        <xd:param name="error_list"/>
        <xd:param name="PatID"/>
    </xd:doc>
    <xsl:template name="vf:Error_translate">
        <xsl:param name="error_list" as="element()*"/>
        <xsl:param name="PatID"/>

        <xsl:for-each select="$error_list">
            <xsl:variable name="errorHL7code" select="./hl7:code/@code"/>
            <xsl:variable name="errordisplay" select="./hl7:code/@displayName"/>
            <xsl:variable name="errortext" select="./hl7:text"/>
            <xsl:variable name="errorFHIRcode">
                <xsl:call-template name="vf:getFHIRError">
                    <xsl:with-param name="v3Error" select="$errorHL7code"/>
                </xsl:call-template>
            </xsl:variable>

            <outcome>
                <status value="{$errorFHIRcode//status/@value}"/>
                <OperationOutcome xmlns="http://hl7.org/fhir"
                    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
                    <xsl:comment> getransformeerd met Errorhandling versie <xsl:value-of select="$errorVersionXSLT"/> </xsl:comment>
                    <xsl:sequence select="$metaStructure"/>
                    <issue>
                        <severity value="{$errorFHIRcode//severity/@value}"/>
                        <code value="{$errorFHIRcode//code/@value}"/>
                        <xsl:if test="$errordisplay">
                            <details>
                                <text value="{$errordisplay}"/>
                            </details>
                        </xsl:if>
                        <xsl:if test="$errortext">
                            <diagnostics value="{vf:HideBSN($errortext, $PatID)}"/>
                        </xsl:if>
                    </issue>
                </OperationOutcome>
            </outcome>
        </xsl:for-each>
    </xsl:template>


    <xd:doc>
        <xd:desc>Bouw een Operation outcome op basis van 'NF'</xd:desc>
        <xd:param name="Query_response_list"/>
    </xd:doc>
    <xsl:template name="vf:Query_response_translate">
        <xsl:param name="Query_response_list" as="element()*"/>

        <xsl:if test="$Query_response_list/@code = 'NF'">

            <OperationOutcome xmlns="http://hl7.org/fhir"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
                <xsl:comment> getransformeerd met Errorhandling versie <xsl:value-of select="$errorVersionXSLT"/> </xsl:comment>
                
                <issue>
                    <severity value="error"/>
                    <code value="not-found"/>
                    <details>
                        <text value="resource not found"/>
                    </details>
                </issue>
            </OperationOutcome>

        </xsl:if>

    </xsl:template>

    <xd:doc>
        <xd:desc>Maskeer BSN</xd:desc>
        <xd:param name="Text"/>
        <xd:param name="BSN"/>
        <xd:return>Error text met BSN afgeschermd</xd:return>
    </xd:doc>
    <xsl:function name="vf:HideBSN" as="xs:string">
        <xsl:param name="Text"/>
        <xsl:param name="BSN"/>

        <xsl:choose>
            <xsl:when test="string-length($BSN) = 0">
                <xsl:value-of select="$Text"/>
            </xsl:when>
            <xsl:when test="not(starts-with($BSN, '0'))">
                <xsl:value-of select="replace($Text, $BSN, 'XXXXXXXXX')"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- verwijder de hele BSN incl voorloopnullen en verwijder de BSN als hij zonder voorloopnullen voorkomt -->
                <xsl:value-of
                    select="replace(replace($Text, $BSN, 'XXXXXXXXX'), string(number($BSN)), 'XXXXXXXXX')"
                />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xd:doc>
        <xd:desc>Bepaal de attributen van de FHIR error die hoort bij de V3 error</xd:desc>
        <xd:param name="v3Error">De V3 error code</xd:param>
    </xd:doc>
    <xsl:template name="vf:getFHIRError">
        <xsl:param name="v3Error"/>

        <error>
            <xsl:choose>
                <xsl:when test="exists($error_mapping//error[@v3 = $v3Error])">
                    <xsl:copy-of select="$error_mapping//error[@v3 = $v3Error]/*"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="$error_mapping//otherwise/*"/>
                </xsl:otherwise>
            </xsl:choose>
        </error>

    </xsl:template>

    <xd:doc>
        <xd:desc>Variabele met alle mappings tussen V3 en FHIR foutmeldingen</xd:desc>
    </xd:doc>
    <xsl:variable name="error_mapping">
        <error_mapping>
            <error v3="NOSTORE">
                <status value="507 Insufficient Storage"/>
                <severity value="error"/>
                <code value="'exception'"/>
            </error>
            <error v3="RTEDEST">
                <status value="408 Request Timeout"/>
                <severity value="error"/>
                <code value="no-store"/>
            </error>
            <error v3="RTUDEST">
                <status value="404 Not Found"/>
                <severity value="error"/>
                <code value="no-store"/>
            </error>
            <error v3="KEY204">
                <status value="404 Not Found"/>
                <severity value="error"/>
                <code value="not-found"/>
            </error>
            <error v3="QABRTITI">
                <status value="504 Gateway Timeout"/>
                <severity value="error"/>
                <code value="timeout"/>
            </error>
            <error v3="AUTERR_MEDISCH">
                <status value="403 Forbidden"/>
                <severity value="error"/>
                <code value="forbidden"/>
            </error>
            <error v3="AUTERR_SWV_FALSE">
                <status value="403 Forbidden"/>
                <severity value="error"/>
                <code value="suppressed"/>
            </error>
            <error v3="AUTERR_CONFRCV">
                <status value="404 Not Found"/>
                <severity value="error"/>
                <code value="not-found"/>
            </error>
            <error v3="SYN105">
                <status value="422 Unprocessable Entity"/>
                <severity value="error"/>
                <code value="invalid"/>
            </error>
            <otherwise>
                <status value="500 Internal Server Error"/>
                <severity value="error"/>
                <code value="incomplete"/>
            </otherwise>
        </error_mapping>
    </xsl:variable>
</xsl:stylesheet>
