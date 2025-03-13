<?xml version="1.0" encoding="UTF-8"?>

<!-- == Provenance: YATC-internal/ada-2-fhir-r4/env/zibs/2020/payload/0.8.0-beta.1/all_zibs.xsl == -->
<!-- == Distribution: MP9-Medicatieproces-9.3.0; 1.0.7; 2025-01-17T18:03:28.04+01:00 == -->
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
                xmlns:nm="http://www.nictiz.nl/mappings"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
   <!-- ================================================================== -->
   <!--
        This document imports common and zib and nl-core specific functions and templates to convert zib2020 ada instances to FHIR.
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
   <xsl:import href="2_fhir_fhir_include-d913e448.xsl"/>
   <!-- If a file imported here exists in a different folder (meaning a different 'package'), this means the profile and therefore its ada2fhir mapping is the same in the current and the imported package version (and all versions in between). 
        If a bug is found and fixed, this fix should apply to the mapping in all versions of the package that use this mapping.
        If a profile is edited in a non-backwards compatible way, a new version of the ada2fhir mapping should be made for that profile. -->
   <xsl:import href="nl-core-AbilityToDressOneself-d913e449.xsl"/>
   <xsl:import href="nl-core-AbilityToDrink-d913e450.xsl"/>
   <xsl:import href="nl-core-AbilityToEat-d913e451.xsl"/>
   <xsl:import href="nl-core-AbilityToGroom-d913e453.xsl"/>
   <xsl:import href="nl-core-AbilityToUseToilet-d913e454.xsl"/>
   <xsl:import href="nl-core-AbilityToWashOneself-d913e455.xsl"/>
   <xsl:import href="nl-core-AddressInformation-d913e456.xsl"/>
   <xsl:import href="nl-core-AdvanceDirective-d913e457.xsl"/>
   <xsl:import href="nl-core-AlcoholUse-d913e458.xsl"/>
   <xsl:import href="nl-core-Alert-d913e459.xsl"/>
   <xsl:import href="nl-core-AllergyIntolerance-d913e460.xsl"/>
   <xsl:import href="nl-core-AnatomicalLocation-d913e461.xsl"/>
   <xsl:import href="nl-core-ApgarScore-d913e462.xsl"/>
   <xsl:import href="nl-core-BloodPressure-d913e463.xsl"/>
   <xsl:import href="nl-core-BodyHeight-d913e465.xsl"/>
   <xsl:import href="nl-core-BodyWeight-d913e466.xsl"/>
   <xsl:import href="nl-core-BodyTemperature-d913e467.xsl"/>
   <xsl:import href="nl-core-CareTeam-d913e468.xsl"/>
   <xsl:import href="nl-core-ComfortScale-d913e469.xsl"/>
   <xsl:import href="nl-core-ContactInformation-d913e470.xsl"/>
   <xsl:import href="nl-core-ContactPerson-d913e471.xsl"/>
   <xsl:import href="nl-core-DOSScore-d913e472.xsl"/>
   <xsl:import href="nl-core-DrugUse-d913e473.xsl"/>
   <xsl:import href="nl-core-Education-d913e474.xsl"/>
   <xsl:import href="nl-core-Encounter-d913e475.xsl"/>
   <xsl:import href="nl-core-EpisodeOfCare-d913e477.xsl"/>
   <xsl:import href="nl-core-FLACCpainScale-d913e478.xsl"/>
   <xsl:import href="nl-core-FluidBalance-d913e479.xsl"/>
   <xsl:import href="nl-core-FreedomRestrictingIntervention-d913e480.xsl"/>
   <xsl:import href="nl-core-FunctionalOrMentalStatus-d913e481.xsl"/>
   <xsl:import href="nl-core-HeadCircumference-d913e482.xsl"/>
   <xsl:import href="nl-core-HealthProfessional-d913e483.xsl"/>
   <xsl:import href="nl-core-HealthcareProvider-d913e484.xsl"/>
   <xsl:import href="nl-core-HearingFunction-d913e485.xsl"/>
   <xsl:import href="nl-core-HeartRate-d913e486.xsl"/>
   <xsl:import href="nl-core-HelpFromOthers-d913e487.xsl"/>
   <xsl:import href="nl-core-LaboratoryTestResult-d913e489.xsl"/>
   <xsl:import href="nl-core-LegalSituation-d913e490.xsl"/>
   <xsl:import href="nl-core-LivingSituation-d913e491.xsl"/>
   <xsl:import href="nl-core-MedicalDevice-d913e492.xsl"/>
   <xsl:import href="nl-core-MedicationContraIndication-d913e493.xsl"/>
   <xsl:import href="nl-core-Mobility-d913e494.xsl"/>
   <xsl:import href="nl-core-MUSTScore-d913e495.xsl"/>
   <xsl:import href="nl-core-NameInformation-d913e496.xsl"/>
   <xsl:import href="nl-core-NutritionAdvice-d913e497.xsl"/>
   <xsl:import href="nl-core-O2Saturation-d913e498.xsl"/>
   <xsl:import href="nl-core-ParticipationInSociety-d913e499.xsl"/>
   <xsl:import href="nl-core-Patient-d913e501.xsl"/>
   <xsl:import href="nl-core-Payer-d913e502.xsl"/>
   <xsl:import href="nl-core-PharmaceuticalProduct-d913e503.xsl"/>
   <xsl:import href="nl-core-Problem-d913e504.xsl"/>
   <xsl:import href="nl-core-Procedure-d913e505.xsl"/>
   <xsl:import href="nl-core-Refraction-d913e506.xsl"/>
   <xsl:import href="nl-core-SOAPReport-d913e507.xsl"/>
   <xsl:import href="nl-core-Stoma-d913e508.xsl"/>
   <xsl:import href="nl-core-TextResult-d913e509.xsl"/>
   <xsl:import href="nl-core-TobaccoUse-d913e510.xsl"/>
   <xsl:import href="nl-core-TreatmentDirective2-d913e511.xsl"/>
   <xsl:import href="nl-core-Vaccination-d913e513.xsl"/>
   <xsl:import href="nl-core-VisualAcuity-d913e514.xsl"/>
   <xsl:import href="nl-core-VisualFunction-d913e515.xsl"/>
   <xsl:import href="ext-CodeSpecification-d913e516.xsl"/>
   <xsl:import href="ext-Comment-d913e517.xsl"/>
   <xsl:import href="ext-CopyIndicator-d913e518.xsl"/>
   <xsl:import href="ext-TimeInterval-d913e519.xsl"/>
   <xsl:output method="xml"
               indent="yes"/>
   <xsl:strip-space elements="*"/>
   <!-- ================================================================== -->
</xsl:stylesheet>