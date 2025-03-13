<?xml version="1.0" encoding="UTF-8"?>

<!-- == Provenance: HL7-mappings/hl7_2_ada/mp/9.0.7/sturen_medicatievoorschrift/payload/sturen_medicatievoorschrift_hl7_2_ada.xsl == -->
<!-- == Distribution: MP9-Medicatieproces-9.0.7; 0.1; 2024-08-26T18:25:33.12+02:00 == -->
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:hl7="urn:hl7-org:v3"
                xmlns:sdtc="urn:hl7-org:sdtc"
                xmlns:nf="http://www.nictiz.nl/functions"
                xmlns:hl7nl="urn:hl7-nl:v3"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
                xmlns:pharm="urn:ihe:pharm:medication"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
   <xsl:import href="../../../../../common/includes/hl7_2_ada_mp_include.xsl"/>
   <xsl:import href="../../../../../common/includes/all-zibs-d570e167.xsl"/>
   <xsl:output method="xml"
               indent="yes"
               exclude-result-prefixes="#all"/>
   <!-- Dit is een conversie van MP 9.1.0 naar ADA 9.0 voorschrift bericht -->
   <!-- parameter to control whether or not the result should contain a reference to the ada xsd -->
   <xsl:param name="outputSchemaRef"
              as="xs:boolean"
              select="true()"/>
   <!-- de xsd variabelen worden gebruikt om de juiste conceptId's te vinden voor de ADA xml -->
   <xd:doc>
      <xd:desc> if this xslt is used stand alone the template below could be used. </xd:desc>
   </xd:doc>
   <xsl:template match="/">
      <xsl:variable name="patient-recordTarget"
                    select="//hl7:recordTarget/hl7:patientRole"/>
      <xsl:call-template name="Voorschrift-90-ADA">
         <xsl:with-param name="patient"
                         select="$patient-recordTarget"/>
      </xsl:call-template>
   </xsl:template>
   <xd:doc>
      <xd:desc>Create adaxml for transaction voorschrift</xd:desc>
      <xd:param name="patient">HL7 patient</xd:param>
   </xd:doc>
   <xsl:template name="Voorschrift-90-ADA">
      <xsl:param name="patient"
                 select="//hl7:recordTarget/hl7:patientRole"/>
      <xsl:call-template name="doGeneratedComment">
         <xsl:with-param name="in"
                         select="//*[hl7:ControlActProcess]"/>
      </xsl:call-template>
      <adaxml>
         <xsl:if test="$outputSchemaRef">
            <xsl:attribute name="xsi:noNamespaceSchemaLocation">../ada_schemas/ada_sturen_medicatievoorschrift.xsd</xsl:attribute>
         </xsl:if>
         <meta status="new"
               created-by="generated"
               last-update-by="generated">
            <xsl:attribute name="creation-date"
                           select="current-dateTime()"/>
            <xsl:attribute name="last-update-date"
                           select="current-dateTime()"/>
         </meta>
         <data>
            <sturen_medicatievoorschrift app="mp-mp9"
                                         shortName="sturen_medicatievoorschrift"
                                         formName="sturen_voorschrift"
                                         transactionRef="2.16.840.1.113883.2.4.3.11.60.20.77.4.95"
                                         transactionEffectiveDate="2015-12-01T10:32:15"
                                         versionDate=""
                                         prefix="mp-"
                                         language="nl-NL"
                                         title="testbericht ADA conversie"
                                         id="cd1badfb-2076-4c6f-b08e-bddbc7972340">
               <xsl:for-each select="$patient">
                  <xsl:call-template name="template_2.16.840.1.113883.2.4.3.11.60.3.10.1_20180601000000">
                     <xsl:with-param name="in"
                                     select="."/>
                     <xsl:with-param name="language"
                                     select="$language"/>
                  </xsl:call-template>
               </xsl:for-each>
               <!-- medicatiebouwstenen -->
               <xsl:variable name="component"
                             select="//*[hl7:templateId/@root = $templateId-medicatieafspraak] | //*[hl7:templateId/@root = $templateId-verstrekkingsverzoek]"/>
               <xsl:for-each-group select="$component"
                                   group-by="concat(hl7:entryRelationship/hl7:procedure[hl7:templateId = $templateId-medicamenteuze-behandeling]/hl7:id/@root, hl7:entryRelationship/hl7:procedure[hl7:templateId/@root = $templateId-medicamenteuze-behandeling]/hl7:id/@extension)">
                  <!-- medicamenteuze_behandeling -->
                  <medicamenteuze_behandeling>
                     <xsl:for-each select="hl7:entryRelationship/hl7:procedure[hl7:templateId/@root = $templateId-medicamenteuze-behandeling]/hl7:id">
                        <xsl:variable name="elemName">identificatie</xsl:variable>
                        <xsl:element name="{$elemName}">
                           <xsl:for-each select="@extension">
                              <xsl:attribute name="value"
                                             select="."/>
                           </xsl:for-each>
                           <xsl:for-each select="@root">
                              <xsl:attribute name="root"
                                             select="."/>
                           </xsl:for-each>
                        </xsl:element>
                     </xsl:for-each>
                     <!-- medicatieafspraak, own or other are both handled the same way , kopie-indicator simply outputted in ada -->
                     <xsl:for-each select="current-group()[hl7:templateId/@root = $templateId-medicatieafspraak]">
                        <xsl:call-template name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.9235_20181204143321">
                           <xsl:with-param name="ma_hl7_90"
                                           select="."/>
                        </xsl:call-template>
                     </xsl:for-each>
                     <!-- verstrekkingsverzoek -->
                     <xsl:for-each select="current-group()[hl7:templateId/@root = $templateId-verstrekkingsverzoek]">
                        <xsl:call-template name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.9257_20181204143321">
                           <xsl:with-param name="in"
                                           select="."/>
                        </xsl:call-template>
                     </xsl:for-each>
                  </medicamenteuze_behandeling>
               </xsl:for-each-group>
               <!-- lengte / gewicht van vóór 9.1.0 die in MA zitten ook converteren -->
               <!-- lichaamslengte  -->
               <xsl:for-each select="//*[hl7:templateId/@root = $templateId-lichaamslengte]">
                  <xsl:variable name="zibroot"
                                as="element()?">
                     <xsl:call-template name="HL7element2Zibroot"/>
                  </xsl:variable>
                  <xsl:call-template name="zib-Lichaamslengte-3.1">
                     <xsl:with-param name="zibroot"
                                     select="$zibroot"/>
                  </xsl:call-template>
               </xsl:for-each>
               <!-- lichaamsgewicht  -->
               <xsl:for-each select="//*[hl7:templateId/@root = $templateId-lichaamsgewicht]">
                  <xsl:variable name="zibroot"
                                as="element()?">
                     <xsl:call-template name="HL7element2Zibroot"/>
                  </xsl:variable>
                  <xsl:call-template name="zib-Lichaamsgewicht-3.1">
                     <xsl:with-param name="zibroot"
                                     select="$zibroot"/>
                  </xsl:call-template>
               </xsl:for-each>
               <!-- labuitslag -->
               <xsl:for-each select="//*[hl7:templateId/@root = $templateId-labuitslag]">
                  <xsl:variable name="zibroot"
                                as="element()?">
                     <xsl:call-template name="HL7element2Zibroot"/>
                  </xsl:variable>
                  <xsl:call-template name="zib-LaboratoryTestResult-Observation-4.1">
                     <xsl:with-param name="zibroot"
                                     select="$zibroot"/>
                  </xsl:call-template>
               </xsl:for-each>
            </sturen_medicatievoorschrift>
         </data>
      </adaxml>
   </xsl:template>
   <xd:doc>
      <xd:desc>Handle HL7 stuff to create an ada zibRoot HCIM</xd:desc>
      <xd:param name="schemaFragment">Optional for generating ada conceptId's. XSD Schema complexType for ada parent of zibroot</xd:param>
   </xd:doc>
   <xsl:template name="HL7element2Zibroot"
                 match="hl7:*"
                 mode="HL7element2Zibroot">
      <xsl:param name="schemaFragment"
                 as="element(xs:complexType)?"/>
      <!-- multi language support for ada element names -->
      <xsl:variable name="elmZibroot">
         <xsl:choose>
            <xsl:when test="$language = 'en-US'">hcimroot</xsl:when>
            <xsl:otherwise>zibroot</xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:variable name="elmZibrootIdentification">
         <xsl:choose>
            <xsl:when test="$language = 'en-US'">identification_number</xsl:when>
            <xsl:otherwise>identificatienummer</xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:variable name="elmZibrootAuthor">
         <xsl:choose>
            <xsl:when test="$language = 'en-US'">author</xsl:when>
            <xsl:otherwise>auteur</xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:variable name="elmZibrootAuthorPatient">
         <xsl:choose>
            <xsl:when test="$language = 'en-US'">patient_as_author</xsl:when>
            <xsl:otherwise>patient_als_auteur</xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:variable name="elmZibrootAuthorHealthProfessional">
         <xsl:choose>
            <xsl:when test="$language = 'en-US'">health_professional_as_author</xsl:when>
            <xsl:otherwise>zorgverlener_als_auteur</xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:element name="{$elmZibroot}">
         <!-- identification number -->
         <xsl:for-each select="hl7:id">
            <xsl:call-template name="handleII">
               <xsl:with-param name="in"
                               select="."/>
               <xsl:with-param name="elemName"
                               select="$elmZibrootIdentification"/>
            </xsl:call-template>
         </xsl:for-each>
         <!-- author -->
         <!-- participant exists in HL7 template, don't want to throw that information away -->
         <!-- may be only one author in zibroot, could theoretically encounter both author and participant in HL7 -->
         <xsl:variable name="hl7Author">
            <xsl:choose>
               <xsl:when test="hl7:author">
                  <xsl:sequence select="hl7:author"/>
               </xsl:when>
               <xsl:when test="hl7:participant[@typeCode = 'RESP']">
                  <xsl:sequence select="hl7:participant[@typeCode = 'RESP']"/>
               </xsl:when>
            </xsl:choose>
         </xsl:variable>
         <xsl:for-each select="$hl7Author/*">
            <xsl:element name="{$elmZibrootAuthor}">
               <xsl:choose>
                  <xsl:when test="hl7:patient | hl7:assignedAuthor[hl7:code/@code = 'ONESELF']">
                     <xsl:element name="{$elmZibrootAuthorPatient}">
                        <xsl:element name="{$elmPatient}">
                           <xsl:attribute name="value"
                                          select="$patients/patient_information/*[local-name() = $elmPatient]/@id"/>
                           <xsl:attribute name="datatype">reference</xsl:attribute>
                        </xsl:element>
                     </xsl:element>
                  </xsl:when>
                  <!-- healthprofessional as author -->
                  <xsl:when test="(hl7:assignedPerson | hl7:assignedAuthor | hl7:participantRole)[not(hl7:code/@code = 'ONESELF')]">
                     <xsl:for-each select="hl7:assignedPerson | hl7:assignedAuthor | hl7:participantRole">
                        <xsl:element name="{$elmZibrootAuthorHealthProfessional}">
                           <!-- output the actual healthcare professional -->
                           <xsl:call-template name="HandleHealthProfessional"/>
                        </xsl:element>
                     </xsl:for-each>
                  </xsl:when>
                  <!-- related person as author not in HL7v3 template  -->
                  <!-- no mapping needed -->
               </xsl:choose>
            </xsl:element>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
</xsl:stylesheet>