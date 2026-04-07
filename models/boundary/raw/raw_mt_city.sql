{# デジタル庁 アドレス・ベース・レジストリ 市区町村マスタ
   政令指定都市の区→市コード対応に使用
   元データ: https://data.address-br.digital.go.jp/mt_city/mt_city_all.csv.zip #}

{{
    config(
        materialized='table'
    )
}}

select *
from read_csv(
    'data/mt_city/mt_city_all.csv',
    header=true,
    columns={
        'lg_code': 'VARCHAR',
        'pref': 'VARCHAR',
        'pref_kana': 'VARCHAR',
        'pref_roma': 'VARCHAR',
        'county': 'VARCHAR',
        'county_kana': 'VARCHAR',
        'county_roma': 'VARCHAR',
        'city': 'VARCHAR',
        'city_kana': 'VARCHAR',
        'city_roma': 'VARCHAR',
        'ward': 'VARCHAR',
        'ward_kana': 'VARCHAR',
        'ward_roma': 'VARCHAR',
        'efct_date': 'DATE',
        'ablt_date': 'DATE',
        'remarks': 'VARCHAR'
    }
)
