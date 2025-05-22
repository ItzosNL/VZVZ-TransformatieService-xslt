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
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" 
    xmlns:f="http://hl7.org/fhir" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:hl7="urn:hl7-org:v3"
    xmlns:hl7nl="urn:hl7-nl:v3"
    xmlns:vf="http://www.vzvz.nl/functions" 
    xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"
    exclude-result-prefixes="xs xsi vf s xd hl7 hl7nl f" 
    version="3.0">
    
    <xsl:import href="BATCH_LSP_to_FHIR_OperationOutcome.xsl"/>
    <xsl:import href="vf.transformation-utils.xsl"/>
    <xsl:import href="vf.utils.xsl"/>

    <!-- versionXSLT = versienummer van DEZE transformatie -->
    <xsl:variable name="vf:versionXSLT" as="xs:string" select="'0.3.1'"/>
    <xsl:variable name="transformationCode"/>
    <xsl:variable name="fhirVersion" as="xs:string" select="'R4'"/>

    <xsl:variable name="metaStructure">
        <xsl:call-template name="addTransformationCode">
            <xsl:with-param name="type" select="'fhir'"/>
            <xsl:with-param name="transformationCode" select="$transformationCode"/>
            <xsl:with-param name="versionXSLT" select="$vf:versionXSLT"/>
        </xsl:call-template>
    </xsl:variable>

    <xd:doc>
        <xd:desc>
            <xd:p>update-bundle</xd:p>
            <xd:p>fix the bundle with our necessary modifications</xd:p>
        </xd:desc>
        <xd:param name="in">The original fhir Bundle</xd:param>
        <xd:param name="originalMessage">The original message</xd:param>
        <xd:param name="metaData">The metadata structure</xd:param>
        <xd:param name="defResponse"/>
    </xd:doc>
    <xsl:template name="update-bundle">
        <xsl:param name="originalMessage"/>
        <xsl:param name="metaData"/>
        <xsl:param name="in"/>
        <xsl:param name="defResponse"/>

        <xsl:if test="$xslDebug">
            <!--            
                <xsl:processing-instruction name="xml-model">phase="#ALL" href="http://hl7.org/fhir/R4/fhir-invariants.sch" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:processing-instruction>
            -->
        </xsl:if>

        <Bundle xmlns="http://hl7.org/fhir">
            <xsl:if test="$xslDebug">
                <xsl:attribute name="xsi:schemaLocation">http://hl7.org/fhir http://hl7.org/fhir/<xsl:value-of select="$fhirVersion"
                    />/fhir-all.xsd</xsl:attribute>
            </xsl:if>

            <id value="{$in/f:id/@value}"/>
            <!-- add transformation code to bundle -->
            <xsl:call-template name="updateMetaWithTransformationCode">
                <xsl:with-param name="meta" select="$in"/>
                <xsl:with-param name="metaStructure" select="$metaStructure"/>
            </xsl:call-template>
            <xsl:copy-of select="$in/f:type" copy-namespaces="no"/>
            <xsl:copy-of select="$in/f:total" copy-namespaces="no"/>
            <xsl:copy-of select="$in/f:link" copy-namespaces="no"/>

            <xsl:variable name="defaultResponse">
                <xsl:choose>
                    <xsl:when test="$defResponse">
                        <xsl:sequence select="$defResponse"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="originalMessageObj">
                            <xsl:call-template name="convertToDocumentNode">
                                <xsl:with-param name="xml" select="$originalMessage"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:variable name="metaDataObj">
                            <xsl:call-template name="convertToDocumentNode">
                                <xsl:with-param name="xml" select="$metaData"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:if test="$xslDebug">
                            <count>
                                <xsl:value-of
                                    select="count($originalMessageObj//hl7:organizer/hl7:component)"
                                />
                            </count>
                        </xsl:if>

                        <xsl:call-template name="buildSearchResponse">
                            <xsl:with-param name="response" select="$originalMessageObj"/>
                            <xsl:with-param name="patientID" select="$metaDataObj//Patient"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <xsl:if test="$xslDebug">
                <xsl:comment>Number of V3 organizer/component entries found: <xsl:value-of select="$defaultResponse//f:count"/></xsl:comment>
            </xsl:if>

            <xsl:choose>
                <!-- everything went well -->
                <xsl:when
                    test="$defaultResponse and $defaultResponse//search/mode/@value = 'search'">
                    <xsl:apply-templates select="$in/f:entry" mode="wrapper"
                        exclude-result-prefixes="#all"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="uuid"><xsl:value-of select="vf:UUID4()"/></xsl:variable>
                    <entry>
                        <fullUrl value="{concat('urn:uuid:', $uuid)}"/>
                        <resource>
                            <xsl:copy-of
                                select="$defaultResponse//search/f:outcome/f:OperationOutcome"/>
                        </resource>
                        <search>
                            <mode value="outcome"/>
                        </search>
                    </entry>
