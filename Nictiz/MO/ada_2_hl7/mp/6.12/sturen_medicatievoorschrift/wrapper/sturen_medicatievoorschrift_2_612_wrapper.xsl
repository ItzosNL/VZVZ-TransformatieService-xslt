<?xml version="1.0" encoding="UTF-8"?>

<!-- == Provenance: YATC-internal/ada-2-hl7/env/mp/6.12/sturen_medicatievoorschrift/wrapper/sturen_medicatievoorschrift_2_612_wrapper.xsl == -->
<!-- == Distribution: MP9-Medicatieproces-9.3.0; 1.0.10; 2025-04-16T18:06:20.52+02:00 == -->
<xsl:stylesheet version="2.0"
                exclude-result-prefixes="#all"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="urn:hl7-org:v3"
                xmlns:hl7="urn:hl7-org:v3"
                xmlns:yatcs="https://nictiz.nl/ns/YATC-shared"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:local="#local.2024011810474696534670100"
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
   <xsl:import href="../payload/sturen_medicatievoorschrift_2_612.xsl"/>
   <xsl:output method="xml"
               indent="yes"
               exclude-result-prefixes="#default"/>
   <!-- the param can be called from outside this stylesheet, if no value is provided it defaults to whatever is set in 'select' -->
   <!--    <xsl:param name="input_xml_payload" select="'../ada_instance/8ac56799-00d0-4bfc-98ad-0d6addedc5d3.xml'"/>-->
   <!--    <xsl:param name="input_xml_payload"/>-->
   <xsl:param name="input_xml_wrapper"
              select="'input_wrapper.xml'"/>
   <xsl:param name="prefixPrescriptionIdOid"
              select="'1.3.6.1.4.1.58606.1.3'"/>
   <!--    <xsl:variable name="input_xml_payload_doc" select="document($input_xml_payload)"/>-->
   <xsl:variable name="input_xml_wrapper_doc"
                 select="document($input_xml_wrapper)"/>
   <!-- template MakeWrapper can be called from outside this template, if needed -->
   <!-- Helper templates -->
   <!-- ================================================================== -->
   <xsl:template name="MakeWrapper">
      <xsl:call-template name="Wrappers">
         <xsl:with-param name="transmission_wrapper"
                         select="$input_xml_wrapper_doc//transmission_wrapper"/>
         <xsl:with-param name="payload_xml"/>
      </xsl:call-template>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="/">
      <xsl:call-template name="Wrappers">
         <xsl:with-param name="transmission_wrapper"
                         select="$input_xml_wrapper_doc//transmission_wrapper"/>
         <xsl:with-param name="payload_xml"
                         select="."/>
      </xsl:call-template>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template name="Wrappers">
      <xsl:param name="transmission_wrapper"/>
      <xsl:param name="payload_xml"/>
      <xsl:for-each select="$transmission_wrapper">
         <!-- schematron processing instruction -->
         <xsl:for-each select="./schematron_href">
            <xsl:processing-instruction name="xml-model">href="
