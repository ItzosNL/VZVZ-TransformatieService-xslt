<?xml version="1.0" encoding="UTF-8"?>

<!-- == Provenance: YATC-internal/ada-2-fhir-r4/env/fhir/2_fhir_BundleEntrySearch.xsl == -->
<!-- == Distribution: MP9-Medicatieproces-9.3.0; 1.0.10; 2025-04-16T18:06:20.52+02:00 == -->
<xsl:stylesheet exclude-result-prefixes="#all"
                version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://hl7.org/fhir"
                xmlns:f="http://hl7.org/fhir"
                xmlns:nf="http://www.nictiz.nl/functions"
                xmlns:yatcs="https://nictiz.nl/ns/YATC-shared"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
                xmlns:uuid="http://www.uuid.org"
                xmlns:local="urn:fhir:stu3:functions"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
   <!-- ================================================================== -->
   <!--
        Template for Bundle.entry.request
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
   <xsl:param name="searchMode"
              as="xs:string?">match</xsl:param>
   <!-- ================================================================== -->
   <xsl:template match="f:resource"
                 mode="addBundleEntrySearchOrRequest">
      <!-- Add Bundle.entry.request -->
      <!-- AWE: need to distinguish between match and include, which can only be done when invoking this template, so set this param here if needed -->
      <xsl:param name="entrySearchMode"
                 select="$searchMode">
         <!-- param to override global param in case a different search mode is needed for a particular entry. 
            Typically not all resources in a Bundle have the same searchMode. Defaults to global param $searchMode -->
      </xsl:param>
      <xsl:copy>
         <xsl:apply-templates select="@* | node()"
                              mode="#current"/>
      </xsl:copy>
      <xsl:if test="string-length($entrySearchMode) gt 0">
         <search>
            <mode value="{$entrySearchMode}"/>
         </search>
      </xsl:if>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="@* | node()"
                 mode="addBundleEntrySearchOrRequest">
      <!-- Basis copy template in mode addBundleEntrySearchOrRequest -->
      <xsl:param name="entrySearchMode"
                 select="$searchMode">
         <!-- param to override global param in case a different search mode is needed for a particular entry. 
            Typically not all resources in a Bundle have the same searchMode. Defaults to global param $searchMode -->
      </xsl:param>
      <xsl:copy>
         <xsl:apply-templates select="@* | node()"
                              mode="#current">
            <xsl:with-param name="entrySearchMode"
                            select="$entrySearchMode"/>
         </xsl:apply-templates>
      </xsl:copy>
   </xsl:template>
</xsl:stylesheet>