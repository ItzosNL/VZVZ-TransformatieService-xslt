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
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:hl7="urn:hl7-org:v3"
    xmlns:hl7nl="urn:hl7-nl:v3"
    xmlns:vf="http://www.vzvz.nl/functions" 
    xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"
    exclude-result-prefixes="xs xsi vf s xd hl7 hl7nl f" 
    version="3.0">

    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> 2023-05-22</xd:p>
            <xd:p><xd:b>Author:</xd:b> VZVZ</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>

    <xsl:import href="vf.local_paths.xsl"/>    
    
    <!--
    versionXSLT = versienummer van DEZE transformatie, default de versie van dit bestand
    -->
    <xsl:variable name="vf:versionXSLT" as="xs:string">0.2.4</xsl:variable>
    <xsl:variable name="buildingBlock" select="'dummy'"/>
    <xsl:variable name="xslDebug" as="xs:boolean" select="false()"/>
    <xsl:variable name="zorgToepassing" as="xs:string" select="'MO'"/>

    <xsl:variable name="nictizVersion">
        <!-- over welke distributie hebben we het -->
        <xsl:variable name="distribution">
            <xsl:choose>
                <xsl:when test="exists($zorgToepassing) and $zorgToepassing = 'medmij'">
                    <xsl:value-of select="concat($medmij, '/distribution-info.xml')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat($hl7Mappings, '/distribution-info.xml')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <!-- bestaat de distributie wel? -->
        <xsl:variable name="nictizReleaseInfoAvailable"
            select="unparsed-text-available($distribution)"/>

        <xsl:if test="$nictizReleaseInfoAvailable">
            <xsl:variable name="tmp" select="document($distribution)"/>
            <xsl:value-of select="concat('N', $tmp//distribution/@version)"/>
        </xsl:if>
    </xsl:variable>
     
    <xsl:variable xmlns="" name="mapAORTAWrapper" as="element(map)+">
        <!-- aangepaste kopie van Nictiz en aangevuld met eigen gegevens -->
        <!-- preconcated with en_ to select sturen_medicatievoorschrift and ontvangen_medicatievoorschrift and no other usecases -->
        <map version="920 92 93 930 default" usecase="en_medicatievoorschrift"                buildingblock="PVMV" interactionId="PVMV_IN932000NL03" isPush="true"/>
        <map version="920 92 93 930 default" usecase="afhandeling_medicatievoorschrift"       buildingblock="PAMV" interactionId="PAMV_IN924000NL02" isPush="true"/>
        <!-- preconcated with en_ to select sturen_voorstel_medicatieafspraak and ontvangen_voorstel_medicatieafspraak and no other usecases -->
        <map version="920 92 930 93 default" usecase="en_voorstel_medicatieafspraak"          buildingblock="PVVM" interactionId="PVVM_IN000001NL01" isPush="true"/>
        <map version="920 92 930 93 default" usecase="antwoord_voorstel_medicatieafspraak"    buildingblock="PAVM" interactionId="PAVM_IN000001NL01" isPush="true"/>
        <!-- preconcated with en_ to select sturen_voorstel_verstrekkingsverzoek and ontvangen_voorstel_verstrekkingsverzoek and no other usecases -->
        <map version="920 92 930 93 default" usecase="en_voorstel_verstrekkingsverzoek"       buildingblock="PVVV" interactionId="PVVV_IN000001NL01" isPush="true"/>
        <map version="920 92 930 93 default" usecase="antwoord_voorstel_verstrekkingsverzoek" buildingblock="PAVV" interactionId="PAVV_IN000001NL01" isPush="true"/>
        <map version="930 93 default"        usecase="sturen_medicatiegegevens"               buildingblock="PVMG" interactionId="PVMG_IN000001NL01" isPush="true"/>
        <!-- 2023-09-14 onderstaande gevonden in schemas maar wordt blijkbaar verder niet gebruikt -\->
        <map version="920 92 default"        usecase="Melden Medicatiegebruik 9.2.x"          buildingblock="PMMG" interactionId="PMMG_IN040010NL02" isPush="true"/>
        -->
        <!-- OPEN gerelateerde transformaties -->
        <map version="default"               usecase="delen_zelfmetingen"                     buildingblock="ZM"   interactionId="ZTZM_IN000004NL01" isPush="true" isMedMij="true"/>
        
        <!-- some more complex handling for bouwsteen specific organizers and interactionIds in VZVZ implementation -->
        <map version="930 93 default" usecase="raadplegen_medicatiegegevens" buildingblock="MA"  interactionId="QUMA_IN991203NL04" queryInteractionId="QUMA_IN991201NL04" organizerTemplateId="2.16.840.1.113883.2.4.3.11.60.20.77.10.9432"/>
        <map version="930 93 default" usecase="raadplegen_medicatiegegevens" buildingblock="WDS" interactionId="QUDS_IN000003NL01" queryInteractionId="QUDS_IN000001NL01" organizerTemplateId="2.16.840.1.113883.2.4.3.11.60.20.77.10.9413"/>
        <map version="930 93 default" usecase="raadplegen_medicatiegegevens" buildingblock="VV"  interactionId="QUVV_IN992203NL03" queryInteractionId="QUVV_IN992201NL03" organizerTemplateId="2.16.840.1.113883.2.4.3.11.60.20.77.10.9450"/>
        <map version="930 93 default" usecase="raadplegen_medicatiegegevens" buildingblock="TA"  interactionId="QUTA_IN991213NL02" queryInteractionId="QUTA_IN991211NL02" organizerTemplateId="2.16.840.1.113883.2.4.3.11.60.20.77.10.9418"/>
        <map version="930 93 default" usecase="raadplegen_medicatiegegevens" buildingblock="MVE" interactionId="QUMV_IN992213NL02" queryInteractionId="QUMV_IN992211NL02" organizerTemplateId="2.16.840.1.113883.2.4.3.11.60.20.77.10.9365"/>
        <map version="930 93 default" usecase="raadplegen_medicatiegegevens" buildingblock="MGB" interactionId="QUMG_IN991223NL02" queryInteractionId="QUMG_IN991221NL02" organizerTemplateId="2.16.840.1.113883.2.4.3.11.60.20.77.10.9445"/>
        <map version="930 93 default" usecase="raadplegen_medicatiegegevens" buildingblock="MTD" interactionId="QUTD_IN000003NL01" queryInteractionId="QUTD_IN000001NL01" organizerTemplateId="2.16.840.1.113883.2.4.3.11.60.20.77.10.9408"/>
    </xsl:variable>
           

    <xd:doc>
        <xd:desc>Add transformationcode info depending on the type</xd:desc>
        <xd:param name="type">FHIR or V3</xd:param>
        <xd:param name="transformationCode">
            <xd:p>ID of the transformation</xd:p>
            <xd:p>See:
                https://vzvz.atlassian.net/wiki/spaces/UBEBVLEL/pages/27997299/Interfaces+Transformatie+Server+-+0.8.x</xd:p>
        </xd:param>
        <xd:param name="versionXSLT">version of the XSLT calling the stylesheet</xd:param>
    </xd:doc>
    <xsl:template name="addTransformationCode">
        <xsl:param name="type"/>
        <xsl:param name="transformationCode"/>
        <xsl:param name="versionXSLT" select="$vf:versionXSLT"/>

        <xsl:variable name="transformationInformation">
            <xsl:choose>
                <xsl:when test="$nictizVersion = ''">
                    <xsl:value-of select="concat($transformationCode, '|', $versionXSLT)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of
                        select="concat($transformationCode, '|', $versionXSLT, '|', $nictizVersion)"
                    />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$type = 'f' or $type = 'fhir'">
                <meta xmlns="http://hl7.org/fhir">
                    <security>
                        <system value="http://hl7.org/fhir/v3/ObservationValue"/>
                        <code value="SYNTAC"/>
                    </security>
                    <tag>
                        <system value="http://vzvz.nl/fhir/NamingSystem/transformation"/>
                        <code value="{$transformationInformation}"/>
                    </tag>
                </meta>
            </xsl:when>
            <xsl:when test="$type = 'v3' or $type = 'hl7'">
                <attentionLine xmlns="urn:hl7-org:v3">
                    <keyWordText code="SYNTAC" codeSystem="2.16.840.1.113883.2.4.15.1">syntactic transform</keyWordText>
                    <value xsi:type="II"
                        root="2.16.840.1.113883.2.4.3.111.15.5"
                        extension="{$transformationInformation}"/>
                </attentionLine>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="yes">Onbekend type '<xsl:value-of select="$type"/>' voor
                    addTransformationCode</xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xd:doc>
        <xd:desc>Process payload with Nictiz stylesheets, already performed outside of this
            XSLT</xd:desc>
        <xd:param name="in">Node to process</xd:param>
    </xd:doc>
    <xsl:template name="processPayload">
        <xsl:param name="in"/>
        <xsl:sequence select="$in"/>
    </xsl:template>

    <xd:doc>
        <xd:desc>Split an OID in the format root|extension to an id</xd:desc>
        <xd:param name="oid">value</xd:param>
        <xd:param name="element">name of element, default 'id'</xd:param>
    </xd:doc>
    <xsl:template name="splitMetaOID">
        <xsl:param name="oid" as="xs:string"/>
        <xsl:param name="element" select="'id'" as="xs:string"/>
        
        <xsl:variable name="root" select="substring-before($oid, '|')"/>
        <xsl:variable name="extension" select="substring-after($oid, '|')"/>
        
        <!-- 2024-09-03 BTDOV-84 HvdL no idea why I made these tests. They are creating errors
            <xsl:element name="{$element}" namespace="urn:hl7-org:v3">
                <xsl:attribute name="root">
                    <xsl:choose>
                        <xsl:when test="contains($root, '.')">
                            <xsl:value-of select="$root"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$extension"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:attribute name="extension">
                    <xsl:choose>
                        <xsl:when test="contains($extension, '.')">
                            <xsl:value-of select="$root"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$extension"/>
                        </xsl:otherwise>
                    </xsl:choose>
    
                </xsl:attribute>
            </xsl:element>
         -->
        
        <xsl:element name="{$element}" namespace="urn:hl7-org:v3">
            <xsl:attribute name="root" select="$root"/>
            <xsl:attribute name="extension" select="$extension"/>
        </xsl:element>        
    </xsl:template>


    <xd:doc>
        <xd:desc>Get the BSN from the provided OID (syntax: root|extension)</xd:desc>
        <xd:param name="patient">OID to split</xd:param>
    </xd:doc>
    <xsl:function name="vf:getBSN">
         <xsl:param name="patient"/>
         <xsl:variable name="tmp">
             <xsl:call-template name="splitMetaOID">
                 <xsl:with-param name="oid" select="$patient"/>
             </xsl:call-template>
         </xsl:variable>
         <xsl:value-of select="$tmp//@extension"/>
     </xsl:function>
    
    <xd:doc>
        <xd:desc>find out if this is a push message</xd:desc>
        <xd:param name="buildingBlock"/>
    </xd:doc>
    <xsl:function name="vf:isPushMessage" as="xs:boolean">
        <xsl:param name="buildingBlock"/>
        <xsl:sequence select="exists($mapAORTAWrapper[@buildingblock = $buildingBlock]/@isPush)"/>
    </xsl:function>

    <xd:doc>
        <xd:desc>find out if this is a message used between provider and patient</xd:desc>
        <xd:param name="buildingBlock"/>
    </xd:doc>
    <xsl:function name="vf:isMedMij" as="xs:boolean">
        <xsl:param name="buildingBlock"/>
        <xsl:sequence select="exists($mapAORTAWrapper[@buildingblock = $buildingBlock]/@isMedMij)"/>
    </xsl:function>

    <xd:doc>
        <xd:desc>fallback template</xd:desc>
    </xd:doc>
    <xsl:template match="@* | node()" mode="wrapper">
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates select="@* | node()" mode="wrapper"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
