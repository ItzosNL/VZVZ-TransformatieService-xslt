<?xml version="1.0" encoding="UTF-8"?>

<!-- == Provenance: YATC-shared/xsl/util/mp-4testinstances.xsl == -->
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
   <!-- XSL meant to override templates and functions specifically only needed for test instances, 
    this means stuff like generating usage instruction text based on structured fields and
    functionality for configurable dates (date T) -->
   <!-- give dateT a value when you need conversion of relative T dates, typically only needed for test instances -->
   <!--    <xsl:param name="dateT" as="xs:date?" select="current-date()"/>-->
   <xsl:param name="dateT"
              as="xs:date?"/>
   <!-- wether to generate the instruction text based on structured fields, typically only true for test instances  -->
   <xsl:param name="generateInstructionText"
              as="xs:boolean?"
              select="false()"/>
   <!-- ================================================================== -->
   <!-- Function to create a nice dosage string based on the structured input. -->
   <xsl:function name="nf:dosering-string"
                 as="xs:string">
      <xsl:param name="inDoseerinstructie"
                 as="element()?">
         <!-- Input ada element doseerinstructie -->
      </xsl:param>
      <xsl:param name="amount-doseerinstructies"
                 as="xs:integer">
         <!-- The number of doseerinstructies, this is needed to help create order in the doseringsstring -->
      </xsl:param>
      <xsl:param name="non-parallel-doseerinstructie"
                 as="xs:boolean?">
         <!-- Whether a non-parallel (i.e. with different sequence number) doseerinstructie exists -->
      </xsl:param>
      <xsl:for-each select="$inDoseerinstructie">
         <xsl:variable name="doseerduur-string"
                       as="xs:string*">
            <xsl:choose>
               <xsl:when test="$amount-doseerinstructies gt 1">
                  <xsl:choose>
                     <xsl:when test="not(volgnummer/@value)"/>
                     <xsl:when test="volgnummer/@value = 1 and $non-parallel-doseerinstructie">eerst </xsl:when>
                     <xsl:when test="$non-parallel-doseerinstructie">dan </xsl:when>
                  </xsl:choose>
               </xsl:when>
            </xsl:choose>
            <xsl:if test="doseerduur[@value]">
               <xsl:value-of select="concat('gedurende ', doseerduur/@value, ' ', nwf:unit-string(doseerduur/@value, doseerduur/@unit))"/>
            </xsl:if>
         </xsl:variable>
         <xsl:variable name="dosering-string"
                       as="xs:string*">
            <xsl:choose>
               <xsl:when test="not(dosering[.//(@value | @code | @nullFlavor)])">pauze</xsl:when>
               <xsl:otherwise>
                  <xsl:for-each select="dosering">
                     <xsl:variable name="zo-nodig"
                                   as="xs:string*">
                        <xsl:value-of select="zo_nodig/(criterium | criterium/(code | criterium))/@displayName"/>
                     </xsl:variable>
                     <xsl:variable name="frequentie"
                                   select="toedieningsschema/frequentie[.//(@value | @code)]"/>
                     <xsl:variable name="frequentie-string"
                                   as="xs:string*">
                        <xsl:choose>
                           <!-- vaste waarde -->
                           <xsl:when test="$frequentie/aantal/(vaste_waarde | nominale_waarde)[@value]">
                              <xsl:value-of select="$frequentie/aantal/(vaste_waarde | nominale_waarde)/@value"/>
                           </xsl:when>
                           <!-- min/max -->
                           <xsl:when test="$frequentie/aantal/(min | minimum_waarde | max | maximum_waarde)[@value]">
                              <xsl:if test="$frequentie/aantal/(min | minimum_waarde)/@value and not($frequentie/aantal/(max | maximum_waarde)/@value)">minimaal </xsl:if>
                              <xsl:if test="$frequentie/aantal/(max | maximum_waarde)/@value and not($frequentie/aantal/(min | minimum_waarde)/@value)">maximaal </xsl:if>
                              <xsl:if test="$frequentie/aantal/(min | minimum_waarde)/@value">
                                 <xsl:value-of select="$frequentie/aantal/(min | minimum_waarde)/@value"/>
                              </xsl:if>
                              <xsl:if test="$frequentie/aantal/(min | minimum_waarde)/@value and $frequentie/aantal/(max | maximum_waarde)/@value"> à </xsl:if>
                              <xsl:if test="$frequentie/aantal/(max | maximum_waarde)/@value">
                                 <xsl:value-of select="$frequentie/aantal/(max | maximum_waarde)/@value"/>
                              </xsl:if>
                           </xsl:when>
                        </xsl:choose>
                        <xsl:choose>
                           <xsl:when test="not($frequentie)"/>
                           <xsl:when test="not($frequentie/tijdseenheid/@value)">keer</xsl:when>
                           <xsl:otherwise>
                              <xsl:variable name="frequentie-value">
                                 <xsl:if test="$frequentie/tijdseenheid/@value castable as xs:float and xs:float($frequentie/tijdseenheid/@value) ne 1">
                                    <xsl:value-of select="concat($frequentie/tijdseenheid/@value, ' ')"/>
                                 </xsl:if>
                              </xsl:variable>
                              <xsl:value-of select="concat('maal per ', $frequentie-value, nwf:unit-string($frequentie/tijdseenheid/@value, $frequentie/tijdseenheid/@unit))"/>
                           </xsl:otherwise>
                        </xsl:choose>
                     </xsl:variable>
                     <xsl:variable name="interval"
                                   select="toedieningsschema/interval[(@value | @unit)]"/>
                     <xsl:variable name="interval-string"
                                   as="xs:string?">
                        <xsl:if test="$interval">
                           <xsl:value-of select="concat('iedere ', $interval/@value, ' ', nwf:unit-string($interval/@value, $interval/@unit))"/>
                        </xsl:if>
                     </xsl:variable>
                     <xsl:variable name="toedientijd"
                                   select="toedieningsschema/toedientijd[@value]"/>
                     <xsl:variable name="toedientijd-string"
                                   as="xs:string*">
                        <xsl:choose>
                           <xsl:when test="count($toedientijd) = 1">
                              <xsl:if test="not($frequentie) and not(toedieningsschema/weekdag[@value | @code])">elke dag</xsl:if>
                              <xsl:value-of select="'om'"/>
                              <xsl:value-of select="string-join(nf:datetime-2-timestring($toedientijd[1]/@value), ', ')"/>
                           </xsl:when>
                           <xsl:when test="$toedientijd">
                              <xsl:if test="not($frequentie) and not(toedieningsschema/weekdag[@value | @code])">elke dag</xsl:if>
                              <xsl:value-of select="'om'"/>
                              <xsl:value-of select="string-join($toedientijd[position() lt last()]/nf:datetime-2-timestring(@value), ', ')"/>
                              <xsl:if test="count($toedientijd) gt 1">
                                 <xsl:value-of select="concat(' en ', $toedientijd[last()]/nf:datetime-2-timestring(@value))"/>
                              </xsl:if>
                           </xsl:when>
                        </xsl:choose>
                     </xsl:variable>
                     <xsl:variable name="toedieningssnelheid"
                                   select="toedieningssnelheid[.//(@value | @code | @unit)]"/>
                     <xsl:variable name="toedieningssnelheid-string"
                                   as="xs:string*">
                        <xsl:if test="$toedieningssnelheid">
                           <xsl:value-of select="'toedieningssnelheid: '"/>
                        </xsl:if>
                        <xsl:choose>
                           <!-- vaste waarde -->
                           <xsl:when test="$toedieningssnelheid/(nominale_waarde | waarde/(vaste_waarde | nominale_waarde))[@value]">
                              <xsl:value-of select="$toedieningssnelheid/(nominale_waarde | waarde/(vaste_waarde | nominale_waarde))/@value"/>
                           </xsl:when>
                           <!-- min/max -->
                           <xsl:when test="$toedieningssnelheid/(minimum_waarde | maximum_waarde | waarde/(min | minimum_waarde | max | maximum_waarde))[@value]">
                              <xsl:if test="$toedieningssnelheid/(minimum_waarde | waarde/(min | minimum_waarde))/@value and not($toedieningssnelheid/(maximum_waarde | waarde/(max | maximum_waarde))/@value)">minimaal </xsl:if>
                              <xsl:if test="$toedieningssnelheid/(maximum_waarde | waarde/(max | maximum_waarde))/@value and not($toedieningssnelheid/(minimum_waarde | waarde/(min | minimum_waarde))/@value)">maximaal </xsl:if>
                              <xsl:if test="$toedieningssnelheid/(minimum_waarde | waarde/(min | minimum_waarde))/@value">
                                 <xsl:value-of select="$toedieningssnelheid/(minimum_waarde | waarde/(min | minimum_waarde))/@value"/>
                              </xsl:if>
                              <xsl:if test="$toedieningssnelheid/(minimum_waarde | waarde/(min | minimum_waarde))/@value and $toedieningssnelheid/(maximum_waarde | waarde/(max | maximum_waarde))/@value"> à </xsl:if>
                              <xsl:if test="$toedieningssnelheid/(maximum_waarde | waarde/(max | maximum_waarde))/@value">
                                 <xsl:value-of select="$toedieningssnelheid/(maximum_waarde | waarde/(max | maximum_waarde))/@value"/>
                              </xsl:if>
                           </xsl:when>
                        </xsl:choose>
                        <xsl:if test="$toedieningssnelheid">
                           <xsl:choose>
                              <xsl:when test="$toedieningssnelheid[not(tijdseenheid)][not(eenheid)]/*[@value][@unit]">
                                 <!-- new dataset structure in MP9 3.0.0-beta.4, now same as zib -->
                                 <xsl:value-of select="distinct-values($toedieningssnelheid/(nominale_waarde|minimum_waarde|maximum_waarde)[@value]/normalize-space(@unit))"/>
                              </xsl:when>
                              <xsl:when test="$toedieningssnelheid[not(tijdseenheid)][eenheid[@unit][not(@value) or @value = '1']]">
                                 <!-- dataset structure in MP9 3.0.0-beta.3 -->
                                 <xsl:value-of select="$toedieningssnelheid/eenheid/@unit"/>
                              </xsl:when>
                              <xsl:when test="$toedieningssnelheid[tijdseenheid][eenheid[@displayName]]">
                                 <!-- previous 3.0-beta.3 structure -->
                                 <xsl:variable name="unitString"
                                               as="xs:string?">
                                    <xsl:choose>
                                       <xsl:when test="$toedieningssnelheid[tijdseenheid]/tijdseenheid/@value ne '1'">
                                          <xsl:value-of select="concat($toedieningssnelheid/tijdseenheid/@value, ' ', nwf:unit-string($toedieningssnelheid/tijdseenheid/@value, $toedieningssnelheid/tijdseenheid/@unit))"/>
                                       </xsl:when>
                                       <xsl:when test="$toedieningssnelheid[tijdseenheid[@value or @unit]]">
                                          <xsl:value-of select="concat('', nwf:unit-string($toedieningssnelheid/tijdseenheid/@value, $toedieningssnelheid/tijdseenheid/@unit))"/>
                                       </xsl:when>
                                    </xsl:choose>
                                 </xsl:variable>
                                 <xsl:value-of select="concat(nwf:unit-string(1, $toedieningssnelheid/eenheid/@displayName), ' per ', $unitString)"/>
                              </xsl:when>
                              <xsl:otherwise>
                                 <xsl:call-template name="util:logMessage">
                                    <xsl:with-param name="level"
                                                    select="$logERROR"/>
                                    <xsl:with-param name="msg">Encountered a toedieningssnelheid with an unknown structure. Please investigate. We'll still do an attempt to output something sensible, probably in vain.</xsl:with-param>
                                 </xsl:call-template>
                                 <!-- not a clue what's going on, let's do our best to output something -->
                                 <xsl:variable name="unitString"
                                               as="xs:string?">
                                    <xsl:choose>
                                       <xsl:when test="$toedieningssnelheid[tijdseenheid]/tijdseenheid/@value ne '1'">
                                          <xsl:value-of select="concat($toedieningssnelheid/tijdseenheid/@value, ' ', nwf:unit-string($toedieningssnelheid/tijdseenheid/@value, $toedieningssnelheid/tijdseenheid/@unit))"/>
                                       </xsl:when>
                                       <xsl:when test="$toedieningssnelheid[tijdseenheid[@value or @unit]]">
                                          <xsl:value-of select="concat('', nwf:unit-string($toedieningssnelheid/tijdseenheid/@value, $toedieningssnelheid/tijdseenheid/@unit))"/>
                                       </xsl:when>
                                    </xsl:choose>
                                 </xsl:variable>
                                 <xsl:value-of select="concat(nwf:unit-string(1, string-join($toedieningssnelheid/eenheid/@*[name()!='conceptId'], ' ')), ' per ', $unitString)"/>
                              </xsl:otherwise>
                           </xsl:choose>
                        </xsl:if>
                     </xsl:variable>
                     <xsl:variable name="toedieningsduur"
                                   select="(toedieningsduur | toedieningsduur/tijds_duur)[(@value | @unit)]"/>
                     <xsl:variable name="toedieningsduur-string"
                                   as="xs:string?">
                        <xsl:if test="$toedieningsduur">
                           <xsl:value-of select="concat('gedurende ', $toedieningsduur/@value, ' ', nwf:unit-string($toedieningsduur/@value, $toedieningsduur/@unit))"/>
                        </xsl:if>
                     </xsl:variable>
                     <xsl:variable name="weekdag"
                                   select="./toedieningsschema/weekdag[.//(@value | @code)]"/>
                     <xsl:variable name="weekdag-string"
                                   as="xs:string*">
                        <xsl:if test="$weekdag">op </xsl:if>
                        <xsl:value-of select="string-join($weekdag[position() lt last()]/@displayName, ', ')"/>
                        <xsl:if test="count($weekdag) gt 1">en </xsl:if>
                        <xsl:value-of select="$weekdag[last()]/@displayName"/>
                     </xsl:variable>
                     <xsl:variable name="keerdosis"
                                   select="./keerdosis"/>
                     <xsl:variable name="keerdosis-string"
                                   as="xs:string*">
                        <xsl:choose>
                           <!-- vaste waarde -->
                           <xsl:when test="$keerdosis/aantal/(vaste_waarde | nominale_waarde)[@value]">
                              <xsl:value-of select="$keerdosis/aantal/(vaste_waarde | nominale_waarde)/@value"/>
                           </xsl:when>
                           <!-- min/max -->
                           <xsl:when test="$keerdosis/aantal/(min | minimum_waarde | max | maximum_waarde)[@value]">
                              <xsl:if test="$keerdosis/aantal/(min | minimum_waarde)/@value and not($keerdosis/aantal/(max | maximum_waarde)/@value)">minimaal</xsl:if>
                              <xsl:if test="$keerdosis/aantal/(max | maximum_waarde)/@value and not($keerdosis/aantal/(min | minimum_waarde)/@value)">maximaal</xsl:if>
                              <xsl:if test="$keerdosis/aantal/(min | minimum_waarde)/@value">
                                 <xsl:value-of select="$keerdosis/aantal/(min | minimum_waarde)/@value"/>
                              </xsl:if>
                              <xsl:if test="$keerdosis/aantal/(min | minimum_waarde)/@value and $keerdosis/aantal/(max | maximum_waarde)/@value"> à </xsl:if>
                              <xsl:if test="$keerdosis/aantal/(max | maximum_waarde)/@value">
                                 <xsl:value-of select="$keerdosis/aantal/(max | maximum_waarde)/@value"/>
                              </xsl:if>
                           </xsl:when>
                        </xsl:choose>
                        <xsl:variable name="max-aantal"
                                      select="max($keerdosis/aantal/(min | minimum_waarde | vaste_waarde | nominale_waarde | max | maximum_waarde)/@value)"/>
                        <xsl:value-of select="nwf:unit-string($max-aantal, $keerdosis/eenheid/@displayName)"/>
                     </xsl:variable>
                     <xsl:variable name="dagdeel"
                                   select="toedieningsschema/dagdeel[.//(@value | @code)]"/>
                     <xsl:variable name="dagdeel-string"
                                   as="xs:string*">
                        <xsl:value-of select="string-join($dagdeel[position() lt last()]/@displayName, ', ')"/>
                        <xsl:if test="count($dagdeel) gt 1">en </xsl:if>
                        <xsl:value-of select="$dagdeel[last()]/@displayName"/>
                     </xsl:variable>
                     <xsl:variable name="maxdose"
                                   select="zo_nodig/maximale_dosering[.//(@value | @code)]"/>
                     <xsl:variable name="maxdose-string"
                                   as="xs:string*">
                        <xsl:if test="$maxdose">
                           <xsl:value-of select="', maximaal'"/>
                           <xsl:value-of select="$maxdose/aantal/@value"/>
                           <xsl:value-of select="nwf:unit-string($maxdose/aantal/@value, $maxdose/eenheid/@displayName)"/>
                           <xsl:value-of select="'per'"/>
                           <xsl:if test="$maxdose/tijdseenheid/@value ne '1'">
                              <xsl:value-of select="$maxdose/tijdseenheid/@value"/>
                           </xsl:if>
                           <xsl:value-of select="nwf:unit-string($maxdose/tijdseenheid/@value, $maxdose/tijdseenheid/@unit)"/>
                        </xsl:if>
                     </xsl:variable>
                     <xsl:variable name="isFlexible"
                                   as="xs:string?">
                        <!-- AWE, MP-515 new default text for interval -->
                        <xsl:choose>
                           <xsl:when test="$interval">- gelijke tussenpozen aanhouden</xsl:when>
                           <xsl:when test="toedieningsschema/is_flexibel/@value = 'false'">- let op, tijden exact aanhouden</xsl:when>
                        </xsl:choose>
                     </xsl:variable>
                     <xsl:value-of select="normalize-space(concat(string-join($zo-nodig, ' '), ' ', string-join($weekdag-string, ' '), ' ', string-join($frequentie-string, ' '), $interval-string, ' ', string-join($toedientijd-string, ' '), ' ', string-join($keerdosis-string, ' '), ' ', string-join($dagdeel-string, ' '), ' ', $toedieningsduur-string, ' ', string-join($toedieningssnelheid-string, ' '), string-join($maxdose-string, ' '), $isFlexible))"/>
                  </xsl:for-each>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:variable>
         <xsl:value-of select="normalize-space(concat(string-join($doseerduur-string, ' '), ' ', string-join($dosering-string, ' en ')))"/>
      </xsl:for-each>
   </xsl:function>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <!-- Outputs a human readable string for a period with a possible start, duration, end date. The actual dates may be replaced by a configurable "T"-date with an addition of subtraction of a given number of days. -->
   <xsl:function name="nf:periode-string"
                 as="xs:string?">
      <xsl:param name="start-date"
                 as="element()?">
         <!-- start date of the period -->
      </xsl:param>
      <xsl:param name="periode"
                 as="element()?">
         <!-- duration of the period -->
      </xsl:param>
      <xsl:param name="end-date"
                 as="element()?">
         <!-- end date of the period -->
      </xsl:param>
      <xsl:param name="criterium"
                 as="element()?">
         <!-- criterium of the period -->
      </xsl:param>
      <xsl:variable name="waarde"
                    as="xs:string*">
         <xsl:if test="$start-date[@value]">Vanaf 
