<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:f="http://hl7.org/fhir" 
    xmlns:hl7="urn:hl7-org:v3"
    xmlns:hl7nl="urn:hl7-nl:v3"
    xmlns:vf="http://www.vzvz.nl/functions" 
    xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:saxon="http://saxon.sf.net/"
    xmlns:util="urn:hl7:utilities"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs xsi vf s xd hl7 hl7nl math saxon util f" 
    version="3.0"
    xmlns="urn:hl7-org:v3">
    
    <xsl:import href="vf.transformation-utils.xsl"/>
    <xsl:import href="vf.datetime-functions.xsl"/>
    
    <!-- versionXSLT = versienummer van DEZE transformatie -->
    <!-- 2025-01-21 remove original query param because the necessary ids are part of the metadata, so this file becomes backwards incompatible
        with the previous version
    -->
    <xsl:variable name="vf:versionXSLT" as="xs:string">1.0.0</xsl:variable>
    <xsl:variable name="transformationCode" select="'dummy'"/>


    <xd:doc scope="stylesheet">
        <xd:desc>All helper templates and functions for the conversion to HL7 V3</xd:desc>
    </xd:doc>

    <xd:doc>
        <xd:desc>
            <xd:p>Build the document fragment for authorOrPerformer from the metaData</xd:p>
            <xd:ul>
                <xd:li>'2.16.528.1.1007.3.1' = UZI persoon</xd:li>
                <xd:li>'2.16.528.1.1007.3.2' = UZI servercertificaat</xd:li>
                <xd:li>'2.16.528.1.1007.3.3' = URA</xd:li>
                <xd:li>'2.16.840.1.113883.2.4.6.3' = BSN</xd:li>
                <xd:li>'2.16.840.1.113883.2.4.6.6' = appID</xd:li>
            </xd:ul>
        </xd:desc>
        <xd:param name="author">metaData section that contains the info</xd:param>
    </xd:doc>
    <xsl:template name="buildAuthorOrPerformer">
        <xsl:param name="author"/>

        <authorOrPerformer xmlns="urn:hl7-org:v3" typeCode="AUT">
            <participant>
                <xsl:choose>
                    <xsl:when
                        test="$author/ID[contains(., '2.16.528.1.1007.3.1') or contains(., '2.16.840.1.113883.2.4.6.3')]">
                        <xsl:call-template name="buildAssignedPerson">
                            <xsl:with-param name="person" select="$author"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$author/ID[
                            contains(., '2.16.528.1.1007.3.2') or
                            contains(., '2.16.528.1.1007.3.3') or
                            contains(., '2.16.840.1.113883.2.4.6.6')]
                            ">
                        <xsl:call-template name="buildAssignedDevice">
                            <xsl:with-param name="device" select="$author"/>
                        </xsl:call-template>
                    </xsl:when>
                </xsl:choose>
            </participant>
        </authorOrPerformer>
    </xsl:template>

    <xd:doc>
        <xd:desc>Build the document fragment for overseer from the metaData</xd:desc>
        <xd:param name="overseer">metaData section that contains the info</xd:param>
    </xd:doc>
    <xsl:template name="buildOverseer">
        <xsl:param name="overseer"/>

        <overseer xmlns="urn:hl7-org:v3" typeCode="RESP">
            <xsl:choose>
                <xsl:when
                    test="contains($overseer/ID, '2.16.528.1.1007.3.1') or contains($overseer/ID, '2.16.840.1.113883.2.4.6.3')">
                    <xsl:call-template name="buildAssignedPerson">
                        <xsl:with-param name="person" select="$overseer"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when
                    test="contains($overseer/ID, '2.16.528.1.1007.3.2') or contains($overseer/ID, '2.16.528.1.1007.3.3')">
                    <xsl:call-template name="buildAssignedDevice">
                        <xsl:with-param name="device" select="$overseer"/>
                        <xsl:with-param name="elementName" select="'assignedEntity'"/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>
        </overseer>
    </xsl:template>

    <xd:doc>
        <xd:desc>Build the document fragment for overseer from the metaData</xd:desc>
        <xd:param name="author">metaData section that contains the info</xd:param>
    </xd:doc>
    <xsl:template name="buildOverseerFromAuthor">
        <xsl:param name="author"/>

        <xsl:variable name="authorPerformer">
            <xsl:call-template name="buildAuthorOrPerformer">
                <xsl:with-param name="author" select="$author"/>
            </xsl:call-template>
        </xsl:variable>
        <overseer xmlns="urn:hl7-org:v3" typeCode="RESP">
            <xsl:sequence select="$authorPerformer//hl7:participant/*"/>
        </overseer>
    </xsl:template>

    <xd:doc>
        <xd:desc>Build the document fragment for AssignedPerson from the metaData</xd:desc>
        <xd:param name="person">metaData section that contains the info</xd:param>
    </xd:doc>

    <xsl:template name="buildAssignedPerson">
        <xsl:param name="person"/>

        <AssignedPerson xmlns="urn:hl7-org:v3">
            <xsl:call-template name="splitMetaOID">
                <xsl:with-param name="oid" select="$person/ID"/>
            </xsl:call-template>
            <xsl:variable name="tmp">
                <xsl:call-template name="splitMetaOID">
                    <xsl:with-param name="oid" select="$person/Role"/>
                </xsl:call-template>
            </xsl:variable>
            <code code="{$tmp//hl7:id/@extension}" codeSystem="{$tmp//hl7:id/@root}"/>
            <xsl:choose>
                <xsl:when test="exists($person/AssignedPerson)">
                    <assignedPrincipalChoiceList>
                        <assignedPerson>
                            <name><xsl:value-of select="$person/AssignedPerson/Name"/></name>
                        </assignedPerson>
                    </assignedPrincipalChoiceList>
                </xsl:when>
                <xsl:otherwise>
                    <!-- 2023-08-28 AOF-1598: add dummy values for missing elements -->
                    <assignedPrincipalChoiceList>
                        <assignedPerson>
                            <name>N/A</name>
                        </assignedPerson>
                    </assignedPrincipalChoiceList>
                </xsl:otherwise>
            </xsl:choose>
            <Organization>
                <xsl:call-template name="splitMetaOID">
                    <xsl:with-param name="oid" select="$person/Org/ID"/>
                </xsl:call-template>
                <xsl:choose>
                    <xsl:when test="exists($person/Org/Name)">
                        <name><xsl:value-of select="$person/Org/Name"/></name>                        
                    </xsl:when>
                    <xsl:otherwise>
                        <name>N/A</name>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="exists($person/Org/Place)">
                        <addr>
                            <city><xsl:value-of select="$person/Org/Place"/></city>
                        </addr>                        
                    </xsl:when>
                    <xsl:otherwise>
                        <addr>
                            <city>N/A</city>
                        </addr>
                    </xsl:otherwise>
                </xsl:choose>
            </Organization>
        </AssignedPerson>

    </xsl:template>

    <xd:doc>
        <xd:desc>Build the document fragment for AssignedDevice from the metaData</xd:desc>
        <xd:param name="device">metaData section that contains the info</xd:param>
        <xd:param name="elementName">name of the surrounding element, defaults to AssignedDevice</xd:param>
    </xd:doc>

    <xsl:template name="buildAssignedDevice">
        <xsl:param name="device"/>
        <xsl:param name="elementName" select="'AssignedDevice'"/>

        <xsl:element name="{$elementName}" namespace="urn:hl7-org:v3">
            <xsl:for-each select="$device/ID">
                <xsl:call-template name="splitMetaOID">
                    <xsl:with-param name="oid" select="."/>
                </xsl:call-template>
            </xsl:for-each>
            <!-- AOF-2380 add a dummy UZI nummer systemen because it matches v3 messages in production
                although we think it's not used
            -->
            <id root="2.16.528.1.1007.3.2" extension="123412345"/>
            <Organization xmlns="urn:hl7-org:v3">
                <xsl:call-template name="splitMetaOID">
                    <xsl:with-param name="oid" select="$device/Org/ID"/>
                </xsl:call-template>
                <xsl:choose>
                    <xsl:when test="exists($device/Org/Name)">
                        <name><xsl:value-of select="$device/Org/Name"/></name>                        
                    </xsl:when>
                    <xsl:otherwise>
                        <name>N/A</name>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="exists($device/Org/Place)">
                        <addr>
                            <city><xsl:value-of select="$device/Org/Place"/></city>
                        </addr>                        
                    </xsl:when>
                    <xsl:otherwise>
                        <addr>
                            <city>N/A</city>
                        </addr>
                    </xsl:otherwise>
                </xsl:choose>
            </Organization>
        </xsl:element>

    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xsl:p>Build the wrapper elements for a 'normal' query response</xsl:p>
        </xd:desc>
        <xd:param name="buildingBlock">Type of building block that is processed</xd:param>
        <xd:param name="hasOverseer">Message has overseer, default = false()</xd:param>
        <xd:param name="metaData">the original parameter with metadata. Processing is done
            here</xd:param>
        <xd:param name="payload">the original payload that is already fixed with the correct
            template</xd:param>
        <xd:param name="transformationCode">transformationCode of the current
            transformation</xd:param>
        <xd:param name="versionXSLT">version of the XSLT that performs the transformation</xd:param>
        <!-- 2025-01-21 remove original query param because the necessary ids are part of the metadata -->
        <!--<xd:param name="originalQuery">The original query message to get some extra
            metadata</xd:param>-->
    </xd:doc>
    <xsl:template name="buildWrapperElements">
        <xsl:param name="buildingBlock"/>
        <xsl:param name="hasOverseer" select="false()"/>
        <xsl:param name="metaData"/>
        <xsl:param name="payload"/>
        <xsl:param name="transformationCode"/>
        <xsl:param name="versionXSLT"/>
        <!-- 2025-01-21 remove original query param because the necessary ids are part of the metadata -->
