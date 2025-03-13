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
<xsl:stylesheet xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="#all"
    xmlns:hl7="urn:hl7-org:v3" 
    xmlns:hl7nl="urn:hl7-nl:v3"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
    xmlns:math="http://exslt.org/math" 
    xmlns:func="http://exslt.org/functions"
    xmlns:vf="http://www.vzvz.nl/functions" 
    extension-element-prefixes="func vf math">

    <xsl:import href="vf.includes/vf.document.xsl"/>

    <xsl:output method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/>

    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>MedMij gegevensdienst 51 in FHIR</xd:p>

            <xd:p><xd:b>Created on:</xd:b> 2024-06-28</xd:p>
            <xd:p><xd:b>Author:</xd:b> VZVZ</xd:p>
        </xd:desc>
    </xd:doc>
    <!-- Dit is een conversie van query response batches van het LSP naar FHIR -->

    <!-- use bundleSelfLink to match the Nictiz name -->
    <xsl:param name="bundleSelfLink"/>
    
    <xsl:variable name="transformationCode" as="xs:string" select="'27.2'"/>
    <xsl:variable name="zorgToepassing" as="xs:string" select="'medmij'"/>
    <xsl:variable name="fhirVersion" as="xs:string" select="'STU3'"/>
    
    <xsl:param name="xslDebug" select="false()" as="xs:boolean"/>
    
    
    <!--
    versionXSLT = versienummer van DEZE transformatie, default de versie van dit bestand
    -->
    <xsl:variable name="vf:versionXSLT" as="xs:string">0.1.0</xsl:variable>


    <xd:doc>
        <xd:desc>Transformeer een V3 referentie naar een DocumentManifest +
            DocumentReference</xd:desc>
    </xd:doc>
    <xsl:template match="/">
        <xsl:variable name="Pat" select="//hl7:organizer[1]/hl7:recordTarget/hl7:patientRole"/>
        <xsl:variable name="PatID">
            <xsl:value-of select="vf:UUID4()"/>
        </xsl:variable>
        <xsl:variable name="DocID">
            <xsl:value-of select="vf:UUID4()"/>
        </xsl:variable>
        <xsl:variable name="DocRefList" select="//hl7:organizer/hl7:component"/>
        <xsl:variable name="DocCount" select="count($DocRefList)"/>
        <Bundle xmlns="http://hl7.org/fhir" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <id value="{vf:UUID4()}"/>
            <xsl:call-template name="addTransformationCode">
                <xsl:with-param name="transformationCode" select="$transformationCode"/>
                <xsl:with-param name="versionXSLT" select="$versionXSLT"/>
                <xsl:with-param name="type" select="'fhir'"/>
            </xsl:call-template>
            <type value="searchset"/>
            <total>
                <xsl:attribute name="value">
                    <xsl:value-of select="$DocCount"/>
                </xsl:attribute>
            </total>
            <link>
                <relation value="self"/>
                <url value="{$bundleSelfLink}"/>
            </link>
            <xsl:if test="$DocCount > 0">
                <xsl:for-each select="$DocRefList">
                    <xsl:if
                        test="vf:CanBeConverted(./hl7:act/hl7:reference/hl7:externalDocument/hl7:text/@mediaType)">
                        <entry>
                            <fullUrl>
                                <xsl:attribute name="value">
                                    <xsl:value-of
                                        select="concat('urn:uuid:', substring($DocID, 1, 34), substring(string(100 + position()), 2))"
                                    />
                                </xsl:attribute>
                            </fullUrl>
                            <resource>
                                <xsl:call-template name="DocRef_translate">
                                    <xsl:with-param name="Base"
                                        select="substring-before($bundleSelfLink, '/DocumentReference')"/>
                                    <xsl:with-param name="AppID"
                                        select="../../../../hl7:sender/hl7:device/hl7:id/@extension"/>
                                    <xsl:with-param name="DocID" select="$DocID"/>
                                    <xsl:with-param name="DocNr" select="position()"/>
                                    <xsl:with-param name="PatID" select="$PatID"/>
                                    <xsl:with-param name="Patient" select="$Pat"/>
                                    <xsl:with-param name="DocRefList" select="$DocRefList"/>
                                </xsl:call-template>
                            </resource>
                            <search>
                                <mode value="match"/>
                            </search>
                        </entry>
                    </xsl:if>
                </xsl:for-each>
                <entry>
                    <fullUrl value="urn:uuid:{$PatID}"/>
                    <resource>
                        <xsl:call-template name="Pat_translate">
                            <xsl:with-param name="PatID" select="$PatID"/>
                            <xsl:with-param name="Patient" select="$Pat"/>
                        </xsl:call-template>
                    </resource>
                    <search>
                        <mode value="include"/>
                    </search>
                </entry>
            </xsl:if>
        </Bundle>
    </xsl:template>

</xsl:stylesheet>
