"""国土数値情報データパイプライン。

1. administrative_boundary: 行政区域データ取得 (N03)
2. mt_city:                 市区町村マスタ取得 (ABR)
3. future_population:       将来推計人口メッシュ取得 (1kmメッシュ R6推計)
4. dbt:                     dbt ビルド
"""

import logging

from dbt.cli.main import dbtRunner

from pipelines.administrative_boundary import download_administrative_boundary
from pipelines.future_population import download_future_population
from pipelines.mt_city import extract_mt_city

logger = logging.getLogger("pipelines")


def dbt_build():
    dbt = dbtRunner()

    result = dbt.invoke(["deps"])
    if not result.success:
        raise SystemExit("dbt deps failed")

    result = dbt.invoke(["build"])
    if not result.success:
        raise SystemExit("dbt build failed")

    result = dbt.invoke(["docs", "generate"])
    if not result.success:
        raise SystemExit("dbt docs generate failed")


def main():
    # 1. 行政区域データ (国土数値情報 N03)
    logger.info("1/4: administrative_boundary (行政区域データ)")
    download_administrative_boundary("data/administrative_boundary")

    # 2. 市区町村マスタ (アドレス・ベース・レジストリ)
    logger.info("2/4: mt_city (市区町村マスタ)")
    extract_mt_city("data/mt_city")

    # 3. 将来推計人口メッシュ (国土数値情報 1kmメッシュ R6推計)
    logger.info("3/4: future_population (将来推計人口メッシュ)")
    download_future_population("data/future_population")

    # 4. dbt ビルド
    logger.info("4/4: dbt build")
    dbt_build()


if __name__ == "__main__":
    main()
