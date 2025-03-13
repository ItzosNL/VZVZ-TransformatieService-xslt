<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:hl7="urn:hl7-org:v3" 
    xmlns:hl7nl="urn:hl7-nl:v3" 
    xmlns:math="http://exslt.org/math"
    xmlns:func="http://exslt.org/functions" 
    xmlns:vf="http://www.vzvz.nl/functions" 
    extension-element-prefixes="func math vf" exclude-result-prefixes="#all" version="3.0">

    <xd:doc>
        <xd:desc>
            <xd:p>converteer Performer naar Practitioner</xd:p>
            <xd:p>Version: 1.0.1</xd:p>
        </xd:desc>
        <xd:param name="Performer">Performer object</xd:param>
    </xd:doc>
    <xsl:template name="GetPerformer">
        <xsl:param name="Performer"/>

        <xsl:choose>
            <!-- when the performer is a person -->
            <xsl:when test="$Performer/hl7:assignedEntity/hl7:id or $Performer/hl7:assignedEntity/hl7:assignedPerson/hl7:name">
                <contained xmlns="http://hl7.org/fhir">
                    <PractitionerRole>
                        <id value="practitionerRole"/>
                        <practitioner>
                            <reference value="#performer"/>
                            <display value="{vf:GetPerformerDisp($Performer)}"/>
                        </practitioner>
                        <xsl:if test="$Performer/hl7:assignedEntity/hl7:representedOrganization/hl7:id or $Performer/hl7:assignedEntity/hl7:representedOrganization/hl7:desc">
                            <organization>
                                <reference value="#performerOrganization"/>
                                <display value="{vf:GetPerformerOrgDisp($Performer)}"/>
                            </organization>
                        </xsl:if>
                        <specialty>
                            <coding>
                                <system value="http://fhir.nl/fhir/NamingSystem/uzi-rolcode"/>
                                <code value="01.015"/>
                                <display value="Huisarts"/>
                            </coding>
                        </specialty>
                    </PractitionerRole>

                </contained>
                <contained xmlns="http://hl7.org/fhir">
                    <Practitioner xmlns="http://hl7.org/fhir">
                        <id value="performer"/>
                        <xsl:if test="$Performer/hl7:assignedEntity/hl7:id and not($Performer/hl7:assignedEntity/hl7:id/@nullFlavor)">
                            <identifier>
                                <xsl:choose>
                                    <xsl:when test="$Performer/hl7:assignedEntity/hl7:id/@root = '2.16.528.1.1007.3.1'">
                                        <system value="http://fhir.nl/fhir/NamingSystem/uzi-nr-pers"/>
                                    </xsl:when>
                                    <xsl:when test="$Performer/hl7:assignedEntity/hl7:id/@root = '2.16.840.1.113883.2.4.6.1'">
                                        <system value="http://fhir.nl/fhir/NamingSystem/agb-z"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <system value="urn:oid:{$Performer/hl7:assignedEntity/hl7:id/@root}"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <value value="{$Performer/hl7:assignedEntity/hl7:id/@extension}"/>
                            </identifier>
                        </xsl:if>
                        <xsl:if test="$Performer/hl7:assignedEntity/hl7:assignedPerson/hl7:name">
                            <name>
                                <text value="{vf:GetPerformerDisp($Performer)}"/>
                                <xsl:if test="$Performer/hl7:assignedEntity/hl7:assignedPerson/hl7:name/hl7:family">
                                    <family value="{$Performer/hl7:assignedEntity/hl7:assignedPerson/hl7:name/hl7:family}"/>
                                </xsl:if>
                                <xsl:if test="$Performer/hl7:assignedEntity/hl7:assignedPerson/hl7:name/hl7:given/@qualifier = 'IN'">
                                    <given value="{$Performer/hl7:assignedEntity/hl7:assignedPerson/hl7:name/hl7:given[@qualifier = 'IN']}">
                                        <extension url="http://hl7.org/fhir/StructureDefinition/iso21090-EN-qualifier">
                                            <valueCode value="IN"/>
                                        </extension>
                                    </given>
                                </xsl:if>
                                <xsl:if test="$Performer/hl7:assignedEntity/hl7:assignedPerson/hl7:name/hl7:given/@qualifier = 'BR'">
                                    <given value="{$Performer/hl7:assignedEntity/hl7:assignedPerson/hl7:name/hl7:given[@qualifier = 'BR']}">
                                        <extension url="http://hl7.org/fhir/StructureDefinition/iso21090-EN-qualifier">
                                            <valueCode value="BR"/>
                                        </extension>
                                    </given>
                                </xsl:if>
                            </name>
                        </xsl:if>
                    </Practitioner>
                </contained>
                <xsl:if test="$Performer/hl7:assignedEntity/hl7:representedOrganization/hl7:id or $Performer/hl7:assignedEntity/hl7:representedOrganization/hl7:desc">
                    <contained xmlns="http://hl7.org/fhir">
                        <xsl:call-template name="performerOrganization">
                            <xsl:with-param name="Performer" select="$Performer"/>
                            <xsl:with-param name="idReference">performerOrganization</xsl:with-param>
                        </xsl:call-template>
                    </contained>
                </xsl:if>

            </xsl:when>
            <!-- when the represented performer is an organization -->
            <xsl:when test="$Performer/hl7:assignedEntity/hl7:representedOrganization/hl7:id or $Performer/hl7:assignedEntity/hl7:representedOrganization/hl7:desc">
                <contained xmlns="http://hl7.org/fhir">
                    <xsl:call-template name="performerOrganization">
                        <xsl:with-param name="Performer" select="$Performer"/>
                        <xsl:with-param name="idReference">performer</xsl:with-param>
                    </xsl:call-template>
                </contained>
            </xsl:when>
            <xsl:otherwise>
                <contained>
                    <Practitioner xmlns="http://hl7.org/fhir">
                        <id value="performer"/>
                        <name>
                            <family value="onbekende uitvoerende zorgverlener"/>
                        </name>
                    </Practitioner>

                </contained>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xd:doc>
        <xd:desc>Get the organization of the performer</xd:desc>
        <xd:param name="Performer"/>
        <xd:param name="idReference">Which ID to use to reference the organiszation</xd:param>
    </xd:doc>
    <xsl:template name="performerOrganization">
        <xsl:param name="Performer"/>
        <xsl:param name="idReference"/>

        <Organization xmlns="http://hl7.org/fhir">
            <id value="{$idReference}"/>
            <!-- get identifier -->
            <xsl:if test="$Performer/hl7:assignedEntity/hl7:representedOrganization/hl7:id and not($Performer/hl7:assignedEntity/hl7:representedOrganization/hl7:id/@nullFlavor)">
                <identifier>
                    <xsl:choose>
                        <xsl:when test="$Performer/hl7:assignedEntity/hl7:representedOrganization/hl7:id/@root = '2.16.528.1.1007.3.3'">
                            <system value="http://fhir.nl/fhir/NamingSystem/ura"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <system value="urn:oid:{$Performer/hl7:assignedEntity/hl7:representedOrganization/hl7:id/@root}"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <value value="{$Performer/hl7:assignedEntity/hl7:representedOrganization/hl7:id/@extension}"/>
                </identifier>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="$Performer/hl7:assignedEntity/hl7:representedOrganization/hl7:desc">
                    <name value="{$Performer/hl7:assignedEntity/hl7:representedOrganization/hl7:desc}"/>
                </xsl:when>
                <xsl:when test="$Performer/hl7:assignedEntity/hl7:representedOrganization/hl7:name">
                    <name value="{$Performer/hl7:assignedEntity/hl7:representedOrganization/hl7:name}"/>
                </xsl:when>
                <xsl:otherwise>
                    <name>Organisatienaam onbekend</name>
                </xsl:otherwise>
            </xsl:choose>
            <address>
                <text value="{vf:GetPerfOrgAddrDisp($Performer)}"/>
            </address>
        </Organization>
    </xsl:template>

    <xd:doc>
        <xd:desc>Haal performer gegevens op voor display weergave</xd:desc>
        <xd:param name="Performer">Performer object</xd:param>
        <xd:return>String met naam en organisatie</xd:return>
    </xd:doc>
    <xsl:function name="vf:GetPerformerDisp">
        <xsl:param name="Performer"/>

        <xsl:variable name="Disp">
            <xsl:choose>
                <xsl:when test="$Performer/hl7:assignedEntity/hl7:assignedPerson/hl7:name">
                    <xsl:choose>
                        <xsl:when test="$Performer/hl7:assignedEntity/hl7:assignedPerson/hl7:name/hl7:family">
                            <xsl:if test="$Performer/hl7:assignedEntity/hl7:assignedPerson/hl7:name/hl7:given">
                                <xsl:value-of select="$Performer/hl7:assignedEntity/hl7:assignedPerson/hl7:name/hl7:given"/>
                                <xsl:text> </xsl:text>
                            </xsl:if>
                            <xsl:value-of select="$Performer/hl7:assignedEntity/hl7:assignedPerson/hl7:name/hl7:family"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$Performer/hl7:assignedEntity/hl7:assignedPerson/hl7:name"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$Performer/hl7:assignedEntity/hl7:representedOrganization/hl7:desc">
                    <xsl:value-of select="$Performer/hl7:assignedEntity/hl7:representedOrganization/hl7:desc"/>
                </xsl:when>
                <xsl:when test="$Performer/hl7:assignedEntity/hl7:id">
                    <xsl:value-of select="$Performer/hl7:assignedEntity/hl7:id/@extension"/>
                </xsl:when>
                <xsl:when test="$Performer/hl7:assignedEntity/hl7:representedOrganization/hl7:id">
                    <xsl:value-of select="$Performer/hl7:assignedEntity/hl7:representedOrganization/hl7:id/@extension"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>onbekende uitvoerende zorgverlener</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="$Disp"/>
    </xsl:function>

    <xd:doc>
        <xd:desc>Haal performer gegevens op voor display weergave</xd:desc>
        <xd:param name="Performer">Performer object</xd:param>
        <xd:return>String met naam en organisatie</xd:return>
    </xd:doc>
    <xsl:function name="vf:GetPerformerOrgDisp">
        <xsl:param name="Performer"/>

        <xsl:variable name="Disp">
            <xsl:choose>
                <xsl:when test="$Performer/hl7:assignedEntity/hl7:representedOrganization/hl7:name">
                    <xsl:value-of select="$Performer/hl7:assignedEntity/hl7:representedOrganization/hl7:name"/>
                </xsl:when>
                <xsl:when test="$Performer/hl7:assignedEntity/hl7:representedOrganization/hl7:desc">
                    <xsl:value-of select="$Performer/hl7:assignedEntity/hl7:representedOrganization/hl7:desc"/>
                </xsl:when>
                <xsl:when test="$Performer/hl7:assignedEntity/hl7:representedOrganization/hl7:id">
                    <xsl:value-of select="$Performer/hl7:assignedEntity/hl7:representedOrganization/hl7:id/@extension"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>onbekende uitvoerende zorgaanbieder</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="$Disp"/>
    </xsl:function>

    <xd:doc>
        <xd:desc>Haal performer gegevens op voor display weergave</xd:desc>
        <xd:param name="Performer">Performer object</xd:param>
        <xd:return>String met adres van de organisatie of van de uitvoerende of 'locatie bekend'</xd:return>
    </xd:doc>
    <xsl:function name="vf:GetPerfOrgAddrDisp">
        <xsl:param name="Performer"/>

        <xsl:variable name="Disp">
            <xsl:choose>
                <xsl:when test="$Performer/hl7:assignedEntity/hl7:representedOrganization/hl7:addr">
                    <xsl:value-of
                        select="normalize-space(concat($Performer/hl7:assignedEntity/hl7:representedOrganization/hl7:addr/hl7:streetName, ' ', 
                        $Performer/hl7:assignedEntity/hl7:representedOrganization/hl7:addr/hl7:houseNumber, ' ',
                        $Performer/hl7:assignedEntity/hl7:representedOrganization/hl7:addr/hl7:city))"
                    />
                </xsl:when>
                <xsl:when test="$Performer/hl7:assignedEntity//hl7:addr">
                    <xsl:value-of
                        select="normalize-space(concat($Performer/hl7:assignedEntity/hl7:addr/hl7:streetName, ' ', 
                        $Performer/hl7:assignedEntity/hl7:addr/hl7:houseNumber, ' ',
                        $Performer/hl7:assignedEntity/hl7:addr/hl7:city))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>locatie zorgaanbieder bekend</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="$Disp"/>
    </xsl:function>
</xsl:stylesheet>
