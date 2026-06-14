# dataset-nlftp

国土数値情報（nlftp.mlit.go.jp）の行政区域 GIS データと将来推計人口データを DuckLake カタログ化したデータセット。

## データ出典

国土交通省「国土数値情報ダウンロードサイト」が公開する行政区域データ（N03、令和7年版 / 世界測地系）を使用する。全国の都道府県・市区町村の境界ポリゴンを収録する。

- 行政区域データ（N03-2025）: https://nlftp.mlit.go.jp/ksj/gml/datalist/KsjTmplt-N03-2025.html

政令指定都市の区から市へのコード対応には、デジタル庁「アドレス・ベース・レジストリ（市区町村マスタデータ）」を加工して利用する。

- アドレス・ベース・レジストリ: https://dataset.address-br.digital.go.jp/

すべての境界ポリゴンの座標参照系は EPSG:4612（JGD2011）。

将来推計人口は、同サイトの「1kmメッシュ別将来推計人口データ（R6国政局推計）」を使用する。推計値は総務省「令和2年国勢調査」と国立社会保障・人口問題研究所「日本の地域別将来推計人口（令和5年推計）」に基づき、2025〜2070年の5年ごとの値を収録する。メッシュのポリゴンの座標参照系は EPSG:6668（JGD2011）。

- 1kmメッシュ別将来推計人口（R6国政局推計）: https://nlftp.mlit.go.jp/ksj/gml/datalist/KsjTmplt-mesh1000r6.html

## テーブル: prefecture

都道府県の行政区域境界ポリゴン。N03（令和7年）の行政区域データを都道府県単位で集約したもの。

- prefecture_code: 都道府県コード（2桁）
- prefecture_name: 都道府県名
- geometry: 境界ポリゴン（EPSG:4612 / JGD2011）

## テーブル: municipality

市区町村の行政区域境界ポリゴン。N03（令和7年）の行政区域データを市区町村単位で集約したもの。同一自治体の飛び地等は統合済み。政令指定都市は区単位で収録され、行政区名を ward_name に持つ。

- lg_code: 全国地方公共団体コード（5桁、都道府県2桁 + 市区町村3桁）
- prefecture_code: 都道府県コード（2桁）
- prefecture_name: 都道府県名
- county_name: 郡名
- city_name: 市区町村名
- ward_name: 行政区名（政令指定都市のみ。他は NULL）
- geometry: 境界ポリゴン（EPSG:4612 / JGD2011）

## テーブル: designated_city

市区町村境界（政令指定都市の区を市レベルに統合）。municipality モデルから政令指定都市の区を結合し、市単位の境界として出力する。区コードから市コードへのマッピングは、デジタル庁「アドレス・ベース・レジストリ（市区町村マスタデータ）」を加工して作成。東京23区（特別区）は独立した地方公共団体のため統合しない。

- lg_code: 全国地方公共団体コード（5桁、政令指定都市は市レベルのコード）
- prefecture_code: 都道府県コード
- prefecture_name: 都道府県名
- county_name: 郡名
- city_name: 市区町村名
- geometry: 境界ポリゴン（EPSG:4612 / JGD2011）

## テーブル: future_population_municipality

市区町村別の将来推計人口（2020〜2070年、5年ごと）。1kmメッシュ別将来推計人口を市区町村コード（SHICODE）で集計したもの。複数市区町村にまたがるメッシュの人口は該当市区町村へ均等按分して集計する。政令指定都市は区単位のコードで収録される。

- city_code: 市区町村コード（5桁。政令指定都市は区単位）
- prefecture_code: 都道府県コード（2桁）
- prefecture_name / county_name / city_name / ward_name: 都道府県名・郡名・市区町村名・行政区名
- population_2020 〜 population_2070: 推計年次別の総人口（人、5年ごと）
- growth_rate_2025_2035 / growth_rate_2025_2050: 人口増減率（%）
- elderly_ratio_2025 / elderly_ratio_2050: 高齢化率（65歳以上人口の割合、%）

メッシュの SHICODE は令和2年国勢調査時点のコードのため、その後に再編された一部の自治体（浜松市の旧行政区など）や福島県浜通りの特別集計コード（07999）では名称が NULL になる。

## テーブル: future_population_mesh

1kmメッシュ単位の将来推計人口。地図ヒートマップ用。

- mesh_id: 基準地域メッシュコード（1km四方）
- city_code: 市区町村コード（複数市区町村にまたがるメッシュは "_" 連結）
- population_2025 / population_2035 / population_2050: 推計年次別の総人口（人）
- growth_rate_2025_2050: 人口増減率（%）
- elderly_ratio_2025 / elderly_ratio_2050: 高齢化率（%）
- geometry: メッシュポリゴン（EPSG:6668 / JGD2011）

### データ更新手順

1. 行政区域データ（N03）はパイプライン実行時に N03-2025 の全国版 GML を自動ダウンロードする。
2. 市区町村マスタ（ABR）はアドレス・ベース・レジストリのサイトから最新の zip をダウンロードし、`data/mt_city/mt_city_all.csv.zip` に配置してコミットする。
3. 将来推計人口（1kmメッシュ）はパイプライン実行時に全国版 Shapefile を自動ダウンロードする。
4. `bash scripts/build.sh local` でビルドする。

## クレジット

本データセットは以下の出典データを加工して作成している。

- 「国土数値情報（行政区域データ）」（国土交通省）（https://nlftp.mlit.go.jp/ksj/gml/datalist/KsjTmplt-N03-2025.html）
- 「国土数値情報（1kmメッシュ別将来推計人口データ）」（国土交通省）（https://nlftp.mlit.go.jp/ksj/gml/datalist/KsjTmplt-mesh1000r6.html）
- 「アドレス・ベース・レジストリ（市区町村マスタデータ）」（デジタル庁）（https://dataset.address-br.digital.go.jp/）

## ライセンス

国土数値情報の利用約款および政府標準利用規約（第2.0版）に従う。出典データは加工して利用している。

- 国土数値情報 利用約款: https://nlftp.mlit.go.jp/ksj/other/agreement.html
