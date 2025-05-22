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
    xmlns:math="http://exslt.org/math" xmlns:func="http://exslt.org/functions"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:date="http://exslt.org/dates-and-times"
    xmlns:vf="http://www.vzvz.nl/functions"
    extension-element-prefixes="func math vf"
    exclude-result-prefixes="#all"
    version="2.0">
    
    <xsl:import href="date.day-in-week.template.xsl"/>
    <xsl:import href="vf.utils.xsl"/>
    
    <xd:doc>
        <xd:desc>Variabelen die de tijdzone weergeven voor zomer- en wintertijd, resp. 'CEST' en 'CET'
        </xd:desc>
    </xd:doc>
    <xsl:variable name="summertime" select="xs:string('+02:00')"/>
    <xsl:variable name="wintertime" select="xs:string('+01:00')"/>
    
    <xd:doc>
        <xd:desc>Bepaal de huidige tijdzone van het systeem</xd:desc>
    </xd:doc>
    <xsl:variable name="currentTimezone">
        <xsl:choose>
            <xsl:when test="xs:string(implicit-timezone()) = 'PT2H'">
                <xsl:sequence select="$summertime"/>
            </xsl:when>
            <xsl:when test="xs:string(implicit-timezone()) = 'PT1H'">
                <xsl:sequence select="$wintertime"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
   
    <xd:doc>
        <xd:desc>Converteer de datum/tijd van V3 naar FHIR</xd:desc>
        <xd:param name="date_time_v3">V3 waarde in yyyyMMdd(hhmm)</xd:param>
        <xd:param name="incl_time">inclusief tijd ja/nee</xd:param>
        <xd:return>string met tijd</xd:return>
    </xd:doc>
    <xsl:function name="vf:dateTimeV3_FHIR" as="xs:string">
        <xsl:param name="date_time_v3" as="xs:string"/>
        <xsl:param name="incl_time" as="xs:boolean"/>
        
        <xsl:variable name="isoDate" select="vf:parseV3dateTime($date_time_v3)"/>
        
        <xsl:variable name="timezone" select="vf:calculateTimezone($isoDate)"/>
        
        <xsl:variable name="date" select="xs:date($isoDate)"/>
        <xsl:variable name="time" select="xs:time($isoDate)"/>
        
        <xsl:choose>
            <xsl:when test="$incl_time = true()">
                <xsl:sequence select="xs:string(concat($date, 'T', $time, $timezone))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="xs:string($date)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xd:doc>
        <xd:desc>Converteer de datum/tijd van FHIR naar V3</xd:desc>
        <xd:param name="date_time_in">FHIR timestamp</xd:param>
        <xd:param name="incl_time">inclusief tijd ja/nee</xd:param>
    </xd:doc>
    <xsl:function name="vf:dateTimeFHIR_V3">
        <xsl:param name="date_time_in" as="xs:string"/>
        <xsl:param name="incl_time" as="xs:boolean"/>

        <xsl:variable name="isoDate" select="vf:parseFHIRdateTime($date_time_in)"/>
        <!-- volgens mij doen we niet aan tijdzones in V3 CDA
        <xsl:variable name="timezone" select="vf:calculateTimezone($isoDate)"/>
        -->

        <xsl:choose>
            <xsl:when test="$incl_time = true()">
                <xsl:sequence select="vf:toV3dateTime($isoDate)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="vf:toV3date(xs:date($isoDate))"/>                
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>


    <xd:doc>
        <xd:desc>
            <xd:p>Bereken einddatumtijd op basis van width</xd:p>
            <xd:p>tel het aantal minuten of uren van de width op bij de startdatumtijd.</xd:p>
        </xd:desc>
        <xd:param name="BeginTS">start datumtijd in 'yyyyMMddhhmm'</xd:param>
        <xd:param name="WidthValue">width waarde</xd:param>
        <xd:param name="WidthUnit">width eenheid</xd:param>
        <xd:return>einddatumtijd in yyyyMMddhhmm (!)</xd:return>
    </xd:doc>
    <xsl:function name="vf:calcEndTS" as="xs:string">
        <xsl:param name="BeginTS"/>
        <xsl:param name="WidthValue"/>
        <xsl:param name="WidthUnit"/>
        
        <xsl:variable name="isoDate" select="vf:parseV3dateTime($BeginTS)"/>
        
        <xsl:variable name="duration" as="xs:dayTimeDuration">
            <xsl:choose>
                <xsl:when test="$WidthUnit = 'min'">
                    <xsl:value-of select="concat('PT', $WidthValue, 'M')"/>
                </xsl:when>
                <xsl:when test="$WidthUnit = 'h'">
                    <xsl:value-of select="concat('P', $WidthValue, 'H')"/>
                </xsl:when>
                <xsl:otherwise>PT0H</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="endDate" select="xs:string(vf:toV3dateTime($isoDate + $duration))"/>
     
        <xsl:sequence select="$endDate"/>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Calculate the timezone and return the correct one</xd:p>
            <xd:p>Dutch summertime: last Sunday in March</xd:p>
            <xd:p>Dutch wintertime: last Sunday in October</xd:p>
            <xd:p/>
            <xd:p>Note: this calculation doesn't take the hours between 00:00 and 03:00 on the
                switch day into account. I.e. these hours are calculated the same as the timezone
                after 03:00.</xd:p>
        </xd:desc>
        <xd:param name="date">Datestring already in xs:dateTime format</xd:param>
        <xd:return>string with correct timezone</xd:return>
    </xd:doc>
    <xsl:function name="vf:calculateTimezone" as="xs:string">
        <xsl:param name="date"/>
        
        <xsl:variable name="month" select="fn:month-from-dateTime(xs:dateTime($date))"/>
        <xsl:variable name="day" select="fn:day-from-dateTime(xs:dateTime($date))"/>
        
        <!-- find out if we are before the last Sunday of the month,
             we assume it's a 31 days month, which is true for
             March and October anyway
        -->
        <xsl:variable name="year" select="xs:string(fn:year-from-dateTime(xs:dateTime($date)))"/>
        
        <!-- The numbering of days of the week starts at 1 for Sunday, 2 for Monday and so on up to 7 for Saturday. -->
        <xsl:variable name="sunday" select="1" as="xs:integer"/>
        <xsl:variable name="lastDay">
            <xsl:call-template name="date:day-in-week">
                <xsl:with-param name="date-time">
                    <xsl:value-of select="concat($year, '-')"/>
                    <xsl:if test="$month &lt; 10">
                        <xsl:text>0</xsl:text>
                    </xsl:if>
                    <xsl:value-of select="$month"/>
                    <xsl:text>-31</xsl:text>
                </xsl:with-param> 
            </xsl:call-template>
            
        </xsl:variable>
        <xsl:variable name="lastSunday" select="31 - (($lastDay + (7 - $sunday)) mod 7)"/>
        
        <xsl:variable name="timeZone">
            <xsl:choose>
                <xsl:when test="$month &lt; 3 or $month &gt; 10">
                    <!-- wintertime -->
                    <xsl:sequence select="$wintertime"/>
                </xsl:when>
                <xsl:when test="$month = 3 and $day &lt; $lastSunday">
                    <!-- wintertime -->
                    <xsl:sequence select="$wintertime"/>
                </xsl:when>
                <xsl:when test="$month = 3 and $day &gt;= $lastSunday">
                    <!-- summertime, we don't take the hours between 00:00 and 03:00 into account -->
                    <xsl:sequence select="$summertime"/>
                </xsl:when>
                <xsl:when test="$month &gt; 3 and $month &lt; 10">
                    <!-- summertime -->
                    <xsl:sequence select="$summertime"/>
                </xsl:when>
                <xsl:when test="$month = 10 and $day &lt; $lastSunday">
                    <!-- summertime -->
                    <xsl:sequence select="$summertime"/>
                </xsl:when>
                <xsl:when test="$month = 10 and $day &gt;= $lastSunday">
                    <!-- wintertime, we don't take the hours between 00:00 and 03:00 into account -->
                    <xsl:sequence select="$wintertime"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>0</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:sequence select="xs:string($timeZone)"/>
    </xsl:function>

    <xd:doc>
        <xd:desc>Converteer een V3 datumtijd naar xs:dateTime</xd:desc>
        <xd:param name="dateTime">Datumtijd in yyyyMM(ddhhmm)</xd:param>
        <xd:return>datumtijd als xs:dateTime</xd:return>
    </xd:doc>
    <xsl:function name="vf:parseV3dateTime">
        <xsl:param name="dateTime"/>
        
        <xsl:variable name="year" select="substring($dateTime, 1, 4)"/>
        <xsl:variable name="month" select="substring($dateTime, 5, 2)"/>
        <xsl:variable name="day" select="substring($dateTime, 7, 2)"/>
        <xsl:variable name="hours" select="substring($dateTime, 9, 2)"/>
        <xsl:variable name="minutes" select="substring($dateTime, 11, 2)"/>
        <xsl:variable name="seconds" select="substring($dateTime, 13, 2)"/>

        <xsl:variable name="localMonth">
            <xsl:choose>
                <xsl:when test="$month = ''">
                    <xsl:sequence select="0"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="number($month)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="localDay">
            <xsl:choose>
                <xsl:when test="$day = ''">
                    <xsl:sequence select="0"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="number($day)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="localHours">
            <xsl:choose>
                <xsl:when test="$hours = ''">
                    <xsl:sequence select="0"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="number($hours)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="localMinutes">
            <xsl:choose>
                <xsl:when test="$minutes = ''">
                    <xsl:sequence select="0"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="number($minutes)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="localSeconds">
            <xsl:choose>
                <xsl:when test="$seconds = ''">
                    <xsl:sequence select="0"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="number($seconds)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>  
        
        <xsl:sequence select="vf:toDateTime($year, $localMonth, $localDay, $localHours, $localMinutes, $localSeconds)"/>
    </xsl:function>

    <xd:doc>
        <xd:desc>Converteer een FHIR datumtijd naar xs:dateTime</xd:desc>
        <xd:param name="dateTime">Datumtijd in yyyy-MM-ddThh:mm of yyyyMMddhhmm</xd:param>
        <xd:return>datumtijd als xs:dateTime</xd:return>
    </xd:doc>
    <xsl:function name="vf:parseFHIRdateTime">
        <xsl:param name="dateTime"/>

        <xsl:choose>
            <xsl:when test="substring($dateTime, 5, 1) != '-'">
                <!-- het is een V3 formaat -->
                <xsl:sequence select="vf:parseV3dateTime($dateTime)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="year" select="substring($dateTime, 1, 4)"/>
                <xsl:variable name="month" select="substring($dateTime, 6, 2)"/>
                <xsl:variable name="day" select="substring($dateTime, 9, 2)"/>
                <xsl:variable name="hours" select="substring($dateTime, 12, 2)"/>
                <xsl:variable name="minutes" select="substring($dateTime, 15, 2)"/>
                <xsl:variable name="seconds" select="substring($dateTime, 18, 2)"/>


                <xsl:variable name="localMonth">
                    <xsl:choose>
                        <xsl:when test="$month = ''">
                            <xsl:sequence select="0"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="number($month)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="localDay">
                    <xsl:choose>
                        <xsl:when test="$day = ''">
                            <xsl:sequence select="0"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="number($day)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="localHours">
                    <xsl:choose>
                        <xsl:when test="$hours = ''">
                            <xsl:sequence select="0"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="number($hours)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="localMinutes">
                    <xsl:choose>
                        <xsl:when test="$minutes = ''">
                            <xsl:sequence select="0"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="number($minutes)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="localSeconds">
                    <xsl:choose>
                        <xsl:when test="$seconds = ''">
                            <xsl:sequence select="0"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="number($seconds)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>

                <xsl:sequence
                    select="vf:toDateTime($year, $localMonth, $localDay, $localHours, $localMinutes, $localSeconds)"
                />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xd:doc>
        <xd:desc>
            <xd:p>Convert datetime elements to datetime variable</xd:p>
            <xd:p>NOTE: deze functie heeft geen foutafhandeling, dus hij moet door de aanroepende 
                functies voorzien worden van de juiste parameters</xd:p>
        </xd:desc>
        
        <xd:param name="year"/>
        <xd:param name="month"/>
        <xd:param name="day"/>
        <xd:param name="hours"/>
        <xd:param name="minutes"/>
        <xd:param name="seconds"/>
    </xd:doc>
    <xsl:function name="vf:toDateTime" as="xs:dateTime">
        <xsl:param name="year"/>
        <xsl:param name="month"/>
        <xsl:param name="day"/>
        <xsl:param name="hours"/>
        <xsl:param name="minutes"/>
        <xsl:param name="seconds"/>
        
        <xsl:variable name="result" as="xs:dateTime"
            select="xs:dateTime(fn:concat($year, '-', 
            fn:format-number(number($month), '00'), '-', 
            fn:format-number(number($day), '00'), 'T', 
            fn:format-number(number($hours), '00'), ':', 
            fn:format-number(number($minutes), '00'), ':', 
            fn:format-number(number($seconds), '00')))"
        />
        <xsl:sequence select="$result"/>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>Converteer een dateTime type naar een FHIR datetime string (ISO 8601)</xd:desc>
        <xd:param name="dateTime">de datumtijd als xs:dateTime type</xd:param>
        <xd:return>datumtijd als string (zonder tijdzone)</xd:return>
    </xd:doc>
    <xsl:function name="vf:toFHIRdateTime" as="xs:string">
        <xsl:param name="dateTime" as="xs:dateTime"/>
        <xsl:value-of select="fn:format-dateTime($dateTime, '[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01]')"/>
    </xsl:function>

    <xd:doc>
        <xd:desc>Converteer een dateTime type naar een V3 datetime string (ISO 8601 zonder streepjes en 'T')</xd:desc>
        <xd:param name="dateTime">de datumtijd als xs:dateTime type</xd:param>
        <xd:return>datumtijd als string (zonder tijdzone)</xd:return>
    </xd:doc>
    <xsl:function name="vf:toV3dateTime" as="xs:string">
        <xsl:param name="dateTime"/>
        <xsl:value-of select="fn:format-dateTime($dateTime, '[Y0001][M01][D01][H01][m01][s01]')"/>
    </xsl:function>

    <xd:doc>
        <xd:desc>Converteer een date type naar een V3 date string (ISO 8601 zonder streepjes)</xd:desc>
        <xd:param name="date">de datumtijd als xs:date type</xd:param>
        <xd:return>datumtijd als string (zonder tijdzone)</xd:return>
    </xd:doc>
    <xsl:function name="vf:toV3date" as="xs:string">
        <xsl:param name="date" as="xs:date"/>
        <xsl:value-of select="fn:format-date($date, '[Y0001][M01][D01]')"/>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>Converts a TODAY-12D{12:34:56} like string into a proper XML date or dateTime</xd:desc>
        <xd:param name="in">The input string to be converted</xd:param>
    </xd:doc>
    <xsl:function name="vf:calculate-t-date" as="xs:string?">
        <xsl:param name="in" as="xs:string?"/>
        
        <xsl:variable name="inputDateT" select="fn:current-date()"/>
        <xsl:choose>
            <xsl:when test="contains($in, 'TODAY')">
                <xsl:variable name="sign" select="replace($in, '.*(TODAY)([+-])?.*', '$2')"/>
                <xsl:variable name="amountYearMonth" as="xs:string?">
                    <xsl:if test="matches($in, '^.*(TODAY)[+-](\d+(\.\d+)?[YM]){0,2}')">
                        <xsl:value-of select="replace($in, '^.*(TODAY)[+-]((\d+(\.\d+)?Y)?(\d+(\.\d+)?M)?).*', '$2')"/>
                    </xsl:if>
                </xsl:variable>
                <xsl:variable name="amountDay" as="xs:string?">
                    <xsl:if test="matches($in, '^.*(TODAY)[+-](\d+(\.\d+)?[YM]){0,2}(\d+(\.\d+)?D).*')">
                        <xsl:value-of select="replace($in, '^.*(TODAY)[+-](\d+(\.\d+)?[YM]){0,2}(\d+(\.\d+)?D)?.*', '$4')"/>
                    </xsl:if>
                </xsl:variable>
                
                <xsl:variable name="timePart" select="
                    if (matches($in, '^.*(TODAY)[^\{]*\{([^\}]+)\}')) then
                    replace($in, '^.*(TODAY)[^\{]*\{([^\}]+)\}', '$2')
                    else
                    ()"/>
                <xsl:variable name="time" as="xs:string?">
                    <xsl:choose>
                        <xsl:when test="string-length($timePart) = 2">
                            <!-- time given in hours, let's add 0 minutes/seconds -->
                            <xsl:value-of select="concat($timePart, ':00:00')"/>
                        </xsl:when>
                        <xsl:when test="string-length($timePart) = 5">
                            <!-- time given in minutes, let's add 0 seconds -->
                            <xsl:value-of select="concat($timePart, ':00')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$timePart"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="calculatedYearMonth" as="xs:date">
                    <xsl:choose>
                        <xsl:when test="$sign = '+' and string-length($amountYearMonth) gt 0">
                            <xsl:value-of select="$inputDateT + xs:yearMonthDuration(concat('P', $amountYearMonth))"/>
                        </xsl:when>
                        <xsl:when test="$sign = '-' and string-length($amountYearMonth) gt 0">
                            <xsl:value-of select="$inputDateT - xs:yearMonthDuration(concat('P', $amountYearMonth))"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of select="$inputDateT"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="calculatedDay" as="xs:date">
                    <xsl:choose>
                        <xsl:when test="$sign = '+' and string-length($amountDay) gt 0">
                            <xsl:value-of select="$calculatedYearMonth + xs:dayTimeDuration(concat('P', $amountDay))"/>
                        </xsl:when>
                        <xsl:when test="$sign = '-' and string-length($amountDay) gt 0">
                            <xsl:value-of select="$calculatedYearMonth - xs:dayTimeDuration(concat('P', $amountDay))"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of select="$calculatedYearMonth"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                
                <xsl:if test="string-length($time) gt 0 and not($time castable as xs:time)">
                    <xsl:message>Variable dateTime "<xsl:value-of select="$in"/>" found with illegal time string "<xsl:value-of select="$timePart"/>"</xsl:message>
                </xsl:if>
                <xsl:variable name="calculatedDateTime">
                    <xsl:choose>
                        <xsl:when test="string-length($time) gt 0 and $time castable as xs:time">
                            <xsl:value-of select="xs:dateTime(concat(format-date($calculatedDay, '[Y0001]-[M01]-[D01]'), 'T', $time))"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- we sometimes get a timezone, which is the current timezone of the system which does not make sense -->
                            <!-- so we strip the timezone -->
                            <xsl:value-of select="format-date($calculatedDay, '[Y0001]-[M01]-[D01]')"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:value-of select="vf:add-Amsterdam-timezone-to-dateTimeString($calculatedDateTime)"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- we cannot calculate anything -->
                <xsl:value-of select="vf:add-Amsterdam-timezone-to-dateTimeString($in)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Takes input string. If it is a dateTime, it checks if it has a timezone.</xd:p>
            <xd:p>If it is a dateTime without timezone the appropriate Amsterdam timezone will be set.</xd:p>
            <xd:p>In all other cases, the input string is returned.</xd:p>
            <xd:p>Inspired by similar function written by Nictiz</xd:p>
        </xd:desc>
        <xd:param name="in">ISO 8601 formatted dateTimeString with or without timezone "yyyy-mm-ddThh:mm:ss" or "yyyy-mm-ddThh:mm:ss[+/-]nn:nn"</xd:param>
    </xd:doc>
    <xsl:function name="vf:add-Amsterdam-timezone-to-dateTimeString" as="xs:string?">
        <xsl:param name="in" as="xs:string?"/>
        
        <xsl:choose>
            <xsl:when test="$in castable as xs:dateTime">
                <xsl:value-of select="vf:add-Amsterdam-timezone(xs:dateTime($in))"/>
            </xsl:when>
            <!-- http://hl7.org/fhir/STU3/datatypes.html#datetime
                If hours and minutes are specified, a time zone SHALL be populated. 
                Seconds must be provided due to schema type constraints but may be zero-filled and may be ignored. -->
            <xsl:when test="concat($in, ':00') castable as xs:dateTime">
                <xsl:value-of select="vf:add-Amsterdam-timezone(xs:dateTime(concat($in, ':00')))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$in"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Add an Amsterdam timezone to an xs:dateTime without one. Return input unaltered otherwise.</xd:p>
            <xd:p>Inspired by similar function written by Nictiz</xd:p>
        </xd:desc>
        <xd:param name="in">xs:dateTime with or without timezone</xd:param>
    </xd:doc>
    <xsl:function name="vf:add-Amsterdam-timezone" as="xs:dateTime">
        <xsl:param name="in" as="xs:dateTime"/>
        
        <xsl:choose>
            <xsl:when test="empty(timezone-from-dateTime($in))">
                <!-- Since 1996 DST starts last Sunday of March 02:00 and ends last Sunday of October at 03:00/02:00 (clock is set backwards) -->
                <!-- There is one hour in october (from 02 - 03) for which we can't be sure if no timezone is provided in the input, 
                    we default to standard time (+01:00), the correct time will be represented if a timezone was in the input, 
                    otherwise we cannot know in which hour it occured (DST or standard time) -->
                <xsl:variable name="March31" select="xs:date(concat(year-from-dateTime($in), '-03-31'))"/>
                <xsl:variable name="DateTime-Start-SummerTime" select="xs:dateTime(concat(year-from-dateTime($in), '-03-', (31 - vf:day-of-week($March31)), 'T02:00:00+01:00'))"/>
                <xsl:variable name="October31" select="xs:date(concat(year-from-dateTime($in), '-10-31'))"/>
                <xsl:variable name="DateTime-End-SummerTime" select="xs:dateTime(concat(year-from-dateTime($in), '-10-', (31 - vf:day-of-week($October31)), 'T02:00:00+02:00'))"/>
                <xsl:choose>
                    <xsl:when test="$in ge $DateTime-Start-SummerTime and $in lt $DateTime-End-SummerTime">
                        <!--return UTC +2 in summer-->
                        <xsl:value-of select="adjust-dateTime-to-timezone($in, xs:dayTimeDuration('PT2H'))"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!--return UTC +1 in winter -->
                        <xsl:value-of select="adjust-dateTime-to-timezone($in, xs:dayTimeDuration('PT1H'))"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$in"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>


<xd:doc>
    <xd:desc>
        <xd:p>
            The day-of-week function returns the day of the week of $date as a number, where 0 is Sunday, 1 is Monday, etc.
            The $date argument must be castable to xs:date, meaning that it must have the type xs:date or xs:dateTime, or be an xs:string or untyped value of the form YYYY-MM-DD.            
        </xd:p>
        <xd:p>
            Src: http://www.xsltfunctions.com/xsl/functx_day-of-week.html
        </xd:p>
    </xd:desc>
    <xd:param name="date"/>
    <xd:return>number</xd:return>
</xd:doc>
    
    <xsl:function name="vf:day-of-week" as="xs:integer?">
        <xsl:param name="date" as="xs:anyAtomicType?"/>
        
        <xsl:sequence select="
            if (empty($date))
            then ()
            else xs:integer((xs:date($date) - xs:date('1901-01-06')) div xs:dayTimeDuration('P1D')) mod 7
            "/>
        
    </xsl:function>

</xsl:stylesheet>
