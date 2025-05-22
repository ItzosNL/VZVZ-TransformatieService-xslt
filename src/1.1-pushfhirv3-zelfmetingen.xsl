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
<xsl:stylesheet xmlns:fhir="http://hl7.org/fhir" 
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:hl7="urn:hl7-org:v3" 
    xmlns:hl7nl="urn:hl7-nl:v3"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:math="http://exslt.org/math" 
    xmlns:func="http://exslt.org/functions"
    xmlns:vf="http://www.vzvz.nl/functions" 
    xmlns="urn:hl7-org:v3" 
    exclude-result-prefixes="#all"
    version="3.0">

    <xsl:import href="vf.includes/vf.transformation-utils-v3.xsl"/>
    <xsl:import href="vf.includes/vf.patient.xsl"/>
    
    <xsl:output method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/>
    
    <!-- pass the metaData object -->
    <xsl:param name="metaData"/>
    
    <xsl:param name="xslDebug" select="false()" as="xs:boolean"/>
    <xsl:param name="logLevel" select="$logDEBUG"/>


    <!-- BSN van de patiënt -->
    <xsl:param name="PatID" select="123456789"/>

    <xsl:variable name="versionXSLT" as="xs:string">2.1.2</xsl:variable>
    <xsl:variable name="transformationCode" as="xs:string" select="'1.1'"/>
    
    <xsl:variable name="buildingBlock" select="'ZM'"/>
    <xsl:variable name="schematronRef" select="concat('file:', $svnAortaOpen, '/schematron_closed_warnings/ho-vzvz-DelenZelfmetingen.sch')"/>
    <xsl:variable name="schemaRefDir" select="concat('file:', $svnAortaOpen, '/schemas')"/>
   

    <!-- Tabel 45 versie. Variabele is hier neergezet zodat hij gemakkelijker terug te vinden is. -->
    <xsl:variable name="nhgTabel45-versie">20</xsl:variable>

    <xd:doc>
        <xd:desc>
            <xd:p>Dit is een conversie van een FHIR Bundle met Observation resources naar het CDA
                document dat als payload fungeert voor de V3 interactie delenZelfmetingen.</xd:p>
            <xd:p>Versie: zie variabele $versionXSLT</xd:p>
        </xd:desc>

    </xd:doc>
    <xsl:template match="/">

        <xsl:variable name="DocID">
            <xsl:value-of select="vf:UUID4()"/>
        </xsl:variable>
        <xsl:variable name="BSN">
            <xsl:value-of
                select="vf:PatientBSN(/fhir:Bundle/fhir:entry/fhir:resource/fhir:Patient/fhir:identifier, $PatID)"
            />
        </xsl:variable>
        
        <!-- metaData information MUST have an overseer, so if it doesn't exist, add a dummy -->
        <xsl:variable name="metaDataTmp">
            <xsl:call-template name="convertToDocumentNode">
                <xsl:with-param name="msg" select="$metaData"/>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:variable name="payload">
            <ClinicalDocument>
                <realmCode code="NL"/>
                <typeId root="2.16.840.1.113883.1.3" extension="POCD_HD000040"/>
                <!-- template ID Zelfmetingen Overzicht -->
                <!-- templateId root="2.16.840.1.113883.2.4.3.111.3.22.10.5"/ -->
                <!-- template ID overdrachtgegevens zorggroep huisarts -->
                
                <!-- let op: eigenlijk moet het template ...10.51 zijn, want dan wordt het correct gevalideerd,
                     maar dat is niet conform specificaties, waar ten onrechte ...10.61 staat
                     Zie emailwisseling van 2 en 3 november 2022
                -->
                <templateId root="2.16.840.1.113883.2.4.3.11.60.66.10.61"/>
                <!-- <templateId root="2.16.840.1.113883.2.4.3.11.60.66.10.51"/> -->
                <!-- template ID CDA Header NL -->
                <templateId root="2.16.840.1.113883.2.4.6.10.100001"/>
                
                <!-- 2.16.840.1.113883.2.4.3.111.19.2 vastgelegd als root van Message-id's van getransformeerde berichten -->
                <id extension="{$DocID}" root="2.16.840.1.113883.2.4.3.111.19.2"/>
                <code code="68608-9" codeSystem="2.16.840.1.113883.6.1" codeSystemName="LOINC"
                    displayName="Summarization note"/>
                <effectiveTime value="{vf:dateTimeFHIR_V3(string(current-dateTime()), true())}"/>
                <confidentialityCode code="N" codeSystem="2.16.840.1.113883.5.25"/>
                <languageCode code="nl-NL"/>
                <recordTarget>
                    <xsl:call-template name="V3_patientRole">
                        <xsl:with-param name="FHIR_Patient"
                            select="/fhir:Bundle/fhir:entry/fhir:resource/fhir:Patient"/>
                    </xsl:call-template>
                </recordTarget>
                <author>
                    <time value="{vf:dateTimeFHIR_V3(string(current-dateTime()), true())}"/>
                    <assignedAuthor>
                        <id extension="{$BSN}" root="2.16.840.1.113883.2.4.6.3"/>
                        <code code="P" codeSystem="2.16.840.1.113883.2.4.3.11.8" displayName="Patiënt"/>
                    </assignedAuthor>
                </author>
                <custodian>
                    <assignedCustodian>
                        <representedCustodianOrganization>
                            <id extension="{$BSN}" root="2.16.840.1.113883.2.4.6.3"/>
                        </representedCustodianOrganization>
                    </assignedCustodian>
                </custodian>
                <!-- CDA Body -->
                <component>
                    <structuredBody>
                        <component>
                            <section>
                                <templateId root="2.16.840.1.113883.2.4.3.111.3.22.10.6"/>
                                <code code="67781-5" codeSystem="2.16.840.1.113883.6.1"
                                    codeSystemName="LOINC" displayName="Summarization of encounter note"/>
                                <title>Zelfmetingen</title>
                                <xsl:variable name="observations">
                                    <observations>
                                        <xsl:for-each
                                            select="/fhir:Bundle/fhir:entry/fhir:resource/fhir:Observation">
                                            <xsl:variable name="LOINC-code"
                                                select="fhir:code/fhir:coding/fhir:code/@value"/>
                                            <xsl:variable name="V3-comment" select="vf:V3_comment(.)"/>
                                            <xsl:if
                                                test="contains('85354-9/29463-7/8867-4/14770-2/14743-9/14760-3', $LOINC-code)">
                                                <xsl:choose>
                                                    <xsl:when test="$LOINC-code = '85354-9'">
                                                        <xsl:for-each select="fhir:component">
                                                            <xsl:variable name="LOINC-code"
                                                                select="fhir:code/fhir:coding/fhir:code/@value"/>
                                                            <xsl:if
                                                                test="$LOINC-code = '8480-6' or $LOINC-code = '8462-4'">
                                                                <entry typeCode="DRIV">
                                                                    <xsl:call-template name="V3_observation">
                                                                        <xsl:with-param name="FHIR-identifier"
                                                                            select="../fhir:identifier"/>
                                                                        <xsl:with-param name="FHIR-statuscode"
                                                                            select="../fhir:status/@value"/>
                                                                        <xsl:with-param name="FHIR-datetime"
                                                                            select="../fhir:effectiveDateTime/@value"/>
                                                                        <xsl:with-param name="V3-comment"
                                                                            select="$V3-comment"/>
                                                                        <xsl:with-param name="FHIR-compnumber"
                                                                            select="position()"/>
                                                                    </xsl:call-template>
                                                                </entry>
                                                            </xsl:if>
                                                        </xsl:for-each>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <entry typeCode="DRIV">
                                                            <xsl:call-template name="V3_observation">
                                                                <xsl:with-param name="FHIR-identifier"
                                                                    select="fhir:identifier"/>
                                                                <xsl:with-param name="FHIR-statuscode"
                                                                    select="fhir:status/@value"/>
                                                                <xsl:with-param name="FHIR-datetime"
                                                                    select="fhir:effectiveDateTime/@value"/>
                                                                <xsl:with-param name="V3-comment"
                                                                    select="$V3-comment"/>
                                                                <xsl:with-param name="FHIR-compnumber" select="0"
                                                                />
                                                            </xsl:call-template>
                                                        </entry>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:if>
                                        </xsl:for-each>
                                    </observations>
                                </xsl:variable>
                                <xsl:choose>
                                    <xsl:when test="count($observations//entry) &gt; 0">
                                        <text><xsl:value-of select="count($observations//entry)"/> meting(en) gevonden</text>
                                        <xsl:copy-of select="$observations//observations/*"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <text>Geen metingen gevonden</text>
                                        <entry typeCode="DRIV">
                                            <observation classCode="OBS" moodCode="EVN" nullFlavor="NI">
                                                <templateId
                                                    root="2.16.840.1.113883.2.4.3.11.60.66.10.202"/>
                                                <id root="2.16.840.1.113883.2.4.3.11.60.66.10.202"
                                                    extension="0000"/>
                                                <code nullFlavor="NI"/>
                                                <statusCode code="nullified"/>
                                                <effectiveTime nullFlavor="NI"/>
                                                <value nullFlavor="NI" xsi:type="CE"/>
                                            </observation>
                                        </entry>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </section>
                        </component>
                    </structuredBody>
                </component>
            </ClinicalDocument>

        
        </xsl:variable>

        <xsl:call-template name="buildV3message">
            <xsl:with-param name="xslDebug" select="$xslDebug"/>
            <xsl:with-param name="schematronRef" select="$schematronRef"/>
            <xsl:with-param name="schemaRefDir" select="$schemaRefDir"/>
            <xsl:with-param name="buildingBlock" select="$buildingBlock"/>
            <xsl:with-param name="metaData" select="$metaData"/>
            <xsl:with-param name="hasOverseer" select="true()"/>
            <!-- 2025-01-21 remove original query param because the necessary ids are part of the metadata -->
