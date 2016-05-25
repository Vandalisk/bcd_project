class LabResult
  @INDICATORS:
    A1c:
      name: 'A1c'
      nameFull: 'Hemoglobin A1c'
      description: 'A1c is an index of blood sugar over the previous 3 months — it is related to the average blood sugar were it to be taken every 5 minutes, 24/7 for 100 days.  The actual estimated average blood sugar is shown beside A1c as eAG  Recent changes in blood sugar will not be fully reflected in A1c.  The range in non-diabetic individuals is 4.0-6.0.  For individuals with diabetes a value >8.0 usually requires intervention (change in diet, exercise, or medication).  In Type 2 diabetes a value of 4.0-6.0 is currently regarded as "Ideal", 6.1-6.9 as "optimal", 7.0-7.9 as "adequate" and >7.9 as "inadequate".  In Type 1 diabetes values <6.4 suggest frequent low blood sugar: values 6.5-7.5 are regarded as "optimal", 7.6-8.4 as "sub-optimal"&>8.4 as "inadequate".'
      maxLevel: 8.0
      isImportant: true
    eAG:
      name: 'eAG'
      nameFull: 'Estimated Average Glucose'
      description: 'This parameter is a good estimate of the average blood sugar if it were to be measured every 5 minutes 24/7 for 100 days.  It is calculated directly from A1c - the formula is eAG = 1.6xA1c-2.6.'
      maxLevel: 10.2
      isImportant: true
    LDL:
      name: 'LDL'
      nameFull: 'LDL Cholesterol'
      description: 'LDL is otherwise known as "bad" cholesterol.  The major determinant of LDL is genetics.  Other causes include low thyroid function, liver disease and kidney disease.  LDL values <2.0 are recommended for individuals with diabetes aged > 42, heart disease & stroke or with a particularly adverse family history.  "Statin" drugs are highly effective in reducing LDL.  If you are being treated with a "statin" and your LDL is above target, your physician may increase the dose or add another agent. Another alternative therapy is a medication in the PCSK9 inhibitor class.  There drugs are expensive and given by injection every 2 or 4 weeks.'
      maxLevel: 2.0
      isImportant: true
    apoB:
      name: 'apoB'
      nameFull: 'Apolipoprotein B'
      description: 'ApoB is the structural protein of the LDL particle,the cholesterol portion of which is reported as "LDL cholesterol" see above.  Apo B is a very useful indirect measure of LDL cholesterol.  BCDiabetes prefers to use apoB over LDL cholesterol because fasting is not required. ApoB values <0.8 are considered ideal for individuals with diabetes aged > 42, heart disease & stroke or with a particularly adverse family history.  "Statin" drugs are highly effective in reducing apoB.  If you are being treated with a "statin" and your apoB is above target, your physician may increase the dose or add another agent. Another alternative therapy is a medication in the PCSK9 inhibitor class.  There drugs are expensive and given by injection every 2 or 4 weeks.'
      maxLevel: 0.8
      isImportant: true
    lipemia:
      name: 'lipemia'
      nameFull: 'Lipemia'
      description: 'The presence of lipemia suggests elevated blood fat levels.  Lipemia is normal if a blood sample is collected within hours of eating a fatty or starchy meal.  If lipemia is present in a blood sample collected in the fasting state it should be investigated.  Common causes of lipemia include overweight, inadequately controlled diabetes & alcohol excess.'
      minLevel: 0
      isImportant: false
    ACR:
      name: 'ACR'
      nameFull: 'Urine Albumin/Creatinine Ratio'
      description: 'Urinary albumin-creatinine ratio (ACR) is an index of the amount of albumin (protein) in the urine.  Values >20 are seen in established kidney disease.  Values 2.5-20 may indicate the early stages of kidney disease (microalbuminuria).  Blood pressure lowering medication and improved diabetes control (if diabetes present) are important treatments of elevated ACR.'
      maxLevel: 3.0
      isImportant: true
    Creat:
      name: 'Creat'
      nameFull: 'Serum Creatinine'
      description: 'Creatinine is excreted by the kidneys. Elevated creatinine may imply kidney insufficiency (failure). The normal range is generally 70-120. Values >150 may require medical attention.  Low values are of no significance.  See also eGFR.'
      maxLevel: 120
      isImportant: true
    eGFR:
      name: 'eGFR'
      nameFull: 'Estimated GFR'
      description: 'eGFR is an index of kidney function.  Values >59 are considered normal though values 50-60 may be normal in individuals who are overweight.  Values <45 require medical attention.'
      minLevel: 45
      isImportant: true
    K:
      name: 'K'
      nameFull: 'Potassium'
      description: 'K is potassium.  The normal range for blood is 3.5-5.5. High K levels may be seen in kidney disease or be caused by medication.  Values >5.9 are potentially dangerous and require urgent medical attention.  Low potassium levels may be seen with diuretic treatment or with diarrhea or vomiting.  Values <2.5 potentially dangerous and require urgent medical attention.'
      minLevel: 3.4
      maxLevel: 5.5
      isImportant: false
    'Na+':
      name: 'Na+'
      nameFull: 'Sodium'
      description: 'Na+ is sodium which is part of common salt. The normal range is usually 135-145.  The blood level of Na+, rather than being an indicator of how much salt is in the body is more indicative of how much water is in the body.  Low Na+ suggests too much water (but can be seen with diuretic therapy).  High Na+ suggests too little water or dehydration.  Abnormal levels require medical attention.'
      minLevel: 134
      maxLevel: 146
      isImportant: false
    ALT:
      name: 'ALT'
      nameFull: 'Alanine Aminotransferase'
      description: 'ALT is an enzyme that comes from liver and muscle. The normal range is usually <60. Elevated levels of ALT, particularly those >3 times the upper range of normal, require medical attention. Common causes of elevated ALT include overweight, poorly controlled diabetes, excess alcohol, hepatitis and medication.  Marked elevations of ALT can be seen in healthy individuals who have just done a work out (in such cases CK is also elevated) such elevated values of ALT & CK will return to normal within 96 hours of rest.'
      maxLevel: 80
      isImportant: false
    AST:
      name: 'AST'
      nameFull: 'Aspartate Aminotransferase'
      description: 'AST is an enzyme that comes from liver and muscle. The normal range is usually <35. Elevated levels, particularly those >3 times the upper range of normal, require medical attention.  Common causes of elevated AST include overweight, poorly controlled diabetes, excess alcohol, hepatitis and medication.  Marked elevations of AST can be seen in healthy individuals who have just done a work out (in such cases CK is also elevated) such elevated values of ALT & CK will return to normal within 96 hours of rest.'
      maxLevel: 80
      isImportant: false
    CK:
      name: 'CK'
      nameFull: 'Creatine Kinase'
      description: 'Creatine kinase (CK) is a muscle enzyme.  Elevated levels are commonly seen after exercise, in rare muscle conditions and during treatment with certain medication including statins.  If the CK level is >1000 or if you are weak or have sore muscles urgent medical attention is required. CK was previously used to detect muscle damage from heart attacks.  The preferred blood test for heart attack is now troponin.'
      maxLevel: 350
      isImportant: false
    TSH:
      name: 'TSH'
      nameFull: 'Thyroid Stimulating Hormone'
      description: 'TSH is a screening test for thyroid function.  The normal range is 0.27-4.2.  A normal value reliably excludes abnormal thyroid function (or confirms adequate thyroid hormone replacement) in individuals whose general health is stable. TSH may be unreliable in individuals with a history of head injury, pituitary disease or being treated with anti-thyroid medication (in which cases free T4 is the preferred screening test). TSH 4.3-9.9 suggests a borderline low thyroid "hypothyroidism" (values 4.3-6.0 may also be seen in normal individuals). TSH values >9.9 suggest hypothyroidism or inadequate thyroid replacement dose and require medical attention. A TSH value <0.05 suggests an overactive thyroid "hyperthyroidism" (or excess thyroid hormone replacement) and requires medical attention. TSH values 0.05-0.26 may be seen in many conditions including other (non-thyroid) illness. An additional thyroid test, such as "free T4" may be ordered in by your doctor.'
      maxLevel: 4.2
      isImportant: false
    FT4:
      name: 'FT4'
      nameFull: 'Free Thyroxine'
      description: 'Free T4 is the amount of free thyroid hormone in your blood.  The normal range is usually 10-20.   A low value suggests low thyroid function (or too much anti-thyroid medication); a high value suggests excessive thyroid function: both require medical attention.  In the presence of a normal TSH an abnormal (high or low) free T4 level may actually be "normal" (consistent with good health).'
      minLevel: 10
      maxLevel: 20
      isImportant: false
    FT3:
      name: 'FT3'
      nameFull: 'Free Triiodothyronine'
      description: 'Free T3 is the amount of free triiodthyronine (a short-acting form of thyroid hormone) in your blood.  The normal range is usually 3.5-6.5.   A low value suggests low thyroid function (or too much anti-thyroid medication); a high value suggests excessive thyroid function: both require medical attention.  In the presence of a normal TSH an abnormal (high or low) free T3 level may actually be "normal" (consistent with good health).'
      minLevel: 3.5
      maxLevel: 6.5
      isImportant: false
    Hb:
      name: 'Hb'
      nameFull: 'Hemoglobin'
      description: 'Hb is hemoglobin.  Hb is the protein that binds oxygen in the blood. Normal values in men are 130-170, normal values in women are 115-150. Low levels (anemia) are seen in many conditions including kidney and other chronic diseases, malnutrition, iron/B12/folate deficiency and in many blood conditions.  High levels are seen in smokers, individuals with kidney disease treated on medication, in rare blood conditions, in people living at altitude and in athletes who have done blood doping.'
      minLevel: 110
      maxLevel: 170
      isImportant: false
    PRL:
      name: 'PRL'
      nameFull: 'Prolactin'
      description: 'Prolactin (PRL) is a pituitary hormone that is required for normal milk production after childbirth. The normal range is generally <20. Mildly elevated levels such as those in the 20-50 range are seen in many medical conditions.  Levels >50 are seen during normal pregnancy otherwise such levels are seen in pituitary conditions such as prolactinoma with certain medication — all require medical attention.'
      minLevel: 0
      isImportant: false
    iCa:
      name: 'iCa'
      nameFull: 'Calcium Ionized'
      description: 'iCa is ionized calcium — the free calcium in the blood. Normal levels are generally 1.1-1.32. Elevated levels are seen in hyperparathyroidism and a number of other conditions — all require medical attention.  Low values are seen in malnutrition, malabsorption, Celiac disease and kidney disease — all require medical attention.'
      minLevel: 1.0
      maxLevel: 1.35
      isImportant: false
    Test:
      name: 'Test'
      nameFull: 'Testosterone'
      description: 'Testosterone is male hormone: in men it is produced primarily in the testicles.  It is also produced in the adrenal glands.  Normal values in adult men are 8.4-28.8.  Values in healthy adult women are one tenth male values.  A testosterone value <6 are suggestive of low testicular production.  Low values are normal during marked illness of any cause. Low production of testosterone may be due to an abnormality in the testicles or a deficient signal from the pituitary gland or the use of performance enhancing drugs.'
      minLevel: 8.4
      maxLevel: 30
      isImportant: false

  constructor: (labResult) ->
    @date = labResult.date
    @indicatorName = labResult.indicator


window.LabResult = LabResult
