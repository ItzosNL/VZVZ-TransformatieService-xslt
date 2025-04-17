<?xml version="1.0" encoding="UTF-8"?>

<!-- == Provenance: YATC-internal/hl7-2-ada/env/mp/mp-handle-bouwstenen.xsl == -->
<!-- == Distribution: MP9-Medicatieproces-9.3.0; 1.0.10; 2025-04-16T18:06:20.52+02:00 == -->
<xsl:stylesheet exclude-result-prefixes="#all"
                version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:f="http://hl7.org/fhir"
                xmlns:yatcs="https://nictiz.nl/ns/YATC-shared"
                xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
                xmlns:local="#local.2024120415184442653180100"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:hl7="urn:hl7-org:v3"
                xmlns:util="urn:hl7:utilities"
                xmlns:sdtc="urn:hl7-org:sdtc"
                xmlns:nf="http://www.nictiz.nl/functions"
                xmlns:hl7nl="urn:hl7-nl:v3"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:pharm="urn:ihe:pharm:medication">
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
   <xsl:output method="xml"
               indent="yes"/>
   <!-- ================================================================== -->
   <xsl:template match="medicamenteuze_behandeling[not(following-sibling::medicamenteuze_behandeling)][not(@datatype = 'reference')]"
                 mode="deduplicateBouwstenenStep1">
      <!-- Bouwstenen are directly after the last medicamenteuze_behandeling -->
      <xsl:copy>
         <xsl:apply-templates select="node() | @*"
                              mode="deduplicateBouwstenenStep1"/>
      </xsl:copy>
      <bouwstenen>
         <!-- contactpersoon -->
         <xsl:variable name="concactpersonen"
                       select="../medicamenteuze_behandeling//contactpersoon"/>
         <xsl:variable name="uniekePersonen"
                       as="element()*">
            <xsl:for-each-group select="$concactpersonen"
                                group-by="nf:getGroupingKeyDefaulthl72ada(.)">
               <uniek-persoon>
                  <group-key>
                     <xsl:value-of select="current-grouping-key()"/>
                  </group-key>
                  <xsl:copy-of select="."/>
               </uniek-persoon>
            </xsl:for-each-group>
         </xsl:variable>
         <xsl:for-each select="$uniekePersonen">
            <contactpersoon id="{contactpersoon/@id}">
               <key>
                  <xsl:value-of select="group-key/text()"/>
               </key>
               <xsl:apply-templates select="contactpersoon/*"
                                    mode="deduplicateBouwstenenStep1"/>
            </contactpersoon>
         </xsl:for-each>
         <!-- farmaceutisch_product -->
         <xsl:variable name="farmaceutischeProducten"
                       select="../medicamenteuze_behandeling//farmaceutisch_product"/>
         <xsl:variable name="uniekeProducten"
                       as="element()*">
            <xsl:for-each-group select="$farmaceutischeProducten"
                                group-by="nf:getGroupingKeyDefaulthl72ada(.)">
               <uniek-product>
                  <group-key>
                     <xsl:value-of select="current-grouping-key()"/>
                  </group-key>
                  <xsl:copy-of select="."/>
               </uniek-product>
            </xsl:for-each-group>
         </xsl:variable>
         <xsl:for-each select="$uniekeProducten">
            <farmaceutisch_product id="{farmaceutisch_product/@id}">
               <key>
                  <xsl:value-of select="group-key/text()"/>
               </key>
               <xsl:apply-templates select="farmaceutisch_product/*"
                                    mode="deduplicateBouwstenenStep1"/>
            </farmaceutisch_product>
         </xsl:for-each>
         <!-- zorgverlener -->
         <xsl:variable name="zorgverleners"
                       select="../(medicamenteuze_behandeling | voorstel_gegevens)//zorgverlener[not(zorgverlener)]"/>
         <xsl:variable name="uniekezorgverleners"
                       as="element()*">
            <xsl:for-each-group select="$zorgverleners"
                                group-by="nf:getGroupingKeyDefaulthl72ada(.)">
               <uniek-zorgverlener>
                  <group-key>
                     <xsl:value-of select="current-grouping-key()"/>
                  </group-key>
                  <xsl:copy-of select="."/>
               </uniek-zorgverlener>
            </xsl:for-each-group>
         </xsl:variable>
         <xsl:for-each select="$uniekezorgverleners">
            <zorgverlener id="{zorgverlener/@id}">
               <key>
                  <xsl:value-of select="group-key/text()"/>
               </key>
               <xsl:apply-templates select="zorgverlener/*"
                                    mode="deduplicateBouwstenenStep1"/>
            </zorgverlener>
         </xsl:for-each>
         <!-- zorgaanbieder -->
         <xsl:variable name="zorgaanbieders"
                       select="../(medicamenteuze_behandeling | voorstel_gegevens)//zorgaanbieder[not(zorgaanbieder)]"/>
         <xsl:variable name="uniekeZorgaanbieders"
                       as="element()*">
            <xsl:for-each-group select="$zorgaanbieders"
                                group-by="nf:getGroupingKeyDefaulthl72ada(.)">
               <uniek-zorgaanbieder>
                  <group-key>
                     <xsl:value-of select="current-grouping-key()"/>
                  </group-key>
                  <xsl:copy-of select="."/>
               </uniek-zorgaanbieder>
            </xsl:for-each-group>
         </xsl:variable>
         <xsl:for-each select="$uniekeZorgaanbieders">
            <zorgaanbieder id="{zorgaanbieder/@id}">
               <key>
                  <xsl:value-of select="group-key/text()"/>
               </key>
               <xsl:apply-templates select="zorgaanbieder/*"
                                    mode="deduplicateBouwstenenStep1"/>
            </zorgaanbieder>
         </xsl:for-each>
         <!-- copy existing bouwstenen as well, should only be lichaamsgewicht / lichaamslengte -->
         <xsl:apply-templates select="../bouwstenen/*"
                              mode="deduplicateBouwstenenStep1"/>
      </bouwstenen>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="voorstel_gegevens[not(preceding-sibling::medicamenteuze_behandeling)]"
                 mode="deduplicateBouwstenenStep1">
      <!-- Bouwstenen are directly before voorstel_gegevens that were not handled with medicamenteuze_behandeling -->
      <bouwstenen>
         <!-- zorgverlener -->
         <xsl:variable name="zorgverleners"
                       select="*//zorgverlener[not(zorgverlener)]"/>
         <xsl:variable name="uniekezorgverleners"
                       as="element()*">
            <xsl:for-each-group select="$zorgverleners"
                                group-by="nf:getGroupingKeyDefaulthl72ada(.)">
               <uniek-zorgverlener>
                  <group-key>
                     <xsl:value-of select="current-grouping-key()"/>
                  </group-key>
                  <xsl:copy-of select="."/>
               </uniek-zorgverlener>
            </xsl:for-each-group>
         </xsl:variable>
         <xsl:for-each select="$uniekezorgverleners">
            <zorgverlener id="{zorgverlener/@id}">
               <key>
                  <xsl:value-of select="group-key/text()"/>
               </key>
               <xsl:apply-templates select="zorgverlener/*"
                                    mode="deduplicateBouwstenenStep1"/>
            </zorgverlener>
         </xsl:for-each>
         <!-- zorgaanbieder -->
         <xsl:variable name="zorgaanbieders"
                       select="*//zorgaanbieder[not(zorgaanbieder)]"/>
         <xsl:variable name="uniekeZorgaanbieders"
                       as="element()*">
            <xsl:for-each-group select="$zorgaanbieders"
                                group-by="nf:getGroupingKeyDefaulthl72ada(.)">
               <uniek-zorgaanbieder>
                  <group-key>
                     <xsl:value-of select="current-grouping-key()"/>
                  </group-key>
                  <xsl:copy-of select="."/>
               </uniek-zorgaanbieder>
            </xsl:for-each-group>
         </xsl:variable>
         <xsl:for-each select="$uniekeZorgaanbieders">
            <zorgaanbieder id="{zorgaanbieder/@id}">
               <key>
                  <xsl:value-of select="group-key/text()"/>
               </key>
               <xsl:apply-templates select="zorgaanbieder/*"
                                    mode="deduplicateBouwstenenStep1"/>
            </zorgaanbieder>
         </xsl:for-each>
      </bouwstenen>
      <xsl:copy>
         <xsl:apply-templates select="node() | @*"
                              mode="deduplicateBouwstenenStep1"/>
      </xsl:copy>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="data/*/bouwstenen"
                 mode="deduplicateBouwstenenStep1">
      <!-- Do not copy any original bouwstenen, should there have been bouwstenen they were copied in the template that handles creating the bouwsten directly after the last medicamenteuze_behandeling -->
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="bouwstenen/zorgverlener"
                 mode="deduplicateBouwstenenStep2">
      <!-- zorgverlener has a bouwstenen reference to zorgaanbieder, some special handling here in deduplication step 2 -->
      <xsl:copy>
         <xsl:apply-templates select="@*"
                              mode="deduplicateBouwstenenStep2"/>
         <xsl:apply-templates select="*[not(self::zorgaanbieder)]"
                              mode="deduplicateBouwstenenStep2"/>
         <xsl:for-each select="zorgaanbieder">
            <xsl:copy>
               <!-- double nested in the dataset, unfortunately -->
               <zorgaanbieder>
                  <xsl:attribute name="value">
                     <xsl:value-of select="ancestor::data/*/bouwstenen/*[key/text() = nf:getGroupingKeyDefaulthl72ada(current())]/@id"/>
                  </xsl:attribute>
                  <xsl:attribute name="datatype">reference</xsl:attribute>
               </zorgaanbieder>
            </xsl:copy>
         </xsl:for-each>
      </xsl:copy>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="bouwstenen/*/key"
                 mode="deduplicateBouwstenenStep2">
      <!--  get rid of the now (in step 2) obsolete temporary deduplication key, don't want it in the end result ada xml  -->
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="medicamenteuze_behandeling//farmaceutisch_product | medicamenteuze_behandeling//contactpersoon | medicamenteuze_behandeling//zorgaanbieder[not(zorgaanbieder)] | voorstel_gegevens//zorgaanbieder[not(zorgaanbieder)] | medicamenteuze_behandeling//zorgverlener[not(zorgverlener)] | voorstel_gegevens//zorgverlener[not(zorgverlener)] | voorstel_gegevens/medicamenteuze_behandeling"
                 mode="deduplicateBouwstenenStep2">
      <!-- Find the correct reference in the deduplication mode in step 2  -->
      <xsl:copy>
         <xsl:apply-templates select="@conceptId"
                              mode="#current"/>
         <xsl:attribute name="value">
            <xsl:value-of select="ancestor::data/*/bouwstenen/*[key/text() = nf:getGroupingKeyDefaulthl72ada(current())]/@id"/>
         </xsl:attribute>
         <xsl:attribute name="datatype">reference</xsl:attribute>
      </xsl:copy>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="medicamenteuze_behandeling[not(following-sibling::medicamenteuze_behandeling)][not(@datatype = 'reference')]"
                 mode="handleBouwstenen">
      <!-- Bouwstenen are directly after the last medicamenteuze_behandeling -->
      <xsl:copy>
         <xsl:apply-templates select="node() | @*"
                              mode="handleBouwstenen"/>
      </xsl:copy>
      <bouwstenen>
         <xsl:apply-templates select="../medicamenteuze_behandeling//contactpersoon"
                              mode="addBouwstenen"/>
         <xsl:apply-templates select="../medicamenteuze_behandeling//farmaceutisch_product"
                              mode="addBouwstenen"/>
         <!-- zorgverlener has a bouwstenen reference to zorgaanbieder, some special handling here -->
         <xsl:for-each select="../(medicamenteuze_behandeling | voorstel_gegevens)//zorgverlener[not(zorgverlener)]">
            <xsl:copy>
               <xsl:apply-templates select="@*"
                                    mode="addBouwstenen"/>
               <xsl:apply-templates select="*[not(self::zorgaanbieder | self::zorgverlener_rol)]"
                                    mode="addBouwstenen"/>
               <xsl:for-each select="zorgaanbieder">
                  <xsl:copy>
                     <!-- double nested in the dataset, unfortunately -->
                     <zorgaanbieder>
                        <xsl:attribute name="datatype">reference</xsl:attribute>
                        <xsl:attribute name="value"
                                       select="@id"/>
                     </zorgaanbieder>
                  </xsl:copy>
               </xsl:for-each>
               <xsl:apply-templates select="zorgverlener_rol"
                                    mode="addBouwstenen"/>
            </xsl:copy>
         </xsl:for-each>
         <xsl:for-each select="../(medicamenteuze_behandeling | voorstel_gegevens)//zorgaanbieder[not(zorgaanbieder)]">
            <xsl:copy>
               <xsl:apply-templates select="node() | @*"
                                    mode="addBouwstenen"/>
            </xsl:copy>
         </xsl:for-each>
         <!-- copy existing bouwstenen as well, should only be lichaamsgewicht / lichaamslengte -->
         <xsl:apply-templates select="../bouwstenen/*"
                              mode="addBouwstenen"/>
      </bouwstenen>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="voorstel_gegevens[not(preceding-sibling::medicamenteuze_behandeling)]"
                 mode="handleBouwstenen">
      <!-- Handle bouwstenen for voorstel_gegevens without medicamenteuze_behandeling -->
      <bouwstenen>
         <!-- zorgverlener has a bouwstenen reference to zorgaanbieder, some special handling here -->
         <xsl:for-each select="*/auteur//zorgverlener[not(zorgverlener)]">
            <xsl:copy>
               <xsl:apply-templates select="@*"
                                    mode="addBouwstenen"/>
               <xsl:apply-templates select="*[not(self::zorgaanbieder | self::zorgverlener_rol)]"
                                    mode="addBouwstenen"/>
               <xsl:for-each select="zorgaanbieder">
                  <xsl:copy>
                     <!-- double nested in the dataset, unfortunately -->
                     <zorgaanbieder>
                        <xsl:attribute name="datatype">reference</xsl:attribute>
                        <xsl:attribute name="value"
                                       select="@id"/>
                     </zorgaanbieder>
                  </xsl:copy>
               </xsl:for-each>
               <xsl:apply-templates select="zorgverlener_rol"
                                    mode="addBouwstenen"/>
            </xsl:copy>
         </xsl:for-each>
         <xsl:for-each select="*//zorgaanbieder">
            <xsl:copy>
               <xsl:apply-templates select="node() | @*"
                                    mode="addBouwstenen"/>
            </xsl:copy>
         </xsl:for-each>
      </bouwstenen>
      <!-- now output the voorstel_gegevens -->
      <xsl:copy>
         <xsl:apply-templates select="node() | @*"
                              mode="#current"/>
      </xsl:copy>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="toediener/mantelzorger/contactpersoon | voorschrijver/zorgverlener | auteur/zorgverlener | auteur_is_zorgverlener/zorgverlener | toediener//zorgverlener[not(zorgverlener)] | toediener[not(.//zorgverlener)]//zorgaanbieder[not(zorgaanbieder)] | farmaceutisch_product | beoogd_verstrekker/zorgaanbieder | verstrekker/zorgaanbieder | auteur_is_zorgaanbieder[not(ancestor::documentgegevens)]/zorgaanbieder"
                 mode="handleBouwstenen">
      <!-- Make a reference to the bouwstenen -->
      <xsl:copy>
         <xsl:attribute name="datatype">reference</xsl:attribute>
         <xsl:attribute name="value"
                        select="@id"/>
      </xsl:copy>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="telecom_type[@codeSystem = $oidHL7NullFlavor]"
                 mode="handleBouwstenen">
      <!-- Do not output telecom_type when nullFlavor in handleBouwstenen, it is officially not in  ada dataset anyway -->
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="documentgegevens/auteur/auteur_is_zorgaanbieder/zorgaanbieder/@id"
                 mode="handleBouwstenen">
      <!-- Do not output documentgegevens/auteur/auteur_is_zorgaanbieder/zorgaanbieder/@id in handleBouwstenen, unlike other zorgaanbieders, this is not a reference in the ada dataset -->
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="bouwstenen"
                 mode="handleBouwstenen">
      <!-- Do not output bouwstenen and voorstel_gegevens (again) in handleBouwstenen, those are completely handled in the template that handles medicamenteuze_behandeling -->
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="zorgverlener/zorgaanbieder"
                 mode="addBouwstenen">
      <!-- Make a reference to the bouwstenen -->
      <xsl:copy>
         <xsl:attribute name="datatype">reference</xsl:attribute>
         <xsl:attribute name="value"
                        select="@id"/>
      </xsl:copy>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="node() | @*"
                 mode="addBouwstenen deduplicateBouwstenenStep1 deduplicateBouwstenenStep2 handleBouwstenen">
      <!-- Default copy template for all modes -->
      <xsl:copy>
         <xsl:apply-templates select="node() | @*"
                              mode="#current"/>
      </xsl:copy>
   </xsl:template>
</xsl:stylesheet>