<!--            <xsl:with-param name="originalQuery" select="''"/>-->
            <xsl:with-param name="payload" select="$payload"/>
            <xsl:with-param name="transformationCode" select="$transformationCode"/>
            <xsl:with-param name="versionXSLT" select="$versionXSLT"/>
        </xsl:call-template>

    </xsl:template>

    <xd:doc>
        <xd:desc>Zet een FHIR patiënt resource om naar een V3 patientRole</xd:desc>
        <xd:param name="FHIR_Patient"/>
    </xd:doc>
    <xsl:template name="V3_patientRole">
        <xsl:param name="FHIR_Patient"/>

        <xsl:variable name="BSN" select="vf:PatientBSN($FHIR_Patient/fhir:identifier, $PatID)"/>
        <xsl:variable name="Name-given">
            <xsl:for-each select="$FHIR_Patient/fhir:name/fhir:given">
                <xsl:if test="fhir:extension/fhir:valueCode/@value = 'BR'">
                    <xsl:value-of select="@value"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="Name-initials">
            <xsl:for-each select="$FHIR_Patient/fhir:name/fhir:given">
                <xsl:if test="fhir:extension/fhir:valueCode/@value = 'IN'">
                    <!-- add missing dot if necessary -->
                    <xsl:value-of select="if(substring(@value, string-length(@value) - 1) != '.')
                        then concat(@value, '.')
                        else @value
                        "/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="Name-family"
            select="normalize-space($FHIR_Patient/fhir:name/fhir:family/@value)"/>
        <xsl:variable name="Geslacht" select="vf:V3Gender($FHIR_Patient/fhir:gender/@value)"/>
        <xsl:variable name="GebDat">
            <xsl:if test="exists($FHIR_Patient/fhir:birthDate)">
                <xsl:value-of
                    select="vf:dateTimeFHIR_V3($FHIR_Patient/fhir:birthDate/@value, false())"/>
            </xsl:if>
        </xsl:variable>

        <patientRole>
            <id extension="{$BSN}" root="2.16.840.1.113883.2.4.6.3"/>
            <patient classCode="PSN" determinerCode="INSTANCE">
                <xsl:choose>
                    <xsl:when
                        test="normalize-space($Name-given) = '' and normalize-space($Name-initials) = ''">
                        <name nullFlavor="NI"/>
                    </xsl:when>
                    <xsl:when test="normalize-space($Name-family) = ''">
                        <name nullFlavor="NI"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <name>
                            <xsl:if test="normalize-space($Name-given) != ''">
                                <given qualifier="BR">
                                    <xsl:value-of select="$Name-given"/>
                                </given>
                            </xsl:if>
                            <xsl:if test="normalize-space($Name-initials) != ''">
                                <given qualifier="IN">
                                    <xsl:value-of select="$Name-initials"/>
                                </given>
                            </xsl:if>
                            <family>
                                <xsl:value-of select="$Name-family"/>
                            </family>
                        </name>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="empty($Geslacht)">
                        <administrativeGenderCode nullFlavor="UNK"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <administrativeGenderCode codeSystem="2.16.840.1.113883.5.1"
                            code="{$Geslacht}"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:if test="normalize-space($GebDat) != ''">
                    <birthTime value="{$GebDat}"/>
                </xsl:if>
            </patient>
        </patientRole>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>Zet een FHIR observation (meting) om naar een V3 meting.</xd:p>
            <xd:p>NB. een bloeddruk wordt, conform NGH tabel, omgezet in 2 V3 observations.</xd:p>
        </xd:desc>
        <xd:param name="FHIR-identifier"/>
        <xd:param name="FHIR-statuscode"/>
        <xd:param name="FHIR-datetime"/>
        <xd:param name="V3-comment"/>
        <xd:param name="FHIR-compnumber"/>
    </xd:doc>
    <xsl:template name="V3_observation">
        <xsl:param name="FHIR-identifier"/>
        <xsl:param name="FHIR-statuscode"/>
        <xsl:param name="FHIR-datetime"/>
        <xsl:param name="V3-comment"/>
        <xsl:param name="FHIR-compnumber"/>

        <xsl:variable name="IsNHG">
            <xsl:value-of
                select="fhir:code/fhir:coding/fhir:system/@value = 'https://referentiemodel.nhg.org/tabellen/nhg-tabel-45-diagnostische-bepalingen'"
            />
        </xsl:variable>
        <xsl:variable name="ObsCode">
            <xsl:value-of select="fhir:code/fhir:coding/fhir:code/@value"/>
        </xsl:variable>
        <xsl:variable name="ObsDisplay">
            <xsl:value-of select="fhir:code/fhir:coding/fhir:display/@value"/>
        </xsl:variable>
        <xsl:variable name="TimingEvent">
            <xsl:value-of
                select="fhir:extension[@url = 'http://hl7.org/fhir/StructureDefinition/observation-eventTiming']/fhir:extension/fhir:valueCodeableConcept/fhir:coding/fhir:code/@value"
            />
        </xsl:variable>
        <xsl:variable name="IsLab">
            <xsl:value-of
                select="($IsNHG and 
                    ($ObsCode = '381' or $ObsCode = '382' or
                    $ObsCode = '3222' or $ObsCode = '3223' or
                    $ObsCode = '3224' or $ObsCode = '3225' or
                    $ObsCode = '3226' or $ObsCode = '3227')) or
                    (not($IsNHG) and ($ObsCode = '14770-2' or $ObsCode = '14743-9' or $ObsCode = '14760-3'))"
            />
        </xsl:variable>
        <xsl:variable name="UCUM-value" select="fhir:valueQuantity/fhir:value/@value"/>
        <xsl:variable name="UCUM-unit" select="fhir:valueQuantity/fhir:unit/@value"/>

        <observation classCode="OBS" moodCode="EVN">
            <xsl:choose>
                <xsl:when test="$IsLab = true()">
                    <templateId root="2.16.840.1.113883.2.4.3.11.60.66.10.203"/>
                </xsl:when>
                <xsl:otherwise>
                    <templateId root="2.16.840.1.113883.2.4.3.11.60.66.10.202"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:call-template name="V3_id">
                <xsl:with-param name="FHIR_identifier" select="$FHIR-identifier"/>
                <xsl:with-param name="FHIR_compnumber" select="$FHIR-compnumber"/>
            </xsl:call-template>
            <xsl:call-template name="V3_NHG-code">
                <xsl:with-param name="FHIR_ObsCode" select="$ObsCode"/>
                <xsl:with-param name="FHIR_ObsDisplay" select="$ObsDisplay"/>
                <xsl:with-param name="FHIR_IsNHG" select="$IsNHG"/>
                <xsl:with-param name="FHIR_TimingEvent" select="$TimingEvent"/>
            </xsl:call-template>
            <xsl:if test="$V3-comment">
                <text>
                    <xsl:value-of select="$V3-comment"/>
                </text>
            </xsl:if>
            <statusCode code="{vf:V3_statuscode($FHIR-statuscode)}"/>
            <effectiveTime value="{vf:dateTimeFHIR_V3($FHIR-datetime, true())}"/>
            <value xsi:type="PQ" value="{$UCUM-value}" unit="{$UCUM-unit}"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"/>
            <xsl:if test="$IsLab = true()">
                <!-- Hier komt de referenceRange als die ook vertaald moet worden. -->
            </xsl:if>
        </observation>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>Genereer een V3 id uit een FHIR identifier.</xd:p>
            <xd:p>Als er geen FHIR identifier meegegeven wordt, dan wordt een OID gemaakt met een
                vaste OID root en een gegenereerde UUID als extension.</xd:p>
        </xd:desc>
        <xd:param name="FHIR_identifier"/>
        <xd:param name="FHIR_compnumber"/>
    </xd:doc>
    <xsl:template name="V3_id">
        <xsl:param name="FHIR_identifier"/>
        <xsl:param name="FHIR_compnumber"/>

        <xsl:choose>
            <xsl:when test="$FHIR_identifier">
                <xsl:variable name="FHIR_value">
                    <xsl:choose>
                        <xsl:when test="$FHIR_compnumber > 0">
                            <xsl:value-of
                                select="concat($FHIR_identifier/fhir:value/@value, '-', string($FHIR_compnumber))"
                            />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$FHIR_identifier/fhir:value/@value"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>

                <id root="2.16.840.1.113883.2.4.3.23.3.21" extension="{$FHIR_value}"/>
            </xsl:when>
            <xsl:otherwise>
                <id root="2.16.840.1.113883.2.4.3.23.3.21" extension="{vf:UUID4()}"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xd:doc>
        <xd:desc>Bepaal de NHG code van de FHIR LOINC code</xd:desc>
        <xd:param name="FHIR_ObsCode"/>
        <xd:param name="FHIR_ObsDisplay"/>
        <xd:param name="FHIR_IsNHG"/>
        <xd:param name="FHIR_TimingEvent"/>
    </xd:doc>
    <xsl:template name="V3_NHG-code">
        <xsl:param name="FHIR_ObsCode"/>
        <xsl:param name="FHIR_ObsDisplay"/>
        <xsl:param name="FHIR_IsNHG"/>
        <xsl:param name="FHIR_TimingEvent"/>

        <!-- voor LOINC-code 14760-3 moet eigenlijk de timing event worden meegegeven om te bepalen of het na diner, na lunch of na ontbijt is -->

        <xsl:variable name="NHG-code">
            <xsl:choose>
                <xsl:when test="$FHIR_IsNHG = true()">
                    <xsl:value-of select="$FHIR_ObsCode"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="$FHIR_ObsCode = '8480-6'">2055</xsl:when>
                        <xsl:when test="$FHIR_ObsCode = '8462-4'">2056</xsl:when>
                        <xsl:when test="$FHIR_ObsCode = '29463-7'">2408</xsl:when>
                        <xsl:when test="$FHIR_ObsCode = '8867-4'">3963</xsl:when>
                        <xsl:when test="$FHIR_ObsCode = '14770-2'">382</xsl:when>
                        <xsl:when test="$FHIR_ObsCode = '14743-9'">381</xsl:when>
                        <xsl:when test="$FHIR_ObsCode = '14760-3'">
                            <xsl:choose>
                                <xsl:when test="$FHIR_TimingEvent = 'PCV'">3222</xsl:when>
                                <xsl:when test="$FHIR_TimingEvent = 'PCM'">3224</xsl:when>
                                <xsl:when test="$FHIR_TimingEvent = 'PCD'">3223</xsl:when>
                                <xsl:otherwise>381</xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="NHG-disp">
            <xsl:choose>
                <xsl:when test="$FHIR_IsNHG = true()">
                    <xsl:value-of select="$FHIR_ObsDisplay"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="$FHIR_ObsCode = '8480-6'">systolische bloeddruk (thuismeting)</xsl:when>
                        <xsl:when test="$FHIR_ObsCode = '8462-4'">diastolische bloeddruk (thuismeting)</xsl:when>
                        <xsl:when test="$FHIR_ObsCode = '29463-7'">gewicht patiënt (thuismeting)</xsl:when>
                        <xsl:when test="$FHIR_ObsCode = '8867-4'">hartfrequentie (thuismeting)</xsl:when>
                        <xsl:when test="$FHIR_ObsCode = '14770-2'">glucose nuchter, draagbare meter</xsl:when>
                        <xsl:when test="$FHIR_ObsCode = '14743-9'">glucose niet nuchter, draagbare meter</xsl:when>
                        <xsl:when test="$FHIR_ObsCode = '14760-3'">
                            <xsl:choose>
                                <xsl:when test="$FHIR_TimingEvent = 'PCV'">glucose (dagcurve) 2u na diner, draagbare meter</xsl:when>
                                <xsl:when test="$FHIR_TimingEvent = 'PCM'">glucose (dagcurve) 2u na ontbijt, draagbare meter</xsl:when>
                                <xsl:when test="$FHIR_TimingEvent = 'PCD'">glucose (dagcurve) 2u na lunch, draagbare meter</xsl:when>
                                <xsl:otherwise>glucose niet nuchter, draagbare meter</xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <code code="{$NHG-code}" displayName="{$NHG-disp}"
            codeSystem="2.16.840.1.113883.2.4.4.30.45" codeSystemName="NHG Labcodes"
            codeSystemVersion="{$nhgTabel45-versie}"/>
    </xsl:template>

    <xd:doc>
        <xd:desc>Zet de FHIR statuscode om naar V3 equivalent</xd:desc>
        <xd:param name="FHIR_statuscode"/>
    </xd:doc>
    <xsl:function name="vf:V3_statuscode">
        <xsl:param name="FHIR_statuscode"/>

        <xsl:choose>
            <xsl:when test="$FHIR_statuscode = 'registered'">new</xsl:when>
            <xsl:when test="$FHIR_statuscode = 'preliminary'">active</xsl:when>
            <xsl:when test="$FHIR_statuscode = 'final'">completed</xsl:when>
            <xsl:when test="$FHIR_statuscode = 'amended'">completed</xsl:when>
        </xsl:choose>
    </xsl:function>

    <xd:doc>
        <xd:desc>
            <xd:p>Verzamel aanvullende attributen van metingen als V3 comment</xd:p>
        </xd:desc>
        <xd:param name="FHIR_observation"/>
    </xd:doc>
    <xsl:function name="vf:V3_comment">
        <xsl:param name="FHIR_observation"/>

        <xsl:if test="$FHIR_observation/fhir:comment">
            <xsl:value-of select="$FHIR_observation/fhir:comment/@value"/>
            <xsl:text>&#10;</xsl:text>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="$FHIR_observation/fhir:code/fhir:coding/fhir:code/@value = '85354-9'">
                <xsl:if
                    test="$FHIR_observation/fhir:bodySite/fhir:coding[fhir:system/@value = 'http://snomed.info/sct' and fhir:code/@value = '368208006']/fhir:display/@value"
                    >Meetlocatie: <xsl:value-of
                        select="$FHIR_observation/fhir:bodySite/fhir:coding[fhir:system/@value = 'http://snomed.info/sct' and fhir:code/@value = '368208006']/fhir:display/@value"
                    /><xsl:text>&#10;</xsl:text>
                </xsl:if>
                <xsl:if
                    test="$FHIR_observation/fhir:component[fhir:code/fhir:coding/fhir:system/@value = 'http://loinc.org' and fhir:code/fhir:coding/fhir:code/@value = '8361-8']/fhir:valueCodeableConcept/fhir:coding/fhir:display/@value"
                    >Houding: <xsl:value-of
                        select="$FHIR_observation/fhir:component[fhir:code/fhir:coding/fhir:system/@value = 'http://loinc.org' and fhir:code/fhir:coding/fhir:code/@value = '8361-8']/fhir:valueCodeableConcept/fhir:coding/fhir:display/@value"
                    /><xsl:text>&#10;</xsl:text>
                </xsl:if>
                <xsl:if
                    test="$FHIR_observation/fhir:component[fhir:code/fhir:coding/fhir:system/@value = 'http://snomed.info/sct' and fhir:code/fhir:coding/fhir:code/@value = '424724000']/fhir:valueCodeableConcept/fhir:coding/fhir:display/@value"
                    >Houding: <xsl:value-of
                        select="$FHIR_observation/fhir:component[fhir:code/fhir:coding/fhir:system/@value = 'http://snomed.info/sct' and fhir:code/fhir:coding/fhir:code/@value = '424724000']/fhir:valueCodeableConcept/fhir:coding/fhir:display/@value"
                    /><xsl:text>&#10;</xsl:text>
                </xsl:if>
                <xsl:if
                    test="$FHIR_observation/fhir:component[fhir:code/fhir:coding/fhir:system/@value = 'http://loinc.org' and fhir:code/fhir:coding/fhir:code/@value = '8358-4']/fhir:valueCodeableConcept/fhir:coding/fhir:display/@value"
                    >Manchet: <xsl:value-of
                        select="$FHIR_observation/fhir:component[fhir:code/fhir:coding/fhir:system/@value = 'http://loinc.org' and fhir:code/fhir:coding/fhir:code/@value = '8358-4']/fhir:valueCodeableConcept/fhir:coding/fhir:display/@value"
                    /><xsl:text>&#10;</xsl:text>
                </xsl:if>
                <xsl:if
                    test="$FHIR_observation/fhir:component[fhir:code/fhir:coding/fhir:system/@value = 'http://snomed.info/sct' and fhir:code/fhir:coding/fhir:code/@value = '70665002']/fhir:valueCodeableConcept/fhir:coding/fhir:display/@value"
                    >Manchet: <xsl:value-of
                        select="$FHIR_observation/fhir:component[fhir:code/fhir:coding/fhir:system/@value = 'http://snomed.info/sct' and fhir:code/fhir:coding/fhir:code/@value = '70665002']/fhir:valueCodeableConcept/fhir:coding/fhir:display/@value"
                    /><xsl:text>&#10;</xsl:text>
                </xsl:if>

                <!-- gemiddelde bloeddruk -->
                <xsl:if
                    test="$FHIR_observation/fhir:component[fhir:code/fhir:coding/fhir:system/@value = 'http://loinc.org' and fhir:code/fhir:coding/fhir:code/@value = '8478-0']/fhir:valueQuantity/fhir:value/@value"
                    >Gemiddelde bloeddruk: <xsl:value-of
                        select="$FHIR_observation/fhir:component[fhir:code/fhir:coding/fhir:system/@value = 'http://loinc.org' and fhir:code/fhir:coding/fhir:code/@value = '8478-0']/fhir:valueQuantity/fhir:value/@value"
                        /><xsl:text> </xsl:text><xsl:value-of
                        select="$FHIR_observation/fhir:component[fhir:code/fhir:coding/fhir:system/@value = 'http://loinc.org' and fhir:code/fhir:coding/fhir:code/@value = '8478-0']/fhir:valueQuantity/fhir:unit/@value"/>
                    <xsl:text>&#10;</xsl:text>
                </xsl:if>

                <!-- diastolisch eindunt = Korotkoff sound -->

                <xsl:if
                    test="$FHIR_observation/fhir:component[fhir:code/fhir:coding/fhir:system/@value = 'http://snomed.info/sct' and fhir:code/fhir:coding/fhir:code/@value = '85549003']/fhir:valueCodeableConcept/fhir:coding/fhir:display/@value"
                    >Diastolisch eindpunt: <xsl:value-of
                        select="$FHIR_observation/fhir:component[fhir:code/fhir:coding/fhir:system/@value = 'http://snomed.info/sct' and fhir:code/fhir:coding/fhir:code/@value = '85549003']/fhir:valueCodeableConcept/fhir:coding/fhir:display/@value"
                    /><xsl:text>&#10;</xsl:text>
                </xsl:if>

            </xsl:when>
            <xsl:when test="$FHIR_observation/fhir:code/fhir:coding/fhir:code/@value = '14743-9'">
                <xsl:if
                    test="$FHIR_observation/fhir:extension[@url = 'http://hl7.org/fhir/StructureDefinition/observation-eventTiming']/fhir:extension/fhir:valueCodeableConcept/fhir:coding[fhir:system/@value = 'http://hl7.org/fhir/v3/TimingEvent']/fhir:display/@value"
                    >Tijdstip: <xsl:value-of
                        select="vf:TimeEventDescription($FHIR_observation/fhir:extension[@url = 'http://hl7.org/fhir/StructureDefinition/observation-eventTiming']/fhir:extension/fhir:valueCodeableConcept/fhir:coding[fhir:system/@value = 'http://hl7.org/fhir/v3/TimingEvent']/fhir:display/@value)"
                    /><xsl:text>&#10;</xsl:text>
                </xsl:if>
            </xsl:when>
            <xsl:when test="$FHIR_observation/fhir:code/fhir:coding/fhir:code/@value = '8867-4'">
                <xsl:if test="$FHIR_observation/fhir:interpretation/fhir:coding/fhir:display/@value"
                    >Regelmaat: <xsl:value-of
                        select="$FHIR_observation/fhir:interpretation/fhir:coding/fhir:display/@value"
                    /><xsl:text>&#10;</xsl:text>
                </xsl:if>
                <xsl:if test="$FHIR_observation/fhir:method/fhir:coding/fhir:display/@value"
                    >Meetmethode: <xsl:value-of
                        select="$FHIR_observation/fhir:method/fhir:coding/fhir:display/@value"
                    /><xsl:text>&#10;</xsl:text>
                </xsl:if>
            </xsl:when>
            <xsl:when test="$FHIR_observation/fhir:code/fhir:coding/fhir:code/@value = '29463-7'">
                <xsl:if
                    test="$FHIR_observation/fhir:component[fhir:code/fhir:coding/fhir:system/@value = 'http://loinc.org' and fhir:code/fhir:coding/fhir:code/@value = '8352-7']/fhir:valueCodeableConcept/fhir:coding/fhir:display/@value"
                    >Kleding: <xsl:value-of
                        select="$FHIR_observation/fhir:component[fhir:code/fhir:coding/fhir:system/@value = 'http://loinc.org' and fhir:code/fhir:coding/fhir:code/@value = '8352-7']/fhir:valueCodeableConcept/fhir:coding/fhir:display/@value"
                    /><xsl:text>&#10;</xsl:text>
                </xsl:if>
            </xsl:when>
        </xsl:choose>
    </xsl:function>

    <xd:doc>
        <xd:desc>
            <xd:p>Bepaal de omschrijving voor de TimeEventCode</xd:p>
        </xd:desc>
        <xd:param name="TimeEventCode"/>
    </xd:doc>
    <xsl:function name="vf:TimeEventDescription">
        <xsl:param name="TimeEventCode"/>

        <xsl:choose>
            <xsl:when test="$TimeEventCode = 'HS'">voor het uur van (poging tot) slapen</xsl:when>
            <xsl:when test="$TimeEventCode = 'WAKE'">na wakker worden</xsl:when>
            <xsl:when test="$TimeEventCode = 'C'">tijdens maaltijd</xsl:when>
            <xsl:when test="$TimeEventCode = 'CM'">tijdens ontbijt</xsl:when>
            <xsl:when test="$TimeEventCode = 'CD'">tijdens lunch</xsl:when>
            <xsl:when test="$TimeEventCode = 'CV'">tijdens diner</xsl:when>
            <xsl:when test="$TimeEventCode = 'AC'">voor maaltijd</xsl:when>
            <xsl:when test="$TimeEventCode = 'ACM'">voor ontbijt</xsl:when>
            <xsl:when test="$TimeEventCode = 'ACD'">voor lunch</xsl:when>
            <xsl:when test="$TimeEventCode = 'ACV'">voor diner</xsl:when>
            <xsl:when test="$TimeEventCode = 'PC'">na maaltijd</xsl:when>
            <xsl:when test="$TimeEventCode = 'PCM'">na ontbijt</xsl:when>
            <xsl:when test="$TimeEventCode = 'PCD'">na lunch</xsl:when>
            <xsl:when test="$TimeEventCode = 'PCV'">na diner</xsl:when>
            <xsl:when test="$TimeEventCode = 'IC'">tussen maaltijden</xsl:when>
            <xsl:when test="$TimeEventCode = 'ICD'">tussen lunch en diner</xsl:when>
            <xsl:when test="$TimeEventCode = 'ICM'">tussen ontbijt en lunch</xsl:when>
            <xsl:when test="$TimeEventCode = 'ICV'">tussen diner en uur van slapen</xsl:when>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>