<!--                    <xsl:for-each select="$in/f:entry">
                        <entry>
                            <xsl:copy-of select="./f:resource"/>
                            <xsl:copy-of select="$defaultResponse/search"/>
                        </entry>
                    </xsl:for-each>
-->
                </xsl:otherwise>
            </xsl:choose>

        </Bundle>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>Add the transformation code to the meta section</xd:p>
            <xd:p>If there is no meta section, create one</xd:p>
        </xd:desc>
        <xd:param name="meta"/>
        <xd:param name="metaStructure"/>
    </xd:doc>
    <xsl:template name="updateMetaWithTransformationCode">
        <xsl:param name="meta"/>
        <xsl:param name="metaStructure"/>
        <xsl:choose>
            <xsl:when test="exists($meta/f:meta)">
                <meta xmlns="http://hl7.org/fhir">
                    <xsl:apply-templates select="
                            $meta/f:meta/*[local-name() = 'versionId'
                            or local-name() = 'lastUpdated'
                            or local-name() = 'profile'
                            or local-name() = 'security'
                            ]" mode="wrapper"/>
                    <xsl:sequence select="$metaStructure/f:meta/*"/>
                    <xsl:apply-templates select="$meta/f:meta/*[local-name() = 'tag']"
                        mode="wrapper"/>
                </meta>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$metaStructure"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>Dit is een conversie van een ACK van de V3 interactie voorschrift naar een FHIR
                response.</xd:p>
        </xd:desc>

        <xd:param name="EntryList">De oorspronkelijke Bundle waar antwoord op wordt
            gegeven</xd:param>
        <xd:param name="AckMessage">Het V3 ACK message dat als antwoord moet worden
            doorgegeven</xd:param>
        <xd:param name="patientID">Het nummer (BSN) van de patiënt waar het bericht betrekking op
            heeft</xd:param>
        <xd:param name="defaultResponse"/>
        <xd:param name="versionXSLT">Versie van de transformatie. Default is versie van dit
            bestand</xd:param>
    </xd:doc>
    <xsl:template name="buildTransactionResponseBundle">
        <xsl:param name="EntryList"/>
        <xsl:param name="AckMessage"/>
        <xsl:param name="patientID"/>
        <xsl:param name="defaultResponse"/>
        <xsl:param name="versionXSLT" select="$vf:versionXSLT"/>
        <!-- 
            
            make a list of the original entry ids, because they have to match
            in references.
            
            Calculate the oldID based on the id of the resource or, if that is missing
            based on the fullUrl.
            
            Some resources will not be stored, so we use the old ID as new ID.
        -->
        <!--        
            <xsl:variable name="entryIds" as="map(xs:string, xs:string)">
            <xsl:map>
            <xsl:for-each select="$EntryList//f:entry">
            <xsl:variable name="oldID" as="xs:string">
            <xsl:choose>
            <xsl:when test="exists(f:resource/child::*/f:id)">
            <xsl:value-of select="f:resource/child::*/f:id/@value"/>
            </xsl:when>
            <xsl:otherwise>
            <!-\- ik ga er maar even van uit dat er altijd een fullUrl is -\->
            <xsl:value-of>
            <xsl:choose>
            <xsl:when
            test="starts-with(f:fullUrl/@value, 'urn:oid:')">
            <xsl:value-of
            select="substring(f:fullUrl/@value, 9)"/>
            </xsl:when>
            <xsl:when
            test="starts-with(f:fullUrl/@value, 'urn:uuid:')">
            <xsl:value-of
            select="substring(f:fullUrl/@value, 10)"/>
            </xsl:when>
            <xsl:otherwise>
            <xsl:value-of select="f:fullUrl/@value"/>
            </xsl:otherwise>
            </xsl:choose>
            </xsl:value-of>
            </xsl:otherwise>
            </xsl:choose>
            </xsl:variable>
            <xsl:variable name="tmpID" as="xs:string">
            <xsl:choose>
            <xsl:when test="exists(f:resource/f:Patient)
            or exists(f:resource/f:Organization)
            or exists(f:resource/f:Practitioner)
            or exists(f:resource/f:PractitionerRole)
            ">
            <xsl:value-of select="$oldID"/>
            </xsl:when>
            <xsl:otherwise>
            <xsl:value-of select="vf:UUID4()"/>
            </xsl:otherwise>
            </xsl:choose>                        
            </xsl:variable>
            <xsl:map-entry key="$oldID" select="$tmpID"/>
            </xsl:for-each>
            </xsl:map>
            </xsl:variable>
            
        -->
        <!-- create a response that the resource is not stored -->
        <xsl:variable name="noStoreResponse">
            <xsl:call-template name="buildTransactionNoStoreResponse"/>
        </xsl:variable>

        <xsl:variable name="metaStructure">
            <xsl:call-template name="addTransformationCode">
                <xsl:with-param name="type" select="'fhir'"/>
                <xsl:with-param name="transformationCode" select="$transformationCode"/>
                <xsl:with-param name="versionXSLT" select="$versionXSLT"/>
            </xsl:call-template>
        </xsl:variable>

        <Bundle xmlns="http://hl7.org/fhir" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://hl7.org/fhir/R4/fhir-all.xsd">
            <!--            <xsl:comment> getransformeerd met versie <xsl:value-of select="$versionXSLT"/> </xsl:comment>-->
            <id value="{vf:UUID4()}"/>
            <xsl:sequence select="$metaStructure"/>
            <type value="transaction-response"/>

            <xsl:for-each select="$EntryList//f:entry">
                <xsl:variable name="specialResource" as="xs:boolean">
                    <xsl:choose>
                        <!-- this resource needs a special treatment -->
                        <xsl:when test="
                                exists(f:resource/f:Patient)
                                or exists(f:resource/f:Organization)
                                or exists(f:resource/f:Practitioner)
                                or exists(f:resource/f:PractitionerRole)
                                or exists(f:resource/f:Medication)
                                or exists(f:resource/f:Condition)
                                ">
                            <xsl:value-of select="true()"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="false()"/>
                        </xsl:otherwise>
                    </xsl:choose>

                </xsl:variable>

                <!-- define response -->
                <xsl:variable name="response">
                    <xsl:choose>
                        <xsl:when test="
                                contains($defaultResponse//status/@value, '201')
                                and ($specialResource)
                                ">
                            <!-- deze gaan we niet opslaan, dus 'nostore' teruggeven -->
                            <xsl:copy-of select="$noStoreResponse"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of select="$defaultResponse"/>
                        </xsl:otherwise>
                    </xsl:choose>

                </xsl:variable>

                <entry>

                    <xsl:variable name="elementRoot" select="local-name(f:resource/*)"/>

                    <!-- bepaal de resource.id -->
                    <xsl:variable name="newResourceId">
                        <xsl:variable name="oldID" as="xs:string">
                            <xsl:choose>
                                <xsl:when test="exists(f:resource/child::*/f:id)">
                                    <xsl:value-of select="f:resource/child::*/f:id/@value"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <!-- ik ga er maar even van uit dat er altijd een fullUrl is -->
                                    <xsl:value-of>
                                        <xsl:choose>
                                            <xsl:when
                                                test="starts-with(f:fullUrl/@value, 'urn:oid:')">
                                                <xsl:value-of
                                                  select="substring(f:fullUrl/@value, 9)"/>
                                            </xsl:when>
                                            <xsl:when
                                                test="starts-with(f:fullUrl/@value, 'urn:uuid:')">
                                                <xsl:value-of
                                                  select="substring(f:fullUrl/@value, 10)"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="f:fullUrl/@value"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:value-of>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:choose>
                            <xsl:when test="$specialResource">
                                <xsl:value-of select="$oldID"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="vf:UUID4()"/>
                            </xsl:otherwise>
                        </xsl:choose>

                        <!--                        
                            <xsl:value-of select="$entryIds(f:resource/child::*/f:id/@value)"/>
                        -->
                    </xsl:variable>

                    <!-- fullUrl MOET dezelfde ID bevatten als de resource.id -->
                    <xsl:variable name="resourceFullUrl">
                        <xsl:choose>
                            <xsl:when test="$specialResource">
                                <xsl:value-of select="f:fullUrl/@value"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="concat('urn:uuid:', $newResourceId)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>

                    <fullUrl value="{$resourceFullUrl}"/>

                    <resource>
                        <xsl:call-template name="transformResource">
                            <xsl:with-param name="originalResource" select="f:resource"/>
                            <xsl:with-param name="resourceID" select="$newResourceId"/>
                            <xsl:with-param name="metaTransformationCode" select="$metaStructure"/>
                        </xsl:call-template>
                    </resource>

                    <response>
                        <status value="{$response/response/status/@value}"/>
                        <xsl:choose>
                            <xsl:when test="not(exists($response/response/outcome))">
                                <!-- een location geeft de locatie van het nieuw aangemaakte object aan.
                                    dat is er niet bij een fout.
                                    location is gelijk aan location header = vergelijkbaar met fullUrl
                                -->
                                <location value="{$resourceFullUrl}"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:copy-of select="$response/response/outcome"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </response>
                </entry>
            </xsl:for-each>
        </Bundle>
    </xsl:template>

    <xd:doc>
        <xd:desc>Translate Entry</xd:desc>
        <xd:param name="originalResource">Copy of the original resource</xd:param>
        <xd:param name="resourceID">ID van het net aangemaakte entry</xd:param>
        <xd:param name="metaTransformationCode">Meta structure containing the transformation
            code</xd:param>
    </xd:doc>
    <xsl:template name="transformResource">
        <xsl:param name="originalResource"/>
        <xsl:param name="resourceID"/>
        <xsl:param name="metaTransformationCode"/>

        <xsl:variable name="elementRoot" select="local-name($originalResource/*)"/>
        <xsl:element name="{$elementRoot}" namespace="http://hl7.org/fhir">
            <xsl:if test="not(empty($resourceID))">
                <id value="{$resourceID}" xmlns="http://hl7.org/fhir"/>
            </xsl:if>
            <xsl:call-template name="updateMetaWithTransformationCode">
                <xsl:with-param name="metaStructure" select="$metaTransformationCode"/>
                <xsl:with-param name="meta" select="$originalResource/*"/>
            </xsl:call-template>
            <xsl:call-template name="fixNarrative">
                <xsl:with-param name="txt" select="$originalResource/node()/f:text"/>
            </xsl:call-template>
            <xsl:copy-of select="$originalResource/node()/child::node()[not(local-name() = 'meta') 
                    and not(local-name() = 'id') and not(local-name() = 'text')]" 
                copy-namespaces="no" />
        </xsl:element>
    </xsl:template>


    <xd:doc>
        <xd:desc>An empty div in the narrative throws all kinds of strange validation errors, 
            so we fix it by adding dummy text</xd:desc>
        <xd:param name="txt">The 'text' element containing the narrative</xd:param>
    </xd:doc>
    <xsl:template name="fixNarrative">
        <xsl:param name="txt"/>
        <xsl:if test="$txt">
            <text xmlns="http://hl7.org/fhir">
                <xsl:copy-of select="$txt/f:status" copy-namespaces="no"/>
                <xsl:variable name="tmp" select="$txt/*[local-name() = 'div']"/>
                    <xsl:choose>
                        <xsl:when test="exists($tmp/*[local-name() = 'div']) and 
                            empty($tmp/*[local-name() = 'div']/text())">
                            
                            <div xmlns="http://www.w3.org/1999/xhtml">dummy text</div>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of select="$tmp" copy-namespaces="no"/>
                        </xsl:otherwise>
                    </xsl:choose>
            </text>
        </xsl:if>
    </xsl:template>


    <xd:doc>
        <xd:desc>Rebuild the entry but modify it to update ID and add/update meta
            structure</xd:desc>
    </xd:doc>
    <xsl:template match="f:entry" mode="wrapper">
        <entry xmlns="http://hl7.org/fhir">
            <xsl:copy-of select="./f:fullUrl" copy-namespaces="no"/>
            <resource>
                <xsl:call-template name="transformResource">
                    <xsl:with-param name="originalResource" select="./f:resource"/>
                    <xsl:with-param name="resourceID" select="./f:resource/node()/f:id/@value"/>
                    <xsl:with-param name="metaTransformationCode" select="$metaStructure"/>
                </xsl:call-template>
            </resource>
            <xsl:copy-of select="./f:search" copy-namespaces="no"/>
            <xsl:copy-of select="./f:request" copy-namespaces="no"/>
        </entry>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>Build the default response</xd:p>
            <xd:p>This allows to determine the result</xd:p>
        </xd:desc>
        <xd:param name="ack"/>
        <xd:param name="patientID"/>
    </xd:doc>
    <xsl:template name="buildTransactionResponse">
        <xsl:param name="ack"/>
        <xsl:param name="patientID"/>

        <xsl:variable name="operationOutcome">
            <xsl:apply-templates select="$ack" mode="error-detect">
                <xsl:with-param name="patientID" select="$patientID"/>
            </xsl:apply-templates>
        </xsl:variable>
        <response>
            <xsl:choose>
                <xsl:when test="local-name($operationOutcome/*) = 'outcome'">
                    <!-- voorlopig zet ik de status op de HTTP foutcode die ik in de outcome gezet heb.
                        De outcome kan meer dan 1 OutcomeOperation hebben en dan is niet 
                        duidelijk te bepalen welke statuscode we nodig hebben -->
                    <status value="{$operationOutcome/outcome/status/@value}"/>
                    <outcome xmlns="http://hl7.org/fhir">
                        <xsl:copy-of select="$operationOutcome/outcome/f:OperationOutcome"
                            exclude-result-prefixes="#all"/>
                    </outcome>
                </xsl:when>
                <xsl:otherwise>
                    <status value="201 Created"/>
                </xsl:otherwise>
            </xsl:choose>
        </response>
    </xsl:template>


    <xd:doc>
        <xd:desc>
            <xd:p>Build the response for a secondary resource that will not be stored</xd:p>
            <xd:p>status '200 OK' as described in the V0.9FHIR_IG_R4 §2.11 MO</xd:p>
            <xd:p>status '202 Accepted' for resources we are not going to modify</xd:p>
        </xd:desc>
        <xd:param name="statusCode">set other than default 200 code</xd:param>
    </xd:doc>
    <xsl:template name="buildTransactionNoStoreResponse">
        <xsl:param name="statusCode" select="200"/>

        <xsl:variable xmlns="" name="mapStatusCode" as="element(map)+">
            <map statusCode="200" description="200 OK"/>
            <map statusCode="202" description="202 Accepted"/>
        </xsl:variable>

        <response>
            <status value="{$mapStatusCode[@statusCode = $statusCode]/@description}"/>
        </response>

    </xsl:template>


    <xd:doc>
        <xd:desc>
            <xd:p>Bouw de response voor een resource die niet ondersteund wordt wordt</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="buildNotSupportedResponse">

        <response>
            <OperationOutcome xmlns="http://hl7.org/fhir"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
                <issue>
                    <severity value="error"/>
                    <code value="not-supported"/>
                    <details>
                        <text value="Unsupported code value"/>
                    </details>
                </issue>
            </OperationOutcome>
            <status value="422 Unprocessable Entity"/>
        </response>

    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>Build the default search response</xd:p>
            <xd:p>This allows to determine the result</xd:p>
        </xd:desc>
        <xd:param name="response">Original response</xd:param>
        <xd:param name="patientID"/>
    </xd:doc>
    <xsl:template name="buildSearchResponse">
        <xsl:param name="response"/>
        <xsl:param name="patientID"/>

        <xsl:variable name="operationOutcome">
            <xsl:apply-templates select="$response" mode="error-detect">
                <xsl:with-param name="patientID" select="$patientID"/>
            </xsl:apply-templates>
        </xsl:variable>
        <search>
            <xsl:choose>
                <xsl:when test="local-name($operationOutcome/*) = 'outcome'">
                    <!-- voorlopig zet ik de status op de HTTP foutcode die ik in de outcome gezet heb.
                        De outcome kan meer dan 1 OutcomeOperation hebben en dan is niet 
                        duidelijk te bepalen welke statuscode we nodig hebben -->
                    <mode value="outcome"/>
                    <outcome xmlns="http://hl7.org/fhir">
                        <xsl:copy-of select="$operationOutcome/outcome/f:OperationOutcome"
                            exclude-result-prefixes="#all"/>
                    </outcome>
                </xsl:when>
                <xsl:otherwise>
                    <mode value="search"/>
                </xsl:otherwise>
            </xsl:choose>
        </search>

    </xsl:template>
</xsl:stylesheet>
