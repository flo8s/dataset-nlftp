{#
  医療機関データ（P04）のコード値を名称に変換するマクロ。

    - 医療機関分類（P04_001）: MedicalInstitutionCd
    - 開設者分類（P04_007）: 開設者分類コード（病院のみ対象。それ以外は分類対象外）
    - 救急告示病院（P04_009）
    - 災害拠点病院（P04_010）
#}
{% macro medical_class_name(col) %}
  CASE {{ col }}
    WHEN 1 THEN '病院'
    WHEN 2 THEN '診療所'
    WHEN 3 THEN '歯科診療所'
  END
{% endmacro %}

{% macro establisher_type_name(col) %}
  CASE {{ col }}
    WHEN 1 THEN '国'
    WHEN 2 THEN '公的医療機関'
    WHEN 3 THEN '社会保険関係団体'
    WHEN 4 THEN '医療法人'
    WHEN 5 THEN '個人'
    WHEN 6 THEN 'その他'
    WHEN 9 THEN '分類対象外'
  END
{% endmacro %}

{% macro emergency_hospital_name(col) %}
  CASE {{ col }}
    WHEN 1 THEN '指定あり'
    WHEN 9 THEN '指定なし'
  END
{% endmacro %}

{% macro disaster_base_hospital_name(col) %}
  CASE {{ col }}
    WHEN 1 THEN '基幹災害拠点病院'
    WHEN 2 THEN '地域災害拠点病院'
    WHEN 9 THEN '指定なし'
  END
{% endmacro %}
