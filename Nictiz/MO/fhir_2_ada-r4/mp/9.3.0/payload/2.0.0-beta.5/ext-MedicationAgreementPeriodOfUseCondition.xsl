<?xml version="1.0" encoding="UTF-8"?>

<!-- == Provenance: HL7-mappings/fhir_2_ada-r4/mp/9.3.0/payload/2.0.0-beta.5/ext-MedicationAgreementPeriodOfUseCondition.xsl == -->
<!-- == Distribution: MP9-Medicatieproces-9.3.0; 1.0.7; 2025-01-17T18:03:28.04+01:00 == -->
<xsl:stylesheet exclude-result-prefixes="#all"
                version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:f="http://hl7.org/fhir"
                xmlns:nf="http://www.nictiz.nl/functions"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
                xmlns:local="urn:fhir:stu3:functions">
   <xd:doc>
      <xd:desc>Template to convert f:extension $urlExtMedicationAgreementPeriodOfUseCondition to criterium element.</xd:desc>
   </xd:doc>
   <xsl:template match="f:extension[@url = $urlExtMedicationAgreementPeriodOfUseCondition]"
                 mode="urlExtMedicationAgreementPeriodOfUseCondition">
      <criterium value="{f:valueString/@value}"/>
   </xsl:template>
</xsl:stylesheet>