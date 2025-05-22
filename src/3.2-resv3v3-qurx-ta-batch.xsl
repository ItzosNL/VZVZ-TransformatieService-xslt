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
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" 
    xmlns:hl7="urn:hl7-org:v3"
    xmlns:vf="http://www.vzvz.nl/functions" 
    xmlns="urn:hl7-org:v3" 
    exclude-result-prefixes="#all"
    version="3.0">
    
    <xsl:import href="vf.includes/vf.transformation-utils-v3.xsl"/>
    
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>Transformatie voor opleveren ToedieningsAfspraak</xd:p>
            
            <xd:p><xd:b>Created on:</xd:b> Jan 27, 2023</xd:p>
            <xd:p><xd:b>Author:</xd:b> VZVZ</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>

    <xsl:output indent="yes"/>
    
    <!-- pass originalMessage message -->
    <xsl:param name="originalMessage"/>

    <xsl:param name="xslDebug" select="false()" as="xs:boolean"/>
    <xsl:param name="logLevel" select="$logDEBUG"/>
    
    <!-- versionXSLT = versienummer van DEZE combo -->
    <xsl:variable name="versionXSLT" as="xs:string">0.5.1</xsl:variable>
    <xsl:variable name="transformationCode" as="xs:string" select="'3.2'"/>
    
    <xsl:variable name="buildingBlock" select="'TA'"/>
    <xsl:variable name="schematronRef" select="concat('file:', $svnAortaMP9, '/schematron_closed_warnings/mp-vzvz-opleverenToedieningsafspraken.sch')"/>
    <xsl:variable name="schematronRefZT" select="concat('file:', $svnAortaZTMP, '/mp-runtime-develop/mp-mp93_mg_ta.sch')"/>
        
    <xd:doc>
        <xd:desc>
            <xd:p>Main template</xd:p>
            <xd:p>We copy the wrapper elements from the original message</xd:p>
        </xd:desc>
        
    </xd:doc>
    <xsl:template match="/">
        <xsl:variable name="payload">
            <organizer classCode="CLUSTER" moodCode="EVN">
                <xsl:apply-templates select="./hl7:organizer/*" mode="wrapper"/>
            </organizer>
        </xsl:variable>        
        
        <!-- 
            We gebruiken het originele bericht om alle wrapper gegevens over te halen.
            Dus GEEN metaData object!!
            En om foutmeldingen te detecteren
          -->
        <xsl:variable name="originalMessageObj">
            <xsl:call-template name="convertToDocumentNode">
                <xsl:with-param name="xml" select="$originalMessage"/>
                <xsl:with-param name="msg">parameter originalMessage niet beschikbaar</xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:if test="$xslDebug">
            <xsl:processing-instruction name="xml-model">phase="#ALL" href="<xsl:value-of select="$schematronRef"/>" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:processing-instruction>
            <xsl:processing-instruction name="xml-model">phase="#ALL" href="<xsl:value-of select="$schematronRefZT"/>" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:processing-instruction>
        </xsl:if>
        
        <QUTA_IN991213NL02 xmlns="urn:hl7-org:v3" 
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <xsl:if test="$xslDebug">
                <xsl:variable name="schemaRef" select="concat('file:', $svnAortaMP9, '/schemas/', $mapAORTAWrapper[@buildingblock=$buildingBlock]/@interactionId, '.xsd')"/>
                <xsl:attribute name="xsi:schemaLocation">urn:hl7-org:v3 <xsl:value-of select="$schemaRef"/></xsl:attribute>
            </xsl:if>
            
            <!-- copy everything except ControlActProcess -->
            <xsl:for-each select="$originalMessageObj//hl7:QURX_IN990113NL/child::*" >
<!--                <xsl:comment><xsl:value-of select="local-name(.)"/></xsl:comment>-->
                <xsl:if test="not(local-name(.) = 'ControlActProcess')">
                    <xsl:apply-templates select="." mode="wrapper" exclude-result-prefixes="#all"/>
                </xsl:if>
            </xsl:for-each> 
                
            <ControlActProcess moodCode="EVN">
                <xsl:apply-templates select="$originalMessageObj//hl7:ControlActProcess/hl7:effectiveTime"/>
                <xsl:apply-templates select="$originalMessageObj//hl7:ControlActProcess/hl7:authorOrPerformer" mode="wrapper"/>
                <xsl:apply-templates select="$originalMessageObj//hl7:ControlActProcess/hl7:overseer" mode="wrapper"/>
                
                <!-- only if there is actually content -->
                
                <xsl:if test="
                    exists($payload/hl7:organizer/hl7:recordTarget)
                    ">
                    <subject>
                        <xsl:sequence select="$payload"/>
                    </subject>                    
                </xsl:if>
                <xsl:apply-templates select="$originalMessageObj//hl7:ControlActProcess/hl7:queryAck" mode="wrapper"/>
            </ControlActProcess>
        </QUTA_IN991213NL02>
    </xsl:template>
        
    <xd:doc>
        <xd:desc>
            <xd:p>Add attentionLine before receiver</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="hl7:receiver" mode="wrapper">
        <xsl:call-template name="addTransformationCode">
            <xsl:with-param name="type" select="'v3'"/>
            <xsl:with-param name="transformationCode" select="$transformationCode"/>
            <xsl:with-param name="versionXSLT" select="$versionXSLT"/>
        </xsl:call-template>
        <receiver>
            <xsl:apply-templates mode="wrapper"/>
        </receiver>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Replace interactionId</xd:desc>
    </xd:doc>
    <xsl:template match="hl7:interactionId" mode="wrapper">
        <interactionId extension="QUTA_IN991213NL02" root="2.16.840.1.113883.1.6" />
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Replace the code</xd:desc>
    </xd:doc>
    <xsl:template match="hl7:code[parent::hl7:organizer]" mode="wrapper">
        <code code="419891008"
            displayName="Gegevensobject"
            codeSystem="2.16.840.1.113883.6.96"
            codeSystemName="SNOMED CT"/>        
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Replace the statusCode</xd:desc>
    </xd:doc>
    <xsl:template match="hl7:statusCode[parent::hl7:organizer]" mode="wrapper">
        <statusCode code="completed"/>        
    </xsl:template>
  
</xsl:stylesheet>
