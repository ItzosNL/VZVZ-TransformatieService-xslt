<?xml version="1.0" encoding="UTF-8"?>

<!-- == Provenance: YATC-shared/xsl/util/mp-functions.xsl == -->
<!-- == Distribution: MP9-Medicatieproces-9.3.0; 1.0.7; 2025-01-17T18:03:28.04+01:00 == -->
<xsl:stylesheet exclude-result-prefixes="#all"
                version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:util="urn:hl7:utilities"
                xmlns:f="http://hl7.org/fhir"
                xmlns:nf="http://www.nictiz.nl/functions"
                xmlns:yatcs="https://nictiz.nl/ns/YATC-shared"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:nwf="http://www.nictiz.nl/wiki-functions"
                xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
                xmlns:local="#local.2024020614533854545020100"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
   <!-- ================================================================== -->
   <!--
        TBD
    -->
   <!-- ================================================================== -->
   <!--
        Copyright © Nictiz
        
        This program is free software; you can redistribute it and/or modify it under the terms of the
        GNU Lesser General Public License as published by the Free Software Foundation; either version
        2.1 of the License, or (at your option) any later version.
        
        This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
        without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
        See the GNU Lesser General Public License for more details.
        
        The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
    -->
   <!-- ================================================================== -->
   <!-- give dateT a value when you need conversion of relative T dates, typically only needed for test instances -->
   <!--    <xsl:param name="dateT" as="xs:date?" select="current-date()"/>-->
   <xsl:param name="dateT"
              as="xs:date?"/>
   <!-- wether to generate the instruction text based on structured fields. Should be false for real live use  -->
   <xsl:param name="generateInstructionText"
              as="xs:boolean?"
              select="false()"/>
   <!-- mp constants -->
   <xsl:variable name="maCode"
                 as="xs:string*"
                 select="('16076005', '33633005')"/>
   <xsl:variable name="maCodeMP920"
                 as="xs:string">33633005</xsl:variable>
   <xsl:variable name="wdsCode"
                 as="xs:string*"
                 select="('395067002')"/>
   <xsl:variable name="vvCode"
                 as="xs:string*"
                 select="('52711000146108')"/>
   <xsl:variable name="taCode"
                 as="xs:string*"
                 select="('422037009')"/>
   <xsl:variable name="mveCode"
                 as="xs:string*"
                 select="('373784005')"/>
   <xsl:variable name="mgbCode"
                 as="xs:string*"
                 select="('422979000')"/>
   <xsl:variable name="mtdCode"
                 as="xs:string*"
                 select="('18629005')"/>
   <xsl:variable name="genericMBHidPRK">2.16.840.1.113883.2.4.3.11.61.2</xsl:variable>
   <xsl:variable name="genericMBHidHPK">2.16.840.1.113883.2.4.3.11.61.3</xsl:variable>
   <xsl:variable name="concatOidMBH">1.3.6.1.4.1.58606.1.2.</xsl:variable>
   <xsl:variable name="concatOidTA">1.3.6.1.4.1.58606.1.1.</xsl:variable>
   <xsl:variable name="stoptypeMap"
                 as="element()+">
      <map stoptype="onderbroken"
           code="385655000"
           codeSystem="2.16.840.1.113883.6.96"
           displayName="onderbroken"
           version="930"/>
      <map stoptype="stopgezet"
           code="410546004"
           codeSystem="2.16.840.1.113883.6.96"
           displayName="stopgezet"
           version="930"/>
      <map stoptype="geannuleerd"
           code="89925002"
           codeSystem="2.16.840.1.113883.6.96"
           displayName="geannuleerd"
           version="930"/>
      <!-- deprecated codes from MP9 2.0 -->
      <map stoptype="tijdelijk"
           code="113381000146106"
           codeSystem="2.16.840.1.113883.6.96"
           displayName="tijdelijk gestopt"
           version="920"/>
      <map stoptype="definitief"
           code="113371000146109"
           codeSystem="2.16.840.1.113883.6.96"
           displayName="definitief gestopt"
           version="920"/>
      <!-- deprecated codes from pre MP 9.1 -->
      <map stoptype="tijdelijk"
           code="1"
           codeSystem="2.16.840.1.113883.2.4.3.11.60.20.77.5.2.1"
           displayName="tijdelijk gestopt"
           version="907"/>
      <map stoptype="definitief"
           code="2"
           codeSystem="2.16.840.1.113883.2.4.3.11.60.20.77.5.2.1"
           displayName="definitief gestopt"
           version="907"/>
   </xsl:variable>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <!-- Outputs a human readable date based on input. -->
   <xsl:function name="nf:output-T-date"
                 as="xs:string?">
      <xsl:param name="current-bouwsteen"
                 as="element()?">
         <!-- ada bouwsteen of the input ada instance xml -->
      </xsl:param>
      <xsl:param name="current-element"
                 as="element()?">
         <!-- the ada xml element in the current bouwsteen that has a date to be converted -->
      </xsl:param>
      <xsl:param name="output0time"
                 as="xs:boolean?">
         <!-- whether or not a time of 00:00 should be outputted in the text. -->
      </xsl:param>
      <xsl:param name="outputEndtime"
                 as="xs:boolean?">
         <!-- whether or not a time of 23:59 should be outputted in the text. -->
      </xsl:param>
      <xsl:variable name="string-output"
                    as="xs:string*">
         <xsl:choose>
            <xsl:when test="$current-element/@value castable as xs:dateTime">
               <xsl:value-of select="nf:formatDate($current-element/@value)"/>
               <xsl:variable name="time"
                             select="nf:formatTime(nf:getTime($current-element/@value), $output0time)"/>
               <xsl:value-of select="                             if ($time) then                                 concat(', om ', $time)                             else                                 ()"/>
            </xsl:when>
            <xsl:when test="$current-element/@value castable as xs:date">
               <xsl:value-of select="nf:formatDate($current-element/@value)"/>
            </xsl:when>
            <xsl:when test="starts-with($current-element/@value, 'T')">
               <xsl:value-of select="nf:formatTDate($current-element/@value, $output0time, $outputEndtime)"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="$current-element/@value"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:value-of select="normalize-space(string-join($string-output, ''))"/>
   </xsl:function>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <!-- Returns a unit string for display purposes, depending on the given unit ánd whether the value is singular or plural -->
   <xsl:function name="nwf:unit-string"
                 as="xs:string?">
      <xsl:param name="value">
         <!-- Input param to determine whether to return the singular or plural form for display -->
      </xsl:param>
      <xsl:param name="unit-in"
                 as="xs:string?">
         <!-- Input unit string -->
      </xsl:param>
      <xsl:variable name="unit"
                    select="normalize-space(lower-case($unit-in))"/>
      <xsl:variable name="floatValue"
                    as="xs:float?">
         <xsl:if test="$value castable as xs:float">
            <xsl:value-of select="xs:float($value)"/>
         </xsl:if>
      </xsl:variable>
      <xsl:choose>
         <!-- same string for singular and plural -->
         <xsl:when test="$unit = ('milliliter', 'ml')">ml</xsl:when>
         <xsl:when test="$unit = ('internationale eenheid', '[iU]')">internationale eenheid</xsl:when>
         <xsl:when test="$unit = ('uur', 'h')">uur</xsl:when>
         <!-- return singular form -->
         <xsl:when test="$floatValue gt 0 and $floatValue lt 2">
            <xsl:choose>
               <xsl:when test="$unit = ('seconde', 'sec', 's')">seconde</xsl:when>
               <xsl:when test="$unit = ('minuut', 'min')">minuut</xsl:when>
               <xsl:when test="$unit = ('dag', 'd')">dag</xsl:when>
               <xsl:when test="$unit = ('week', 'wk')">week</xsl:when>
               <xsl:when test="$unit = ('jaar', 'a')">jaar</xsl:when>
               <xsl:when test="$unit = ('stuk', '1')">stuk</xsl:when>
               <xsl:when test="$unit = ('dosis')">dosis</xsl:when>
               <xsl:when test="$unit = ('druppel', '[drp]')">druppel</xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="$unit"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <!-- return plural form -->
         <xsl:otherwise>
            <xsl:choose>
               <xsl:when test="$unit = ('seconde', 'sec', 's')">seconden</xsl:when>
               <xsl:when test="$unit = ('minuut', 'min')">minuten</xsl:when>
               <xsl:when test="$unit = ('dag', 'd')">dagen</xsl:when>
               <xsl:when test="$unit = ('week', 'wk')">weken</xsl:when>
               <xsl:when test="$unit = ('jaar', 'a')">jaar</xsl:when>
               <xsl:when test="$unit = ('stuk', '1')">stuks</xsl:when>
               <xsl:when test="$unit = ('dosis')">doses</xsl:when>
               <xsl:when test="$unit = ('druppel', '[drp]')">druppels</xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="$unit"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:function name="nf:calculate_Duur_In_Dagen">
      <xsl:param name="inputDuur"/>
      <xsl:param name="eenheid_UCUM"/>
      <xsl:choose>
         <xsl:when test="$eenheid_UCUM = 'h'">
            <xsl:value-of select="format-number(number($inputDuur) div number(24), '0.####')"/>
         </xsl:when>
         <xsl:when test="$eenheid_UCUM = 'wk'">
            <xsl:value-of select="format-number(number($inputDuur) * number(7), '0.####')"/>
         </xsl:when>
         <xsl:when test="$eenheid_UCUM = 'a'">
            <!-- schrikkeljaren buiten beschouwing gelaten -->
            <xsl:value-of select="format-number(number($inputDuur) * number(365), '0.####')"/>
         </xsl:when>
         <xsl:when test="$eenheid_UCUM = 'd'">
            <xsl:value-of select="$inputDuur"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="concat('onverwachte tijdseenheid, kan niet omrekenen naar dagen: ', $inputDuur, ' ', $eenheid_UCUM)"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <!-- Takes an inputTime as string and outputs the time in format '14:32' (24 hour clock, hoours and minutes only) -->
   <xsl:function name="nf:datetime-2-timestring"
                 as="xs:string?">
      <xsl:param name="in"
                 as="xs:string?">
         <!-- xs:dateTime or xs:time castable string or ada relative datetimestring -->
      </xsl:param>
      <xsl:choose>
         <xsl:when test="$in castable as xs:dateTime">
            <xsl:value-of select="format-dateTime(xs:dateTime($in), '[H01]:[m01]')"/>
         </xsl:when>
         <!-- sometimes the time in ada does not have seconds -->
         <xsl:when test="concat($in, ':00') castable as xs:dateTime">
            <xsl:value-of select="format-dateTime(xs:dateTime(concat($in, ':00')), '[H01]:[m01]')"/>
         </xsl:when>
         <xsl:when test="$in castable as xs:time">
            <xsl:value-of select="format-time(xs:time($in), '[H01]:[m01]')"/>
         </xsl:when>
         <!-- sometimes the time in ada does not have seconds -->
         <xsl:when test="concat($in, ':00') castable as xs:time">
            <xsl:value-of select="format-time(xs:time(concat($in, ':00')), '[H01]:[m01]')"/>
         </xsl:when>
         <xsl:when test="matches($in, 'T.*')">
            <!-- relative T-date -->
            <xsl:variable name="timePart"
                          select="replace($in, 'T[+\-]?\d*(\.\d+)?[YMD]?(\{(.*)\})?', '$3')"/>
            <xsl:choose>
               <xsl:when test="(string-length($timePart) gt 0)">
                  <xsl:value-of select="$timePart"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="$in"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="$in"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <!-- Returns the xs:time from a xs:dateTime formatted string. Could include timezone. -->
   <xsl:function name="nf:getTime"
                 as="xs:time?">
      <xsl:param name="xs-datetime"
                 as="xs:string?"/>
      <xsl:if test="substring-after($xs-datetime, 'T') castable as xs:time">
         <xsl:value-of select="xs:time(substring-after($xs-datetime, 'T'))"/>
      </xsl:if>
   </xsl:function>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <!-- Takes an xml date(time) as a string in inputDate and outputs the date in format '3 jun 2018' -->
   <xsl:function name="nf:formatDate"
                 as="xs:string?">
      <xsl:param name="inputDate"
                 as="xs:string?">
         <!-- xs:date castable string -->
      </xsl:param>
      <xsl:variable name="date"
                    select="substring($inputDate, 1, 10)"/>
      <!-- Normally you would use format-date() using Dutch language/country, but Saxon-He and Saxon-PE both misbehave and return English month names regardless
                e.g. format-date(xs:date('2019-03-21'), '[D01] [Mn,*-3] [Y0001]', 'nl', AD', 'NL') -->
      <xsl:choose>
         <xsl:when test="$date castable as xs:date">
            <xsl:variable name="xsdate"
                          select="xs:date($date)"
                          as="xs:date"/>
            <xsl:variable name="daynum"
                          select="day-from-date($xsdate)"
                          as="xs:integer"/>
            <xsl:variable name="monthnum"
                          select="month-from-date($xsdate)"
                          as="xs:integer"/>
            <xsl:variable name="yearnum"
                          select="year-from-date($xsdate)"
                          as="xs:integer"/>
            <xsl:value-of select="concat($daynum, ' ', nf:getDutchMonthName($monthnum, 3, 'low'), ' ', $yearnum)"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="nf:formatTDate($inputDate, false(), false())"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <!-- Formats ada relativeDate(time) to a display date(Time) -->
   <xsl:function name="nf:formatTDate"
                 as="xs:string*">
      <xsl:param name="relativeDate"
                 as="xs:string?">
         <!-- Input ada relativeDate(Time) -->
      </xsl:param>
      <xsl:param name="output0time"
                 as="xs:boolean?">
         <!-- Whether or not a time of 00:00 should be outputted in the text. Defaults to true. -->
      </xsl:param>
      <xsl:param name="outputEndtime"
                 as="xs:boolean?">
         <!-- Whether or not a time of 23:59 should be outputted in the text.  Defaults to true. -->
      </xsl:param>
      <xsl:choose>
         <!-- double check for expected relative date(time) like "T-50D{12:34:56}" in the input -->
         <xsl:when test="matches($relativeDate, 'T([+\-]\d+(\.\d+)?[YMD])?')">
            <xsl:variable name="sign"
                          select="replace($relativeDate, 'T([+\-]).*', '$1')"/>
            <xsl:variable name="amount"
                          select="replace($relativeDate, 'T([+\-](\d+(\.\d+)?)[YMD])?.*', '$2')"/>
            <xsl:variable name="yearMonthDay"
                          select="replace($relativeDate, 'T([+\-]\d+(\.\d+)?([YMD]))?.*', '$3')"/>
            <xsl:variable name="displayYearMonthDay">
               <xsl:choose>
                  <xsl:when test="$yearMonthDay = 'Y'">jaar</xsl:when>
                  <xsl:when test="$yearMonthDay = 'M' and $amount = '1'">maand</xsl:when>
                  <xsl:when test="$yearMonthDay = 'M' and $amount ne '1'">maanden</xsl:when>
                  <xsl:when test="$yearMonthDay = 'D' and $amount = '1'">dag</xsl:when>
                  <xsl:when test="$yearMonthDay = 'D' and $amount ne '1'">dagen</xsl:when>
               </xsl:choose>
            </xsl:variable>
            <xsl:variable name="xsDurationString"
                          select="replace($relativeDate, 'T[+\-](\d+(\.\d+)?)([YMD]).*', 'P$1$3')"/>
            <xsl:variable name="timePart"
                          select="replace($relativeDate, 'T([+\-]\d+(\.\d+)?[YMD])?(\{(.*)\})?', '$4')"/>
            <xsl:variable name="time"
                          as="xs:string?">
               <xsl:choose>
                  <xsl:when test="string-length($timePart) = 8 and ends-with($timePart, ':00')">
                     <xsl:value-of select="substring($timePart, 1, 5)"/>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:value-of select="$timePart"/>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:variable>
            <!-- output a relative date for display -->
            <xsl:choose>
               <xsl:when test="string-length($amount) = 0 or xs:integer($amount) = 0">
                  <xsl:value-of select="'T'"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="concat('T ', $sign, ' ', $amount, ' ', $displayYearMonthDay)"/>
               </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="(string-length($time) gt 0) and (not(starts-with($time, '00:00') or starts-with($time, '23:59'))) or ($outputEndtime and starts-with($time, '23:59')) or ($output0time and starts-with($time, '00:00'))">
               <xsl:value-of select="concat(' om ', $time, ' uur')"/>
            </xsl:if>
         </xsl:when>
         <xsl:otherwise>
            <!-- simply return input string -->
            <xsl:value-of select="$relativeDate"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:function name="nf:getDutchMonthName"
                 as="xs:string?">
      <!-- Return Dutch month name from month number (1-12) -->
      <xsl:param name="monthnum"
                 as="xs:integer?">
         <!-- xs:integer month number e.g. from month-from-date() -->
      </xsl:param>
      <xsl:param name="length"
                 as="xs:integer?">
         <!-- Max length of the name to return. Default 3 -->
      </xsl:param>
      <xsl:param name="case"
                 as="xs:string">
         <!-- Casing of the name to return. 'low' (default), 'high', 'firstcap' -->
      </xsl:param>
      <xsl:variable name="fullMonthName"
                    as="xs:string?">
         <xsl:choose>
            <xsl:when test="$monthnum = 1">Januari</xsl:when>
            <xsl:when test="$monthnum = 2">Februari</xsl:when>
            <xsl:when test="$monthnum = 3">Maart</xsl:when>
            <xsl:when test="$monthnum = 4">April</xsl:when>
            <xsl:when test="$monthnum = 5">Mei</xsl:when>
            <xsl:when test="$monthnum = 6">Juni</xsl:when>
            <xsl:when test="$monthnum = 7">Juli</xsl:when>
            <xsl:when test="$monthnum = 8">Augustus</xsl:when>
            <xsl:when test="$monthnum = 9">September</xsl:when>
            <xsl:when test="$monthnum = 10">Oktober</xsl:when>
            <xsl:when test="$monthnum = 11">November</xsl:when>
            <xsl:when test="$monthnum = 12">December</xsl:when>
         </xsl:choose>
      </xsl:variable>
      <xsl:variable name="casedMonthName"
                    as="xs:string?">
         <xsl:choose>
            <xsl:when test="$case = 'high'">
               <xsl:value-of select="upper-case($fullMonthName)"/>
            </xsl:when>
            <xsl:when test="$case = 'firstcap'">
               <xsl:value-of select="$fullMonthName"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="lower-case($fullMonthName)"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:choose>
         <xsl:when test="string-length($casedMonthName) = 0"/>
         <xsl:when test="$length gt 0">
            <xsl:choose>
               <xsl:when test="$length = 3 and $monthnum = 3">
                  <!-- maart in drie karakters, de afkorting 'maa' vind ik raar, maar dat kan aan mij liggen -->
                  <xsl:value-of select="'mar'"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="substring($casedMonthName, 1, $length)"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="$casedMonthName"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <!-- Takes an inputTime as string or time and outputs the time in format ' 14:32' (24 hour clock) -->
   <xsl:function name="nf:formatTime"
                 as="xs:string?">
      <xsl:param name="inputTime"/>
      <xsl:param name="output0time"
                 as="xs:boolean?">
         <!-- boolean to either output the time smaller than or equal to 00:00:29 or not. Default = true = output the zero-time -->
      </xsl:param>
      <xsl:if test="$inputTime castable as xs:time">
         <xsl:choose>
            <xsl:when test="not(exists($output0time)) or $output0time">
               <xsl:value-of select="format-time(xs:time($inputTime), ' [H01]:[m01]')"/>
            </xsl:when>
            <xsl:when test="xs:time($inputTime) gt xs:time('00:00:29')">
               <xsl:value-of select="format-time(xs:time($inputTime), ' [H01]:[m01]')"/>
            </xsl:when>
         </xsl:choose>
      </xsl:if>
   </xsl:function>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <!-- Returns the most specific G-standaard oid based on a collection of product codes -->
   <xsl:function name="nf:get-main-gstd-level"
                 as="xs:string?">
      <xsl:param name="productCode"
                 as="element()*">
         <!-- Input param for ada product_code element -->
      </xsl:param>
      <xsl:choose>
         <xsl:when test="$productCode[@codeSystem = $oidGStandaardZInummer]">
            <xsl:value-of select="$oidGStandaardZInummer"/>
         </xsl:when>
         <xsl:when test="$productCode[@codeSystem = $oidGStandaardHPK]">
            <xsl:value-of select="$oidGStandaardHPK"/>
         </xsl:when>
         <xsl:when test="$productCode[@codeSystem = $oidGStandaardPRK]">
            <xsl:value-of select="$oidGStandaardPRK"/>
         </xsl:when>
         <xsl:when test="$productCode[@codeSystem = $oidGStandaardGPK]">
            <xsl:value-of select="$oidGStandaardGPK"/>
         </xsl:when>
         <xsl:when test="$productCode[@codeSystem = $oidGStandaardSSK]">
            <xsl:value-of select="$oidGStandaardSSK"/>
         </xsl:when>
         <xsl:when test="$productCode[@codeSystem = $oidGStandaardSNK]">
            <xsl:value-of select="$oidGStandaardSNK"/>
         </xsl:when>
      </xsl:choose>
   </xsl:function>
</xsl:stylesheet>