<xsl:value-of select="./@value"/>" type="
<xsl:value-of select="./@type"/>" schematypens="
<xsl:value-of select="./@schematypens"/>" phase="
<xsl:value-of select="./@phase"/>"</xsl:processing-instruction>
         </xsl:for-each>
         <xsl:element name="{./root_xml_element/@value}">
            <xsl:namespace name="hl7"
                           select="'urn:hl7-org:v3'"/>
            <xsl:namespace name="xs"
                           select="'http://www.w3.org/2001/XMLSchema'"/>
            <xsl:for-each select="./schema_location">
               <xsl:attribute name="xsi:schemaLocation"
                              select="./@value"/>
            </xsl:for-each>
            <xsl:for-each select="./id">
               <xsl:call-template name="makeId"/>
            </xsl:for-each>
            <xsl:for-each select="./creation_time">
               <creationTime>
                  <xsl:call-template name="makeTSValueAttr"/>
               </creationTime>
            </xsl:for-each>
            <versionCode code="NICTIZEd2005-Okt"/>
            <xsl:for-each select="./interaction_id">
               <interactionId extension="{./@value}"
                              root="{$oidHL7InteractionID}"/>
            </xsl:for-each>
            <profileId root="2.16.840.1.113883.2.4.3.11.1"
                       extension="810"/>
            <processingCode code="P"/>
            <processingModeCode code="T"/>
            <xsl:for-each select="./accept_ack_code">
               <acceptAckCode code="{./@value}"/>
            </xsl:for-each>
            <xsl:for-each select="./attention_line_bsn">
               <attentionLine>
                  <keyWordText code="PATID"
                               codeSystem="2.16.840.1.113883.2.4.15.1">Patient.id</keyWordText>
                  <value extension="{./@value}"
                         root="{$oidBurgerservicenummer}">
                     <xsl:attribute name="xsi:type"
                                    select="'II'"/>
                  </value>
               </attentionLine>
            </xsl:for-each>
            <xsl:for-each select="./receiver">
               <receiver typeCode="RCV">
                  <xsl:call-template name="makeDevice"/>
               </receiver>
            </xsl:for-each>
            <xsl:for-each select="./sender">
               <sender typeCode="SND">
                  <xsl:call-template name="makeDevice"/>
               </sender>
            </xsl:for-each>
            <xsl:for-each select="./controlact_wrapper">
               <ControlActProcess classCode="CACT"
                                  moodCode="EVN">
                  <!-- authorOrPerformer and overseer are the same person as prescription/author -->
                  <xsl:variable name="vv"
                                select="$payload_xml//sturen_medicatievoorschrift//verstrekkingsverzoek"/>
                  <xsl:variable name="vvAuteur"
                                select="$vv/../../bouwstenen/zorgverlener[@id = $vv/auteur/zorgverlener/@value] | $vv/auteur/zorgverlener[*]"/>
                  <xsl:choose>
                     <xsl:when test="$vvAuteur">
                        <xsl:for-each select="$vvAuteur">
                           <authorOrPerformer typeCode="AUT">
                              <participant>
                                 <AssignedPerson>
                                    <xsl:call-template name="template_2.16.840.1.113883.2.4.3.11.60.102.10.514_20120901000000"/>
                                 </AssignedPerson>
                              </participant>
                           </authorOrPerformer>
                        </xsl:for-each>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:for-each select="./author_or_performer/assigned_person">
                           <authorOrPerformer typeCode="AUT">
                              <participant>
                                 <xsl:call-template name="makeAssignedPerson"/>
                              </participant>
                           </authorOrPerformer>
                        </xsl:for-each>
                     </xsl:otherwise>
                  </xsl:choose>
                  <!-- overseer -->
                  <xsl:choose>
                     <xsl:when test="$vvAuteur">
                        <overseer typeCode="RESP">
                           <xsl:for-each select="$vvAuteur">
                              <AssignedPerson>
                                 <xsl:call-template name="template_2.16.840.1.113883.2.4.3.11.60.102.10.514_20120901000000"/>
                              </AssignedPerson>
                           </xsl:for-each>
                        </overseer>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:for-each select="overseer/assigned_person">
                           <overseer typeCode="RESP">
                              <xsl:call-template name="makeAssignedPerson"/>
                           </overseer>
                        </xsl:for-each>
                     </xsl:otherwise>
                  </xsl:choose>
                  <!-- call this template with the appropriate input file -->
                  <xsl:call-template name="Make_Voorschrift_612">
                     <xsl:with-param name="voorschrift"
                                     select="$payload_xml//sturen_medicatievoorschrift"/>
                  </xsl:call-template>
               </ControlActProcess>
            </xsl:for-each>
         </xsl:element>
      </xsl:for-each>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template name="makeAssignedPerson">
      <AssignedPerson>
         <xsl:for-each select="./id">
            <xsl:call-template name="makeId"/>
         </xsl:for-each>
         <xsl:for-each select="./code">
            <xsl:call-template name="makeWrapperCode"/>
         </xsl:for-each>
         <xsl:for-each select="./name">
            <assignedPrincipalChoiceList>
               <assignedPerson>
                  <name>
                     <xsl:value-of select="./@value"/>
                  </name>
               </assignedPerson>
            </assignedPrincipalChoiceList>
         </xsl:for-each>
         <xsl:for-each select="./organization">
            <Organization>
               <xsl:for-each select="./id">
                  <xsl:call-template name="makeId"/>
               </xsl:for-each>
               <xsl:for-each select="./code">
                  <xsl:call-template name="makeWrapperCode"/>
               </xsl:for-each>
               <xsl:for-each select="./name">
                  <name>
                     <xsl:value-of select="./@value"/>
                  </name>
               </xsl:for-each>
               <xsl:for-each select="address/city">
                  <addr>
                     <city>
                        <xsl:value-of select="./@value"/>
                     </city>
                  </addr>
               </xsl:for-each>
            </Organization>
         </xsl:for-each>
      </AssignedPerson>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template name="makeDevice">
      <device classCode="DEV"
              determinerCode="INSTANCE">
         <xsl:for-each select="./id">
            <id extension="{./@value}"
                root="{./@root}"/>
         </xsl:for-each>
         <xsl:for-each select="./name">
            <name>
               <xsl:value-of select="./@value"/>
            </name>
         </xsl:for-each>
      </device>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template name="makeId">
      <id extension="{./@value}"
          root="{./@root}"/>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template name="makeWrapperCode">
      <code code="{./@code}"
            codeSystem="{./@codeSystem}"
            displayName="{./@displayName}"/>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template name="template_2.16.840.1.113883.2.4.3.11.60.102.10.514_20120901000000">
      <!--  Assigned Person [universal]  -->
      <xsl:for-each select="zorgverlener_identificatie_nummer | zorgverlener_identificatienummer">
         <xsl:choose>
            <xsl:when test="(@root = $oidUZIPersons) or (@root = $oidAGB)">
               <xsl:call-template name="makeIIValue">
                  <xsl:with-param name="elemName">id</xsl:with-param>
                  <xsl:with-param name="root"
                                  select="@root"/>
               </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
               <id nullFlavor="NI"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:for-each>
      <xsl:choose>
         <xsl:when test="specialisme[@codeSystem = $oidUZIRoleCode]">
            <xsl:for-each select="specialisme[@codeSystem = $oidUZIRoleCode]">
               <xsl:call-template name="makeCEValue">
                  <xsl:with-param name="elemName">code</xsl:with-param>
                  <xsl:with-param name="xsiType"
                                  select="''"/>
               </xsl:call-template>
            </xsl:for-each>
         </xsl:when>
         <xsl:otherwise>
            <!-- okay we don't have uzi rolecode, but wrapper needs it, we input generic arts since this is a voorschrift -->
            <code code="01.000"
                  codeSystem="2.16.840.1.113883.2.4.15.111"
                  displayName="Arts"/>
         </xsl:otherwise>
      </xsl:choose>
      <assignedPrincipalChoiceList>
         <assignedPerson classCode="PSN"
                         determinerCode="INSTANCE">
            <xsl:call-template name="template_2.16.840.1.113883.2.4.3.11.60.101.10.1_20141106000000">
               <xsl:with-param name="naamgegevens"
                               select="zorgverlener_naam/naamgegevens | naamgegevens"/>
            </xsl:call-template>
         </assignedPerson>
      </assignedPrincipalChoiceList>
      <xsl:for-each select="zorgaanbieder/zorgaanbieder[*] | ../zorgaanbieder[@id = current()//zorgaanbieder[not(zorgaanbieder)]/@value]">
         <Organization classCode="ORG"
                       determinerCode="INSTANCE">
            <xsl:for-each select="(zorgaanbieder_identificatie_nummer | zorgaanbieder_identificatienummer)[@value]">
               <xsl:call-template name="makeIIValue">
                  <xsl:with-param name="elemName">id</xsl:with-param>
                  <xsl:with-param name="xsiType"
                                  select="''"/>
                  <xsl:with-param name="root"
                                  select="@root"/>
               </xsl:call-template>
            </xsl:for-each>
            <xsl:for-each select="organisatie_naam[@value]">
               <name>
                  <xsl:value-of select="@value"/>
               </name>
            </xsl:for-each>
            <xsl:for-each select=".//adresgegevens[not(adresgegevens)][*]">
               <addr>
                  <xsl:for-each select="woonplaats[@value | @code | @nullFlavor]">
                     <xsl:choose>
                        <xsl:when test="@code">
                           <city>
                              <xsl:call-template name="makeCodeAttribs"/>
                           </city>
                        </xsl:when>
                        <xsl:otherwise>
                           <xsl:call-template name="makeText">
                              <xsl:with-param name="elemName">city</xsl:with-param>
                           </xsl:call-template>
                        </xsl:otherwise>
                     </xsl:choose>
                  </xsl:for-each>
               </addr>
            </xsl:for-each>
         </Organization>
      </xsl:for-each>
   </xsl:template>
</xsl:stylesheet>