<!--        <xsl:param name="originalQuery"/>-->

        <xsl:variable name="interactionID" as="xs:string"
            select="$mapAORTAWrapper[@buildingblock = $buildingBlock]/@interactionId"/>
        <xsl:variable name="isPushMessage" select="vf:isPushMessage($buildingBlock)" as="xs:boolean"/>

        <!-- convert metaData parameter to a document node -->
        <xsl:variable name="metaDataObj">
            <xsl:call-template name="convertToDocumentNode">
                <xsl:with-param name="xml" select="$metaData"/>
                <xsl:with-param name="msg">
                    <xsl:text>Metadata object niet beschikbaar</xsl:text>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="queryResponse">
            <xsl:choose>
                <xsl:when test="not($isPushMessage)">
                    <!-- there is an 'original query' -->

                    <!-- convert originalQuery parameter to a document node -->
                    <!-- 2025-01-21 remove original query param because the necessary ids are part of the metadata -->
<!--                    <xsl:variable name="originalQueryObj">
                        <xsl:call-template name="convertToDocumentNode">
                            <xsl:with-param name="xml" select="$originalQuery"/>
                            <xsl:with-param name="msg">Origineel v3 bericht niet beschikbaar</xsl:with-param>
                        </xsl:call-template>
                    </xsl:variable>
