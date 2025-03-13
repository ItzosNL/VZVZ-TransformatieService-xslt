<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:hl7="urn:hl7-org:v3" 
    xmlns:hl7nl="urn:hl7-nl:v3" 
    xmlns:math="http://exslt.org/math"
    xmlns:func="http://exslt.org/functions" 
    xmlns:vf="http://www.vzvz.nl/functions" 
    extension-element-prefixes="func math vf" exclude-result-prefixes="#all" version="2.0">

    <xd:doc>
        <xd:desc>
            <xd:p>converteer Author naar Practitioner</xd:p>
            <xd:p>Version: 0.1.0</xd:p>
        </xd:desc>
        <xd:param name="Author">Author object</xd:param>
    </xd:doc>
    <xsl:template name="GetAuthor">
        <xsl:param name="Author"/>
        
        <xsl:choose>
            <xsl:when
                test="$Author/hl7:participantRole/hl7:id or $Author/hl7:participantRole/hl7:playingEntity/hl7:name">
                <Practitioner xmlns="http://hl7.org/fhir">
                    <id value="author"/>
                    <xsl:if
                        test="$Author/hl7:participantRole/hl7:id and not($Author/hl7:participantRole/hl7:id/@nullFlavor)">
                        <identifier>
                            <xsl:choose>
                                <xsl:when
                                    test="$Author/hl7:participantRole/hl7:id/@root = '2.16.528.1.1007.3.1'">
                                    <system value="http://fhir.nl/fhir/NamingSystem/uzi-nr-pers"/>
                                </xsl:when>
                                <xsl:when
                                    test="$Author/hl7:participantRole/hl7:id/@root = '2.16.840.1.113883.2.4.6.1'">
                                    <system value="http://fhir.nl/fhir/NamingSystem/agb-z"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <system
                                        value="urn:oid:{$Author/hl7:participantRole/hl7:id/@root}"/>
                                </xsl:otherwise>
                            </xsl:choose>
                            <value value="{$Author/hl7:participantRole/hl7:id/@extension}"/>
                        </identifier>
                    </xsl:if>
                    <xsl:if test="$Author/hl7:participantRole/hl7:playingEntity/hl7:name">
                        <name>
                            <text value="{vf:GetAuthorDisp($Author)}"/>
                            <xsl:if
                                test="$Author/hl7:participantRole/hl7:playingEntity/hl7:name/hl7:family">
                                <family
                                    value="{$Author/hl7:participantRole/hl7:playingEntity/hl7:name/hl7:family}"
                                />
                            </xsl:if>
                            <xsl:if
                                test="$Author/hl7:participantRole/hl7:playingEntity/hl7:name/hl7:given/@qualifier = 'IN'">
                                <given
                                    value="{$Author/hl7:participantRole/hl7:playingEntity/hl7:name/hl7:given[@qualifier = 'IN']}">
                                    <extension
                                        url="http://hl7.org/fhir/StructureDefinition/iso21090-EN-qualifier">
                                        <valueCode value="IN"/>
                                    </extension>
                                </given>
                            </xsl:if>
                            <xsl:if
                                test="$Author/hl7:participantRole/hl7:playingEntity/hl7:name/hl7:given/@qualifier = 'BR'">
                                <given
                                    value="{$Author/hl7:participantRole/hl7:playingEntity/hl7:name/hl7:given[@qualifier = 'BR']}">
                                    <extension
                                        url="http://hl7.org/fhir/StructureDefinition/iso21090-EN-qualifier">
                                        <valueCode value="BR"/>
                                    </extension>
                                </given>
                            </xsl:if>
                        </name>
                    </xsl:if>
                </Practitioner>
            </xsl:when>
            <xsl:when
                test="$Author/hl7:participantRole/hl7:scopingEntity/hl7:id or $Author/hl7:participantRole/hl7:scopingEntity/hl7:desc">
                <Organization xmlns="http://hl7.org/fhir">
                    <id value="author"/>
                    <xsl:if
                        test="$Author/hl7:participantRole/hl7:scopingEntity/hl7:id and not($Author/hl7:participantRole/hl7:scopingEntity/hl7:id/@nullFlavor)">
                        <identifier>
                            <xsl:choose>
                                <xsl:when
                                    test="$Author/hl7:participantRole/hl7:id/@root = '2.16.528.1.1007.3.3'">
                                    <system value="http://fhir.nl/fhir/NamingSystem/ura"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <system
                                        value="urn:oid:{$Author/hl7:participantRole/hl7:scopingEntity/hl7:id/@root}"
                                    />
                                </xsl:otherwise>
                            </xsl:choose>
                            <value
                                value="{$Author/hl7:participantRole/hl7:scopingEntity/hl7:id/@extension}"
                            />
                        </identifier>
                    </xsl:if>
                    <xsl:if test="$Author/hl7:participantRole/hl7:scopingEntity/hl7:desc">
                        <name value="{$Author/hl7:participantRole/hl7:scopingEntity/hl7:desc}"/>
                    </xsl:if>
                </Organization>
            </xsl:when>
            <xsl:otherwise>
                <Practitioner xmlns="http://hl7.org/fhir">
                    <id value="author"/>
                    <name>
                        <family value="auteur onbekend"/>
                    </name>
                </Practitioner>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Haal author gegevens op voor display weergave</xd:desc>
        <xd:return>String met naam</xd:return>
        <xd:param name="Author"/>
    </xd:doc>
    <xsl:function name="vf:GetAuthorDisp">
        <xsl:param name="Author"/>
        
        <xsl:variable name="Disp">
            <xsl:choose>
                <xsl:when test="$Author/hl7:participantRole/hl7:playingEntity/hl7:name">
                    <xsl:choose>
                        <xsl:when
                            test="$Author/hl7:participantRole/hl7:playingEntity/hl7:name/hl7:family">
                            <xsl:if
                                test="$Author/hl7:participantRole/hl7:playingEntity/hl7:name/hl7:given">
                                <xsl:value-of
                                    select="$Author/hl7:participantRole/hl7:playingEntity/hl7:name/hl7:given"/>
                                <xsl:text> </xsl:text>
                            </xsl:if>
                            <xsl:value-of
                                select="$Author/hl7:participantRole/hl7:playingEntity/hl7:name/hl7:family"
                            />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of
                                select="$Author/hl7:participantRole/hl7:playingEntity/hl7:name"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$Author/hl7:participantRole/hl7:scopingEntity/hl7:desc">
                    <xsl:value-of select="$Author/hl7:participantRole/hl7:scopingEntity/hl7:desc"/>
                </xsl:when>
                <xsl:when test="$Author/hl7:participantRole/hl7:id">
                    <xsl:value-of select="$Author/hl7:participantRole/hl7:id/@extension"/>
                </xsl:when>
                <xsl:when test="$Author/hl7:participantRole/hl7:scopingEntity/hl7:id">
                    <xsl:value-of
                        select="$Author/hl7:participantRole/hl7:scopingEntity/hl7:id/@extension"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>auteur onbekend</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="$Disp"/>
    </xsl:function>    

</xsl:stylesheet>
