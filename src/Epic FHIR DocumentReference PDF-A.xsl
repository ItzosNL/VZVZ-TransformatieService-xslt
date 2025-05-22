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
<xsl:stylesheet xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" 
  exclude-result-prefixes="#all" 
  xmlns:nf="http://www.nictiz.nl/functions" 
  xmlns:fhir="http://hl7.org/fhir" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <xsl:output method="xml" indent="yes"/>
    <!-- 
      Dit is een conversie van de FHIR output voor PDF/A (DocumentReference) 
      zoals die door Epic wordt opgeleverd naar het formaat dat Nictiz vereist voor kwalificatie. 
    -->

    <xsl:template match="fhir:DocumentReference">
        <DocumentReference xmlns="http://hl7.org/fhir">
            <xsl:apply-templates select="fhir:id"/>
            <meta>
                <profile value="http://nictiz.nl/fhir/StructureDefinition/IHE.MHD.Minimal.DocumentReference"/>
            </meta>
			<xsl:variable name="display">
                <xsl:value-of select="fhir:author/fhir:display/@value"/>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="fhir:contained">
                    <xsl:apply-templates select="fhir:contained"/>
                </xsl:when>
                <xsl:otherwise>
                    <contained>
                        <Practitioner>
                            <id value="author"/>
							<meta>
								<profile value="http://fhir.nl/fhir/StructureDefinition/nl-core-practitioner"/>
							</meta>
							<active value="true"/>
                            <name>
								<use value="usual"/>
                                <text value="{$display}"/>
                            </name>
                        </Practitioner>
                    </contained>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="fhir:masterIdentifier"/>
            <xsl:apply-templates select="fhir:identifier"/>
            <xsl:apply-templates select="fhir:status"/>
            <xsl:apply-templates select="fhir:type"/>

            <xsl:apply-templates select="fhir:class"/>
            <xsl:apply-templates select="fhir:subject"/>
            <xsl:apply-templates select="fhir:indexed"/>
            <xsl:choose>
                <xsl:when test="fhir:contained">
                    <xsl:apply-templates select="fhir:author"/>
                </xsl:when>
                <xsl:otherwise>
                    <author>
                        <reference value="#author"/>
                        <display value="{$display}"/>
                    </author>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="fhir:description"/>
            <xsl:apply-templates select="fhir:content"/>
            <xsl:apply-templates select="fhir:context"/>
        </DocumentReference>
    </xsl:template>

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
