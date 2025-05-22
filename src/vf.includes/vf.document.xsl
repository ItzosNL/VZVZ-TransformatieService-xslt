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
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:hl7="urn:hl7-org:v3" 
    xmlns:hl7nl="urn:hl7-nl:v3" 
    xmlns:f="http://hl7.org/fhir" 
    xmlns:math="http://exslt.org/math"
    xmlns:func="http://exslt.org/functions" 
    xmlns:vf="http://www.vzvz.nl/functions" 
    extension-element-prefixes="func math vf" exclude-result-prefixes="#all" version="3.0">

    <xsl:import href="vf.patient.xsl"/>
    <xsl:import href="vf.author.xsl"/>
    <xsl:import href="vf.utils.xsl"/>
    <xsl:import href="vf.transformation-utils-fhir.xsl"/>

    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> 2024-06-28</xd:p>
            <xd:p><xd:b>Author:</xd:b> VZVZ</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
        
    <!--
    versionXSLT = versienummer van DEZE transformatie, default de versie van dit bestand
    -->
    <xsl:variable name="vf:versionXSLT" as="xs:string">0.1.1</xsl:variable>

    <xsl:variable name="transformation">
        <xsl:call-template name="addTransformationCode">
            <xsl:with-param name="transformationCode" select="$transformationCode"/>
            <xsl:with-param name="versionXSLT" select="$versionXSLT"/>
            <xsl:with-param name="type" select="'fhir'"/>
        </xsl:call-template>
    </xsl:variable>
    
    <xd:doc>
        <xd:desc>Build a DocumentManifest</xd:desc>
        <xd:param name="Base"/>
        <xd:param name="AppID"/>
        <xd:param name="DocID"/>
        <xd:param name="DocNr"/>
        <xd:param name="PatID"/>
        <xd:param name="Patient"/>
        <xd:param name="DocRefList"/>
    </xd:doc>
    <xsl:template name="DocMan_translate">
        <xsl:param name="Base"/>
        <xsl:param name="AppID"/>
        <xsl:param name="DocID"/>
        <xsl:param name="DocNr"/>
        <xsl:param name="PatID"/>
        <xsl:param name="Patient"/>
        <xsl:param name="DocRefList"/>
        <xsl:variable name="DocRefRoot"
            select="./hl7:act/hl7:reference/hl7:externalDocument/hl7:id/@root"/>
        <xsl:variable name="DocRefExt"
            select="./hl7:act/hl7:reference/hl7:externalDocument/hl7:id/@extension"/>
        <xsl:variable name="DocRefType"
            select="./hl7:act/hl7:reference/hl7:externalDocument/hl7:text/@mediaType"/>
        <xsl:variable name="DocRefURL"
            select="./hl7:act/hl7:reference/hl7:externalDocument/hl7:text/hl7:reference/@value"/>
        <xsl:variable name="DocDateTime">
            <xsl:choose>
                <xsl:when test="./hl7:act/hl7:effectiveTime/hl7:center/@value">
                    <xsl:sequence select="vf:dateTimeV3_FHIR(./hl7:act/hl7:effectiveTime/hl7:center/@value, true())"/>
                    
<!--                    <xsl:call-template name="date_time_convert">
                        <xsl:with-param name="date_time_v3"
                            select="./hl7:act/hl7:effectiveTime/hl7:center/@value"/>
                        <xsl:with-param name="incl_time" select="true()"/>
                    </xsl:call-template>
-->                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="vf:dateTimeV3_FHIR(./hl7:act/hl7:effectiveTime/@value, true())"/>
                    
<!--                    <xsl:call-template name="date_time_convert">
                        <xsl:with-param name="date_time_v3"
                            select="./hl7:act/hl7:effectiveTime/@value"/>
                        <xsl:with-param name="incl_time" select="true()"/>
                    </xsl:call-template>
