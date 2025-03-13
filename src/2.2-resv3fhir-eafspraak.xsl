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
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" 
    xmlns:hl7="urn:hl7-org:v3" 
    xmlns:f="http://hl7.org/fhir"
    xmlns:vf="http://www.vzvz.nl/functions"
    xmlns="http://hl7.org/fhir"
    exclude-result-prefixes="#all"
    version="3.0">
    
    <xsl:import href="vf.includes/vf.patient.xsl"/>
    <xsl:import href="vf.includes/vf.performer.xsl"/>
    <xsl:import href="vf.includes/vf.transformation-utils-fhir.xsl"/>
    
    <xsl:output method="xml" indent="yes" exclude-result-prefixes="#all"/>
    <xsl:strip-space elements="*"/>

    <xd:doc>
        <xd:desc>
            <xd:p>Dit is een conversie van een V3 batch met ContactAfspraak bouwsteenresponses naar een FHIR Bundle met Appointment resources.</xd:p>
        </xd:desc>

    </xd:doc>

    <xsl:param name="SearchURL"/>
    <xsl:param name="xslDebug" select="false()" as="xs:boolean"/>
    
    <xsl:variable name="vf:versionXSLT" as="xs:string">2.0.2</xsl:variable>
    <xsl:variable name="transformationCode" as="xs:string" select="'2.2'"/>
    <xsl:variable name="fhirVersion" as="xs:string" select="'STU3'"/>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Main template</xd:p>
            <xd:p>Document = transformed v3-message to fhir bundle, aka a fhir bundle</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xd:doc>
        <xd:desc> Match de batch van afspraken, maak er een bundle van </xd:desc>
    </xd:doc>
    <xsl:template match="/">
        <xsl:variable name="Pat" select="//hl7:organizer[1]/hl7:recordTarget/hl7:patientRole"/>
        <xsl:variable name="PatID">
            <xsl:value-of select="vf:UUID4()"/>
        </xsl:variable>
        <xsl:variable name="AppointmentBaseID">
            <xsl:value-of select="vf:UUID4()"/>
        </xsl:variable>
        <xsl:variable name="AppointmentList" select="//hl7:organizer/hl7:component"/>
        <xsl:variable name="AppointmentCount" select="count($AppointmentList)"/>
        <xsl:variable name="payload">            
            <Bundle xmlns="http://hl7.org/fhir" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <id value="{vf:UUID4()}"/>
            <type value="searchset"/>
            <total>
                <xsl:attribute name="value">
                    <xsl:value-of select="$AppointmentCount"/>
                </xsl:attribute>
            </total>
            <link>
                <relation value="self"/>
                <url value="{$SearchURL}"/>
            </link>
            <xsl:if test="$AppointmentCount > 0">
                <xsl:for-each select="$AppointmentList">
                    <xsl:if test="vf:IsPatientContact(./hl7:encounter/hl7:code/@code)">
                        <entry>
                            <fullUrl>
                                <xsl:attribute name="value">
                                    <xsl:value-of select="concat('urn:uuid:', substring($AppointmentBaseID, 1, 34), substring(string(100 + position()), 2))"/>
                                </xsl:attribute>
                            </fullUrl>
                            <resource>
                                <xsl:call-template name="Appointment_translate">
                                    <xsl:with-param name="Base" select="substring-before($SearchURL, '/Appointment')"/>
                                    <xsl:with-param name="AppID" select="../../../../hl7:sender/hl7:device/hl7:id/@extension"/>
                                    <xsl:with-param name="AppointmentBaseID" select="$AppointmentBaseID"/>
                                    <xsl:with-param name="AppointmentNr" select="position()"/>
                                    <xsl:with-param name="PatID" select="$PatID"/>
                                    <xsl:with-param name="Patient" select="$Pat"/>
                                    <xsl:with-param name="AppointmentList" select="$AppointmentList"/>
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
        </xsl:variable>
        
        <xsl:variable name="defaultResponse">
            <xsl:call-template name="buildSearchResponse">
                <xsl:with-param name="response" select="."/>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:call-template name="update-bundle">
            <xsl:with-param name="in" select="$payload/f:Bundle"/>
            <xsl:with-param name="defResponse" select="$defaultResponse"/>
        </xsl:call-template>

    </xsl:template>

    <xd:doc>
        <xd:desc>Vertaal een individuele afspraak</xd:desc>
        <xd:param name="Base">lijkt niet gebruikt te worden</xd:param>
        <xd:param name="AppID">lijkt niet gebruikt te worden</xd:param>
        <xd:param name="AppointmentBaseID">prefix voor afspraak</xd:param>
        <xd:param name="AppointmentNr">positie van afspraak in de lijst</xd:param>
        <xd:param name="PatID">patiënt identifier</xd:param>
        <xd:param name="Patient">patiënt object</xd:param>
        <xd:param name="AppointmentList">lijkt niet gebruikt te worden</xd:param>
    </xd:doc>
    <xsl:template name="Appointment_translate">
        <xsl:param name="Base"/>
        <xsl:param name="AppID"/>
        <xsl:param name="AppointmentBaseID"/>
        <xsl:param name="AppointmentNr"/>
        <xsl:param name="PatID"/>
        <xsl:param name="Patient"/>
        <xsl:param name="AppointmentList"/>

        <xsl:variable name="AppointmentIdentifierRoot" select="./hl7:encounter/hl7:id/@root"/>
        <xsl:variable name="AppointmentIdentifierExt" select="./hl7:encounter/hl7:id/@extension"/>
        <xsl:variable name="AppointmentTypeCode" select="./hl7:encounter/hl7:code/@code"/>
        <xsl:variable name="AppointmentDescription" select="./hl7:encounter/hl7:text"/>
        <xsl:variable name="AppointmentStart" select="./hl7:encounter/hl7:effectiveTime/hl7:low/@value"/>
        <xsl:variable name="AppointmentEnd" select="./hl7:encounter/hl7:effectiveTime/hl7:high/@value"/>
        <xsl:variable name="AppointmentDurationValue" select="./hl7:encounter/hl7:effectiveTime/hl7:width/@value"/>
        <xsl:variable name="AppointmentDurationUnit" select="./hl7:encounter/hl7:effectiveTime/hl7:width/@unit"/>
        <xsl:variable name="Performer" select="./hl7:encounter/hl7:performer"/>
        <xsl:variable name="AppDateTime" select="vf:dateTimeV3_FHIR(./hl7:encounter/hl7:effectiveTime/hl7:low/@value, true())"/>
        <xsl:variable name="AppTypeDesc">
            <xsl:choose>
                <xsl:when test="./hl7:encounter/hl7:code/@nullFlavor">
                    <xsl:value-of select="./hl7:encounter/hl7:code/hl7:originalText"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="./hl7:encounter/hl7:code/@displayName"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <Appointment xmlns="http://hl7.org/fhir" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <id value="{concat(substring($AppointmentBaseID, 1, 34), substring(string(100 + $AppointmentNr), 2))}"/>
            <meta>
                <profile value="http://nictiz.nl/fhir/StructureDefinition/eAfspraak-Appointment"/>
            </meta>
            <text>
                <status value="extensions"/>
                <div xmlns="http://www.w3.org/1999/xhtml">
                    <table>
                        <caption>Contactafspraak. Patiënt: <xsl:value-of select="vf:PatientNaamDisp($Patient)"/>
                            <span style="display: block;">Arts: <xsl:value-of select="vf:GetPerformerDisp($Performer)"/>
                            </span>
                        </caption>
                        <tbody>
                            <tr>
                                <th>Type</th>
                                <td>
                                    <span>
                                        <xsl:value-of select="$AppTypeDesc"/>
                                    </span>
                                </td>
                            </tr>
                            <tr>
                                <th>Gepland voor</th>
                                <td>
                                    <xsl:value-of select="$AppDateTime"/>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </text>
            <xsl:if test="$Performer">
                <xsl:call-template name="GetPerformer">
                    <xsl:with-param name="Performer" select="$Performer"/>
                </xsl:call-template>
                <contained>
                    <Location>
                        <id value="location"/>
                        <meta>
                            <profile value="http://fhir.nl/fhir/StructureDefinition/nl-core-location"/>
                        </meta>
                        <name value="{vf:GetPerformerOrgDisp($Performer)}"/>
                        <managingOrganization>
                            <reference value="#performerOrganization"/>
                            <display value="{vf:GetPerformerOrgDisp($Performer)}"/>
                        </managingOrganization>
                    </Location>
                </contained>
            </xsl:if>
            <identifier>
                <system value="urn:oid:{$AppointmentIdentifierRoot}"/>
                <value value="{$AppointmentIdentifierExt}"/>
            </identifier>
            <status value="booked"/>
            <serviceCategory>
                <coding>
                    <system value="http://hl7.org/fhir/service-category"/>
                    <code value="17"/>
                    <display value="General Practice/GP (doctor)"/>
                </coding>
            </serviceCategory>
            <serviceType>
                <coding>
                    <system value="http://hl7.org/fhir/service-type"/>
                    <code value="124"/>
                    <display value="General Practice/GP (doctor)"/>
                </coding>
            </serviceType>
            <specialty>
                <coding>
                    <system value="urn:oid:2.16.840.1.113883.2.4.6.7"/>
                    <code value="0100"/>
                    <display value="Huisartsen, niet nader gespecificeerd"/>
                </coding>
            </specialty>
            <specialty>
                <coding>
                    <system value="http://fhir.nl/fhir/NamingSystem/uzi-rolcode"/>
                    <code value="01.015"/>
                    <display value="Huisarts"/>
                </coding>
            </specialty>
            <xsl:call-template name="GetAppointmentType">
                <xsl:with-param name="Tabel14AppointmentType" select="$AppointmentTypeCode"/>
            </xsl:call-template>
            <xsl:if test="not(empty($AppointmentDescription))">
                <description value="{$AppointmentDescription}"/>
            </xsl:if>
            <start value="{vf:dateTimeV3_FHIR($AppointmentStart, true())}"/>
            <xsl:choose>
                <xsl:when test="$AppointmentEnd">
                    <end value="{vf:dateTimeV3_FHIR($AppointmentEnd, true())}"/>
                </xsl:when>
                <xsl:when test="$AppointmentDurationValue">
                    <end value="{vf:dateTimeV3_FHIR(vf:calcEndTS($AppointmentStart, number($AppointmentDurationValue), $AppointmentDurationUnit), true())}"/>
                </xsl:when>
            </xsl:choose>
            <xsl:if test="$Performer">
                <participant>
                    <actor>
                        <extension url="http://nictiz.nl/fhir/StructureDefinition/practitionerrole-reference">
                            <valueReference>
                                <reference value="#practitionerRole"/>
                                <display value="zorgverlener"/>
                            </valueReference>
                        </extension>
                        <reference value="#performer"/>
                        <display value="{vf:GetPerformerDisp($Performer)}"/>
                    </actor>
                    <status value="accepted"/>
                </participant>
            </xsl:if>
            <participant>
                <actor>
                    <reference value="urn:uuid:{$PatID}"/>
                    <display value="{vf:PatientNaamDisp($Patient)}"/>
                </actor>
                <status value="accepted"/>
            </participant>
            <participant>
                <actor>
                    <reference value="#location"/>
                    <display value="{vf:GetPerfOrgAddrDisp($Performer)}"/>
                </actor>
                <status value="accepted"/>
            </participant>
        </Appointment>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>Bepaal het type van de afspraak. Conversie van NHG tabel 14 naar..</xd:p>
            <xd:p>TODO benaming doeltabel</xd:p>
        </xd:desc>
        <xd:param name="Tabel14AppointmentType">id van NHG Tabel 14</xd:param>
    </xd:doc>
    <xsl:template name="GetAppointmentType">
        <xsl:param name="Tabel14AppointmentType"/>

        <appointmentType xmlns="http://hl7.org/fhir">
            <coding>
                <system value="http://hl7.org/fhir/v3/ActCode"/>
                <xsl:choose>
                    <xsl:when test="$Tabel14AppointmentType = '01' or $Tabel14AppointmentType = '02'">
                        <code value="HH"/>
                        <display value="Thuis"/>
                    </xsl:when>
                    <xsl:when test="$Tabel14AppointmentType = '03' or $Tabel14AppointmentType = '04'">
                        <code value="AMB"/>
                        <display value="Poliklinisch"/>
                    </xsl:when>
                    <xsl:when test="$Tabel14AppointmentType = '05' or $Tabel14AppointmentType = '06'">
                        <code value="VR"/>
                        <display value="Virtueel"/>
                    </xsl:when>
                </xsl:choose>
            </coding>
        </appointmentType>
    </xsl:template>

    <xd:doc>
        <xd:desc>Is dit een patiëntcontact conform NGH Tabel 14</xd:desc>
        <xd:param name="Tabel14AppointmentType">id van NHG Tabel 14</xd:param>
        <xd:return>boolean</xd:return>
    </xd:doc>
    <xsl:function name="vf:IsPatientContact">
        <xsl:param name="Tabel14AppointmentType"/>

        <xsl:choose>
            <xsl:when test="$Tabel14AppointmentType = '01' or $Tabel14AppointmentType = '02'">true</xsl:when>
            <xsl:when test="$Tabel14AppointmentType = '03' or $Tabel14AppointmentType = '04'">true</xsl:when>
            <xsl:when test="$Tabel14AppointmentType = '05' or $Tabel14AppointmentType = '06'">true</xsl:when>
        </xsl:choose>
    </xsl:function>

</xsl:stylesheet>