<xsl:value-of select="nf:formatDate(nf:calculate-t-date($start-date/@value, $dateT))"/>
         </xsl:if>
         <xsl:if test="$start-date[@value] and ($periode[@value] | $end-date[@value])">
            <xsl:value-of select="', '"/>
         </xsl:if>
         <xsl:if test="$periode[@value]">gedurende 
<xsl:value-of select="concat($periode/@value, ' ', nwf:unit-string($periode/@value, $periode/@unit))"/>
         </xsl:if>
         <xsl:if test="$end-date[@value]"> tot en met 
<xsl:value-of select="nf:formatDate(nf:calculate-t-date($end-date/@value, $dateT))"/>
         </xsl:if>
         <xsl:if test="$criterium[@value]"> (
<xsl:value-of select="$criterium/@value"/>)</xsl:if>
         <!-- projectgroep wil geen tekst 'tot nader order' in omschrijving, teams app Marijke dd 30 mrt 2020 -->
         <!--                <xsl:if test="not($periode[@value]) and not($end-date[@value])"><xsl:if test="$start-date[@value]">, </xsl:if>tot nader order</xsl:if>-->
      </xsl:variable>
      <xsl:value-of select="normalize-space(string-join($waarde, ''))"/>
   </xsl:function>
</xsl:stylesheet>