<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:f="http://www.w3.org/2005/xpath-functions"
    xmlns:util="urn:hl7:utilities"
    xmlns:vf="http://www.vzvz.nl/functions" exclude-result-prefixes="xs math xd f vf util" version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Mar 13, 2023</xd:p>
            <xd:p><xd:b>Author:</xd:b> VZVZ</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>

    <xsl:import href="vf.datetime-functions.xsl"/>
    <xsl:import href="vf.utils.xsl"/>

    <xd:doc>
        <xd:desc>
            <xd:p>Parse a period of use and create an effectiveTime with appropriate range and if
                necessary a calculated date</xd:p>
            <xd:p>if group1='ge' then low else high</xd:p>
            <xd:p>if group2=TODAY then val</xd:p>
        </xd:desc>
        <xd:param name="range">One or more dates to be parsed</xd:param>
    </xd:doc>
    <xsl:template name="parseRange">
        <xsl:param name="range"/>
        <xsl:variable name="parsedDates">
        <xsl:for-each select="$range//text()">
                <xsl:call-template name="parseDate">
                    <xsl:with-param name="period" select="."/>
                </xsl:call-template>
        </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="effectiveTime">
        <value>
            <xsl:for-each select="$parsedDates//parsedDate[@value]">     
                <xsl:choose>
                    <xsl:when test=".[@range = '' or @range = 'eq' or not(@range)]">
                        <low value="{./@value}T000000"/>
                        <high value="{./@value}T235959"/>
                    </xsl:when>
                    <xsl:when test=".[@range = 'ge']">
                        <low value="{./@value}"/>
                    </xsl:when>
                    <xsl:when test=".[@range = 'le']">
                        <high value="{./@value}"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="util:logMessage">
                            <xsl:with-param name="level" select="$logERROR"/>
                            <xsl:with-param name="msg"><xsl:text>Cannot process into effectiveTime: </xsl:text>
                                <xsl:sequence select="$parsedDates"/></xsl:with-param>
                            <xsl:with-param name="terminate" select="f:false()"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </value>
        </xsl:variable>
        <!-- check if the effectiveTime is valid, if not, throw out a message -->
        <xsl:if test="
            (count($effectiveTime//low) = 1 and count($effectiveTime//high) &lt; 2) or 
            (count($effectiveTime//low) &lt; 1 and count($effectiveTime//high) = 1)
            ">
            <xsl:sequence select="$effectiveTime"/>
        </xsl:if>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>Parse a period of use and create an effectiveTime with appropriate range and if
                necessary a calculated date</xd:p>
            <xd:p>if group1='ge' then low else high</xd:p>
            <xd:p>if group2=TODAY then val</xd:p>
        </xd:desc>
        <xd:param name="period"/>
    </xd:doc>

    <xsl:template name="parseDate">
        <xsl:param name="period" as="xs:string"/>
        <xsl:variable name="tmp"
            select="f:analyze-string($period, '(ge|le|eq)?(TODAY|\d\d\d\d-\d\d-\d\d)(\+|-)?([\d]+)?([DM])?')"/>
        <xsl:variable name="hasRange" select="f:normalize-space($tmp//f:match/f:group[@nr = 1])"/>
        <xsl:variable name="tmpDate" select="f:normalize-space($tmp//f:match/f:group[@nr = 2])"/>
        <xsl:variable name="adjustment" select="
                f:normalize-space(
                f:concat($tmp//f:match/f:group[@nr = 3], $tmp//f:match/f:group[@nr = 4], $tmp//f:match/f:group[@nr = 5])
                )"/>
        <xsl:variable name="inputDate" select="vf:calculate-t-date(f:concat($tmpDate, $adjustment))"/>
        
        <!--<xsl:message>
            <xsl:text expand-text="true">tmp: '{$tmp} - {$hasRange} - {$tmpDate}'</xsl:text>
        </xsl:message>
        <xsl:message>
            <xsl:text expand-text="true">inputDate: '{$inputDate}'</xsl:text>
        </xsl:message>


        <xsl:message>
            <xsl:text expand-text="true">tmpStartDate: '{$tmpStartDate}'</xsl:text>
        </xsl:message>-->


        <parsedDate>
            <xsl:if test="$inputDate">
                <xsl:attribute name="value" select="$inputDate"/>
            </xsl:if>
            <xsl:if test="$hasRange">
                <xsl:attribute name="range" select="$hasRange"/>
            </xsl:if>
        </parsedDate>
    </xsl:template>


    <xd:doc>
        <xd:desc>Parse the url string into resource and the individiual parameters. Take into
            account that there can also be an operation </xd:desc>
        <xd:param name="urlString"/>
    </xd:doc>
    <xsl:template name="parseURLparameters" as="element()+">
        <xsl:param name="urlString"/>

        <xsl:variable name="resource"
            select="f:normalize-space(f:replace($urlString, '^.*/([a-zA-Z0-9]+)\?.*', '$1'))"/>
        <xsl:variable name="hasOperation"
            select="f:normalize-space(f:replace($urlString, '^.*/?([a-zA-Z0-9]*)\$([\w]*)', '$2'))"/>
        <xsl:variable name="queryParam"
            select="f:analyze-string($urlString, '[\?]?([\w._]+)=([\w|:/.\-]+)', 'm')"/>
        <params>
            <xsl:if test="not($resource = '') and not($resource = $urlString)">
                <param name="FHIRresource">
                    <xsl:value-of select="$resource"/>
                </param>
            </xsl:if>
            <xsl:if test="not($hasOperation = '') and not($hasOperation = $urlString)">
                <param name="FHIRoperation">
                    <xsl:value-of select="$hasOperation"/>
                </param>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="f:count($queryParam//f:match) = 0">
                    <xsl:call-template name="util:logMessage">
                        <xsl:with-param name="level" select="$logDEBUG"/>
                        <xsl:with-param name="msg"><xsl:text expand-text="yes">No parameters found in '{$urlString}'</xsl:text></xsl:with-param>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:for-each select="$queryParam//f:match">
                        <param name="{./f:group[@nr=1]}">
                            <xsl:value-of select="./f:group[@nr = 2]"/>
                        </param>
                    </xsl:for-each>
                </xsl:otherwise>
            </xsl:choose>
        </params>
    </xsl:template>

</xsl:stylesheet>