-->
                    <!-- get the metadata we need from the original query message -->
                    <xsl:variable name="queryMessage">
                        <xsl:variable name="queryInteractionID" as="xs:string"
                            select="$mapAORTAWrapper[@buildingblock = $buildingBlock]/@queryInteractionId"/>

                        <xsl:choose>
                            <xsl:when test="exists($metaDataObj/Meta/OrigMessageId) and exists($metaDataObj/Meta/OrigQueryId)">
                                <xsl:choose>
                                    <xsl:when test="contains($metaDataObj/Meta/OrigMessageId, '|')">
                                        <xsl:call-template name="splitMetaOID">
                                            <xsl:with-param name="oid" select="$metaDataObj/Meta/OrigMessageId"/>
                                        </xsl:call-template>                                        
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <id xmlns="urn:hl7-org:v3" extension="{$metaDataObj/Meta/OrigMessageId}"
                                            root="2.16.840.1.113883.2.4.6.6.1.1"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:choose>
                                    <xsl:when test="contains($metaDataObj/Meta/OrigQueryId, '|')">
                                        <xsl:call-template name="splitMetaOID">
                                    <xsl:with-param name="oid" select="$metaDataObj/Meta/OrigQueryId"/>
                                    <xsl:with-param name="element" select="'queryId'"/>
                                </xsl:call-template>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <queryId xmlns="urn:hl7-org:v3" extension="{$metaDataObj/Meta/OrigQueryId}"
                                            root="2.16.840.1.113883.2.4.6.6.1.2"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <!-- 2025-01-21 remove original query param because the necessary ids are part of the metadata -->