-->                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="DocTypeSys"
            select="./hl7:act/hl7:reference/hl7:externalDocument/hl7:code/@system"/>
        <xsl:variable name="DocTypeCode"
            select="./hl7:act/hl7:reference/hl7:externalDocument/hl7:code/@code"/>
        <xsl:variable name="DocTypeDesc">
            <xsl:choose>
                <xsl:when test="./hl7:act/hl7:reference/hl7:externalDocument/hl7:code/@nullFlavor">
                    <xsl:value-of
                        select="./hl7:act/hl7:reference/hl7:externalDocument/hl7:code/hl7:originalText"
                    />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of
                        select="./hl7:act/hl7:reference/hl7:externalDocument/hl7:code/@displayName"
                    />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="ActText" select="normalize-space(./hl7:act/hl7:text)"/>
        <xsl:variable name="Sender" select="./hl7:act/hl7:participant[@typeCode='DIST']"/>
        <xsl:variable name="EncounterRoot"
            select="./hl7:act/hl7:entryRelationship/hl7:encounter/hl7:id/@root"/>
        <xsl:variable name="EncounterExt"
            select="./hl7:act/hl7:entryRelationship/hl7:encounter/hl7:id/@extension"/>
        <xsl:variable name="EpisodeRoot"
            select="./hl7:act/hl7:entryRelationship/hl7:act/hl7:id/@root"/>
        <xsl:variable name="EpisodeExt"
            select="./hl7:act/hl7:entryRelationship/hl7:act/hl7:id/@extension"/>
        <DocumentManifest xmlns="http://hl7.org/fhir"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <id value="{concat(substring($DocID, 1, 33), substring(string(100 + $DocNr), 1, 3))}"/>
            <meta>
                <profile value="http://nictiz.nl/fhir/StructureDefinition/IHE.MHD.DocumentManifest"
                />
                <xsl:copy-of select="$transformation/f:meta/*"/>
            </meta>
            <text>
                <status value="extensions"/>
                <div xmlns="http://www.w3.org/1999/xhtml">
                    <table>
                        <caption>DocumentManifest. Subject: <xsl:value-of
                                select="vf:PatientNaamDisp($Patient)"/>
                            <span style="display: block;">Auteur: <xsl:value-of
                                    select="vf:GetAuthorDisp($Sender)"/>
                            </span>
                        </caption>
                        <tbody>
                            <tr>
                                <th>Type</th>
                                <td>
                                    <span>
                                        <xsl:value-of select="$DocTypeDesc"/>
                                    </span>
                                </td>
                            </tr>
                            <tr>
                                <th>Geïndexeerd</th>
                                <td>
                                    <xsl:value-of select="$DocDateTime"/>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </text>
            <xsl:if test="$Sender">
                <contained>
                    <xsl:call-template name="GetAuthor">
                        <xsl:with-param name="Author" select="$Sender"/>
                    </xsl:call-template>
                </contained>
            </xsl:if>
            <masterIdentifier>
                <system value="urn:oid:{$DocRefRoot}"/>
                <value value="{$DocRefExt}"/>
            </masterIdentifier>
            <identifier>
                <system value="urn:oid:{$DocRefRoot}"/>
                <value value="{$DocRefExt}"/>
            </identifier>
            <status value="current"/>
            <type>
                <xsl:choose>
                    <xsl:when test="$DocTypeCode">
                        <coding>
                            <system value="urn:oid:{$DocTypeSys}"/>
                            <code value="{$DocTypeCode}"/>
                            <display value="{$DocTypeDesc}"/>
                        </coding>
                    </xsl:when>
                    <xsl:otherwise>
                        <text value="{$DocTypeDesc}"/>
                    </xsl:otherwise>
                </xsl:choose>
            </type>
            <subject>
                <reference value="urn:uuid:{$PatID}"/>
                <display value="{vf:PatientNaamDisp($Patient)}"/>
            </subject>
            <created value="{$DocDateTime}"/>
            <xsl:if test="$Sender">
                <author>
                    <reference value="#author"/>
                    <display value="{vf:GetAuthorDisp($Sender)}"/>
                </author>
            </xsl:if>
            <source value="urn:oid:2.16.840.1.113883.2.4.6.6.{$AppID}"/>
            <content>
                <pReference>
                    <reference
                        value="{concat('urn:uuid:', concat(substring($DocID, 1, 33), substring(string(200 + $DocNr), 1, 3)))}"/>
                    <display value="{$ActText}"/>
                </pReference>
            </content>
        </DocumentManifest>
    </xsl:template>

    <xd:doc>
        <xd:desc>Build a DocumentReference resource</xd:desc>
        <xd:param name="Base"/>
        <xd:param name="AppID"/>
        <xd:param name="DocID"/>
        <xd:param name="DocNr"/>
        <xd:param name="PatID"/>
        <xd:param name="Patient"/>
        <xd:param name="DocRefList"/>
    </xd:doc>
    <xsl:template name="DocRef_translate">
        <xsl:param name="Base"/>
        <xsl:param name="AppID"/>
        <xsl:param name="DocID"/>
        <xsl:param name="DocNr"/>
        <xsl:param name="PatID"/>
        <xsl:param name="Patient"/>
        <xsl:param name="DocRefList"/>
        <xsl:variable name="DocRefRoot"
            select="./hl7:act/hl7:reference/hl7:externalDocument/hl7:id/@root"/>
        <xsl:variable name="DocRefExt"
            select="./hl7:act/hl7:reference/hl7:externalDocument/hl7:id/@extension"/>
        <xsl:variable name="DocRefType"
            select="./hl7:act/hl7:reference/hl7:externalDocument/hl7:text/@mediaType"/>
        <xsl:variable name="DocRefURL"
            select="./hl7:act/hl7:reference/hl7:externalDocument/hl7:text/hl7:reference/@value"/>
        <xsl:variable name="DocDateTime">
            <xsl:choose>
                <xsl:when test="./hl7:act/hl7:effectiveTime/hl7:center/@value">
                    <xsl:sequence select="vf:dateTimeV3_FHIR(./hl7:act/hl7:effectiveTime/hl7:center/@value, true())"/>
                    
