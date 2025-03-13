<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://exslt.org/math" 
    xmlns:func="http://exslt.org/functions"
    xmlns:uuid="http://www.uuid.org"
    xmlns:util="urn:hl7:utilities"
    xmlns:vf="http://www.vzvz.nl/functions" extension-element-prefixes="func math vf"
    exclude-result-prefixes="#all"
    version="3.0">

    <xsl:import href="uuid.xsl"/>
    
    <xsl:variable name="versionXSLT" select="'0.1.1'"/>
            
    <xd:doc>
        <xd:desc>
            <xd:p>Genereer een UUID op de manier zoals Nictiz dat doet</xd:p>
            <xd:p>namespace aangepast zodat er geen clashes kunnen ontstaan.</xd:p>
        </xd:desc>
        <xd:param name="node"/>
        <xd:return>een string met een UUID</xd:return>
    </xd:doc>
    <xsl:function name="vf:UUID4-nictiz">
        <xsl:param name="node"/>
        <xsl:value-of select="uuid:get-uuid($node)"/>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>Genereer een UUID</xd:desc>
        <xd:return>een string met een UUID</xd:return>
    </xd:doc>
    <xsl:function name="vf:UUID4">
        
        <!-- 8 -->
        <xsl:value-of select="vf:_generateNumber()"/>
        <xsl:value-of select="vf:_generateNumber()"/>
        <xsl:value-of select="vf:_generateNumber()"/>
        <xsl:value-of select="vf:_generateNumber()"/>
        <xsl:value-of select="vf:_generateNumber()"/>
        <xsl:value-of select="vf:_generateNumber()"/>
        <xsl:value-of select="vf:_generateNumber()"/>
        <xsl:value-of select="vf:_generateNumber()"/>
        <xsl:text>-</xsl:text>
        
        <!-- 4 -->
        <xsl:value-of select="vf:_generateNumber()"/>
        <xsl:value-of select="vf:_generateNumber()"/>
        <xsl:value-of select="vf:_generateNumber()"/>
        <xsl:value-of select="vf:_generateNumber()"/>
        
        <!-- version identifier -->
        <xsl:text>-4</xsl:text>
        
        <!-- 3 -->
        <xsl:value-of select="vf:_generateNumber()"/>
        <xsl:value-of select="vf:_generateNumber()"/>
        <xsl:value-of select="vf:_generateNumber()"/>
        <xsl:text>-</xsl:text>
        
        <!-- 1* -->
        <xsl:value-of select="substring('89ab', floor(4*math:random()) + 1, 1)"/>
        
        <!-- 3 -->
        <xsl:value-of select="vf:_generateNumber()"/>
        <xsl:value-of select="vf:_generateNumber()"/>
        <xsl:value-of select="vf:_generateNumber()"/>
        <xsl:text>-</xsl:text>
        
        <!-- 12 -->
        <xsl:value-of select="vf:_generateNumber()"/>
        <xsl:value-of select="vf:_generateNumber()"/>
        <xsl:value-of select="vf:_generateNumber()"/>
        <xsl:value-of select="vf:_generateNumber()"/>
        <xsl:value-of select="vf:_generateNumber()"/>
        <xsl:value-of select="vf:_generateNumber()"/>
        <xsl:value-of select="vf:_generateNumber()"/>
        <xsl:value-of select="vf:_generateNumber()"/>
        <xsl:value-of select="vf:_generateNumber()"/>
        <xsl:value-of select="vf:_generateNumber()"/>
        <xsl:value-of select="vf:_generateNumber()"/>
        <xsl:value-of select="vf:_generateNumber()"/>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>Internal function to generate a random hex number</xd:desc>
    </xd:doc>
    <xsl:function name="vf:_generateNumber">
        <xsl:value-of select="substring('0123456789abcdef', floor(16*math:random()) + 1, 1)"/>
    </xsl:function>
       
    <xd:doc>
        <xd:desc>maak een string met voorloopnullen van de gewenste lengte</xd:desc>
        <xd:param name="value">de waarde</xd:param>
        <xd:param name="length">de gewenste lengte</xd:param>
        <xd:return>string</xd:return>
    </xd:doc>
    <xsl:function name="vf:strzero">
        <xsl:param name="value"/>
        <xsl:param name="length"/>
        
        <xsl:variable name="str" select="string($value)"/>
        <xsl:variable name="strlen" select="string-length($str)"/>
        
        <xsl:value-of
            select="concat(substring('00000000000000000000000000000000', 1, $length - $strlen), $str)"
        />
    </xsl:function>
    
    <xd:doc>
        <xd:desc>
            <xd:p>maskeer de BSN in een tekst met XXXXXXXXX</xd:p>
            <xd:p>LET OP: dit werkt alleen als de BSN exact zo in de tekst voorkomt als meegegeven,
                dus een BSN met voorloopnullen als parameter wordt niet herkend in een tekst waar de BSN zonder 
                voorloopnullen voorkomt.
            </xd:p>
        </xd:desc>
        <xd:param name="Text"/>
        <xd:param name="BSN"/>
    </xd:doc>
    <xsl:function name="vf:HideBSN">
        <xsl:param name="Text"/>
        <xsl:param name="BSN"/>
        
        <xsl:choose>
            <xsl:when test="string-length($BSN) = 0">
                <xsl:value-of select="$Text"/>
            </xsl:when>
            <xsl:when test="not(starts-with($BSN, '0'))">
                <xsl:value-of select="replace($Text, $BSN, 'XXXXXXXXX')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of
                    select="replace(replace($Text, $BSN, 'XXXXXXXXX'), string(number($BSN)), 'XXXXXXXXX')"
                />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- onderstaande logMessage met bijbehorende variabelen overgenomen van Nictiz -->
    <!-- provide a mapping from string logLevel to numeric value -->
    <xsl:variable name="logALL" select="'ALL'"/>
    <xsl:variable name="logDEBUG" select="'DEBUG'"/>
    <xsl:variable name="logINFO" select="'INFO'"/>
    <xsl:variable name="logWARN" select="'WARN'"/>
    <xsl:variable name="logERROR" select="'ERROR'"/>
    <xsl:variable name="logFATAL" select="'FATAL'"/>
    <xsl:variable name="logOFF" select="'OFF'"/>
    
    <xsl:param name="logLevel" select="$logINFO" as="xs:string"/>
    
    <xsl:variable name="logLevelMap" as="element(level)*">
        <level name="{$logALL}" int="6" desc="The ALL has the lowest possible rank and is intended to turn on all logging."/>
        <level name="{$logDEBUG}" int="5" desc="The DEBUG Level designates fine-grained informational events that are most useful to debug an application."/>
        <level name="{$logINFO}" int="4" desc="The INFO level designates informational messages that highlight the progress of the application at coarse-grained level."/>
        <level name="{$logWARN}" int="3" desc="The WARN level designates potentially harmful situations."/>
        <level name="{$logERROR}" int="2" desc="The ERROR level designates error events that might still allow the application to continue running."/>
        <level name="{$logFATAL}" int="1" desc="The FATAL level designates very severe error events that will presumably lead the application to abort."/>
        <level name="{$logOFF}" int="0" desc="The OFF level has the highest possible rank and is intended to turn off logging."/>
    </xsl:variable>
    <xsl:variable name="util:chkdLogLevel" select="if ($logLevelMap[@name = $logLevel]) then $logLevel else $logINFO"/>
    
    <xd:doc>
        <xd:desc>Emit message text if the level of the message is smaller than or equal to logLevel </xd:desc>
        <xd:param name="msg">The message to emit</xd:param>
        <xd:param name="level">The level this should be emitted at</xd:param>
        <xd:param name="terminate">Terminate after emitting</xd:param>
    </xd:doc>
    <xsl:template name="util:logMessage">
        <xsl:param name="msg" as="item()*"/>
        <xsl:param name="level" select="$logINFO" as="xs:string"/>
        <xsl:param name="terminate" select="false()" as="xs:boolean"/>
        <xsl:variable name="term" select="if ($terminate) then 'yes' else 'no'"/>
        <xsl:variable name="currLevel" select="$logLevelMap[@name = $level]/number(@int)"/>
        <xsl:variable name="compLevel" select="$logLevelMap[@name = $util:chkdLogLevel]/number(@int)"/>
        <!--<xsl:if test="$term='yes'">
            <!-\- we'll gonna die anyway, write a survivor document for later post processing -\->
            <xsl:result-document href="last-survivor-message.xml" format="xml" indent="yes">
                <last level="{$level}">
                    <xsl:copy-of select="$msg"/>
                </last>
            </xsl:result-document>
        </xsl:if>-->
        <xsl:if test="$terminate or ($currLevel le $compLevel)">
            <!-- must die if to be terminated on message -->
            <xsl:message terminate="{$term}">
                <xsl:value-of select="substring(concat($level,'        '),1,5)"/>
                <xsl:text>: </xsl:text>
                <xsl:copy-of select="$msg"/>
            </xsl:message>
        </xsl:if>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Convert a string of XML, usually passed on from a parameter, to a document node</xd:desc>
        <xd:param name="xml">xml string to be converted</xd:param>
        <xd:param name="msg">error message when it doesn't succeed</xd:param>
    </xd:doc>
    <xsl:template name="convertToDocumentNode">
        <xsl:param name="xml"/>
        <xsl:param name="msg">XML niet beschikbaar</xsl:param>
        