<!--                            <xsl:when test="exists($originalQueryObj/hl7:id)">
                                <xsl:variable name="firstChild"
                                    select="$originalQueryObj/*[local-name() = $queryInteractionID]"/>
                                <!-\- xsl:variable name="test" select="local-name($firstChild)" as="xs:string"/>-\->
                                
                                <!-\- id of the message we respond to -\->
                                <xsl:sequence select="$firstChild/hl7:id"/>

                                <!-\- queryID of query we respond to -\->
                                <xsl:sequence
                                    select="$firstChild//hl7:ControlActProcess/hl7:queryByParameter/hl7:queryId"
                                />
                            </xsl:when>
-->
                            <xsl:otherwise>
                                <!-- dummy id -->
                                <id xmlns="urn:hl7-org:v3" extension="0012345678"
                                    root="2.16.840.1.113883.2.4.6.6.1.1"/>
                                <queryId xmlns="urn:hl7-org:v3" extension="0000123456"
                                    root="2.16.840.1.113883.2.4.6.6.1.2"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>

                    <acknowledgement xmlns="urn:hl7-org:v3" typeCode="AA">
                        <targetMessage>
                            <xsl:sequence select="$queryMessage/hl7:id"/>
                        </targetMessage>
                    </acknowledgement>
                    <queryAck xmlns="urn:hl7-org:v3">
                        <xsl:sequence select="$queryMessage/hl7:queryId"/>
                        <queryResponseCode code="OK"/>
                        <resultTotalQuantity value="1"/>
                        <resultCurrentQuantity value="1"/>
                        <resultRemainingQuantity value="0"/>
                    </queryAck>

                </xsl:when>
                <xsl:otherwise>
                    <acknowledgement/>
                    <queryAck/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- 2.16.840.1.113883.2.4.3.111.19.2 vastgelegd als root van Message-id's van getransformeerde berichten -->
        <id xmlns="urn:hl7-org:v3" extension="{vf:UUID4()}" root="2.16.840.1.113883.2.4.3.111.19.2"/>

        <creationTime xmlns="urn:hl7-org:v3"
            value="{vf:dateTimeFHIR_V3(string(current-dateTime()), true())}"/>
        <versionCode xmlns="urn:hl7-org:v3" code="NICTIZEd2005-Okt"/>
        <interactionId xmlns="urn:hl7-org:v3" extension="{$interactionID}"
            root="2.16.840.1.113883.1.6"/>
        <profileId xmlns="urn:hl7-org:v3" root="2.16.840.1.113883.2.4.3.11.1" extension="810"/>
        <processingCode xmlns="urn:hl7-org:v3" code="P"/>
        <processingModeCode xmlns="urn:hl7-org:v3" code="T"/>
        <acceptAckCode xmlns="urn:hl7-org:v3" code="{if ($isPushMessage) then 'AL' else 'NE'}"/>
        <xsl:if test="not($isPushMessage)">
            <!-- there is an original query -->
            <xsl:sequence select="$queryResponse/hl7:acknowledgement"/>
        </xsl:if>

        <xsl:if test="$isPushMessage">
            <!-- include BSN -->
            <attentionLine xmlns="urn:hl7-org:v3">
                <keyWordText code="PATID" codeSystem="2.16.840.1.113883.2.4.15.1"
                    >Patient.id</keyWordText>
                <value xsi:type="II" root="2.16.840.1.113883.2.4.6.3"
                    extension="{$metaDataObj/Meta/Patient}"/>
            </attentionLine>
        </xsl:if>
        <xsl:call-template name="addTransformationCode">
            <xsl:with-param name="transformationCode" select="$transformationCode"/>
            <xsl:with-param name="type" select="'v3'"/>
            <xsl:with-param name="versionXSLT" select="$versionXSLT"/>
        </xsl:call-template>
        <receiver xmlns="urn:hl7-org:v3">
            <device>
                <xsl:call-template name="splitMetaOID">
                    <xsl:with-param name="oid" select="$metaDataObj/Meta/Receiver"/>
                </xsl:call-template>
            </device>
        </receiver>
        <sender xmlns="urn:hl7-org:v3">
            <device>
                <xsl:call-template name="splitMetaOID">
                    <xsl:with-param name="oid" select="$metaDataObj/Meta/Sender"/>
                </xsl:call-template>
            </device>
        </sender>
        <ControlActProcess xmlns="urn:hl7-org:v3" moodCode="EVN">
            <xsl:call-template name="buildAuthorOrPerformer">
                <xsl:with-param name="author" select="$metaDataObj/Meta/Author"/>
            </xsl:call-template>
            <xsl:choose>
                <xsl:when test="$hasOverseer and exists($metaDataObj/Meta/Overseer)">
                    <xsl:call-template name="buildOverseer">
                        <xsl:with-param name="overseer" select="$metaDataObj/Meta/Overseer"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="$hasOverseer and vf:isMedMij($buildingBlock)">
                    <!-- build overseer from author because an overseer is required -->
                    <xsl:call-template name="buildOverseerFromAuthor">
                        <xsl:with-param name="author" select="$metaDataObj/Meta/Author"/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>

            <xsl:for-each select="$payload/hl7:organizer | $payload/hl7:ClinicalDocument">
                <subject>
                    <xsl:choose>
                        <xsl:when test="exists($payload/hl7:organizer) and not(exists($payload/hl7:organizer/hl7:recordTarget))">
                            <organizer>
                                <xsl:copy-of select="@*"/>
                                <xsl:copy-of select="$payload/hl7:organizer/hl7:templateId"/>
                                <xsl:copy-of select="$payload/hl7:organizer/hl7:code"/>
                                <xsl:copy-of select="$payload/hl7:organizer/hl7:statusCode"/>
                                <recordTarget>
                                    <patientRole>
                                        <xsl:call-template name="splitMetaOID">
                                            <xsl:with-param name="oid" select="$metaDataObj/Meta/Patient"/>
                                        </xsl:call-template> 
                                    </patientRole>
                                </recordTarget>
                                <xsl:copy-of select="$payload/hl7:organizer/hl7:component"/>
                            </organizer>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="."/>                            
                        </xsl:otherwise>
                    </xsl:choose>
                </subject>                
            </xsl:for-each>
            <xsl:if test="not($isPushMessage)">
                <!-- there is an original query -->

                <xsl:sequence select="$queryResponse/hl7:queryAck"/>
            </xsl:if>
        </ControlActProcess>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>Fix templateID</xd:p>
            <xd:p>But not for push messages</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="/hl7:organizer/hl7:templateId" mode="wrapper">
        <xsl:choose>
            <xsl:when test="vf:isPushMessage($buildingBlock)">
                <xsl:sequence select="."/>
            </xsl:when>
            <xsl:otherwise>
                <templateId xmlns="urn:hl7-org:v3"
                    root="{$mapAORTAWrapper[@buildingblock=$buildingBlock]/@organizerTemplateId}"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xd:doc>
        <xd:desc>Build the content of the V3 acknowledgement</xd:desc>
        <xd:param name="buildingBlock"/>
        <xd:param name="payload"/>
        <xd:param name="ackResultObj"/>
    </xd:doc>
    <xsl:template name="buildAcknowledgement">
        <xsl:param name="buildingBlock"/>
        <xsl:param name="payload"/>
        <xsl:param name="ackResultObj"/>

        <!-- id of the message we respond to -->
        <xsl:variable name="targetMessageID">
            <xsl:variable name="interactionId"
                select="$mapAORTAWrapper[@buildingblock = $buildingBlock]/@interactionId"/>
            <xsl:choose>
                <xsl:when test="exists($payload/child::*[name() = $interactionId])">
                    <xsl:sequence select="$payload/child::*[name() = $interactionId]/hl7:id"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- dummy id -->
                    <id extension="0012345678" root="2.16.840.1.113883.2.4.6.6.1.1"
                        xsl:exclude-result-prefixes="#all"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="$ackResultObj//f:Bundle/f:type[@value = 'transaction-response']">
                <!-- it's ok -->
                <acknowledgement typeCode="AA">
                    <targetMessage>
                        <xsl:sequence select="$targetMessageID"/>
                    </targetMessage>
                </acknowledgement>
            </xsl:when>
            <xsl:when test="$ackResultObj//f:OperationOutcome">
                <acknowledgement typeCode="CE">
                    <acknowledgementDetail>
                        <code xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" code="SYN105"
                            codeSystem="2.16.840.1.113883.5.1100"
                            displayName="Required element missing" xsi:type="CV"/>
                        <text>
                            <xsl:value-of
                                select="$ackResultObj//f:OperationOutcome/f:issue[1]/f:details/f:text/@value"
                            />
                        </text>
                    </acknowledgementDetail>
                    <targetMessage>
                        <xsl:sequence select="$targetMessageID"/>
                    </targetMessage>
                </acknowledgement>
            </xsl:when>
            <xsl:otherwise>
                <!-- TODO: is SYN105 de meest logische fout voor 'het is onduidelijk wat we ontvangen hebben'? -->
                <acknowledgement typeCode="CE">
                    <acknowledgementDetail>
                        <code xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" code="SYN105"
                            codeSystem="2.16.840.1.113883.5.1100"
                            displayName="Required element missing" xsi:type="CV"/>
                        <text>Een verplicht element is niet aanwezig: Bundle.type of
                            OperationOutcome</text>
                    </acknowledgementDetail>
                    <targetMessage>
                        <xsl:sequence select="$targetMessageID"/>
                    </targetMessage>
                </acknowledgement>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xd:doc>
        <xd:desc>Build the full V3 Acknowledgement message</xd:desc>
        <xd:param name="buildingBlock">The code of the interaction to use</xd:param>
        <xd:param name="payload">The original V3 message this is a response to</xd:param>
        <xd:param name="ackResult">The answer that the receiving system sent</xd:param>
        <xd:param name="metaData">The object with the meta data</xd:param>
        <xd:param name="transformationCode">The transformation code of this
            transformation</xd:param>
        <xd:param name="versionXSLT">The version of this transformation</xd:param>
    </xd:doc>
    <xsl:template name="buildV3AcknowledgementMessage">
        <xsl:param name="buildingBlock"/>
        <xsl:param name="payload"/>
        <xsl:param name="ackResult"/>
        <xsl:param name="metaData"/>
        <xsl:param name="transformationCode"/>
        <xsl:param name="versionXSLT"/>

        <!-- convert parameter to a Document node -->
        <xsl:variable name="ackResultObj">
            <xsl:call-template name="convertToDocumentNode">
                <xsl:with-param name="xml" select="$ackResult"/>
                <xsl:with-param name="msg">Fhir response bericht niet beschikbaar</xsl:with-param>
            </xsl:call-template>
        </xsl:variable>

        <!-- convert parameter to a Document node -->

        <xsl:variable name="metaDataObj">
            <xsl:call-template name="convertToDocumentNode">
                <xsl:with-param name="xml" select="$metaData"/>
                <xsl:with-param name="msg">
                    <xsl:text>Metadata object niet beschikbaar</xsl:text>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:variable>

        <!-- find out if it's an OK message or an error -->
        <xsl:variable name="acknowledgement">
            <xsl:call-template name="buildAcknowledgement">
                <xsl:with-param name="buildingBlock" select="$buildingBlock"/>
                <xsl:with-param name="payload" select="$payload"/>
                <xsl:with-param name="ackResultObj" select="$ackResultObj"/>
            </xsl:call-template>
        </xsl:variable>

        <MCCI_IN000002 xmlns="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="urn:hl7-org:v3 ../XML/schemas/MCCI_IN000002.xsd">
            <!-- Transport Wrapper -->
            <id extension="{vf:UUID4()}" root="2.16.840.1.113883.2.4.3.111.19.2"/>
            <creationTime value="{vf:dateTimeFHIR_V3(string(current-dateTime()), true())}"/>
            <versionCode code="NICTIZEd2005-Okt"/>
            <interactionId extension="MCCI_IN000002" root="2.16.840.1.113883.1.6"/>
            <profileId root="2.16.840.1.113883.2.4.3.11.1" extension="810"/>
            <processingCode code="P"/>
            <processingModeCode code="T"/>
            <!-- accept acks dienen zelf nooit ge-acked te worden -->
            <acceptAckCode code="NE"/>
            <!-- CA = accept/commit-level ack -->
            <xsl:sequence select="$acknowledgement"/>
            <xsl:call-template name="addTransformationCode">
                <xsl:with-param name="transformationCode" select="$transformationCode"/>
                <xsl:with-param name="type" select="'v3'"/>
                <xsl:with-param name="versionXSLT" select="$versionXSLT"/>
            </xsl:call-template>
            <receiver>
                <device>
                    <xsl:call-template name="splitMetaOID">
                        <xsl:with-param name="oid" select="$metaDataObj/Meta/Receiver"/>
                    </xsl:call-template>
                </device>
            </receiver>
            <sender>
                <device>
                    <xsl:call-template name="splitMetaOID">
                        <xsl:with-param name="oid" select="$metaDataObj/Meta/Sender"/>
                    </xsl:call-template>
                </device>
            </sender>
        </MCCI_IN000002>
    </xsl:template>

    <xd:doc>
        <xd:desc>Build the V3 interaction message</xd:desc>
        <xd:param name="xslDebug">define if schematron/schemas should be include</xd:param>
        <xd:param name="schematronRef">schematron files to be included</xd:param>
        <xd:param name="schematronRefZT">schematron files of the Zorgtoepassing to be
            included</xd:param>
        <xd:param name="schemaRefDir">directory of the XML schema definition to be
            included</xd:param>
        <xd:param name="buildingBlock">which building block to use</xd:param>
        <xd:param name="metaData">meta data object to use</xd:param>
        <xd:param name="hasOverseer">does the original message have an overseer</xd:param>
        <!-- 2025-01-21 remove original query param because the necessary ids are part of the metadata -->
