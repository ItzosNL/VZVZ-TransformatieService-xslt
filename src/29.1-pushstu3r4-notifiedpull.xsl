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
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:saxon="http://saxon.sf.net/"
    xmlns:vf="http://www.vzvz.nl/functions" xmlns:f="http://hl7.org/fhir"
    xmlns="http://hl7.org/fhir" exclude-result-prefixes="xs math xd vf f saxon" version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>Transformation from TA Notified Pull (STU3) to AORTA Notified Pull (R4B)</xd:p>
            <xd:p><xd:b>Created on:</xd:b> Jan 23, 2024</xd:p>
            <xd:p><xd:b>Author:</xd:b> VZVZ</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>

    <xsl:import href="vf.includes/vf.transformation-utils-fhir.xsl"/>
    <xsl:import href="vf.includes/vf.datetime-functions.xsl"/>

    <xsl:variable name="transformationCode">29.1</xsl:variable>
    <xsl:variable name="versionXSLT">0.1.4</xsl:variable>

    <xsl:param name="consentToken" select="saxon:string-to-base64Binary('dummy token', 'UTF8')"/>
    <xd:doc>
        <xd:desc>Set the default restriction period to 1 year after today</xd:desc>
    </xd:doc>
    <xsl:param name="endTime" select="vf:calculate-t-date('TODAY+12M')"/>
    <xsl:param name="appID" select="'the-app-id'"/>
    <xsl:param name="ura" select="'the-ura'"/>

    <xd:doc>
        <xd:desc>Main template</xd:desc>
    </xd:doc>
    <xsl:template match="/f:Task">
        <Task>
            <meta>
                <profile value="http://vzvz.nl/fhir/StructureDefinition/nl-vzvz-TaskNotifiedPull"/>
                <xsl:sequence select="$metaStructure//f:meta/*"/>
            </meta>
            <contained>
                <Device xmlns="http://hl7.org/fhir">
                    <id value="device1"/>
                    <meta>
                        <profile value="http://vzvz.nl/fhir/StructureDefinition/nl-vzvz-Device"/>
                    </meta>
                    <xsl:choose>
                        <xsl:when test="not($appID = 'the-app-id')">
                            <identifier>
                                <system value="http://fhir.nl/fhir/NamingSystem/aorta-app-id"/>
                                <value value="{$appID}"/>
                            </identifier>
                        </xsl:when>
                        <xsl:when test="starts-with(/f:Task/f:requester/f:agent/f:identifier/f:value/@value, 'urn:')">
                            <identifier>
                                <system value="urn:ietf:rfc:3986"/>
                                <xsl:sequence select="/f:Task/f:requester/f:agent/f:identifier/f:value"/>
                            </identifier>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- 2024-11-14 BTDOV-112 this is by request but does, today, result in an invalid Device instance according to the profile -->
                            <!-- 2024-11-21 Based on BTDOV-112 is the device profile updated and should the validation succeed -->
                            <xsl:sequence select="/f:Task/f:requester/f:agent/f:identifier"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <owner>
                        <identifier>
                            <system value="http://fhir.nl/fhir/NamingSystem/ura"/>
                            <xsl:choose>
                                <!-- 2024-11-05 we prefer the parameter, but if it is not filled in, use the Task.owner. 
                                    If all else fails, use the dummy value of the parameter -->
                                <xsl:when test="not($ura = 'the-ura')">
                                    <value value="{$ura}"/>                                    
                                </xsl:when>
                              <xsl:when test="exists(/f:Task/f:requester/f:onBehalfOf/f:identifier[f:system/@value='http://fhir.nl/fhir/NamingSystem/ura'])">
                                <xsl:variable name="tmp" select="/f:Task/f:requester/f:onBehalfOf/f:identifier[f:system/@value='http://fhir.nl/fhir/NamingSystem/ura']/f:value/@value"/>
                                <value value="{$tmp}"/>
                              </xsl:when>
                                <xsl:when test="exists(/f:Task/f:owner/f:identifier[f:system/@value='http://fhir.nl/fhir/NamingSystem/ura'])">
                                    <xsl:variable name="tmp" select="/f:Task/f:owner/f:identifier[f:system/@value='http://fhir.nl/fhir/NamingSystem/ura']/f:value/@value"/>
                                    <value value="{$tmp}"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <value value="{$ura}"/>                                    
                                </xsl:otherwise>
                            </xsl:choose>
                        </identifier>
                    </owner>
                </Device>
            </contained>
            <!-- get or create the identifier -->
            <xsl:choose>
                <xsl:when test="exists(./f:identifier)">
                    <xsl:copy-of select="./f:identifier"/>
                </xsl:when>
                <xsl:otherwise>
                    <identifier>
                        <system value="http://sending.system/id"/>
                        <value value="{vf:UUID4()}"/>
                    </identifier>
                </xsl:otherwise>
            </xsl:choose>

            <xsl:apply-templates
                select="./f:definitionReference | ./f:definitionUri "/>
            <!-- 2024-11-14 BTDOV-112 '| ./f:basedOn' removed as per request by Ron van Holland -->

            <!-- get or create the groupIdentifier -->
            <xsl:choose>
                <xsl:when test="exists(./f:groupIdentifier)">
                    <xsl:copy-of select="./f:groupIdentifier"/>
                </xsl:when>
                <xsl:otherwise>
                    <groupIdentifier>
                        <system value="http://sending.system/np-groupId"/>
                        <value value="{vf:UUID4()}"/>
                    </groupIdentifier>
                </xsl:otherwise>
            </xsl:choose>

            <xsl:apply-templates select="
                    ./f:partOf | ./f:status | ./f:intent | ./f:priority | ./f:code
                    | ./f:description | ./f:for"/>
            <xsl:call-template name="requester"/>
            <xsl:apply-templates select="./f:owner"/>

            <xsl:call-template name="restriction">
                <xsl:with-param name="in" select="./f:restriction"/>
            </xsl:call-template>

            <xsl:call-template name="consentToken"/>
            <xsl:apply-templates
                select="f:input[f:type/f:coding/f:code/not(@value = 'authorization-base')]"/>

        </Task>
    </xsl:template>

    <xd:doc>
        <xd:desc>Match the code</xd:desc>
    </xd:doc>
    <xsl:template match="/f:Task/f:code">
        <code>
            <coding>
                <system value="http://vzvz.nl/fhir/CodeSystem/aorta-taskcode"/>
                <code value="notified_pull"/>
            </coding>
        </code>
    </xsl:template>

    <xd:doc>
        <xd:desc>Set the intent, which is fixed in AORTA</xd:desc>
    </xd:doc>
    <xsl:template match="f:intent">
        <intent value="proposal"/>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>Set the restriction period.</xd:p>
            <xd:p>If there is a restriction.period.start available, copy it, if not, ignore
                it.</xd:p>
            <xd:p>If there is a restriction.period.end available, copy it. If it's not available,
                use the content of param $endTime. </xd:p>
        </xd:desc>
        <xd:param name="in">The original restriction element</xd:param>
    </xd:doc>
    <xsl:template name="restriction">
        <xsl:param name="in"/>

        <restriction>
            <period>
                <xsl:if test="exists($in//f:period/f:start)">
                    <xsl:sequence select="$in//f:period/f:start"/>
                </xsl:if>
                <xsl:choose>
                    <xsl:when test="exists($in//f:period/f:end)">
                        <xsl:sequence select="$in//f:period/f:end"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <end value="{$endTime}"/>
                    </xsl:otherwise>
                </xsl:choose>
            </period>
        </restriction>
    </xsl:template>
    <xd:doc>
        <xd:desc>Convert definition as uri</xd:desc>
    </xd:doc>
    <xsl:template match="f:definitionUri">
        <instantiatesUri value="{./@value}"/>
    </xsl:template>

    <xd:doc>
        <xd:desc>Convert definition as reference</xd:desc>
    </xd:doc>
    <xsl:template match="f:definitionReference">
        <instantiatesUri value="{./f:reference/@value}"/>
    </xsl:template>

    <xd:doc>
        <xd:desc>Convert context</xd:desc>
    </xd:doc>
    <xsl:template match="f:context">
        <encounter>
            <xsl:copy-of select="."/>
        </encounter>
    </xsl:template>

    <xd:doc>
        <xd:desc>Convert requester</xd:desc>
    </xd:doc>
    <xsl:template name="requester">
        <requester>
            <reference value="#device1"/>
            <type value="Device"/>
        </requester>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>Convert authorization-base to consent-token</xd:p>
            <xd:p>Chipsoft doesn't provide one and we exchange it for the one in the parameter, so
                no problem to just skip the input element. </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="consentToken">
        <input>
            <type xmlns="http://hl7.org/fhir">
                <coding>
                    <system value="http://vzvz.nl/fhir/CodeSystem/TaskParameterType"/>
                    <code value="consent_token"/>
                </coding>
            </type>
            <xsl:choose>
                <xsl:when
                    test="exists(f:input[f:type/f:coding/f:code/@value = 'authorization-base'])">
                    <xsl:variable name="tmp" select="f:input[f:type/f:coding/f:code/@value='authorization-base']/f:valueString/@value"/>
                    <valueString xmlns="http://hl7.org/fhir" value="{$tmp}"/>
                </xsl:when>
                <xsl:otherwise>
                    <valueString xmlns="http://hl7.org/fhir" value="{$consentToken}"/>
                </xsl:otherwise>
            </xsl:choose>
        </input>
    </xsl:template>

    <xd:doc>
        <xd:desc>Convert Twiin query to AORTA query-string</xd:desc>
    </xd:doc>
    <xsl:template match="f:input[f:type/f:coding/f:code/not(@value = 'authorization-base')]">
        <xsl:variable name="code" select="f:type/f:coding/f:code/@value"/>
        <xsl:choose>
            <xsl:when test="$code = 'get-workflow-task'">
                <!-- 2024-11-14 BTDOV-112 workflow task removed as per request by Ron van Holland -->
