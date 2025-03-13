<?xml version="1.0" encoding="UTF-8"?>

<!-- == Provenance: YATC-internal/ada-2-fhir-r4/env/fhir/2_fhir_fhir_include.xsl == -->
<!-- == Distribution: MP9-Medicatieproces-9.3.0; 1.0.7; 2025-01-17T18:03:28.04+01:00 == -->
<xsl:stylesheet exclude-result-prefixes="#all"
                version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://hl7.org/fhir"
                xmlns:util="urn:hl7:utilities"
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
        TBD
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
   <xsl:import href="2_fhir_fhir_include-d913e312.xsl"/>
   <xsl:param name="populateId"
              select="true()"
              as="xs:boolean"/>
   <xsl:param name="referencingStrategy"
              select="'uuid'"
              as="xs:string"/>
   <xsl:param name="serverBaseUri"
              select="'http://example.nictiz.nl/fhir'"
              as="xs:string"/>
   <xsl:variable name="ada2resourceType">
      <nm:map ada="aandoening_of_gesteldheid"
              resource="Condition"
              profile="cio-Condition"/>
      <nm:map ada="alcohol_gebruik"
              resource="Observation"
              profile="nl-core-AlcoholUse"/>
      <nm:map ada="alert"
              resource="Flag"
              profile="nl-core-Alert"/>
      <nm:map ada="alert"
              resource="Flag"
              profile="cio-MedicationContraIndication"/>
      <nm:map ada="allergie_intolerantie"
              resource="AllergyIntolerance"
              profile="nl-core-AllergyIntolerance"/>
      <nm:map ada="antwoord_voorstel_contra_indicatie"
              resource="Communication"
              profile="cio-ReplyProposalContraIndication"/>
      <nm:map ada="apgar_score"
              resource="Observation"
              profile="nl-core-ApgarScore-1Minute"/>
      <nm:map ada="apgar_score"
              resource="Observation"
              profile="nl-core-ApgarScore-5Minute"/>
      <nm:map ada="apgar_score"
              resource="Observation"
              profile="nl-core-ApgarScore-10Minute"/>
      <nm:map ada="barthel_index"
              resource="Observation"
              profile="nl-core-BarthelADLIndex"/>
      <nm:map ada="behandel_aanwijzing"
              resource="Consent"
              profile="nl-core-TreatmentDirective2"/>
      <nm:map ada="bewaking_besluit"
              resource="Flag"
              profile="cio-SurveillanceDecision"/>
      <nm:map ada="bloeddruk"
              resource="Observation"
              profile="nl-core-BloodPressure"/>
      <nm:map ada="brandwond"
              resource="Condition"
              profile="nl-core-Burnwound"/>
      <nm:map ada="brandwond"
              resource="Observation"
              profile="nl-core-wounds.WoundCharacteristics"/>
      <nm:map ada="uitgebreidheid"
              resource="Observation"
              profile="nl-core-Burnwound.Extent"/>
      <nm:map ada="comfort_score"
              resource="Observation"
              profile="nl-core-ComfortScale"/>
      <nm:map ada="betaler"
              resource="Coverage"
              profile="nl-core-Payer.InsuranceCompany"/>
      <nm:map ada="betaler"
              resource="Coverage"
              profile="nl-core-Payer.PayerPerson"/>
      <nm:map ada="betaler"
              resource="Organization"
              profile="nl-core-Payer-Organization"/>
      <nm:map ada="checklist_pijn_gedrag"
              resource="Observation"
              profile="nl-core-ChecklistPainBehavior"/>
      <nm:map ada="contact"
              resource="Encounter"
              profile="nl-core-Encounter"/>
      <nm:map ada="contactpersoon"
              resource="RelatedPerson"
              profile="nl-core-ContactPerson"/>
      <nm:map ada="darmfunctie"
              resource="Observation"
              profile="nl-core-BowelFunction"/>
      <nm:map ada="decubitus_wond"
              resource="Condition"
              profile="nl-core-PressureUlcer"/>
      <nm:map ada="decubitus_wond"
              resource="Observation"
              profile="nl-core-wounds.WoundCharacteristics"/>
      <nm:map ada="feces_continentie"
              resource="Observation"
              profile="nl-core-BowelFunction.FecalContinence"/>
      <nm:map ada="frequentie"
              resource="Observation"
              profile="nl-core-BowelFunction.Frequency"/>
      <nm:map ada="defecatie_consistentie"
              resource="Observation"
              profile="nl-core-BowelFunction.DefecationConsistency"/>
      <nm:map ada="defecatie_kleur"
              resource="Observation"
              profile="nl-core-BowelFunction.DefecationColor"/>
      <nm:map ada="dosscore"
              resource="Observation"
              profile="nl-core-DOSScore"/>
      <nm:map ada="drugs_gebruik"
              resource="Observation"
              profile="nl-core-DrugUse"/>
      <nm:map ada="envelop"
              resource="ServiceRequest"
              profile="hg-ReferralServiceRequest"/>
      <nm:map ada="envelop"
              resource="Task"
              profile="hg-ReferralTask"/>
      <nm:map ada="farmaceutisch_product"
              resource="Medication"
              profile="nl-core-PharmaceuticalProduct"/>
      <nm:map ada="flaccpijn_score"
              resource="Observation"
              profile="nl-core-FLACCpainScale"/>
      <nm:map ada="functie_horen"
              resource="Observation"
              profile="nl-core-HearingFunction"/>
      <nm:map ada="functie_zien"
              resource="Observation"
              profile="nl-core-VisualFunction"/>
      <nm:map ada="functionele_of_mentale_status"
              resource="Observation"
              profile="nl-core-FunctionalOrMentalStatus"/>
      <nm:map ada="glasgow_coma_scale"
              resource="Observation"
              profile="nl-core-GlasgowComaScale"/>
      <nm:map ada="hartfrequentie"
              resource="Observation"
              profile="nl-core-HeartRate"/>
      <nm:map ada="hartslag_regelmatigheid"
              resource="Observation"
              profile="nl-core-HeartRate.HeartbeatRegularity"/>
      <nm:map ada="interpretatie_frequentie"
              resource="Observation"
              profile="nl-core-HeartRate.InterpretationHeartRate"/>
      <nm:map ada="huidaandoening"
              resource="Condition"
              profile="nl-core-SkinDisorder"/>
      <nm:map ada="hulp_van_anderen"
              resource="CarePlan"
              profile="nl-core-HelpFromOthers"/>
      <nm:map ada="juridische_situatie"
              resource="Condition"
              profile="nl-core-LegalSituation-LegalStatus"/>
      <nm:map ada="juridische_situatie"
              resource="Condition"
              profile="nl-core-LegalSituation-Representation"/>
      <nm:map ada="kern"
              resource="Composition"
              profile="hg-ReferralComposition"/>
      <nm:map ada="laboratorium_uitslag"
              resource="Observation"
              profile="nl-core-LaboratoryTestResult"/>
      <nm:map ada="laboratorium_test"
              resource="Observation"
              profile="nl-core-LaboratoryTestResult"/>
      <nm:map ada="levensovertuiging_rc"
              resource="Observation"
              profile="nl-core-LifeStance"/>
      <nm:map ada="lichaamslengte"
              resource="Observation"
              profile="nl-core-BodyHeight"/>
      <nm:map ada="lichaamstemperatuur"
              resource="Observation"
              profile="nl-core-BodyTemperature"/>
      <nm:map ada="lichaamsgewicht"
              resource="Observation"
              profile="nl-core-BodyWeight"/>
      <nm:map ada="medicatie_contra_indicatie"
              resource="Flag"
              profile="nl-core-MedicationContraIndication"/>
      <nm:map ada="medicatiegebruik"
              resource="MedicationStatement"
              profile="mp-MedicationUse2"/>
      <nm:map ada="medicatie_gebruik"
              resource="MedicationStatement"
              profile="mp-MedicationUse2"/>
      <nm:map ada="medicatie_toediening"
              resource="MedicationAdministration"
              profile="mp-MedicationAdministration2"/>
      <nm:map ada="medicatietoediening"
              resource="MedicationAdministration"
              profile="mp-MedicationAdministration2"/>
      <nm:map ada="medicatieafspraak"
              resource="MedicationRequest"
              profile="mp-MedicationAgreement"/>
      <nm:map ada="medicatieverstrekking"
              resource="MedicationDispense"
              profile="mp-MedicationDispense"/>
      <nm:map ada="medisch_hulpmiddel"
              resource="DeviceUseStatement"
              profile="nl-core-MedicalDevice"/>
      <nm:map ada="medisch_hulpmiddel"
              resource="Device"
              profile="nl-core-MedicalDevice.Product"/>
      <nm:map ada="medisch_hulpmiddel"
              resource="DeviceUseStatement"
              profile="nl-core-HearingFunction.HearingAid"/>
      <nm:map ada="medisch_hulpmiddel"
              resource="Device"
              profile="nl-core-HearingFunction.HearingAid.Product"/>
      <nm:map ada="medisch_hulpmiddel"
              resource="DeviceUseStatement"
              profile="nl-core-VisualFunction.VisualAid"/>
      <nm:map ada="medisch_hulpmiddel"
              resource="Device"
              profile="nl-core-VisualFunction.VisualAid.Product"/>
      <nm:map ada="medisch_hulpmiddel"
              resource="DeviceUseStatement"
              profile="nl-core-Wound.Drain"/>
      <nm:map ada="medisch_hulpmiddel"
              resource="Device"
              profile="nl-core-Wound.Drain.Product"/>
      <nm:map ada="mobiliteit"
              resource="Observation"
              profile="nl-core-Mobility"/>
      <nm:map ada="lopen"
              resource="Observation"
              profile="nl-core-Mobility.Walking"/>
      <nm:map ada="traplopen"
              resource="Observation"
              profile="nl-core-Mobility.ClimbingStairs"/>
      <nm:map ada="houding_veranderen"
              resource="Observation"
              profile="nl-core-Mobility.MaintainingPosition"/>
      <nm:map ada="houding_handhaven"
              resource="Observation"
              profile="nl-core-Mobility.ChangingPosition"/>
      <nm:map ada="uitvoeren_transfer"
              resource="Observation"
              profile="nl-core-Mobility.Transfer"/>
      <nm:map ada="monster"
              resource="Specimen"
              profile="nl-core-LaboratoryTestResult.Specimen"/>
      <nm:map ada="monster2"
              resource="Specimen"
              profile="nl-core-LaboratoryTestResult.Specimen"/>
      <nm:map ada="bron_monster"
              resource="Device"
              profile="nl-core-LaboratoryTestResult.SpecimenSource"/>
      <nm:map ada="mustscore"
              resource="Observation"
              profile="nl-core-MUSTScore"/>
      <nm:map ada="o2saturatie"
              resource="Observation"
              profile="nl-core-O2Saturation"/>
      <nm:map ada="ontwikkeling_kind"
              resource="Observation"
              profile="nl-core-DevelopmentChild"/>
      <nm:map ada="zindelijkheid_urine"
              resource="Observation"
              profile="nl-core-DevelopmentChild.ToiletTrainednessUrine"/>
      <nm:map ada="zindelijkheid_feces"
              resource="Observation"
              profile="nl-core-DevelopmentChild.ToiletTrainednessFeces"/>
      <nm:map ada="leeftijd_eerste_menstruatie"
              resource="Observation"
              profile="nl-core-DevelopmentChild.AgeFirstMenstruation"/>
      <nm:map ada="ontwikkeling_motoriek"
              resource="Observation"
              profile="nl-core-DevelopmentChild.DevelopmentLocomotion"/>
      <nm:map ada="ontwikkeling_sociaal"
              resource="Observation"
              profile="nl-core-DevelopmentChild.DevelopmentSocial"/>
      <nm:map ada="ontwikkeling_taal"
              resource="Observation"
              profile="nl-core-DevelopmentChild.DevelopmentLinguistics"/>
      <nm:map ada="ontwikkeling_verstandelijk"
              resource="Observation"
              profile="nl-core-DevelopmentChild.DevelopmentCognition"/>
      <nm:map ada="opleiding"
              resource="Observation"
              profile="nl-core-Education"/>
      <nm:map ada="overgevoeligheid_intolerantie"
              resource="AllergyIntolerance"
              profile="cio-HypersensitivityIntolerance"/>
      <nm:map ada="participatie_in_maatschappij"
              resource="Observation"
              profile="nl-core-ParticipationInSociety"/>
      <nm:map ada="sociaal_netwerk"
              resource="Observation"
              profile="nl-core-ParticipationInSociety.SocialNetwork"/>
      <nm:map ada="vrijetijdsbesteding"
              resource="Observation"
              profile="nl-core-ParticipationInSociety.Hobby"/>
      <nm:map ada="arbeidssituatie"
              resource="Observation"
              profile="nl-core-ParticipationInSociety.WorkSituation"/>
      <nm:map ada="patient"
              resource="Patient"
              profile="nl-core-Patient"/>
      <nm:map ada="pijn_score"
              resource="Observation"
              profile="nl-core-PainScore"/>
      <nm:map ada="polsfrequentie"
              resource="Observation"
              profile="nl-core-PulseRate"/>
      <nm:map ada="pols_regelmatigheid"
              resource="Observation"
              profile="nl-core-PulseRate.PulseRegularity"/>
      <nm:map ada="probleem"
              resource="Condition"
              profile="nl-core-Problem"/>
      <nm:map ada="reactie"
              resource="AllergyIntolerance"
              profile="cio-Reaction"/>
      <nm:map ada="refractie"
              resource="Observation"
              profile="nl-core-Refraction"/>
      <nm:map ada="registratie_informatie"
              resource="Provenance"
              profile="cio-RegistrationInformation"/>
      <nm:map ada="schedelomvang"
              resource="Observation"
              profile="nl-core-HeadCircumference"/>
      <nm:map ada="snaq65score"
              resource="Observation"
              profile="nl-core-SNAQ65plusScore"/>
      <nm:map ada="snaqrc_score"
              resource="Observation"
              profile="nl-core-SNAQrcScore"/>
      <nm:map ada="snaqscore"
              resource="Observation"
              profile="nl-core-SNAQScore"/>
      <nm:map ada="soepverslag"
              resource="Composition"
              profile="nl-core-SOAPReport"/>
      <nm:map ada="soepregel"
              resource="Observation"
              profile="nl-core-SOAPReport.SOAPLine"/>
      <nm:map ada="stoma"
              resource="Condition"
              profile="nl-core-Stoma"/>
      <nm:map ada="strong_kids_score"
              resource="Observation"
              profile="nl-core-StrongKidsScore"/>
      <nm:map ada="sturen_medicatievoorschrift"
              resource="Bundle"
              profile="mp-MedicationPrescription-Bundle"/>
      <nm:map ada="sturen_afhandeling_medicatievoorschrift"
              resource="Bundle"
              profile="mp-MedicationPrescriptionProcessing-Bundle"/>
      <nm:map ada="sturen_antwoord_voorstel_contra_indicatie"
              resource="Bundle"
              profile="cio-ReplyProposalContraIndication-Bundle"/>
      <nm:map ada="sturen_antwoord_voorstel_medicatieafspraak"
              resource="Bundle"
              profile="mp-ReplyProposalMedicationAgreement-Bundle"/>
      <nm:map ada="sturen_antwoord_voorstel_medicatieafspraak"
              resource="Communication"
              profile="mp-ReplyProposalMedicationAgreement"/>
      <nm:map ada="sturen_antwoord_voorstel_verstrekkingsverzoek"
              resource="Bundle"
              profile="mp-ReplyProposalDispenseRequest-Bundle"/>
      <nm:map ada="sturen_antwoord_voorstel_verstrekkingsverzoek"
              resource="Communication"
              profile="mp-ReplyProposalDispenseRequest"/>
      <nm:map ada="sturen_voorstel_contra_indicatie"
              resource="Bundle"
              profile="cio-ProposalContraIndication-Bundle"/>
      <nm:map ada="sturen_voorstel_medicatieafspraak"
              resource="Bundle"
              profile="mp-ProposalMedicationAgreement-Bundle"/>
      <nm:map ada="sturen_voorstel_verstrekkingsverzoek"
              resource="Bundle"
              profile="mp-ProposalDispenseRequest-Bundle"/>
      <nm:map ada="sturen_afhandeling_medicatievoorschrift"
              resource="Bundle"
              profile="mp-MedicationPrescriptionProcessing-Bundle"/>
      <nm:map ada="sturen_afhandeling_medicatievoorschrift"
              resource="Bundle"
              profile="mp-MedicationPrescriptionProcessing-Bundle"/>
      <nm:map ada="sturen_afhandeling_medicatievoorschrift"
              resource="Bundle"
              profile="mp-MedicationPrescriptionProcessing-Bundle"/>
      <nm:map ada="symptoom"
              resource="Observation"
              profile="cio-Symptom"/>
      <nm:map ada="tabak_gebruik"
              resource="Observation"
              profile="nl-core-TobaccoUse"/>
      <nm:map ada="tekst_uitslag"
              resource="DiagnosticReport"
              profile="nl-core-TextResult"/>
      <nm:map ada="visueel_resultaat"
              resource="Media"
              profile="nl-core-TextResult.VisualResult"/>
      <nm:map ada="toedieningsafspraak"
              resource="MedicationDispense"
              profile="mp-AdministrationAgreement"/>
      <nm:map ada="vaccinatie"
              resource="Immunization"
              profile="nl-core-Vaccination-event"/>
      <nm:map ada="vaccinatie"
              resource="ImmunizationRecommendation"
              profile="nl-core-Vaccination-request"/>
      <nm:map ada="vermogen_tot_drinken"
              resource="Observation"
              profile="nl-core-AbilityToDrink"/>
      <nm:map ada="drink_beperkingen"
              resource="Observation"
              profile="nl-core-AbilityToDrink.DrinkingLimitations"/>
      <nm:map ada="vermogen_tot_eten"
              resource="Observation"
              profile="nl-core-AbilityToEat"/>
      <nm:map ada="eet_beperkingen"
              resource="Observation"
              profile="nl-core-AbilityToEat.EatingLimitations"/>
      <nm:map ada="vermogen_tot_toiletgang"
              resource="Observation"
              profile="nl-core-AbilityToUseToilet"/>
      <nm:map ada="toiletgebruik"
              resource="Observation"
              profile="nl-core-AbilityToUseToilet.ToiletUse"/>
      <nm:map ada="zorg_bij_menstruatie"
              resource="Observation"
              profile="nl-core-AbilityToUseToilet.MenstrualCare"/>
      <nm:map ada="vermogen_tot_uiterlijke_verzorging"
              resource="Observation"
              profile="nl-core-AbilityToGroom"/>
      <nm:map ada="vermogen_tot_zich_kleden"
              resource="Observation"
              profile="nl-core-AbilityToDressOneself"/>
      <nm:map ada="vermogen_tot_zich_wassen"
              resource="Observation"
              profile="nl-core-AbilityToWashOneself"/>
      <nm:map ada="verrichting"
              resource="Procedure"
              profile="nl-core-Procedure-event"/>
      <nm:map ada="verrichting"
              resource="ServiceRequest"
              profile="nl-core-Procedure-request"/>
      <nm:map ada="verstrekkingsverzoek"
              resource="MedicationRequest"
              profile="mp-DispenseRequest"/>
      <nm:map ada="visueel_resultaat"
              resource="Media"
              profile="nl-core-TextResult-Media"/>
      <nm:map ada="visus"
              resource="Observation"
              profile="nl-core-VisualAcuity"/>
      <nm:map ada="vochtbalans"
              resource="Observation"
              profile="nl-core-FluidBalance"/>
      <nm:map ada="vocht_totaal_in"
              resource="Observation"
              profile="nl-core-FluidBalance.FluidTotalIn"/>
      <nm:map ada="vocht_totaal_uit"
              resource="Observation"
              profile="nl-core-FluidBalance.FluidTotalOut"/>
      <nm:map ada="voedingsadvies"
              resource="NutritionOrder"
              profile="nl-core-NutritionAdvice"/>
      <nm:map ada="voedingspatroon_zuigeling"
              resource="Observation"
              profile="nl-core-FeedingPatternInfant"/>
      <nm:map ada="vrijheidsbeperkende_interventie"
              resource="Procedure"
              profile="nl-core-FreedomRestrictingIntervention"/>
      <nm:map ada="wilsverklaring"
              resource="Consent"
              profile="nl-core-AdvanceDirective"/>
      <nm:map ada="wisselend_doseerschema"
              resource="MedicationRequest"
              profile="mp-VariableDosingRegimen"/>
      <nm:map ada="wond"
              resource="Condition"
              profile="nl-core-Wound"/>
      <nm:map ada="wond"
              resource="Observation"
              profile="nl-core-wounds.WoundCharacteristics"/>
      <nm:map ada="wond_weefsel"
              resource="Observation"
              profile="nl-core-Wound.WoundTissue"/>
      <nm:map ada="wond_infectie"
              resource="Observation"
              profile="nl-core-Wound.WoundInfection"/>
      <nm:map ada="wond_vochtigheid"
              resource="Observation"
              profile="nl-core-Wound.WoundMoisture"/>
      <nm:map ada="wond_rand"
              resource="Observation"
              profile="nl-core-Wound.WoundEdge"/>
      <nm:map ada="woonsituatie"
              resource="Observation"
              profile="nl-core-LivingSituation"/>
      <nm:map ada="ziektebeleving"
              resource="Observation"
              profile="nl-core-IllnessPerception"/>
      <nm:map ada="ziekte_inzicht_van_patient"
              resource="Observation"
              profile="nl-core-IllnessPerception.PatientIllnessInsight"/>
      <nm:map ada="omgaan_met_ziekteproces_door_patient"
              resource="Observation"
              profile="nl-core-IllnessPerception.CopingWithIllnessByPatient"/>
      <nm:map ada="omgaan_met_ziekteproces_door_naasten"
              resource="Observation"
              profile="nl-core-IllnessPerception.CopingWithIllnessByFamily"/>
      <nm:map ada="zorgaanbieder"
              resource="Organization"
              profile="nl-core-HealthcareProvider-Organization"/>
      <nm:map ada="zorgaanbieder"
              resource="Location"
              profile="nl-core-HealthcareProvider"/>
      <nm:map ada="zorg_episode"
              resource="EpisodeOfCare"
              profile="nl-core-EpisodeOfCare"/>
      <nm:map ada="zorg_team"
              resource="CareTeam"
              profile="nl-core-CareTeam"/>
      <nm:map ada="zorgverlener"
              resource="PractitionerRole"
              profile="nl-core-HealthProfessional-PractitionerRole"/>
      <nm:map ada="zorgverlener"
              resource="Practitioner"
              profile="nl-core-HealthProfessional-Practitioner"/>
      <nm:map ada="zwangerschap"
              resource="Condition"
              profile="nl-core-Pregnancy"/>
      <nm:map ada="zwangerschapsduur"
              resource="Observation"
              profile="nl-core-Pregnancy.PregnancyDuration"/>
      <nm:map ada="pariteit"
              resource="Observation"
              profile="nl-core-Pregnancy.Parity"/>
      <nm:map ada="graviditeit"
              resource="Observation"
              profile="nl-core-Pregnancy.Gravidity"/>
      <nm:map ada="aterme_datum_items"
              resource="Observation"
              profile="nl-core-Pregnancy.EstimatedDateOfDelivery"/>
      <nm:map ada="datum_laatste_menstruatie"
              resource="Observation"
              profile="nl-core-Pregnancy.DateLastMenstruation"/>
      <!-- Concepts for Brandwond (Burnwound), DecubitusWond (PressureUlcer) and/or Wond (Wound) -->
      <nm:map ada="wondlengte"
              resource="Observation"
              profile="nl-core-wounds.WoundLength"/>
      <nm:map ada="wondbreedte"
              resource="Observation"
              profile="nl-core-wounds.WoundWidth"/>
      <nm:map ada="wonddiepte"
              resource="Observation"
              profile="nl-core-wounds.WoundDepth"/>
      <nm:map ada="datum_laatste_verbandwissel"
              resource="Observation"
              profile="nl-core-wounds.DateOfLastDressingChange"/>
      <nm:map ada="wond_foto"
              resource="DocumentReference"
              profile="nl-core-wounds.WoundImage"/>
   </xsl:variable>
   <xsl:variable name="zib2020Oid"
                 select="'2.16.840.1.113883.2.4.3.11.60.40.1'"/>
   <xsl:param name="fhirVersion"
              select="'R4'"/>
   <xsl:param name="patientTokensXml"
              select="document('../../../ada-2-fhir/env/fhir/QualificationTokens.xml')"/>
   <xsl:param name="fhirMetadata"
              as="element()*">
      <xsl:call-template name="buildFhirMetadata">
         <xsl:with-param name="in"
                         select="/*"/>
      </xsl:call-template>
   </xsl:param>
   <!-- Outputs reference if input is ADA, fhirMetadata or ADA reference element -->
   <!-- Generic (fallback) templates, each zib transformation can have more relevant id and display generation mechanisms -->
   <!-- ================================================================== -->
   <xsl:template name="buildFhirMetadata">
      <!-- Build the FHIR metadata for the resources that shall result from the transformation of the specified ADA instances. This metadata may then be used when building the actual FHIR instances for building references and Bundle's. For each generated FHIR instance, the FHIR metadata will be stored in an nm:resource element and may contain the following elements:
            
                nm:resource-type: the name of the resulting FHIR resource.
                nm:ada-id: the ADA id, if present.
                nm:group-key: a hash of the content of the ADA instance.
                nm:logical-id: the logical id for the FHIR instance, if one is needed (see the populateId and  parameters). If a logical id is not given by ADA, it will be generated using the best matching template with the _generateId mode.
                nm:full-url: the fullUrl for the resource, based on what is needed for the current referencing strategy (see the  parameter).
                nm:ref-url: the url to reference the resource, based on what is needed for the current referencing strategy (see the referencingStrategy parameter).
                nm:reference-display: the display to use when referencing this FHIR resource. The display will be generated by the best matching template with the _generateDisplay mode.
            
            Note that for patient and zorgverlener are treated in a special way; if multiple patients and zorgverleners are passed with the same identification number but with differences in the content, instances for each set of unique content will be generated. 
         -->
      <xsl:param name="in">
         <!-- The ADA instances where the FHIR instances will be generated from. -->
      </xsl:param>
      <xsl:if test="not($referencingStrategy = ('logicalId', 'uuid', 'none'))">
         <xsl:call-template name="util:logMessage">
            <xsl:with-param name="level"
                            select="$logFATAL"/>
            <xsl:with-param name="msg">Invalid $referencingStrategy (
<xsl:value-of select="$referencingStrategy"/>). Should be one of 'logicalId', 'uuid', 'none'</xsl:with-param>
            <xsl:with-param name="terminate"
                            select="true()"/>
         </xsl:call-template>
      </xsl:if>
      <xsl:for-each-group select="$in[self::patient[.//(@value | @code | @nullFlavor)]]"
                          group-by="concat((identificatienummer[@root = $oidBurgerservicenummer], identificatienummer[not(@root = $oidBurgerservicenummer)])[1]/@root, (identificatienummer[@root = $oidBurgerservicenummer], identificatienummer[not(@root = $oidBurgerservicenummer)])[1]/normalize-space(@value))">
         <xsl:for-each-group select="current-group()"
                             group-by="nf:getGroupingKeyDefault(.)">
            <xsl:call-template name="_buildFhirMetadataForAdaEntry">
               <xsl:with-param name="partNumber"
                               select="position()"/>
            </xsl:call-template>
         </xsl:for-each-group>
      </xsl:for-each-group>
      <xsl:for-each-group select="$in[self::zorgverlener[.//(@value | @code | @nullFlavor)]]"
                          group-by="concat(nf:ada-zvl-id(zorgverlener_identificatienummer)/@root,                 nf:ada-zvl-id(zorgverlener_identificatienummer)/normalize-space(@value))">
         <!-- let's resolve the zorgaanbieder ín the zorgverlener, to make sure deduplication also works for duplicated zorgaanbieders -->
         <xsl:variable name="zorgverlenerWithResolvedZorgaanbieder"
                       as="element(zorgverlener)*">
            <xsl:apply-templates select="current-group()"
                                 mode="resolveAdaZorgaanbieder"/>
         </xsl:variable>
         <xsl:for-each-group select="$zorgverlenerWithResolvedZorgaanbieder"
                             group-by="nf:getGroupingKeyDefault(.)">
            <xsl:call-template name="_buildFhirMetadataForAdaEntry">
               <xsl:with-param name="partNumber"
                               select="position()"/>
            </xsl:call-template>
         </xsl:for-each-group>
      </xsl:for-each-group>
      <xsl:for-each-group select="$in[self::zorgaanbieder[.//(@value | @code | @nullFlavor)]]"
                          group-by="concat(nf:ada-za-id(zorgaanbieder_identificatienummer)/@root,                 nf:ada-za-id(zorgaanbieder_identificatienummer)/normalize-space(@value))">
         <xsl:for-each-group select="current-group()"
                             group-by="nf:getGroupingKeyDefault(.)">
            <xsl:call-template name="_buildFhirMetadataForAdaEntry">
               <xsl:with-param name="partNumber"
                               select="position()"/>
            </xsl:call-template>
         </xsl:for-each-group>
      </xsl:for-each-group>
      <!-- If and only if there is more than one laboratorium_test, there should be an instance for each
                 distinct laboratorium_test (in addition the "grouping" instance already identified as part of the 
                 main process. -->
      <xsl:for-each-group select="$in[self::laboratorium_uitslag]/laboratorium_test[.//(@value | @code | @nullFlavor)]"
                          group-by="nf:getGroupingKeyLaboratoryTest(.)">
         <xsl:call-template name="_buildFhirMetadataForAdaEntry"/>
      </xsl:for-each-group>
      <!-- General rule for all zib root concepts that need to be converted into a FHIR resource -->
      <xsl:for-each-group select="($in[not(self::patient | self::zorgverlener | self::zorgaanbieder)],                         $in//horen_hulpmiddel/medisch_hulpmiddel,                         $in//zien_hulpmiddel/medisch_hulpmiddel,                         $in//drain/medisch_hulpmiddel,                         $in//visueel_resultaat[parent::tekst_uitslag],                         $in//soepregel[parent::soepverslag],                         $in//monster[parent::laboratorium_uitslag],                         $in//bron_monster[parent::monster],                         $in//zwangerschapsduur[parent::zwangerschap],                         $in//pariteit[parent::zwangerschap],                         $in//graviditeit[parent::zwangerschap],                         $in//aterme_datum_items[parent::zwangerschap],                         $in//datum_laatste_menstruatie[parent::aterme_datum_items/parent::zwangerschap],                         $in//wond_weefsel[parent::wond],                         $in//wond_infectie[parent::wond],                         $in//wond_vochtigheid[parent::wond],                         $in//wond_rand[parent::wond],                         $in//wondlengte[parent::wond or parent::decubitus_wond],                         $in//wondbreedte[parent::wond or parent::decubitus_wond],                         $in//wonddiepte[parent::wond or parent::decubitus_wond],                         $in//wondfoto[parent::wond or parent::decubitus_wond or parent::brandwond],                         $in//datum_laatste_verband_wissel[parent::wond or parent::decubitus_wond],                         $in//uitgebreidheid[parent::brandwond],                         $in//sociaal_netwerk[parent::participatie_in_maatschappij],                         $in//vrijetijdsbesteding[parent::participatie_in_maatschappij],                         $in//arbeidssituatie[parent::participatie_in_maatschappij],                         $in//lopen[parent::mobiliteit],                         $in//traplopen[parent::mobiliteit],                         $in//houding_veranderen[parent::mobiliteit],                         $in//houding_handhaven[parent::mobiliteit],                         $in//uitvoeren_transfer[parent::mobiliteit],                         $in//ziekte_inzicht_van_patient[parent::ziektebeleving],                         $in//omgaan_met_ziekteproces_door_patient[parent::ziektebeleving],                         $in//omgaan_met_ziekteproces_door_naasten[parent::ziektebeleving],                         $in//toiletgebruik[parent::vermogen_tot_toiletgang],                         $in//zorg_bij_menstruatie[parent::vermogen_tot_toiletgang],                         $in//feces_continentie[parent::darmfunctie],                         $in//frequentie[parent::darmfunctie],                         $in//defecatie_consistentie[parent::darmfunctie],                         $in//defecatie_kleur[parent::darmfunctie],                         $in//zindelijkheid_urine[parent::ontwikkeling_kind],                         $in//zindelijkheid_feces[parent::ontwikkeling_kind],                         $in//leeftijd_eerste_menstruatie[parent::ontwikkeling_kind],                         $in//ontwikkeling_motoriek[parent::ontwikkeling_kind],                         $in//ontwikkeling_sociaal[parent::ontwikkeling_kind],                         $in//ontwikkeling_taal[parent::ontwikkeling_kind],                         $in//ontwikkeling_verstandelijk[parent::ontwikkeling_kind],                         $in//vocht_totaal_in[parent::vochtbalans],                         $in//vocht_totaal_uit[parent::vochtbalans],                         $in//drink_beperkingen[parent::vermogen_tot_drinken],                         $in//eet_beperkingen[parent::vermogen_tot_eten],                         $in//hartslag_regelmatigheid[parent::hartfrequentie],                         $in//interpretatie_frequentie[parent::hartfrequentie],                         $in//pols_regelmatigheid[parent::polsfrequentie])[.//(@value | @code | @nullFlavor)]"
                          group-by="local-name()">
         <xsl:for-each-group select="current-group()"
                             group-by="nf:getGroupingKeyDefault(.)">
            <xsl:call-template name="_buildFhirMetadataForAdaEntry">
               <xsl:with-param name="partNumber"
                               select="position()"/>
            </xsl:call-template>
         </xsl:for-each-group>
         <xsl:variable name="cnt"
                       select="count(current-group())"/>
         <xsl:variable name="monsterMateriaal"
                       as="element(f:monster2)?">
            <xsl:if test="current-group()[self::monster][microorganisme][monstermateriaal]">
               <monster2>
                  <xsl:copy-of select="current-group()[self::monster][microorganisme][monstermateriaal][1]/* except microorganisme"/>
               </monster2>
            </xsl:if>
         </xsl:variable>
         <xsl:for-each-group select="$monsterMateriaal"
                             group-by="nf:getGroupingKeyDefault(.)">
            <xsl:call-template name="_buildFhirMetadataForAdaEntry">
               <xsl:with-param name="in"
                               select="$monsterMateriaal"/>
               <xsl:with-param name="partNumber"
                               select="position()"/>
            </xsl:call-template>
         </xsl:for-each-group>
      </xsl:for-each-group>
      <xsl:for-each select="$in[not(.//(@value | @code | @nullFlavor))][not(ends-with(local-name(), '-start'))]">
         <xsl:call-template name="util:logMessage">
            <xsl:with-param name="level"
                            select="$logERROR"/>
            <xsl:with-param name="msg">no meaningful content found in 
<xsl:value-of select="replace(tokenize(base-uri(), '/')[last()], '.xml', '')"/> - 
<xsl:value-of select="local-name()"/>
            </xsl:with-param>
         </xsl:call-template>
      </xsl:for-each>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template name="_buildFhirMetadataForAdaEntry"
                 as="element(nm:resource)*">
      <!-- Helper template to build the FHIR metadata for a single ADA instance. See the documentation on  for more information. -->
      <xsl:param name="in"
                 select="current-group()[1]">
         <!-- The ADA instance to generate metadata for. -->
      </xsl:param>
      <xsl:param name="partNumber"
                 as="xs:integer"
                 select="0">
         <!-- The sequence number of the ADA instance being passed in the total collection of ADA instances of this kind. This sequence number is needed for ids in resources that represent just a part of a zib. -->
      </xsl:param>
      <xsl:variable name="adaElement"
                    as="xs:string"
                    select="$in/local-name()"/>
      <xsl:variable name="adaId"
                    select="$in/@id"/>
      <xsl:variable name="groupKey"
                    select="current-grouping-key()"/>
      <xsl:for-each select="$ada2resourceType/nm:map[@ada = $adaElement]">
         <xsl:variable name="profile"
                       select="@profile"/>
         <nm:resource profile="{$profile}">
            <nm:resource-type>
               <xsl:value-of select="@resource"/>
            </nm:resource-type>
            <xsl:if test="$adaId">
               <nm:ada-id>
                  <xsl:variable name="baseUri"
                                select="replace(tokenize($in/base-uri(), '/')[last()], '.xml', '')"/>
                  <xsl:if test="string-length($baseUri) gt 0">
                     <xsl:value-of select="$baseUri"/>
                     <xsl:text>-</xsl:text>
                  </xsl:if>
                  <xsl:value-of select="$adaId"/>
               </nm:ada-id>
            </xsl:if>
            <nm:group-key>
               <xsl:value-of select="$groupKey"/>
            </nm:group-key>
            <xsl:variable name="logicalId">
               <xsl:choose>
                  <xsl:when test="$in/@logicalId">
                     <xsl:choose>
                        <xsl:when test="count($ada2resourceType/nm:map[@ada = $adaElement]) gt 1">
                           <xsl:value-of select="concat($in/@logicalId, '-', @resource)"/>
                        </xsl:when>
                        <xsl:otherwise>
                           <xsl:value-of select="$in/@logicalId"/>
                        </xsl:otherwise>
                     </xsl:choose>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:apply-templates select="$in"
                                          mode="_generateId">
                        <xsl:with-param name="profile"
                                        select="$profile"/>
                        <xsl:with-param name="partNumber"
                                        select="$partNumber"/>
                     </xsl:apply-templates>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:variable>
            <xsl:if test="$populateId = true() or $referencingStrategy = 'logicalId'">
               <nm:logical-id>
                  <xsl:value-of select="$logicalId"/>
               </nm:logical-id>
            </xsl:if>
            <xsl:choose>
               <xsl:when test="$in/@referenceUri">
                  <nm:full-url>
                     <xsl:value-of select="$in/@referenceUri"/>
                  </nm:full-url>
                  <nm:ref-url>
                     <xsl:value-of select="$in/@referenceUri"/>
                  </nm:ref-url>
               </xsl:when>
               <xsl:when test="$referencingStrategy = 'logicalId'">
                  <xsl:variable name="serverBaseUriEdit">
                     <xsl:choose>
                        <xsl:when test="ends-with($serverBaseUri, '/')">
                           <xsl:value-of select="$serverBaseUri"/>
                        </xsl:when>
                        <xsl:otherwise>
                           <xsl:value-of select="concat($serverBaseUri, '/')"/>
                        </xsl:otherwise>
                     </xsl:choose>
                  </xsl:variable>
                  <nm:full-url>
                     <xsl:value-of select="concat($serverBaseUriEdit, @resource, '/', $logicalId)"/>
                  </nm:full-url>
                  <nm:ref-url>
                     <xsl:value-of select="concat(@resource, '/', $logicalId)"/>
                  </nm:ref-url>
               </xsl:when>
               <xsl:when test="$referencingStrategy = 'uuid'">
                  <xsl:variable name="profileSpecificUuid"
                                as="element(nm:uuid)">
                     <nm:uuid profile="{$profile}">
                        <xsl:copy-of select="$in"/>
                     </nm:uuid>
                  </xsl:variable>
                  <nm:full-url>
                     <xsl:value-of select="nf:get-fhir-uuid($profileSpecificUuid)"/>
                  </nm:full-url>
                  <nm:ref-url>
                     <xsl:value-of select="nf:get-fhir-uuid($profileSpecificUuid)"/>
                  </nm:ref-url>
               </xsl:when>
            </xsl:choose>
            <nm:reference-display>
               <xsl:variable name="generatedDisplay"
                             as="xs:string*">
                  <xsl:apply-templates select="$in"
                                       mode="_generateDisplay">
                     <xsl:with-param name="profile"
                                     select="$profile"/>
                  </xsl:apply-templates>
               </xsl:variable>
               <xsl:value-of select="normalize-space(string-join($generatedDisplay, ''))"/>
            </nm:reference-display>
         </nm:resource>
      </xsl:for-each>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template name="generateLogicalId"
                 match="*"
                 mode="generateLogicalId">
      <!-- Helper template for creating logicalId -->
      <xsl:param name="uniqueString"
                 as="xs:string?">
         <!-- The unique string with which to create a logical id. Optional. If not given a uuid will be generated. -->
      </xsl:param>
      <xsl:choose>
         <xsl:when test="string-length($uniqueString) le $maxLengthFHIRLogicalId - 2 and string-length($uniqueString) gt 0">
            <xsl:value-of select="nf:assure-logicalid-length(nf:assure-logicalid-chars($uniqueString))"/>
         </xsl:when>
         <xsl:otherwise>
            <!-- we do not have anything to create a stable logicalId, lets return a UUID -->
            <xsl:value-of select="uuid:get-uuid(.)"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template name="makeReference">
      <!-- Generate a FHIR reference. When there's no input or a reference can't otherwise be constructed, no output is generated. -->
      <xsl:param name="in"
                 select="."
                 as="element()*">
         <!-- The target of the reference as either an ADA instance or an ADA reference element. May be omitted if it is the same as the context. -->
      </xsl:param>
      <xsl:param name="profile"
                 as="xs:string"
                 select="''">
         <!-- The id of the profile that is targeted. This is needed to specify which profile is targeted when a single ADA instance is mapped onto multiple FHIR profiles. It may be omitted otherwise. -->
      </xsl:param>
      <xsl:param name="wrapIn"
                 as="xs:string?">
         <!-- Optional element name to wrap the output in. If no output is generated, this wrapper will not be generated as well. -->
      </xsl:param>
      <xsl:param name="contained"
                 as="xs:boolean"
                 tunnel="yes"
                 select="false()"/>
      <xsl:for-each select="$in">
         <!-- Debug -->
         <xsl:if test="count($fhirMetadata) = 0">
            <xsl:call-template name="util:logMessage">
               <xsl:with-param name="level"
                               select="$logFATAL"/>
               <xsl:with-param name="msg">Cannot create reference because $fhirMetadata is empty or unknown.</xsl:with-param>
               <xsl:with-param name="terminate"
                               select="true()"/>
            </xsl:call-template>
         </xsl:if>
         <xsl:variable name="resolvedAdaElement"
                       as="element()*">
            <xsl:choose>
               <xsl:when test="$in[@datatype = 'reference' and @value] and not(empty(nf:resolveAdaInstance($in, /)))">
                  <!-- use xsl:sequence instead of copy-of to preserve the context of the adaXml -->
                  <xsl:sequence select="nf:resolveAdaInstance($in, /)"/>
               </xsl:when>
               <xsl:otherwise>
                  <!-- use xsl:sequence instead of copy-of to preserve the context of the adaXml -->
                  <xsl:sequence select="$in"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:variable>
         <xsl:variable name="groupKey"
                       as="xs:string?">
            <xsl:choose>
               <xsl:when test="$resolvedAdaElement[self::laboratorium_test]">
                  <xsl:value-of select="nf:getGroupingKeyLaboratoryTest($resolvedAdaElement)"/>
               </xsl:when>
               <xsl:when test="$resolvedAdaElement[self::zorgverlener]">
                  <!-- let's resolve the zorgaanbieder ín the zorgverlener, to make sure deduplication also works for duplicated zorgaanbieders -->
                  <xsl:variable name="zorgverlenerWithResolvedZorgaanbieder"
                                as="element(zorgverlener)*">
                     <xsl:apply-templates select="$resolvedAdaElement"
                                          mode="resolveAdaZorgaanbieder"/>
                  </xsl:variable>
                  <xsl:value-of select="nf:getGroupingKeyDefault($zorgverlenerWithResolvedZorgaanbieder)"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="nf:getGroupingKeyDefault($resolvedAdaElement)"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:variable>
         <xsl:variable name="element"
                       as="element()?">
            <xsl:choose>
               <xsl:when test="count($fhirMetadata[nm:group-key = $groupKey]) gt 1">
                  <xsl:if test="string-length($profile) = 0">
                     <xsl:call-template name="util:logMessage">
                        <xsl:with-param name="level"
                                        select="$logFATAL"/>
                        <xsl:with-param name="msg">makeReference: Duplicate entry found for $groupKey '
<xsl:value-of select="$groupKey"/>' in $fhirMetadata, while no $profile was supplied.</xsl:with-param>
                        <xsl:with-param name="terminate"
                                        select="true()"/>
                     </xsl:call-template>
                  </xsl:if>
                  <xsl:if test="not($fhirMetadata[@profile = $profile and nm:group-key = $groupKey])">
                     <xsl:call-template name="util:logMessage">
                        <xsl:with-param name="level"
                                        select="$logFATAL"/>
                        <xsl:with-param name="msg">makeReference: No entry found for $groupKey '
<xsl:value-of select="$groupKey"/>' in $fhirMetadata, but no valid $profile ('
<xsl:value-of select="$profile"/>') was supplied.</xsl:with-param>
                        <xsl:with-param name="terminate"
                                        select="true()"/>
                     </xsl:call-template>
                  </xsl:if>
                  <xsl:if test="count($fhirMetadata[@profile = $profile and nm:group-key = $groupKey]) gt 1">
                     <xsl:call-template name="util:logMessage">
                        <xsl:with-param name="level"
                                        select="$logFATAL"/>
                        <xsl:with-param name="msg">makeReference: Duplicate entry found for $groupKey '
<xsl:value-of select="$groupKey"/>' and $profile '
<xsl:value-of select="$profile"/>'in $fhirMetadata.</xsl:with-param>
                        <xsl:with-param name="terminate"
                                        select="true()"/>
                     </xsl:call-template>
                  </xsl:if>
                  <xsl:copy-of select="$fhirMetadata[@profile = $profile and nm:group-key = $groupKey]"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:copy-of select="$fhirMetadata[nm:group-key = $groupKey]"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:variable>
         <xsl:variable name="identifier"
                       select="(identificatienummer | identificatie)[normalize-space(@value | @nullFlavor)]"/>
         <!-- Debug -->
         <xsl:if test="$in and count($element) = 0 and not($identifier)">
            <xsl:call-template name="util:logMessage">
               <xsl:with-param name="level"
                               select="$logERROR"/>
               <xsl:with-param name="msg">Cannot resolve reference within set of ada-instances: 
<xsl:value-of select="$groupKey"/>
               </xsl:with-param>
            </xsl:call-template>
         </xsl:if>
         <xsl:variable name="populatedReference"
                       as="element()*">
            <xsl:if test="string-length($element/nm:ref-url) gt 0">
               <reference value="{$element/nm:ref-url}"/>
            </xsl:if>
            <xsl:if test="string-length($element/nm:resource-type) gt 0">
               <type value="{$element/nm:resource-type}"/>
            </xsl:if>
            <xsl:choose>
               <xsl:when test="$referencingStrategy = 'none' and not($element/nm:ref-url) and $identifier">
                  <identifier>
                     <xsl:call-template name="id-to-Identifier">
                        <xsl:with-param name="in"
                                        select="($identifier[not(@root = $mask-ids-var)], $identifier)[1]"/>
                     </xsl:call-template>
                  </identifier>
               </xsl:when>
               <!-- AWE regardless of referencingStrategy, it makes sense to output an identifier if available if reference has not been populated -->
               <xsl:when test="empty($element/nm:ref-url) and $identifier">
                  <identifier>
                     <xsl:call-template name="id-to-Identifier">
                        <xsl:with-param name="in"
                                        select="($identifier[not(@root = $mask-ids-var)], $identifier)[1]"/>
                     </xsl:call-template>
                  </identifier>
               </xsl:when>
            </xsl:choose>
            <xsl:if test="string-length($element/nm:reference-display) gt 0">
               <display value="{$element/nm:reference-display}"/>
            </xsl:if>
         </xsl:variable>
         <xsl:if test="count($populatedReference) gt 0">
            <xsl:choose>
               <xsl:when test="$wrapIn">
                  <xsl:element name="{$wrapIn}">
                     <xsl:copy-of select="$populatedReference"/>
                  </xsl:element>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:copy-of select="$populatedReference"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:if>
      </xsl:for-each>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template name="insertLogicalId">
      <!-- Insert the FHIR resource id element for the specified ADA instance, if an id is required.
         -->
      <xsl:param name="in"
                 select=".">
         <!-- The ADA instance that the FHIR resource is generated for. -->
      </xsl:param>
      <xsl:param name="profile"
                 as="xs:string"
                 select="''">
         <!-- The id of the profile that is being generated from the specified ADA instance. This is needed to specify which profile is targeted when a single ADA instance results is mapped onto multiple FHIR profiles. It may be omitted otherwise. -->
      </xsl:param>
      <xsl:variable name="logicalId">
         <xsl:call-template name="getLogicalIdFromFhirMetadata">
            <xsl:with-param name="in"
                            select="$in"/>
            <xsl:with-param name="profile"
                            select="$profile"/>
         </xsl:call-template>
      </xsl:variable>
      <xsl:if test="string-length($logicalId) gt 0">
         <id value="{$logicalId}"/>
      </xsl:if>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template name="getLogicalIdFromFhirMetadata">
      <!-- Get the FHIR resource id element for the specified ADA instance, if an id is available.
         -->
      <xsl:param name="in"
                 select=".">
         <!-- The ADA instance that the FHIR resource is generated for. -->
      </xsl:param>
      <xsl:param name="profile"
                 as="xs:string"
                 select="''">
         <!-- The id of the profile that is being generated from the specified ADA instance. This is needed to specify which profile is targeted when a single ADA instance results is mapped onto multiple FHIR profiles. It may be omitted otherwise. -->
      </xsl:param>
      <xsl:variable name="groupKey">
         <xsl:choose>
            <xsl:when test="$in[self::laboratorium_test]">
               <xsl:value-of select="nf:getGroupingKeyLaboratoryTest($in)"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="nf:getGroupingKeyDefault($in)"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:if test="count($fhirMetadata[nm:group-key = $groupKey]) gt 1 and string-length($profile) = 0">
         <xsl:call-template name="util:logMessage">
            <xsl:with-param name="level"
                            select="$logFATAL"/>
            <xsl:with-param name="msg">insertId: Duplicate entry found in $fhirMetadata, while no $profile was supplied. $groupKey: 
<xsl:value-of select="$groupKey"/>
            </xsl:with-param>
            <xsl:with-param name="terminate"
                            select="true()"/>
         </xsl:call-template>
      </xsl:if>
      <xsl:variable name="logicalId">
         <xsl:choose>
            <xsl:when test="count($fhirMetadata[nm:group-key = $groupKey]) gt 1">
               <xsl:value-of select="$fhirMetadata[@profile = $profile and nm:group-key = $groupKey]/nm:logical-id"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="$fhirMetadata[nm:group-key = $groupKey]/nm:logical-id"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:if test="string-length($logicalId) gt 0">
         <xsl:value-of select="$logicalId"/>
      </xsl:if>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template name="insertFullUrl">
      <!-- Insert the FHIR fullUrl element for the specified instance, if one is available. -->
      <xsl:param name="in"
                 select=".">
         <!-- The ADA instance that the FHIR resource is generated for. -->
      </xsl:param>
      <xsl:param name="profile"
                 as="xs:string"
                 select="''">
         <!-- The id of the profile that is being generated from the specified ADA instance. This is needed to specify which profile is targeted when a single ADA instance results is mapped onto multiple FHIR profiles. It may be omitted otherwise. -->
      </xsl:param>
      <xsl:variable name="groupKey">
         <xsl:choose>
            <xsl:when test="$in[self::laboratorium_test]">
               <xsl:value-of select="nf:getGroupingKeyLaboratoryTest($in)"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="nf:getGroupingKeyDefault($in)"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:if test="count($fhirMetadata[nm:group-key = $groupKey]) gt 1 and string-length($profile) = 0">
         <xsl:call-template name="util:logMessage">
            <xsl:with-param name="level"
                            select="$logFATAL"/>
            <xsl:with-param name="msg">insertFullUrl: Duplicate entry found in $fhirMetadata, while no $profile was supplied.</xsl:with-param>
            <xsl:with-param name="terminate"
                            select="true()"/>
         </xsl:call-template>
      </xsl:if>
      <xsl:variable name="fullUrl">
         <xsl:choose>
            <xsl:when test="count($fhirMetadata[nm:group-key = $groupKey]) gt 1">
               <xsl:value-of select="$fhirMetadata[@profile = $profile and nm:group-key = $groupKey]/nm:full-url"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="$fhirMetadata[nm:group-key = $groupKey]/nm:full-url"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:if test="string-length($fullUrl) gt 0">
         <fullUrl value="{$fullUrl}"/>
      </xsl:if>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="*"
                 mode="_generateId">
      <!-- Generic template for generating an id for a FHIR resource. Stylesheets for specific zibs can override this with a more specific version. -->
      <xsl:param name="in"
                 select=".">
         <!-- The ADA instance to generate the id for. -->
      </xsl:param>
      <xsl:param name="profile"
                 as="xs:string?"
                 select="''">
         <!-- The id of the profile that is targeted. This is needed to specify which profile is targeted when a single ADA instance results is mapped onto multiple FHIR profiles. It may be omitted otherwise. -->
      </xsl:param>
      <xsl:variable name="uuidIn"
                    as="element()?">
         <xsl:element name="{$in/local-name()}">
            <xsl:copy-of select="$in/@*"/>
            <xsl:attribute name="profile"
                           select="$profile"/>
            <xsl:copy-of select="$in/node()"/>
         </xsl:element>
      </xsl:variable>
      <xsl:value-of select="nf:assure-logicalid-chars(nf:get-uuid($uuidIn))"/>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template match="*"
                 mode="_generateDisplay">
      <!-- Generic template for generating a display for use in FHIR references. Stylesheets for specific zibs can override this with a more specific version. -->
      <xsl:param name="in"
                 select=".">
         <!-- The ADA instance to generate the display for. -->
      </xsl:param>
      <xsl:choose>
         <xsl:when test="$in//*[ends-with(local-name(.), '_naam')][@value or @displayName or @originalText]">
            <xsl:value-of select="($in//*[ends-with(local-name(.), '_naam')]/(@displayName, @originalText, @value))[1]"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="local-name($in)"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:function name="nf:resolveAdaInstance"
                 as="element()*">
      <!-- Function to resolve internal references in an ADA instance. The output is the contained ADA instance being referenced or the input node if the input node isn't a reference. -->
      <xsl:param name="in"
                 as="element()?">
         <!-- The ADA instance to resolve. -->
      </xsl:param>
      <xsl:param name="context"
                 as="node()">
         <!-- The complete ADA instance where the contained ADA instance is contained in. -->
      </xsl:param>
      <xsl:choose>
         <xsl:when test="$in[@datatype = 'reference' and @value]">
            <xsl:variable name="adaId"
                          select="$in/@value"/>
            <!-- use xsl:sequence instead of copy-of to preserve the context of the adaXml -->
            <xsl:sequence select="$context//*[@id = $adaId][1]"/>
         </xsl:when>
         <xsl:otherwise>
            <!-- use xsl:sequence instead of copy-of to preserve the context of the adaXml -->
            <xsl:sequence select="$in"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:function name="nf:assure-logicalid-chars"
                 as="xs:string">
      <!-- Returns a string based on requirements for FHIR logicalId (https://www.hl7.org/fhir/datatypes.html#id). 
            An underscore is translated to '-'. Any other char that is not allowed is simply removed. -->
      <xsl:param name="logicalId"
                 as="xs:string?">
         <!-- The string to handle -->
      </xsl:param>
      <xsl:value-of select="replace(translate($logicalId, '_', '-'), '[^A-Za-z0-9\-\.]', '')"/>
   </xsl:function>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:function name="nf:assure-logicalid-length"
                 as="xs:string">
      <!-- Returns a concatenated string based on input param $logicalId. Only returns a string of length max length for FHIR logicalId (64). 
            Because uniqueness is determined more by the latter part of $logicalId than by the start (often some sort of prefix), the last 64 characters are used. -->
      <xsl:param name="logicalId"
                 as="xs:string?">
         <!-- The string to concatenate -->
      </xsl:param>
      <xsl:variable name="lengthLogicalId"
                    select="string-length($logicalId)"
                    as="xs:integer"/>
      <xsl:variable name="startingLoc"
                    as="xs:integer">
         <xsl:choose>
            <xsl:when test="$lengthLogicalId gt $maxLengthFHIRLogicalId">
               <xsl:call-template name="util:logMessage">
                  <xsl:with-param name="msg">We have encountered an id (
<xsl:value-of select="$logicalId"/>) longer than 64 characters, we are truncating it, but it should be looked at.</xsl:with-param>
                  <xsl:with-param name="level"
                                  select="$logWARN"/>
                  <xsl:with-param name="terminate"
                                  select="false()"/>
               </xsl:call-template>
               <xsl:value-of select="$lengthLogicalId - ($maxLengthFHIRLogicalId - 1)"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="1"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:value-of select="substring($logicalId, $startingLoc, $lengthLogicalId)"/>
   </xsl:function>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:function name="nf:get-full-profilename-from-adaelement"
                 as="xs:string?">
      <!-- Returns the full profileName for an ada element, based on $urlBaseNictizProfile and $ada2resourceType constant.
            Selects the first one found, which may be wrong if there is more than one entry. In which case you should not use this function. -->
      <xsl:param name="adaElement"
                 as="element()?">
         <!-- The ada element for which to get the profileName -->
      </xsl:param>
      <xsl:value-of select="concat($urlBaseNictizProfile, nf:get-profilename-from-adaelement($adaElement))"/>
   </xsl:function>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:function name="nf:get-profilename-from-adaelement"
                 as="xs:string?">
      <!-- Returns the last part of the profileName for an ada element, based on $ada2resourceType constant. 
            Selects the first one found, which may be wrong if there is more than one entry. In which case you should not use this function. -->
      <xsl:param name="adaElement"
                 as="element()?">
         <!-- The ada element for which to get the profileName -->
      </xsl:param>
      <xsl:value-of select="$ada2resourceType/nm:map[@ada = $adaElement/local-name()][1]/@profile"/>
   </xsl:function>
   <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
   <xsl:template name="_buildMedicationQuantity">
      <!-- Helper template to build the a quantity for medication. -->
      <xsl:param name="adaValue"
                 as="element()">
         <!-- The ada element containing the value of quantity -->
      </xsl:param>
      <xsl:param name="adaUnit"
                 as="element()">
         <!-- The ada alement containing the code/codeSystem in Gstd eenheden -->
      </xsl:param>
      <!-- G-Standaard (Simple)Quantity -->
      <xsl:for-each select="$adaUnit[@codeSystem = $oidGStandaardBST902THES2]">
         <extension url="{$urlExtIso21090PQtranslation}">
            <valueQuantity>
               <value value="{$adaValue/@value}"/>
               <xsl:if test="string-length(@displayName) gt 0">
                  <unit value="{@displayName}"/>
               </xsl:if>
               <system value="{concat('urn:oid:', $oidGStandaardBST902THES2)}"/>
               <code value="{@code}"/>
            </valueQuantity>
         </extension>
      </xsl:for-each>
      <!-- UCUM -->
      <value value="{$adaValue/@value}"/>
      <xsl:if test="string-length($adaUnit[@codeSystem=$oidGStandaardBST902THES2]/@displayName) gt 0">
         <unit value="{$adaUnit[@codeSystem=$oidGStandaardBST902THES2]/@displayName}"/>
      </xsl:if>
      <system value="{$oidMap[@oid=$oidUCUM]/@uri}"/>
      <code value="{nf:convertGstdBasiseenheid2UCUM($adaUnit[@codeSystem=$oidGStandaardBST902THES2]/@code)}"/>
   </xsl:template>
</xsl:stylesheet>