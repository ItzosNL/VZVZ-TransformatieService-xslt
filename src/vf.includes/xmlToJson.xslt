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
    xmlns="http://hl7.org/fhir"
    exclude-result-prefixes="xs"
    version="2.0">
        <xsl:output method="text" encoding="utf-8"/>
        
        <xsl:template match="/">
            <xsl:apply-templates select="." mode="toJSON"/>
        </xsl:template>
    
        <xsl:template match="/*[node()]" mode="toJSON">
            <xsl:text>{</xsl:text>
            <xsl:apply-templates select="." mode="detect" />
            <xsl:text>}</xsl:text>
        </xsl:template>
        
        <xsl:template match="*" mode="detect">
            <xsl:choose>
                <xsl:when test="name(preceding-sibling::*[1]) = name(current()) and name(following-sibling::*[1]) != name(current())">
                    <xsl:apply-templates select="." mode="obj-content" />
                    <xsl:text>]</xsl:text>
                    <xsl:if test="count(following-sibling::*[name() != name(current())]) &gt; 0">, </xsl:if>
                </xsl:when>
                <xsl:when test="name(preceding-sibling::*[1]) = name(current())">
                    <xsl:apply-templates select="." mode="obj-content" />
                    <xsl:if test="name(following-sibling::*) = name(current())">, </xsl:if>
                </xsl:when>
                <xsl:when test="following-sibling::*[1][name() = name(current())]">
                    <xsl:text>"</xsl:text><xsl:value-of select="name()"/><xsl:text>" : [</xsl:text>
                    <xsl:apply-templates select="." mode="obj-content" /><xsl:text>, </xsl:text>
                </xsl:when>
                <xsl:when test="count(./child::*) > 0 or count(@*) > 0">
                    <xsl:text>"</xsl:text><xsl:value-of select="name()"/>" : <xsl:apply-templates select="." mode="obj-content" />
                    <xsl:if test="count(following-sibling::*) &gt; 0">, </xsl:if>
                </xsl:when>
                <xsl:when test="count(./child::*) = 0">
                    <xsl:text>"</xsl:text><xsl:value-of select="name()"/>" : "<xsl:apply-templates select="." mode="toJSON"/><xsl:text>"</xsl:text>
                    <xsl:if test="count(following-sibling::*) &gt; 0">, </xsl:if>
                </xsl:when>
            </xsl:choose>
        </xsl:template>
        
        <xsl:template match="*" mode="obj-content">
            <xsl:text>{</xsl:text>
            <xsl:apply-templates select="@*" mode="attr" />
            <xsl:if test="count(@*) &gt; 0 and (count(child::*) &gt; 0 or text())">, </xsl:if>
            <xsl:apply-templates select="./*" mode="detect" />
            <xsl:if test="count(child::*) = 0 and text() and not(@*)">
                <xsl:text>"</xsl:text><xsl:value-of select="name()"/>" : "<xsl:value-of select="text()"/><xsl:text>"</xsl:text>
            </xsl:if>
            <xsl:if test="count(child::*) = 0 and text() and @*">
                <xsl:text>"text" : "</xsl:text><xsl:value-of select="text()"/><xsl:text>"</xsl:text>
            </xsl:if>
            <xsl:text>}</xsl:text>
            <xsl:if test="position() &lt; last()">, </xsl:if>
        </xsl:template>
        
        <xsl:template match="@*" mode="attr">
            <xsl:text>"</xsl:text><xsl:value-of select="name()"/>" : "<xsl:value-of select="."/><xsl:text>"</xsl:text>
            <xsl:if test="position() &lt; last()">,</xsl:if>
        </xsl:template>
        
        <xsl:template match="node/@TEXT | text()" name="removeBreaks">
            <xsl:param name="pText" select="normalize-space(.)"/>
            <xsl:choose>
                <xsl:when test="not(contains($pText, '&#xA;'))"><xsl:copy-of select="$pText"/></xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat(substring-before($pText, '&#xD;&#xA;'), ' ')"/>
                    <xsl:call-template name="removeBreaks">
                        <xsl:with-param name="pText" select="substring-after($pText, '&#xD;&#xA;')"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:template>
        
</xsl:stylesheet>