<!--                <input>
                    <type>
                        <coding>
                            <system value="http://fhir.nl/fhir/NamingSystem/TaskParameter"/>
                            <code value="get-workflow-task"/>
                        </coding>
                    </type>
                    <!-\- geen andere resources toegevoegd, workflow-task moet worden opgehaald -\->
                    <valueBoolean value="true"/>
                </input>
-->            </xsl:when>
            <xsl:when test="exists(f:valueReference)">
                <!-- 2024-11-14 BTDOV-112 We assume that a reference refers to a Workflow task, so we skip it -->
            </xsl:when>
            <xsl:otherwise>
                <!-- 2024-10-25 we don't need to parse, just assume everything is a query_string
                <xsl:variable name="id">
                    <xsl:variable name="tmp" select="f:valueString/@value"/>
                    <xsl:sequence select="replace($tmp, '^(?:.*/)?([A-Z][a-zA-Z0-9_]*)(?=(\\?|$|/\\$))', '$1')"/>
                </xsl:variable>
                <xsl:comment>found: <xsl:value-of select="$id"/> with code: <xsl:value-of select="$code"/> </xsl:comment>
                <input>
                    <xsl:sequence select="$mapTwiin2AORTA[@element=$id and @code=$code]/f:type" xmlns='http://hl7.org/fhir'/>
                    <xsl:sequence select="f:valueString"/>            
                </input>                
                -->
                <input>
                    <type xmlns="http://hl7.org/fhir">
                        <coding>
                            <system value="http://vzvz.nl/fhir/CodeSystem/TaskParameterType"/>
                            <code value="query_string"/>
                        </coding>
                    </type>
                    <xsl:sequence select="f:valueString"/>
                </input>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xd:doc>
        <xd:desc>fallback template</xd:desc>
    </xd:doc>
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>Mapping table going from Twiin to AORTA</xd:p>
            <xd:p>NOTE: the valueStrings are only added for reference, and possible use in the
                future, but are currently not used </xd:p>
        </xd:desc>
    </xd:doc>
