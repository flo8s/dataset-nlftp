{#
  学校データ（P29）のコード値を名称に変換するマクロ。

    - 学校分類（P29_003）: SchoolClassCd
    - 管理者コード（P29_006）: AdminCd
    - 休校区分（P29_007）: ClosedSchoolCode
#}
{% macro school_class_name(col) %}
  CASE {{ col }}
    WHEN '16001' THEN '小学校'
    WHEN '16002' THEN '中学校'
    WHEN '16003' THEN '中等教育学校'
    WHEN '16004' THEN '高等学校'
    WHEN '16005' THEN '高等専門学校'
    WHEN '16006' THEN '短期大学'
    WHEN '16007' THEN '大学'
    WHEN '16011' THEN '幼稚園'
    WHEN '16012' THEN '特別支援学校'
    WHEN '16013' THEN '認定こども園'
    WHEN '16014' THEN '義務教育学校'
    WHEN '16015' THEN '各種学校'
    WHEN '16016' THEN '専修学校'
  END
{% endmacro %}

{% macro administrator_name(col) %}
  CASE {{ col }}
    WHEN 0 THEN 'その他'
    WHEN 1 THEN '国'
    WHEN 2 THEN '都道府県'
    WHEN 3 THEN '市区町村'
    WHEN 4 THEN '民間'
  END
{% endmacro %}

{% macro school_status_name(col) %}
  CASE {{ col }}
    WHEN 0 THEN '調査なし'
    WHEN 1 THEN '開校中'
    WHEN 2 THEN '休校中'
  END
{% endmacro %}
