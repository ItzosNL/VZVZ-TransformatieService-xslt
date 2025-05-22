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
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    exclude-result-prefixes="xs math xd"
    version="3.0">
    
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>This stylesheet contains paths to repositories that are local</xd:p>
            <xd:p>to have a single place where all these locations can be modified</xd:p>
            <xd:p><xd:b>Created on:</xd:b> 2023-06-29</xd:p>
            <xd:p><xd:b>Author:</xd:b> vzvz</xd:p>
            <xd:p></xd:p>
        </xd:desc>
    </xd:doc>
    
    <!-- 
        Only this variable should be changed to the path of the project directory.
        All other variables reference this directory.
        
        Below is a dummy path, which will be overridden by the path in the projectpath.xsl file
      -->
<!--    <xsl:variable name="projectsDir">/path/to/transformation/root/directory</xsl:variable>-->
    
    <xsl:import href="../../projectpath.xsl" use-when="doc-available('../../projectpath.xsl')"/>
    
    <!-- 
        Reference to XML schemas and schematrons for validation of the XML output.
        They are only used when the xslDebug parameter is set to 'true', which is only
        relevant in dev and test environments.
      -->
    <xsl:variable name="svnAorta" select="concat($projectsDir, '/../SVN/aorta')"/>
    <xsl:variable name="svnAortaBranches" select="concat($svnAorta, '/branches')"/>
    <xsl:variable name="svnAortaTrunk" select="concat($svnAorta, '/trunk')"/>
    <xsl:variable name="svnAortaMP9" select="concat($svnAortaBranches, '/Onderhoud_Mp-VZVZ_v90/XML')"/>
    <xsl:variable name="svnAortaZTMP" select="concat($svnAortaTrunk, '/Zorgtoepassing/Medicatieproces/DECOR')"/>
    <xsl:variable name="svnAortaOpen" select="concat($svnAortaBranches, '/Onderhoud_Open_HIS/XML')"/>
    
    <!-- reference to the MO XSLTs -->
    <xsl:variable name="hl7Mappings" select="concat($projectsDir, '/Nictiz/MO')"/>
    <!-- <xsl:variable name="hl7Mappings" select="concat($projectsDir, '/../nictiz/HL7-mappings')"/>  -->
    
    <!-- reference to the MedMij XSLTs -->
    <xsl:variable name="medmij" select="concat($projectsDir, '/Nictiz/MedMij')"/>


</xsl:stylesheet>
