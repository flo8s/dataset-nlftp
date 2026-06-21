{#
  鉄道データ（N02）のコード値を名称に変換するマクロ。

  駅・路線の両モデルで同じ区分コードを使うため、CASE 式を共通化する。
    - 鉄道区分コード（N02_001）: RailwayClassCd
    - 事業者種別コード（N02_002）: InstitutionTypeCd
#}
{% macro railway_class_name(col) %}
  CASE {{ col }}
    WHEN '11' THEN '普通鉄道JR'
    WHEN '12' THEN '普通鉄道'
    WHEN '13' THEN '鋼索鉄道'
    WHEN '14' THEN '懸垂式鉄道'
    WHEN '15' THEN '跨座式鉄道'
    WHEN '16' THEN '案内軌条式鉄道'
    WHEN '17' THEN '無軌条鉄道'
    WHEN '21' THEN '軌道'
    WHEN '22' THEN '懸垂式モノレール'
    WHEN '23' THEN '跨座式モノレール'
    WHEN '24' THEN '案内軌条式'
    WHEN '25' THEN '浮上式'
  END
{% endmacro %}

{% macro operator_type_name(col) %}
  CASE {{ col }}
    WHEN '1' THEN 'JRの新幹線'
    WHEN '2' THEN 'JR在来線'
    WHEN '3' THEN '公営鉄道'
    WHEN '4' THEN '民営鉄道'
    WHEN '5' THEN '第三セクター'
  END
{% endmacro %}