<!--        <xsl:call-template name="util:logMessage">
            <xsl:with-param name="level" select="$logDEBUG"/>
            <xsl:with-param name="msg">Found: <xsl:value-of select="$xml"/></xsl:with-param>
        </xsl:call-template>
-->        
        <xsl:choose>
            <!-- fail fast when the parameter does not exists -->
            <xsl:when test="not(exists($xml))">
                <xsl:call-template name="util:logMessage">
                    <xsl:with-param name="level" select="$logERROR"/>
                    <xsl:with-param name="msg"><xsl:sequence select="$msg"/></xsl:with-param>
                </xsl:call-template>             
            </xsl:when>
            <xsl:when test="$xml instance of node()">
                <!-- <xsl:message>I think it's a node</xsl:message> -->
                <xsl:sequence select="$xml" exclude-result-prefixes="#all"/>
            </xsl:when>
            <xsl:when test="doc-available($xml)">
                <!-- <xsl:message>doc uri found</xsl:message> -->
                <xsl:sequence select="doc($xml)" exclude-result-prefixes="#all"/>
            </xsl:when>
            <xsl:when test="$xml instance of xs:untypedAtomic">
                <!-- <xsl:message>I think it's a string</xsl:message> -->
                <xsl:sequence select="parse-xml($xml)" exclude-result-prefixes="#all"/>                    
            </xsl:when>
            <xsl:when test="$xml instance of xs:string">
                <!-- <xsl:message>I think it's a string</xsl:message> -->
                <xsl:sequence select="parse-xml($xml)" exclude-result-prefixes="#all"/>                    
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="util:logMessage">
                    <xsl:with-param name="level" select="$logERROR"/>
                    <xsl:with-param name="msg"><xsl:sequence select="$msg"/></xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
        <!-- <xsl:message>End of convertToDocumentNode, called by: (<xsl:sequence select="$msg"/>)</xsl:message> -->
        
    </xsl:template>
    
    <xd:doc>
        <xd:desc> Prefixes a diagnostic message with identifiable information of its originating element </xd:desc>
        <xd:param name="level"/>
        <xd:param name="message"/>
    </xd:doc>
