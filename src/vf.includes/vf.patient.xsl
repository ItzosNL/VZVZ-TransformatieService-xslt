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
    xmlns:f="http://hl7.org/fhir" 
    xmlns:math="http://exslt.org/math" 
    xmlns:func="http://exslt.org/functions"
    xmlns:fhir="http://hl7.org/fhir"
    xmlns="http://hl7.org/fhir"
    xmlns:vf="http://www.vzvz.nl/functions" 
    extension-element-prefixes="func math vf"
    exclude-result-prefixes="xs hl7 xd func math vf f"
    version="3.0">
    
    <xsl:import href="../vf.includes/vf.datetime-functions.xsl"/>
    <xsl:import href="vf.transformation-utils-fhir.xsl"/>

    <xd:doc>
        <xd:desc>Versie 1.0.1</xd:desc>
    </xd:doc>
    
    <xd:doc>
        <xd:desc>Haal de patiëntnaam op uit het Patient object en converteer naar FHIR</xd:desc>
        <xd:param name="Patient">Patient object</xd:param>
    </xd:doc>
    <xsl:template name="GetPatientNaam">
        <xsl:param name="Patient"/>
        
        <name xmlns="http://hl7.org/fhir">
            <use value="official"/>
            <xsl:if test="$Patient/hl7:patient/hl7:name/hl7:family">
                <family value="{$Patient/hl7:patient/hl7:name/hl7:family}"/>
            </xsl:if>
            <xsl:if test="$Patient/hl7:patient/hl7:name/hl7:given">
                <xsl:if test="$Patient/hl7:patient/hl7:name/hl7:given/@qualifier = 'BR'">
                    <given value="{$Patient/hl7:patient/hl7:name/hl7:given[@qualifier = 'BR']}">
                        <extension
                            url="http://hl7.org/fhir/StructureDefinition/iso21090-EN-qualifier">
                            <valueCode value="BR"/>
                        </extension>
                    </given>
                </xsl:if>
                <xsl:if test="$Patient/hl7:patient/hl7:name/hl7:given/@qualifier = 'IN'">
                    <given value="{$Patient/hl7:patient/hl7:name/hl7:given[@qualifier = 'IN']}">
                        <extension
                            url="http://hl7.org/fhir/StructureDefinition/iso21090-EN-qualifier">
                            <valueCode value="IN"/>
                        </extension>
                    </given>
                </xsl:if>
            </xsl:if>
        </name>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Bepaal naam en aanhef voor display weergaves</xd:desc>
        <xd:param name="Patient">Patient object</xd:param>
        <xd:return>variabele 'aanhef' en variabele 'naam'</xd:return>
    </xd:doc>
    <xsl:function name="vf:PatientNaamDisp">
        <xsl:param name="Patient"/>
        
        <xsl:variable name="Aanhef">
            <xsl:choose>
                <xsl:when test="$Patient/hl7:patient/hl7:administrativeGenderCode/@code = 'M'"
                    >De heer </xsl:when>
                <xsl:when test="$Patient/hl7:patient/hl7:administrativeGenderCode/@code = 'F'"
                    >Mevrouw </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="Naam">
            <xsl:choose>
                <xsl:when test="$Patient/hl7:patient/hl7:name/hl7:family">
                    <xsl:choose>
                        <xsl:when test="$Patient/hl7:patient/hl7:name/hl7:given[@qualifier='CL']">
                            <xsl:value-of
                                select="$Patient/hl7:patient/hl7:name/hl7:given[@qualifier='CL']"/>
                            <xsl:text> </xsl:text>
                        </xsl:when>
                        <xsl:when test="$Patient/hl7:patient/hl7:name/hl7:given[@qualifier='BR']">
                            <xsl:value-of
                                select="$Patient/hl7:patient/hl7:name/hl7:given[@qualifier='BR']"/>
                            <xsl:text> </xsl:text>
                        </xsl:when>
                        <xsl:when test="$Patient/hl7:patient/hl7:name/hl7:given[@qualifier='IN']">
                            <xsl:value-of
                                select="$Patient/hl7:patient/hl7:name/hl7:given[@qualifier='IN']"/>
                            <xsl:text> </xsl:text>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:value-of select="$Patient/hl7:patient/hl7:name/hl7:family"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$Patient/hl7:patient/hl7:name"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="$Aanhef"/>
        <xsl:value-of select="$Naam"/>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>Bepaal de geboortedatum van de patiënt</xd:desc>
        <xd:param name="Patient">Patient object</xd:param>
    </xd:doc>
    <xsl:function name="vf:PatientGebDat">
        <xsl:param name="Patient"/>
        <xsl:sequence select="vf:dateTimeV3_FHIR($Patient/hl7:patient/hl7:birthTime/@value, false())"/>
    </xsl:function>
    
    
    <xd:doc>
        <xd:desc>Bepaal geslacht van de patiënt en converteer naar FHIR gender object</xd:desc>
        <xd:param name="Patient">PatientObject</xd:param>
    </xd:doc>
    <xsl:template name="GetPatientGeslacht">
        <xsl:param name="Patient"/>
        
        <xsl:variable name="V3Gender"
            select="$Patient/hl7:patient/hl7:administrativeGenderCode/@code"/>
        
        <xsl:choose>
            <xsl:when test="$V3Gender = 'M'">
                <gender xmlns="http://hl7.org/fhir" value="male">
                    <extension url="http://nictiz.nl/fhir/StructureDefinition/code-specification">
                        <valueCodeableConcept>
                            <coding>
                                <system value="http://hl7.org/fhir/v3/AdministrativeGender"/>
                                <code value="M"/>
                                <display value="Man"/>
                            </coding>
                        </valueCodeableConcept>
                    </extension>
                </gender>
            </xsl:when>
            <xsl:when test="$V3Gender = 'F'">
                <gender xmlns="http://hl7.org/fhir" value="female">
                    <extension url="http://nictiz.nl/fhir/StructureDefinition/code-specification">
                        <valueCodeableConcept>
                            <coding>
                                <system value="http://hl7.org/fhir/v3/AdministrativeGender"/>
                                <code value="F"/>
                                <display value="Vrouw"/>
                            </coding>
                        </valueCodeableConcept>
                    </extension>
                </gender>
            </xsl:when>
            <xsl:when test="$V3Gender = 'UN'">
                <gender xmlns="http://hl7.org/fhir" value="other">
                    <extension url="http://nictiz.nl/fhir/StructureDefinition/code-specification">
                        <valueCodeableConcept>
                            <coding>
                                <system value="http://hl7.org/fhir/v3/AdministrativeGender"/>
                                <code value="UN"/>
                                <display value="Onbepaald"/>
                            </coding>
                        </valueCodeableConcept>
                    </extension>
                </gender>
            </xsl:when>
            <xsl:otherwise>
                <gender xmlns="http://hl7.org/fhir" value="unknown"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Bepaal geslacht van de patiënt voor display weergave</xd:desc>
        <xd:param name="Patient">Patient object</xd:param>
        <xd:return>string met geslachtsaanduiding</xd:return>
    </xd:doc>
    <xsl:function name="vf:PatientGeslachtDisp">
        <xsl:param name="Patient"/>
        
        <xsl:variable name="V3Gender"
            select="$Patient/hl7:patient/hl7:administrativeGenderCode/@code"/>
        
        <xsl:choose>
            <xsl:when test="$V3Gender = 'M'">Man</xsl:when>
            <xsl:when test="$V3Gender = 'F'">Vrouw</xsl:when>
            <xsl:when test="$V3Gender = 'UN'">Onbepaald</xsl:when>
            <xsl:otherwise>Onbekend</xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>Converteer het patiënt adres in FHIR address resource</xd:desc>
        <xd:param name="Patient">Patient object</xd:param>
    </xd:doc>
    <xsl:template name="GetPatientAdres">
        <xsl:param name="Patient"/>
        
        <xsl:variable name="Straat" select="$Patient/hl7:addr/hl7:streetName"/>
        <xsl:variable name="HuisNr" select="$Patient/hl7:addr/hl7:houseNumber"/>
        <xsl:variable name="Postcode" select="$Patient/hl7:addr/hl7:postalCode"/>
        <xsl:variable name="Stad" select="$Patient/hl7:addr/hl7:city"/>
        
        <xsl:if test="$Patient/hl7:addr">
            <address xmlns="http://hl7.org/fhir">
                <line value="{concat($Straat, ' ', $HuisNr)}">
                    <extension url="http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-streetName">
                        <valueString value="{$Straat}"/>
                    </extension>
                    <extension url="http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-houseNumber">
                        <valueString value="{$HuisNr}"/>
                    </extension>
                </line>
                <city value="{$Stad}"/>
                <xsl:choose>
                  <xsl:when test="exists($fhirVersion) and $fhirVersion='STU3'">
                    <postalCode value="{replace($Postcode, ' ', '')}"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <postalCode value="{$Postcode}"/>                    
                  </xsl:otherwise>
                </xsl:choose>
            </address>
        </xsl:if>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Bepaal het patiënt adres voor display weergave</xd:desc>
        <xd:param name="Patient">Patient object</xd:param>
        <xd:return>string met adres</xd:return>
    </xd:doc>
    <xsl:function name="vf:PatientAdresDisp">
        <xsl:param name="Patient"/>
        
        <xsl:variable name="Straat" select="$Patient/hl7:addr/hl7:streetName"/>
        <xsl:variable name="HuisNr" select="$Patient/hl7:addr/hl7:houseNumber"/>
        <xsl:variable name="Postcode" select="$Patient/hl7:addr/hl7:postalCode"/>
        <xsl:variable name="Stad" select="$Patient/hl7:addr/hl7:city"/>
        
        <xsl:value-of select="$Straat"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="$HuisNr"/>
        <xsl:text>, </xsl:text>
        <xsl:value-of select="$Postcode"/>
        <xsl:text>  </xsl:text>
        <xsl:value-of select="$Stad"/>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>Converteer patiënt naar FHIR</xd:desc>
        <xd:param name="PatID">patiënt id</xd:param>
        <xd:param name="Patient">Patient object</xd:param>
    </xd:doc>
    <xsl:template name="Pat_translate">
        <xsl:param name="PatID"/>
        <xsl:param name="Patient"/>
        
        <xsl:variable name="transformation">
            <xsl:call-template name="addTransformationCode">
                <xsl:with-param name="transformationCode" select="$transformationCode"/>
                <xsl:with-param name="versionXSLT" select="$versionXSLT"/>
                <xsl:with-param name="type" select="'fhir'"/>
            </xsl:call-template>
        </xsl:variable>
        
        <Patient>
            <id value="{$PatID}"/>
            <meta>
                <profile value="http://fhir.nl/fhir/StructureDefinition/nl-core-patient"/>
                <xsl:copy-of select="$transformation/f:meta/*"/>
            </meta>
            <text>
                <status value="extensions"/>
                <div xmlns="http://www.w3.org/1999/xhtml">
                    <div><xsl:value-of select="vf:PatientNaamDisp($Patient)"/>, <xsl:value-of
                        select="vf:PatientGeslachtDisp($Patient)"/>, <xsl:value-of
                            select="vf:PatientGebDat($Patient)"/>
                    </div>
                    <div>
                        <xsl:value-of select="vf:PatientAdresDisp($Patient)"/>
                    </div>
                </div>
            </text>
            <identifier>
                <system value="http://fhir.nl/fhir/NamingSystem/bsn"/>
                <value>
                    <extension url="http://hl7.org/fhir/StructureDefinition/data-absent-reason">
                        <valueCode value="masked"/>
                    </extension>
                </value>
            </identifier>
            <xsl:call-template name="GetPatientNaam">
                <xsl:with-param name="Patient" select="$Patient"/>
            </xsl:call-template>
            <xsl:call-template name="GetPatientGeslacht">
                <xsl:with-param name="Patient" select="$Patient"/>
            </xsl:call-template>
            <birthDate value="{vf:PatientGebDat($Patient)}"/>
            <xsl:call-template name="GetPatientAdres">
                <xsl:with-param name="Patient" select="$Patient"/>
            </xsl:call-template>
        </Patient>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Extraheer BSN uit FHIR bericht, ofwel de parameter, 
            ofwel uit de Patient resource </xd:desc>
        <xd:param name="FHIRPatientIdentifer">Identifier uit Patient Resource</xd:param>
        <xd:param name="PatID">BSN doorgegeven als parameter</xd:param>
    </xd:doc>
    <xsl:function name="vf:PatientBSN">
        <xsl:param name="FHIRPatientIdentifer"/>
        <xsl:param name="PatID"/>
        
        <xsl:choose>
            <xsl:when
                test="$FHIRPatientIdentifer/fhir:system/@value = 'http://fhir.nl/fhir/NamingSystem/bsn'">
                <xsl:value-of select="$FHIRPatientIdentifer/fhir:value/@value"/>
            </xsl:when>
            <xsl:when test="not(empty($PatID))">
                <xsl:value-of select="format-number(number($PatID), '000000000')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'000000000'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>Omzetting geslacht van FHIR naar v3</xd:desc>
        <xd:param name="FHIRGender"/>
    </xd:doc>
    <xsl:function name="vf:V3Gender">
        <xsl:param name="FHIRGender"/>
        
        <xsl:choose>
            <xsl:when test="$FHIRGender = 'male'">
                <xsl:value-of select="'M'"/>
            </xsl:when>
            <xsl:when test="$FHIRGender = 'female'">
                <xsl:value-of select="'F'"/>
            </xsl:when>
            <xsl:when test="$FHIRGender = 'other'">
                <xsl:value-of select="'UN'"/>
            </xsl:when>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>