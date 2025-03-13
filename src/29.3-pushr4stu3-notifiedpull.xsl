<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:math="http://www.w3.org/2005/xpath-functions/math"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:saxon="http://saxon.sf.net/"
  xmlns:vf="http://www.vzvz.nl/functions"
  xmlns:f="http://hl7.org/fhir"
  xmlns="http://hl7.org/fhir" exclude-result-prefixes="xs math xd f saxon vf" version="3.0">
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p>Transformation from AORTA Notified Pull (R4B) to Twiin Notified Pull (STU3)</xd:p>
      <xd:p>
        <xd:b>Created on:</xd:b> Mar 11, 2024</xd:p>
      <xd:p>
        <xd:b>Author:</xd:b> VZVZ</xd:p>
      <xd:p/>
    </xd:desc>
  </xd:doc>

  <xsl:import href="vf.includes/vf.transformation-utils-fhir.xsl"/>

  <xsl:output indent="yes"/>

  <xsl:variable name="transformationCode">29.3</xsl:variable>
  <xsl:variable name="versionXSLT">0.1.2</xsl:variable>
  <xsl:variable name="fhirVersion" select="'STU3'"/>

  <xd:doc>
    <xd:desc>Main template</xd:desc>
  </xd:doc>
  <xsl:template match="/f:Task">
    <Task>
      <xsl:sequence select="f:id"/>
      <meta>
        <xsl:sequence select="$metaStructure//f:meta/*"/>
        <xsl:apply-templates select="f:meta/*[not(self::f:profile)]"/>
      </meta>

      <!-- get or create the identifier -->
      <xsl:choose>
        <xsl:when test="exists(f:identifier)">
          <xsl:copy select="f:identifier"/>
        </xsl:when>
        <xsl:otherwise>
          <identifier>
            <system value="http://sending.system/id"/>
            <value value="{vf:UUID4()}"/>
          </identifier>
        </xsl:otherwise>
      </xsl:choose>
      
      <!-- convert the instantiatesUri -->
      <xsl:if test="exists(f:instantiatesUri)">
          <definitionUri value="{f:instantiatesUri/@value}"/>
      </xsl:if>
      
      <!-- get or create the groupIdentifier -->
      <xsl:choose>
        <xsl:when test="exists(f:groupIdentifier)">
          <xsl:copy select="f:groupIdentifier"/>
        </xsl:when>
        <xsl:otherwise>
          <groupIdentifier>
            <system value="http://sending.system/np-groupId"/>
            <value value="{vf:UUID4()}"/>
          </groupIdentifier>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="f:status | f:intent | f:code | f:for | f:requester | f:owner | f:restriction"/>

      <xsl:apply-templates select="f:input[f:type/f:coding/f:code/@value='consent_token']"/>
      <xsl:apply-templates select="f:input[f:type/f:coding/f:code/@value='query_string']"/>
    </Task>
  </xsl:template>

  <xd:doc>
    <xd:desc>Match the code</xd:desc>
  </xd:doc>
  <xsl:template match="/f:Task/f:code">
    <code>
      <coding>
        <system value="http://fhir.nl/fhir/NamingSystem/TaskCode"/>
        <code value="pull-notification"/>
      </coding>
    </code>
  </xsl:template>

  <xd:doc>
    <xd:desc>Convert AORTA requester to Twiin requester </xd:desc>
  </xd:doc>
  <xsl:template match="f:requester">
    <xsl:variable name="ura">
      <xsl:call-template name="getRequestOwner">
        <xsl:with-param name="requester" select="."/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="device">
      <xsl:call-template name="getDevice">
        <xsl:with-param name="requester" select="."/>
      </xsl:call-template>

    </xsl:variable>
    <requester>
      <agent>
        <xsl:sequence select="$device//f:Device/f:identifier"/>
      </agent>
      <onBehalfOf>
        <xsl:choose>
          <xsl:when test="exists($ura//f:owner/f:identifier)">
            <xsl:sequence select="$ura//f:owner/f:identifier"/>
          </xsl:when>
          <xsl:when test="exists($ura//f:owneer/f:reference)">
            <xsl:sequence select="$ura//f:owner/f:reference"/>
            <xsl:sequence select="$ura//f:owner/f:type"/>
          </xsl:when>
        </xsl:choose>
      </onBehalfOf>
    </requester>
  </xsl:template>

  <xd:doc>
    <xd:desc>Convert AORTA owner to Twiin owner</xd:desc>
  </xd:doc>
  <xsl:template match="f:owner">
    <xsl:variable name="identifier">
      <xsl:choose>
        <xsl:when test="exists(./f:identifier)">
          <xsl:sequence select="./f:identifier"/>
        </xsl:when>
        <xsl:when test="exists(./f:reference)">
          <xsl:variable name="refOrg" select="substring-after(./f:reference/@value, '#')"/>
          <xsl:variable name="org">
            <xsl:sequence select="/f:Task/f:contained/f:Organization[f:id/@value = $refOrg]"/>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="exists($org//f:identifier)">
              <xsl:sequence select="$org//f:identifier"/>
            </xsl:when>
            <xsl:otherwise>
              <identifier>
                <display>Owner not found</display>
              </identifier>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
      </xsl:choose>

    </xsl:variable>
    <owner>
      <xsl:sequence select="$identifier"/>
    </owner>
  </xsl:template>

  <xd:doc>
    <xd:desc>Get the owner from the contained device</xd:desc>
    <xd:param name="requester"/>
  </xd:doc>
  <xsl:template name="getRequestOwner">
    <xsl:param name="requester"/>

    <xsl:variable name="refDevice" select="substring-after($requester//f:reference/@value, '#')"/>
    <xsl:variable name="device">
      <xsl:sequence select="/f:Task/f:contained/f:Device[f:id/@value = $refDevice]"/>
    </xsl:variable>
    <xsl:variable name="ura">
      <xsl:choose>
        <xsl:when test="exists($device)">
          <xsl:sequence select="$device//f:owner"/>
        </xsl:when>
        <xsl:otherwise>
          <owner>
            <identifier>
              <display>Owner not found</display>
            </identifier>
          </owner>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:sequence select="$ura"/>
  </xsl:template>

  <xd:doc>
    <xd:desc>Get the device id from the contained device</xd:desc>
    <xd:param name="requester"/>
  </xd:doc>
  <xsl:template name="getDevice">
    <xsl:param name="requester"/>

    <xsl:variable name="refDevice" select="substring-after($requester//f:reference/@value, '#')"/>
    <xsl:variable name="device">
      <xsl:sequence select="/f:Task/f:contained/f:Device[f:id/@value = $refDevice]"/>
    </xsl:variable>
    <xsl:variable name="identifier">
      <xsl:choose>
        <xsl:when test="exists($device//f:identifier)">
          <xsl:sequence select="$device/f:identifier"/>
        </xsl:when>
        <xsl:otherwise>
          <identifier>
            <display>identifier not found</display>
          </identifier>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:sequence select="$device"/>
  </xsl:template>


  <xd:doc>
    <xd:desc>Convert consent-token to authorization-base</xd:desc>
  </xd:doc>
  <xsl:template match="f:input[f:type/f:coding/f:code/@value='consent_token']">
    <input>
      <type xmlns="http://hl7.org/fhir">
        <coding>
          <system value="http://fhir.nl/fhir/NamingSystem/TaskParameter" />
          <code value="authorization-base" />
        </coding>
      </type>
      <!-- 2024-11-14 See mail to Ron, Tom and Maarten B.
      -->
      <xsl:variable name="token">
        <xsl:choose>
          <xsl:when test="exists(./f:valueBase64Binary)">
            <xsl:value-of select="./f:valueBase64Binary/@value"/>
          </xsl:when>
          <xsl:when test="exists(./f:valueString)">
            <xsl:value-of select="./f:valueString/@value"/>
          </xsl:when>
        </xsl:choose>
      </xsl:variable>
      <valueString xmlns="http://hl7.org/fhir" value="{$token}"/>
    </input>
  </xsl:template>

  <xd:doc>
    <xd:desc>Convert AORTA query-string to Twiin query</xd:desc>
  </xd:doc>
  <!-- 2024-09-04 HvdL according to the v1.2 Twiin specs I can use a generic parameter coding  -->
  <xsl:template match="f:input[f:type/f:coding/f:code/@value='query_string']">