<!--    <xsl:template name="vf:prefix-diag-message" as="xs:string">
        
        <xsl:param name="level" as="xs:string" select="'ERROR'" />
        <xsl:param name="message" as="xs:string" required="yes" />
        
        <xsl:variable name="owner-element" as="element()?" select="ancestor-or-self::*[1]" />
        <xsl:variable name="full-label" as="xs:string" select="
            normalize-space(string-join($owner-element/ancestor-or-self::*[not(self::like or self::pending)]/., ' '))" />
        
        <xsl:value-of>
            <xsl:text>{$level}</xsl:text>
            
            <xsl:for-each select="$owner-element">
                <!-\- If prefixed, use lexical QName. If not prefixed, use URIQualifiedName. -\->
                <xsl:variable name="owner-element-eqname" as="xs:string" select="
                    if (prefix-from-QName(.)) then
                    name()
                    else
                    name()" />
                <xsl:text> in {$owner-element-eqname}</xsl:text>
                
                <xsl:for-each select="@name">
                    <xsl:text> (named {.})</xsl:text>
                </xsl:for-each>

            </xsl:for-each>
            <xsl:for-each select="$full-label[. (: eliminate zero-length string :)]">
                <xsl:text> (</xsl:text>
                <xsl:if test="$owner-element[not(self::expect or self::scenario)]">
                    <xsl:text>under </xsl:text>
                </xsl:if>
                <xsl:text>'{.}')</xsl:text>
            </xsl:for-each>
            
            <xsl:text>: </xsl:text><xsl:value-of select="$message"/>
        </xsl:value-of>
    </xsl:template>
-->
</xsl:stylesheet>