<!--                    <xsl:call-template name="date_time_convert">
                        <xsl:with-param name="date_time_v3"
                            select="./hl7:act/hl7:effectiveTime/hl7:center/@value"/>
                        <xsl:with-param name="incl_time" select="true()"/>
                    </xsl:call-template>
-->
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="vf:dateTimeV3_FHIR(./hl7:act/hl7:effectiveTime/@value, true())"/>
                    
<!--                    <xsl:call-template name="date_time_convert">
                        <xsl:with-param name="date_time_v3"
                            select="./hl7:act/hl7:effectiveTime/@value"/>
                        <xsl:with-param name="incl_time" select="true()"/>
                    </xsl:call-template>
-->
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="DocTypeSys"
            select="./hl7:act/hl7:reference/hl7:externalDocument/hl7:code/@system"/>
        <xsl:variable name="DocTypeCode"
            select="./hl7:act/hl7:reference/hl7:externalDocument/hl7:code/@code"/>
        <xsl:variable name="DocTypeDesc">
            <xsl:choose>
                <xsl:when test="./hl7:act/hl7:reference/hl7:externalDocument/hl7:code/@nullFlavor">
                    <xsl:value-of
                        select="./hl7:act/hl7:reference/hl7:externalDocument/hl7:code/hl7:originalText"
                    />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of
                        select="./hl7:act/hl7:reference/hl7:externalDocument/hl7:code/@displayName"
                    />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="ActText" select="normalize-space(./hl7:act/hl7:text)"/>
        <xsl:variable name="Sender" select="./hl7:act/hl7:participant[@typeCode='DIST']"/>
        <xsl:variable name="EncounterRoot"
            select="./hl7:act/hl7:entryRelationship/hl7:encounter/hl7:id/@root"/>
        <xsl:variable name="EncounterExt"
            select="./hl7:act/hl7:entryRelationship/hl7:encounter/hl7:id/@extension"/>
        <xsl:variable name="EpisodeRoot"
            select="./hl7:act/hl7:entryRelationship/hl7:act/hl7:id/@root"/>
        <xsl:variable name="EpisodeExt"
            select="./hl7:act/hl7:entryRelationship/hl7:act/hl7:id/@extension"/>
        <DocumentReference xmlns="http://hl7.org/fhir"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <id value="{concat(substring($DocID, 1, 34), substring(string(100 + $DocNr), 2))}"/>
            <meta>
                <profile
                    value="http://nictiz.nl/fhir/StructureDefinition/IHE.MHD.Minimal.DocumentReference"
                />
                <xsl:copy-of select="$transformation/f:meta/*"/>
            </meta>
            <text>
                <status value="extensions"/>
                <div xmlns="http://www.w3.org/1999/xhtml">
                    <table>
                        <caption>DocumentReference. Subject: <xsl:value-of
                                select="vf:PatientNaamDisp($Patient)"/>
                            <span style="display: block;">Auteur: <xsl:value-of
                                    select="vf:GetAuthorDisp($Sender)"/>
                            </span>
                        </caption>
                        <tbody>
                            <tr>
                                <th>Type</th>
                                <td>
                                    <span>
                                        <xsl:value-of select="$DocTypeDesc"/>
                                    </span>
                                </td>
                            </tr>
                            <tr>
                                <th>Geïndexeerd</th>
                                <td>
                                    <xsl:value-of select="$DocDateTime"/>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </text>
            <xsl:if test="$Sender">
                <contained>
                    <xsl:call-template name="GetAuthor">
                        <xsl:with-param name="Author" select="$Sender"/>
                    </xsl:call-template>
                </contained>
            </xsl:if>
            <masterIdentifier>
                <system value="urn:oid:{$DocRefRoot}"/>
                <value value="{$DocRefExt}"/>
            </masterIdentifier>
            <status value="current"/>
            <type>
                <xsl:choose>
                    <xsl:when test="$DocTypeCode">
                        <coding>
                            <system value="urn:oid:{$DocTypeSys}"/>
                            <code value="{$DocTypeCode}"/>
                            <display value="{$DocTypeDesc}"/>
                        </coding>
                    </xsl:when>
                    <xsl:otherwise>
                        <text value="{$DocTypeDesc}"/>
                    </xsl:otherwise>
                </xsl:choose>
            </type>
            <class>
                <coding>
                    <system value="http://loinc.org"/>
                    <code value="52033-8"/>
                    <display value="General correspondence attachment"/>
                </coding>
            </class>
            <subject>
                <reference value="urn:uuid:{$PatID}"/>
                <display value="{vf:PatientNaamDisp($Patient)}"/>
            </subject>
            <indexed value="{$DocDateTime}"/>
            <xsl:if test="$Sender">
                <author>
                    <reference value="#author"/>
                    <display value="{vf:GetAuthorDisp($Sender)}"/>
                </author>
            </xsl:if>
            <description value="{$ActText}"/>
            <content>
                <attachment>
                    <contentType value="application/pdf"/>
                    <url
                        value="{$Base}/Binary/{$AppID}.R.{replace($DocRefRoot, '2.16.840.1.113883.2.4', 'HL7NL')}.E.{$DocRefExt}"/>
                    <title value="{$DocTypeDesc}"/>
                </attachment>
            </content>
            <xsl:if test="$EncounterExt or $EpisodeExt">
                <context>
                    <xsl:if test="$EncounterExt">
                        <encounter>
                            <identifier>
                                <system value="urn:oid:{$EncounterRoot}"/>
                                <value value="{$EncounterExt}"/>
                            </identifier>
                            <display value="Contact: {$EncounterExt}"/>
                        </encounter>
                    </xsl:if>
                    <xsl:if test="$EpisodeExt">
                        <related>
                            <identifier>
                                <system value="urn:oid:{$EpisodeRoot}"/>
                                <value value="{$EpisodeExt}"/>
                            </identifier>
                        </related>
                    </xsl:if>
                </context>
            </xsl:if>
        </DocumentReference>
    </xsl:template>

    <xd:doc>
        <xd:desc>Check if the document can be converted</xd:desc>
        <xd:param name="mediaType"/>
    </xd:doc>
    <xsl:function name="vf:CanBeConverted">
        <xsl:param name="mediaType"/>
        
        <xsl:choose>
            <xsl:when test="$mediaType = 'text/plain'"> true </xsl:when>
            <xsl:when test="$mediaType = 'application/pdf'"> true </xsl:when>
            <xsl:when test="$mediaType = 'application/doc'"> true </xsl:when>
            <xsl:when
                test="$mediaType = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'"
                > true </xsl:when>
            <xsl:when test="$mediaType = 'application/rtf'"> true </xsl:when>
            <xsl:when test="$mediaType = 'application/html'"> true </xsl:when>
        </xsl:choose>
    </xsl:function>
    
</xsl:stylesheet>