<!--    <xsl:variable name="id">
      <xsl:sequence select="replace(f:valueString/@value, '([a-zA-Z]*)[\?/].*', '$1')"/>
    </xsl:variable>
    <xsl:variable name="code">
      <xsl:variable name="tmp">
        <xsl:sequence select="replace(f:valueString/@value, '^.*\?.+?[|](.+?)((&amp;.*)|(,.*))?$', '$1')"/>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="$id = $tmp">
          <xsl:sequence select="$id"/>
        </xsl:when>
        <xsl:when test="substring-before($tmp, '?') = $id">
          <xsl:sequence select="$id"/>
        </xsl:when>
        <xsl:when test="substring-before($tmp, '/') = $id">
          <xsl:sequence select="$id"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="$tmp"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-\-    <xsl:comment>found: <xsl:value-of select="$id"/>
 with code: <xsl:value-of select="$code"/>
  </xsl:comment>
-->  
    <xsl:variable name="action">
    <xsl:choose>
      <xsl:when test="contains(f:valueString/@value, '?')">
        <xsl:value-of select="'search-resource'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'read-resource'"/>
      </xsl:otherwise>
    </xsl:choose>
    </xsl:variable>
    <input>
<!--      <xsl:sequence select="$mapAORTA2GTK[@element=$id and @code=$code]/f:type"
        xmlns='http://hl7.org/fhir'/>