<!--    <xsl:variable xmlns="" name="mapTwiin2AORTA" as="element(map)+">
        <map element="Patient" code="79191-3">
            <type xmlns="http://hl7.org/fhir">
                <coding>
                    <system value="http://vzvz.nl/fhir/CodeSystem/TaskParameterType"/>
                    <code value="query_string"/>
                </coding>
            </type>
            <!-\- <valueString xmlns="http://hl7.org/fhir" value="Patient?_include=Patient:general-practitioner"/> -\->
        </map>
        <map element="Coverage" code="48768-6">
            <type xmlns="http://hl7.org/fhir">
                <coding>
                    <system value="http://vzvz.nl/fhir/CodeSystem/TaskParameterType"/>
                    <code value="query_string"/>
                </coding>
            </type>
            <!-\- <valueString xmlns="http://hl7.org/fhir" value="Coverage?_include=Coverage:payor:Patient&amp;_include=Coverage:payor:Organization" /> -\->
        </map>
        <map element="Consent" code="11291000146105">
            <type xmlns="http://hl7.org/fhir">
                <coding>
                    <system value="http://vzvz.nl/fhir/CodeSystem/TaskParameterType"/>
                    <code value="query_string"/>
                </coding>
            </type>
            <!-\- <valueString xmlns="http://hl7.org/fhir" value="Consent?category=http://snomed.info/sct|11291000146105" /> -\->
        </map>
        <map element="Consent" code="11341000146107">
            <type xmlns="http://hl7.org/fhir">
                <coding>
                    <system value="http://vzvz.nl/fhir/CodeSystem/TaskParameterType"/>
                    <code value="query_string"/>
                </coding>
            </type>
            <!-\- <valueString xmlns="http://hl7.org/fhir" value="Consent?category=http://snomed.info/sct|11341000146107" /> -\->
        </map>
        <map element="Observation" code="47420-5">
            <type xmlns="http://hl7.org/fhir">
                <coding>
                    <system value="http://vzvz.nl/fhir/CodeSystem/TaskParameterType"/>
                    <code value="query_string"/>
                </coding>
            </type>
            <!-\- <valueString xmlns="http://hl7.org/fhir" value="Observation/$lastn?category=http://snomed.info/sct|118228005,http://snomed.info/sct|384821006" /> -\->
        </map>
        <map element="Condition" code="11450-4">
            <type xmlns="http://hl7.org/fhir">
                <coding>
                    <system value="http://vzvz.nl/fhir/CodeSystem/TaskParameterType"/>
                    <code value="query_string"/>
                </coding>
            </type>
            <!-\- <valueString xmlns="http://hl7.org/fhir" value="Condition" /> -\->
        </map>
        <map element="Observation" code="365508006">
            <type xmlns="http://hl7.org/fhir">
                <coding>
                    <system value="http://vzvz.nl/fhir/CodeSystem/TaskParameterType"/>
                    <code value="query_string"/>
                </coding>
            </type>
            <!-\- <valueString xmlns="http://hl7.org/fhir" value="Observation/$lastn?code=http://snomed.info/sct|365508006" /> -\->
        </map>
        <map element="Observation" code="228366006">
            <type xmlns="http://hl7.org/fhir">
                <coding>
                    <system value="http://vzvz.nl/fhir/CodeSystem/TaskParameterType"/>
                    <code value="query_string"/>
                </coding>
            </type>
            <!-\- <valueString xmlns="http://hl7.org/fhir" value="Observation?code=http://snomed.info/sct|228366006" /> -\->
        </map>
        <map element="Observation" code="228273003">
            <type xmlns="http://hl7.org/fhir">
                <coding>
                    <system value="http://vzvz.nl/fhir/CodeSystem/TaskParameterType"/>
                    <code value="query_string"/>
                </coding>
            </type>
            <!-\- <valueString xmlns="http://hl7.org/fhir" value="Observation?code=http://snomed.info/sct|228273003" /> -\->
        </map>
        <map element="Observation" code="365980008">
            <type xmlns="http://hl7.org/fhir">
                <coding>
                    <system value="http://vzvz.nl/fhir/CodeSystem/TaskParameterType"/>
                    <code value="query_string"/>
                </coding>
            </type>
            <!-\- <valueString xmlns="http://hl7.org/fhir" value="Observation?code=http://snomed.info/sct|365980008" /> -\->
        </map>
        <map element="NutritionOrder" code="11816003">
            <type xmlns="http://hl7.org/fhir">
                <coding>
                    <system value="http://vzvz.nl/fhir/CodeSystem/TaskParameterType"/>
                    <code value="query_string"/>
                </coding>
            </type>
            <!-\- <valueString xmlns="http://hl7.org/fhir" value="NutritionOrder" /> -\->
        </map>
        <map element="Flag" code="75310-3">
            <type xmlns="http://hl7.org/fhir">
                <coding>
                    <system value="http://vzvz.nl/fhir/CodeSystem/TaskParameterType"/>
                    <code value="query_string"/>
                </coding>
            </type>
            <!-\- <valueString xmlns="http://hl7.org/fhir" value="Flag" /> -\->
        </map>
        <map element="AllergyIntolerance" code="48765-2">
            <type xmlns="http://hl7.org/fhir">
                <coding>
                    <system value="http://vzvz.nl/fhir/CodeSystem/TaskParameterType"/>
                    <code value="query_string"/>
                </coding>
            </type>
            <!-\- <valueString xmlns="http://hl7.org/fhir" value="AllergyIntolerance" /> -\->
        </map>
        <map element="MedicationStatement" code="422979000">
            <type xmlns="http://hl7.org/fhir">
                <coding>
                    <system value="http://vzvz.nl/fhir/CodeSystem/TaskParameterType"/>
                    <code value="query_string"/>
                </coding>
            </type>
            <!-\- <valueString xmlns="http://hl7.org/fhir" value="MedicationStatement?category=urn:oid:2.16.840.1.113883.2.4.3.11.60.20.77.5.3|6&amp;_include=MedicationStatement:medication" /> -\->
        </map>
        <map element="MedicationRequest" code="16076005">
            <type xmlns="http://hl7.org/fhir">
                <coding>
                    <system value="http://vzvz.nl/fhir/CodeSystem/TaskParameterType"/>
                    <code value="query_string"/>
                </coding>
            </type>
            <!-\- <valueString xmlns="http://hl7.org/fhir" value="MedicationRequest?category=http://snomed.info/sct|16076005&amp;_include=MedicationRequest:medication" /> -\->
        </map>
        <map element="MedicationDispense" code="422037009">
            <type xmlns="http://hl7.org/fhir">
                <coding>
                    <system value="http://vzvz.nl/fhir/CodeSystem/TaskParameterType"/>
                    <code value="query_string"/>
                </coding>
            </type>
            <!-\- <valueString xmlns="http://hl7.org/fhir" value="MedicationDispense?category=http://snomed.info/sct|422037009&amp;_include=MedicationDispense:medication" /> -\->
        </map>
        <map element="DeviceUseStatement" code="46264-8">
            <type xmlns="http://hl7.org/fhir">
                <coding>
                    <system value="http://vzvz.nl/fhir/CodeSystem/TaskParameterType"/>
                    <code value="query_string"/>
                </coding>
            </type>
            <!-\- <valueString xmlns="http://hl7.org/fhir" value="DeviceUseStatement?_include=DeviceUseStatement:device" /> -\->
        </map>
        <map element="Immunization" code="11369-6">
            <type xmlns="http://hl7.org/fhir">
                <coding>
                    <system value="http://vzvz.nl/fhir/CodeSystem/TaskParameterType"/>
                    <code value="query_string"/>
                </coding>
            </type>
            <!-\- <valueString xmlns="http://hl7.org/fhir" value="Immunization?status=completed" /> -\->
        </map>
        <map element="Observation" code="85354-9">
            <type xmlns="http://hl7.org/fhir">
                <coding>
                    <system value="http://vzvz.nl/fhir/CodeSystem/TaskParameterType"/>
                    <code value="query_string"/>
                </coding>
            </type>
            <!-\- <valueString xmlns="http://hl7.org/fhir" value="Observation/$lastn?code=http://loinc.org|85354-9" /> -\->
        </map>
        <map element="Observation" code="29463-7">
            <type xmlns="http://hl7.org/fhir">
                <coding>
                    <system value="http://vzvz.nl/fhir/CodeSystem/TaskParameterType"/>
                    <code value="query_string"/>
                </coding>
            </type>
            <!-\- <valueString xmlns="http://hl7.org/fhir" value="Observation/$lastn?code=http://loinc.org|29463-7" /> -\->
        </map>
        <map element="Observation" code="8302-2">
            <type xmlns="http://hl7.org/fhir">
                <coding>
                    <system value="http://vzvz.nl/fhir/CodeSystem/TaskParameterType"/>
                    <code value="query_string"/>
                </coding>
            </type>
            <!-\- <valueString xmlns="http://hl7.org/fhir" value="Observation/$lastn?code=http://loinc.org|8302-2,http://loinc.org|8306-3,http://loinc.org|8308-9" /> -\->
        </map>
        <map element="Observation" code="15220000">
            <type xmlns="http://hl7.org/fhir">
                <coding>
                    <system value="http://vzvz.nl/fhir/CodeSystem/TaskParameterType"/>
                    <code value="query_string"/>
                </coding>
            </type>
            <!-\- <valueString xmlns="http://hl7.org/fhir" value="Observation/$lastn?category=http://snomed.info/sct|275711006&amp;_include=Observation:related-target&amp;_include=Observation:specimen" /> -\->
        </map>
        <map element="Procedure" code="47519-4">
            <type xmlns="http://hl7.org/fhir">
                <coding>
                    <system value="http://vzvz.nl/fhir/CodeSystem/TaskParameterType"/>
                    <code value="query_string"/>
                </coding>
            </type>
            <!-\- <valueString xmlns="http://hl7.org/fhir" value="Procedure?category=http://snomed.info/sct|387713003" /> -\->
        </map>
        <map element="Encounter" code="46240-8">
            <type xmlns="http://hl7.org/fhir">
                <coding>
                    <system value="http://vzvz.nl/fhir/CodeSystem/TaskParameterType"/>
                    <code value="query_string"/>
                </coding>
            </type>
            <!-\- <valueString xmlns="http://hl7.org/fhir" value="Encounter?class=http://hl7.org/fhir/v3/ActCode|IMP,http://hl7.org/fhir/v3/ActCod e|ACUTE,http://hl7.org/fhir/v3/ActCode|NONAC" /> -\->
        </map>
        <map element="ProcedureRequest" code="18776-5">
            <type xmlns="http://hl7.org/fhir">
                <coding>
                    <system value="http://vzvz.nl/fhir/CodeSystem/TaskParameterType"/>
                    <code value="query_string"/>
                </coding>
            </type>
            <!-\- <valueString xmlns="http://hl7.org/fhir" value="ProcedureRequest?status=active" /> -\->
        </map>
        <map element="ImmunizationRecommendation" code="18776-5">
            <type xmlns="http://hl7.org/fhir">
                <coding>
                    <system value="http://vzvz.nl/fhir/CodeSystem/TaskParameterType"/>
                    <code value="query_string"/>
                </coding>
            </type>
            <!-\- <valueString xmlns="http://hl7.org/fhir" value="ImmunizationRecommendation" /> -\->
        </map>
        <map element="DeviceRequest" code="18776-5">
            <type xmlns="http://hl7.org/fhir">
                <coding>
                    <system value="http://vzvz.nl/fhir/CodeSystem/TaskParameterType"/>
                    <code value="query_string"/>
                </coding>
            </type>
            <!-\- <valueString xmlns="http://hl7.org/fhir" value="DeviceRequest?status=active&amp;_include=DeviceRequest:device" /> -\->
        </map>
        <map element="Appointment" code="18776-5">
            <type xmlns="http://hl7.org/fhir">
                <coding>
                    <system value="http://vzvz.nl/fhir/CodeSystem/TaskParameterType"/>
                    <code value="query_string"/>
                </coding>
            </type>
            <!-\- <valueString xmlns="http://hl7.org/fhir" value="Appointment?status=booked,pending,proposed" /> -\->
        </map>
        <map element="DocumentReference" code="77599-9">
            <type xmlns="http://hl7.org/fhir">
                <coding>
                    <system value="http://vzvz.nl/fhir/CodeSystem/TaskParameterType"/>
                    <code value="query_string"/>
                </coding>
            </type>
            <!-\- <valueString xmlns="http://hl7.org/fhir" value="DocumentReference?status=current" /> -\->
        </map>
    </xsl:variable>
-->

</xsl:stylesheet>
