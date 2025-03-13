<?xml version="1.0" encoding="UTF-8"?>

<!-- == Provenance: HL7-mappings/ada_2_fhir-r4/zibs2020/payload/0.8.0-beta.1/all_zibs.xsl == -->
<!-- == Distribution: MP9-Medicatieproces-9.3.0; 1.0.7; 2025-01-17T18:03:28.04+01:00 == -->
<xsl:stylesheet exclude-result-prefixes="#all"
                version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://hl7.org/fhir"
                xmlns:f="http://hl7.org/fhir"
                xmlns:nf="http://www.nictiz.nl/functions"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
                xmlns:uuid="http://www.uuid.org"
                xmlns:local="urn:fhir:stu3:functions"
                xmlns:nm="http://www.nictiz.nl/mappings"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
   <xsl:import href="2_fhir_fhir_include-d913e311.xsl"/>
   <!-- If a file imported here exists in a different folder (meaning a different 'package'), this means the profile and therefore its ada2fhir mapping is the same in the current and the imported package version (and all versions in between). 
        If a bug is found and fixed, this fix should apply to the mapping in all versions of the package that use this mapping.
        If a profile is edited in a non-backwards compatible way, a new version of the ada2fhir mapping should be made for that profile. -->
   <xsl:import href="nl-core-AbilityToDressOneself-d913e314.xsl"/>
   <xsl:import href="nl-core-AbilityToDrink-d913e315.xsl"/>
   <xsl:import href="nl-core-AbilityToEat-d913e316.xsl"/>
   <xsl:import href="nl-core-AbilityToGroom-d913e317.xsl"/>
   <xsl:import href="nl-core-AbilityToUseToilet-d913e318.xsl"/>
   <xsl:import href="nl-core-AbilityToWashOneself-d913e319.xsl"/>
   <xsl:import href="nl-core-AddressInformation-d913e321.xsl"/>
   <xsl:import href="nl-core-AdvanceDirective-d913e322.xsl"/>
   <xsl:import href="nl-core-AlcoholUse-d913e323.xsl"/>
   <xsl:import href="nl-core-Alert-d913e324.xsl"/>
   <xsl:import href="nl-core-AllergyIntolerance-d913e325.xsl"/>
   <xsl:import href="nl-core-AnatomicalLocation-d913e326.xsl"/>
   <xsl:import href="nl-core-ApgarScore-d913e327.xsl"/>
   <xsl:import href="nl-core-BloodPressure-d913e328.xsl"/>
   <xsl:import href="nl-core-BodyHeight-d913e329.xsl"/>
   <xsl:import href="nl-core-BodyWeight-d913e330.xsl"/>
   <xsl:import href="nl-core-BodyTemperature-d913e331.xsl"/>
   <xsl:import href="nl-core-CareTeam-d913e333.xsl"/>
   <xsl:import href="nl-core-ComfortScale-d913e334.xsl"/>
   <xsl:import href="nl-core-ContactInformation-d913e335.xsl"/>
   <xsl:import href="nl-core-ContactPerson-d913e336.xsl"/>
   <xsl:import href="nl-core-DOSScore-d913e337.xsl"/>
   <xsl:import href="nl-core-DrugUse-d913e338.xsl"/>
   <xsl:import href="nl-core-Education-d913e339.xsl"/>
   <xsl:import href="nl-core-Encounter-d913e340.xsl"/>
   <xsl:import href="nl-core-EpisodeOfCare-d913e341.xsl"/>
   <xsl:import href="nl-core-FLACCpainScale-d913e342.xsl"/>
   <xsl:import href="nl-core-FluidBalance-d913e343.xsl"/>
   <xsl:import href="nl-core-FreedomRestrictingIntervention-d913e345.xsl"/>
   <xsl:import href="nl-core-FunctionalOrMentalStatus-d913e346.xsl"/>
   <xsl:import href="nl-core-HeadCircumference-d913e347.xsl"/>
   <xsl:import href="nl-core-HealthProfessional-d913e348.xsl"/>
   <xsl:import href="nl-core-HealthcareProvider-d913e349.xsl"/>
   <xsl:import href="nl-core-HearingFunction-d913e350.xsl"/>
   <xsl:import href="nl-core-HeartRate-d913e351.xsl"/>
   <xsl:import href="nl-core-HelpFromOthers-d913e352.xsl"/>
   <xsl:import href="nl-core-LaboratoryTestResult-d913e353.xsl"/>
   <xsl:import href="nl-core-LegalSituation-d913e354.xsl"/>
   <xsl:import href="nl-core-LivingSituation-d913e355.xsl"/>
   <xsl:import href="nl-core-MedicalDevice-d913e357.xsl"/>
   <xsl:import href="nl-core-MedicationContraIndication-d913e358.xsl"/>
   <xsl:import href="nl-core-Mobility-d913e359.xsl"/>
   <xsl:import href="nl-core-MUSTScore-d913e360.xsl"/>
   <xsl:import href="nl-core-NameInformation-d913e361.xsl"/>
   <xsl:import href="nl-core-NutritionAdvice-d913e362.xsl"/>
   <xsl:import href="nl-core-O2Saturation-d913e363.xsl"/>
   <xsl:import href="nl-core-ParticipationInSociety-d913e364.xsl"/>
   <xsl:import href="nl-core-Patient-d913e365.xsl"/>
   <xsl:import href="nl-core-Payer-d913e366.xsl"/>
   <xsl:import href="nl-core-PharmaceuticalProduct-d913e367.xsl"/>
   <xsl:import href="nl-core-Problem-d913e369.xsl"/>
   <xsl:import href="nl-core-Procedure-d913e370.xsl"/>
   <xsl:import href="nl-core-Refraction-d913e371.xsl"/>
   <xsl:import href="nl-core-SOAPReport-d913e372.xsl"/>
   <xsl:import href="nl-core-Stoma-d913e373.xsl"/>
   <xsl:import href="nl-core-TextResult-d913e374.xsl"/>
   <xsl:import href="nl-core-TobaccoUse-d913e375.xsl"/>
   <xsl:import href="nl-core-TreatmentDirective2-d913e376.xsl"/>
   <xsl:import href="nl-core-Vaccination-d913e377.xsl"/>
   <xsl:import href="nl-core-VisualAcuity-d913e378.xsl"/>
   <xsl:import href="nl-core-VisualFunction-d913e379.xsl"/>
   <xsl:import href="ext-CodeSpecification-d913e381.xsl"/>
   <xsl:import href="ext-Comment-d913e382.xsl"/>
   <xsl:import href="ext-CopyIndicator-d913e383.xsl"/>
   <xsl:import href="ext-TimeInterval-d913e384.xsl"/>
   <xsl:output method="xml"
               indent="yes"/>
   <xsl:strip-space elements="*"/>
   <xd:doc scope="stylesheet">
      <xd:desc>This document imports common and zib and nl-core specific functions and templates to convert zib2020 ada instances to FHIR.</xd:desc>
   </xd:doc>
</xsl:stylesheet>