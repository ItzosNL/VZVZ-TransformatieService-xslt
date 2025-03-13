<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns="urn:hl7-org:v3"
    xmlns:hl7="urn:hl7-org:v3"
    exclude-result-prefixes="xs math xd hl7"
    version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>Try to anonimize asmuch as possible, not just the patient but also the XIS vendor and the healthcare provider</xd:p>
            
            <xd:p><xd:b>Created on:</xd:b> Nov 13, 2024</xd:p>
            <xd:p><xd:b>Author:</xd:b> helma</xd:p>
            <xd:p></xd:p>
        </xd:desc>
    </xd:doc>

    <xsl:variable name="fake-app-id" select="'90012345'"/>
    <xsl:variable name="fake-ura" select="'90054321'"/>
    <xsl:variable name="fake-uzi-server" select="'901234567'"/>
    <xsl:variable name="fake-uzi" select="'907654321'"/>
    <xsl:variable name="fake-agb" select="'09912345'"/>
    <xsl:variable name="fake-bsn" select="'999912345'"/>
    <xsl:variable name="fake-city" select="'STITSWERD'"/>
    <xsl:variable name="fake-postcode-pat" select="'9999 AA'"/>
    <xsl:variable name="fake-postcode-z" select="'9999 AZ'"/>
    <xsl:variable name="fake-street-pat" select="'Testlaan'"/>
    <xsl:variable name="fake-street-z" select="'Teststraat'"/>
    <xsl:variable name="fake-organization" select="'Praktijk Op het hoekje'"/>
    <xsl:variable name="fake-name-z" select="'Dokter Pilledraaier'"/>
    <xsl:variable name="fake-name-pat-given" select="'Pietje'"/>
    <xsl:variable name="fake-name-pat-initials" select="'P.C.'"/>
    <xsl:variable name="fake-name-pat-family" select="'Puckmans'"/>
    <xsl:variable name="fake-phone-number" select="'tel:0612345678'"/>
    
    <xd:doc>
        <xd:desc>Main template</xd:desc>
    </xd:doc>
    <xsl:template match="/">
        <xsl:apply-templates/>    
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Replace the softwarename so it's not traceable back to the vendor</xd:desc>
    </xd:doc>
    <xsl:template match="hl7:softwareName">
        <softwareName xmlns="urn:hl7-org:v3">Testapplicatie</softwareName>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Replace the app id and ura in any root or extension of an id or telecom element
        </xd:desc>
    </xd:doc>
    <xsl:template match="hl7:id|hl7:telecom">
        <xsl:variable name="app-id" select="//hl7:sender/hl7:device/hl7:id[@root='2.16.840.1.113883.2.4.6.6']/@extension"/>
        <xsl:variable name="uzi-server" select="//hl7:ControlActProcess/hl7:authorOrPerformer//hl7:AssignedDevice/hl7:id[@root='2.16.528.1.1007.3.2']/@extension"/>
        <xsl:variable name="uzi" select="//hl7:organizer/hl7:participant/hl7:participantRole/hl7:id[@root='2.16.528.1.1007.3.1']/@extension"/>
        <xsl:variable name="ura" select="//hl7:ControlActProcess/hl7:authorOrPerformer//hl7:AssignedDevice//hl7:id[@root='2.16.528.1.1007.3.3']/@extension"/>
        <xsl:variable name="agb" select="//hl7:organizer/hl7:participant/hl7:participantRole/hl7:id[@root='2.16.840.1.113883.2.4.6.1']/@extension"/>
        <xsl:variable name="bsn" select="//hl7:recordTarget/hl7:patientRole/hl7:id[@root='2.16.840.1.113883.2.4.6.3']/@extension"/>
        
        <xsl:if test="local-name(.) = 'id'">
            <id root="{replace(replace(replace(replace(replace(replace(
                @root, $app-id, $fake-app-id), 
                $ura, $fake-ura),
                $uzi-server, $fake-uzi-server),
                $uzi, $fake-uzi),
                $agb, $fake-agb),
                $bsn, $fake-bsn)
                }" 
                extension="{replace(replace(replace(replace(replace(replace(
                @extension, $app-id, $fake-app-id),
                $ura, $fake-ura),
                $uzi-server, $fake-uzi-server),
                $uzi, $fake-uzi),
                $agb, $fake-agb),
                $bsn, $fake-bsn)
                }"/>            
        </xsl:if>
        <xsl:if test="local-name(.) = 'telecom'">
            <xsl:variable name="phone-regex" 
                select="'^(tel:\s*)?(\+31|0)[\s-]?\d+[\s-]?\d+$'"/>
            <telecom value="{replace(replace(
                @value, $app-id, $fake-app-id),
                $phone-regex, $fake-phone-number)
                }"/>
                        
        </xsl:if>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Replace the city with $fake-city, but only if there is text, to avoid fixing
            a problem that might be the cause of the investigation.
        </xd:desc>
    </xd:doc>
    <xsl:template match="hl7:city">
        <xsl:choose>
            <xsl:when test="./text()">
                <city><xsl:value-of select="$fake-city"/></city>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xd:doc>
        <xd:desc>Replace the postal code with $fake-postcode-pat or $fake-postcode-z, 
            but only if there is text, to avoid fixing
            a problem that might be the cause of the investigation.
        </xd:desc>
    </xd:doc>
    <xsl:template match="hl7:postalCode">
        <xsl:choose>
            <xsl:when test="./text()">
                <xsl:variable name="tmp" select="../parent::*"/>
                <xsl:choose>
                    <xsl:when test="local-name(../parent::*) = 'patientRole'">
                        <postalCode><xsl:value-of select="$fake-postcode-pat"/></postalCode>
                    </xsl:when>
                    <xsl:otherwise>
                        <postalCode><xsl:value-of select="$fake-postcode-z"/></postalCode>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xd:doc>
        <xd:desc>Replace the street with $fake-street-pat or $fake-street-z, 
            but only if there is text, to avoid fixing
            a problem that might be the cause of the investigation.
        </xd:desc>
    </xd:doc>
    <xsl:template match="hl7:streetName">
        <xsl:choose>
            <xsl:when test="./text()">
                <xsl:variable name="tmp" select="../parent::*"/>
                <xsl:choose>
                    <xsl:when test="local-name(../parent::*) = 'patientRole'">
                        <streetName><xsl:value-of select="$fake-street-pat"/></streetName>
                    </xsl:when>
                    <xsl:otherwise>
                        <streetName><xsl:value-of select="$fake-street-z"/></streetName>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Replace the organization name with $fake-organization, but only if there is text, to avoid fixing
            a problem that might be the cause of the investigation.
        </xd:desc>
    </xd:doc>
    <xsl:template match="hl7:Organization/hl7:name|hl7:representedOrganization/hl7:name">
        <xsl:choose>
            <xsl:when test="./text()">
                <name><xsl:value-of select="$fake-organization"/></name>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Replace the organization name with $fake-organization, but only if there is text, to avoid fixing
            a problem that might be the cause of the investigation.
        </xd:desc>
    </xd:doc>
    <xsl:template match="hl7:scopingEntity/hl7:desc">
        <xsl:choose>
            <xsl:when test="./text()">
                <desc><xsl:value-of select="$fake-organization"/></desc>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xd:doc>
        <xd:desc>Replace the healthcare provider name with $fake-name-z, 
            but only if there is text, to avoid fixing
            a problem that might be the cause of the investigation.
        </xd:desc>
    </xd:doc>
    <xsl:template match="hl7:playingEntity/hl7:name">
        <xsl:choose>
            <xsl:when test="./text()">
                <name><xsl:value-of select="$fake-name-z"/></name>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <xd:doc>
        <xd:desc>
            Replace the patient name with fake name 
            but only if there is text, to avoid fixing
            a problem that might be the cause of the investigation.
        </xd:desc>
    </xd:doc>
    <xsl:template match="hl7:patient/hl7:name/hl7:given">
        <xsl:choose>
            <xsl:when test="./text()">
                <xsl:if test="./@qualifier='IN'">
                    <given qualifier="IN"><xsl:value-of select="$fake-name-pat-initials"/></given>
                </xsl:if>
                <xsl:if test="./@qualifier='CL'">
                    <given qualifier="CL"><xsl:value-of select="$fake-name-pat-given"/></given>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="."/>
            </xsl:otherwise>
        </xsl:choose>        
    </xsl:template>

    <xd:doc>
        <xd:desc>
            Replace the patient name with fake name 
            but only if there is text, to avoid fixing
            a problem that might be the cause of the investigation.
        </xd:desc>
    </xd:doc>
    <xsl:template match="hl7:patient/hl7:name/hl7:family">
        <xsl:choose>
            <xsl:when test="./text()">
                <family qualifier="{./@qualifier}">
                    <xsl:value-of select="$fake-name-pat-family"/>
                </family>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="."/>
            </xsl:otherwise>
        </xsl:choose>        
    </xsl:template>
    

    <xd:doc>
        <xd:desc>Catch all template</xd:desc>
    </xd:doc>
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