<!--        <xd:param name="originalQuery">the original query that is answered</xd:param>-->
        <xd:param name="payload">payload of the converted answer</xd:param>
        <xd:param name="transformationCode">code of this transformation</xd:param>
        <xd:param name="versionXSLT">version of this transformation</xd:param>
    </xd:doc>
    <xsl:template name="buildV3message">
        <xsl:param name="xslDebug"/>
        <xsl:param name="schematronRef"/>
        <xsl:param name="schematronRefZT"/>
        <xsl:param name="schemaRefDir" select="concat('file:', $svnAortaMP9, '/schemas')"/>
        <xsl:param name="buildingBlock"/>
        <xsl:param name="metaData"/>
        <xsl:param name="hasOverseer" select="false()"/>
        <!-- 2025-01-21 remove original query param because the necessary ids are part of the metadata -->
<!--        <xsl:param name="originalQuery"/>-->
        <xsl:param name="payload"/>
        <xsl:param name="transformationCode"/>
        <xsl:param name="versionXSLT"/>

        <xsl:if test="$xslDebug">
            <xsl:processing-instruction name="xml-model">phase="#ALL" href="<xsl:value-of select="$schematronRef"/>" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:processing-instruction>
            <xsl:if test="string-length($schematronRefZT) &gt; 0">
                <xsl:processing-instruction name="xml-model">phase="#ALL" href="<xsl:value-of select="$schematronRefZT"/>" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:processing-instruction>
            </xsl:if>
        </xsl:if>

        <xsl:variable name="interactionId"
            select="$mapAORTAWrapper[@buildingblock = $buildingBlock]/@interactionId" as="xs:string"/>

        <xsl:element name="{$interactionId}" namespace="urn:hl7-org:v3">
            <xsl:if test="$xslDebug">
                <xsl:variable name="schemaRef"
                    select="concat($schemaRefDir, '/', $mapAORTAWrapper[@buildingblock = $buildingBlock]/@interactionId, '.xsd')"/>
                <xsl:attribute name="xsi:schemaLocation">urn:hl7-org:v3 <xsl:value-of
                        select="$schemaRef"/></xsl:attribute>
            </xsl:if>

            <xsl:call-template name="buildWrapperElements">
                <xsl:with-param name="buildingBlock" select="$buildingBlock"/>
                <xsl:with-param name="hasOverseer" select="$hasOverseer"/>
                <xsl:with-param name="metaData" select="$metaData"/>
                <!-- 2025-01-21 remove original query param because the necessary ids are part of the metadata -->
<!--                <xsl:with-param name="originalQuery" select="$originalQuery"/>-->
                <xsl:with-param name="payload" select="$payload"/>
                <xsl:with-param name="transformationCode" select="$transformationCode"/>
                <xsl:with-param name="versionXSLT" select="$versionXSLT"/>
            </xsl:call-template>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