-->
      <type>
        <coding>
          <system value="http://fhir.nl/fhir/NamingSystem/TaskParameter" />
          <code value="{$action}" />
        </coding>
      </type>
      <xsl:sequence select="f:valueString"/>
    </input>
</xsl:template>

<xd:doc>
  <xd:desc>fallback template</xd:desc>
</xd:doc>
<xsl:template match="@* | node()">
  <xsl:copy>
    <xsl:apply-templates select="@* | node()"/>
  </xsl:copy>
</xsl:template>

<xd:doc>
  <xd:desc>
    <xd:p>Mapping table going from AORTA to Twiin</xd:p>
    <xd:p>NOTE: the valueStrings are only added for reference, and possible use in the future, but
                are currently not used
    </xd:p>
  </xd:desc>
</xd:doc>
<!--
    <xsl:variable xmlns="" name="mapAORTA2GTK" as="element(map)+">
  <map element="Patient" code="Patient">
    <type xmlns="http://hl7.org/fhir">
      <coding>
        <system value="http://loinc.org" />
        <code value="79191-3" />
        <display value="Patient demographics panel" />
      </coding>
    </type>
    <!-\- <valueString xmlns="http://hl7.org/fhir" value="Patient?_include=Patient:general-practitioner"/> -\->
  </map>
  <map element="Coverage" code="Coverage">
    <type xmlns="http://hl7.org/fhir">
      <coding>
        <system value="http://loinc.org" />
        <code value="48768-6" />
        <display value="Payment sources Document" />
      </coding>
    </type>
    <!-\- <valueString xmlns="http://hl7.org/fhir" value="Coverage?_include=Coverage:payor:Organization&amp;_include=Coverage:payor:Patient"/> -\->
  </map>
  <map element="Consent" code="11291000146105">
    <type xmlns="http://hl7.org/fhir">
      <coding>
        <system value="http://snomed.info/sct" />
        <code value="11291000146105" />
        <display value="Treatment instructions" />
      </coding>
    </type>
    <!-\- <valueString xmlns="http://hl7.org/fhir" value="Consent?category=http://snomed.info/sct|11291000146105" /> -\->
  </map>
  <map element="Consent" code="11341000146107">
    <type xmlns="http://hl7.org/fhir">
      <coding>
        <system value="http://snomed.info/sct" />
        <code value="11341000146107" />
        <display value="Living will and advance directive record" />
      </coding>
    </type>
    <!-\- <valueString xmlns="http://hl7.org/fhir" value="Consent?category=http://snomed.info/sct|11341000146107" /> -\->
  </map>
  <map element="Observation" code="118228005">
    <type xmlns="http://hl7.org/fhir">
      <coding>
        <system value="http://loinc.org" />
        <code value="47420-5" />
        <display value="Functional status assessment note" />
      </coding>
    </type>
    <!-\- <valueString xmlns="http://hl7.org/fhir" value="Observation/$lastn?category=http://snomed.info/sct|118228005,http://snomed.info/sct|384821006" /> -\->
  </map>
  <map element="Condition" code="Condition">
    <type xmlns="http://hl7.org/fhir">
      <coding>
        <system value="http://loinc.org" />
        <code value="11450-4" />
        <display value="Problem list - Reported" />
      </coding>
    </type>
    <!-\- <valueString xmlns="http://hl7.org/fhir" value="Condition" /> -\->
  </map>
  <map element="Observation" code="365508006">
    <type xmlns="http://hl7.org/fhir">
      <coding>
        <system value="http://snomed.info/sct" />
        <code value="365508006" />
        <display value="Residence and accommodation circumstances - finding" />
      </coding>
    </type>
    <!-\- <valueString xmlns="http://hl7.org/fhir" value="Observation/$lastn?code=http://snomed.info/sct|365508006" /> -\->
  </map>
  <map element="Observation" code="228366006">
    <type xmlns="http://hl7.org/fhir">
      <coding>
        <system value="http://snomed.info/sct" />
        <code value="228366006" />
        <display value="Finding relating to drug misuse behavior" />
      </coding>
    </type>
    <!-\- <valueString xmlns="http://hl7.org/fhir" value="Observation?code=http://snomed.info/sct|228366006" /> -\->
  </map>
  <map element="Observation" code="228273003">
    <type xmlns="http://hl7.org/fhir">
      <coding>
        <system value="http://snomed.info/sct" />
        <code value="228273003" />
        <display value="Finding relating to alcohol drinking behavior" />
      </coding>
    </type>
    <!-\- <valueString xmlns="http://hl7.org/fhir" value="Observation?code=http://snomed.info/sct|228273003" /> -\->
  </map>
  <map element="Observation" code="365980008">
    <type xmlns="http://hl7.org/fhir">
      <coding>
        <system value="http://snomed.info/sct" />
        <code value="365980008" />
        <display value="Tobacco use and exposure - finding" />
      </coding>
    </type>
    <!-\- <valueString xmlns="http://hl7.org/fhir" value="Observation?code=http://snomed.info/sct|365980008" /> -\->
  </map>
  <map element="NutritionOrder" code="NutritionOrder">
    <type xmlns="http://hl7.org/fhir">
      <coding>
        <system value="http://snomed.info/sct" />
        <code value="11816003" />
        <display value="Diet education" />
      </coding>
    </type>
    <!-\- <valueString xmlns="http://hl7.org/fhir" value="NutritionOrder" /> -\->
  </map>
  <map element="Flag" code="Flag">
    <type xmlns="http://hl7.org/fhir">
      <coding>
        <system value="http://loinc.org" />
        <code value="75310-3" />
        <display value="Health concerns Document" />
      </coding>
    </type>
    <!-\- <valueString xmlns="http://hl7.org/fhir" value="Flag" /> -\->
  </map>
  <map element="AllergyIntolerance" code="AllergyIntolerance">
    <type xmlns="http://hl7.org/fhir">
      <coding>
        <system value="http://loinc.org" />
        <code value="48765-2" />
        <display value="Allergies and adverse reactions Document" />
      </coding>
    </type>
    <!-\- <valueString xmlns="http://hl7.org/fhir" value="AllergyIntolerance" /> -\->
  </map>
  <map element="MedicationStatement" code="6">
    <type xmlns="http://hl7.org/fhir">
      <coding>
        <system value="http://snomed.info/sct" />
        <code value="422979000" />
        <display value="Known medication use" />
      </coding>
    </type>
    <!-\- <valueString xmlns="http://hl7.org/fhir" value="MedicationStatement?category=urn:oid:2.16.840.1.113883.2.4.3.11.60.20.77.5.3|6&amp;_include=MedicationStatement:medication" /> -\->
  </map>
  <map element="MedicationRequest" code="16076005">
    <type xmlns="http://hl7.org/fhir">
      <coding>
        <system value="http://snomed.info/sct" />
        <code value="16076005" />
        <display value="Known medication agreements" />
      </coding>
    </type>
    <!-\- <valueString xmlns="http://hl7.org/fhir" value="MedicationRequest?category=http://snomed.info/sct|16076005&amp;_include=MedicationRequest:medication" /> -\->
  </map>
  <map element="MedicationDispense" code="422037009">
    <type xmlns="http://hl7.org/fhir">
      <coding>
        <system value="http://snomed.info/sct" />
        <code value="422037009" />
        <display value="Known administration agreements" />
      </coding>
    </type>
    <!-\- <valueString xmlns="http://hl7.org/fhir" value="MedicationDispense?category=http://snomed.info/sct|422037009&amp;_include=MedicationDispense:medication" /> -\->
  </map>
  <map element="DeviceUseStatement" code="DeviceUseStatement">
    <type xmlns="http://hl7.org/fhir">
      <coding>
        <system value="http://loinc.org" />
        <code value="46264-8" />
        <display value="Known medical aids" />
      </coding>
    </type>
    <!-\- <valueString xmlns="http://hl7.org/fhir" value="DeviceUseStatement?_include=DeviceUseStatement:device" /> -\->
  </map>
  <map element="Immunization" code="Immunization">
    <type xmlns="http://hl7.org/fhir">
      <coding>
        <system value="http://loinc.org" />
        <code value="11369-6" />
        <display value="History of Immunization Narrative" />
      </coding>
    </type>
    <!-\- <valueString xmlns="http://hl7.org/fhir" value="Immunization?status=completed" /> -\->
  </map>
  <map element="Observation" code="85354-9">
    <type xmlns="http://hl7.org/fhir">
      <coding>
        <system value="http://loinc.org" />
        <code value="85354-9" />
        <display value="Blood pressure" />
      </coding>
    </type>
    <!-\- <valueString xmlns="http://hl7.org/fhir" value="Observation/$lastn?code=http://loinc.org|85354-9" /> -\->
  </map>
  <map element="Observation" code="29463-7">
    <type xmlns="http://hl7.org/fhir">
      <coding>
        <system value="http://loinc.org" />
        <code value="29463-7" />
        <display value="Body weight" />
      </coding>
    </type>
    <!-\- <valueString xmlns="http://hl7.org/fhir" value="Observation/$lastn?code=http://loinc.org|29463-7" /> -\->
  </map>
  <map element="Observation" code="8302-2">
    <type xmlns="http://hl7.org/fhir">
      <coding>
        <system value="http://loinc.org" />
        <code value="8302-2" />
        <display value="Body height" />
      </coding>
    </type>
    <!-\- <valueString xmlns="http://hl7.org/fhir" value="Observation/$lastn?code=http://loinc.org|8302-2,http://loinc.org|8306-3,http://loinc.org|8308-9" /> -\->
  </map>
  <map element="Observation" code="275711006">
    <type xmlns="http://hl7.org/fhir">
      <coding>
        <system value="http://snomed.info/sct" />
        <code value="15220000" />
        <display value="Laboratory test" />
      </coding>
    </type>
    <!-\- <valueString xmlns="http://hl7.org/fhir" value="Observation/$lastn?category=http://snomed.info/sct|275711006&amp;_include=Observation:related-target&amp;_include=Observation:specimen" /> -\->
  </map>
  <map element="Procedure" code="387713003">
    <type xmlns="http://hl7.org/fhir">
      <coding>
        <system value="http://loinc.org" />
        <code value="47519-4" />
        <display value="History of Procedures" />
      </coding>
    </type>
    <!-\- <valueString xmlns="http://hl7.org/fhir" value="Procedure?category=http://snomed.info/sct|387713003" /> -\->
  </map>
  <map element="Encounter" code="IMP">
    <type xmlns="http://hl7.org/fhir">
      <coding>
        <system value="http://loinc.org" />
        <code value="46240-8" />
        <display value="History of Hospitalizations+Outpatient visits Narrative" />
      </coding>
    </type>
    <!-\- <valueString xmlns="http://hl7.org/fhir" value="Encounter?class=http://hl7.org/fhir/v3/ActCode|IMP,http://hl7.org/fhir/v3/ActCod e|ACUTE,http://hl7.org/fhir/v3/ActCode|NONAC" /> -\->
  </map>
  <map element="ProcedureRequest" code="ProcedureRequest">
    <type xmlns="http://hl7.org/fhir">
      <coding>
        <system value="http://loinc.org" />
        <code value="18776-5" />
        <display value="Plan of care note" />
      </coding>
    </type>
    <!-\- <valueString xmlns="http://hl7.org/fhir" value="ProcedureRequest?status=active" /> -\->
  </map>
  <map element="ImmunizationRecommendation" code="ImmunizationRecommendation">
    <type xmlns="http://hl7.org/fhir">
      <coding>
        <system value="http://loinc.org" />
        <code value="18776-5" />
        <display value="Plan of care note" />
      </coding>
    </type>
    <!-\- <valueString xmlns="http://hl7.org/fhir" value="ImmunizationRecommendation" /> -\->
  </map>
  <map element="DeviceRequest" code="DeviceRequest">
    <type xmlns="http://hl7.org/fhir">
      <coding>
        <system value="http://loinc.org" />
        <code value="18776-5" />
        <display value="Plan of care note" />
      </coding>
    </type>
    <!-\- <valueString xmlns="http://hl7.org/fhir" value="DeviceRequest?status=active&amp;_include=DeviceRequest:device" /> -\->
  </map>
  <map element="Appointment" code="Appointment">
    <type xmlns="http://hl7.org/fhir">
      <coding>
        <system value="http://loinc.org" />
        <code value="18776-5" />
        <display value="Plan of care note" />
      </coding>
    </type>
    <!-\- <valueString xmlns="http://hl7.org/fhir" value="Appointment?status=booked,pending,proposed" /> -\->
  </map>
  <map element="DocumentReference" code="DocumentReference">
    <type xmlns="http://hl7.org/fhir">
      <coding>
        <system value="http://loinc.org" />
        <code value="77599-9" />
        <display value="Additional documentation" />
      </coding>
    </type>
    <!-\- <valueString xmlns="http://hl7.org/fhir" value="DocumentReference?status=current" /> -\->
  </map>
</xsl:variable>
-->
</xsl:stylesheet>
