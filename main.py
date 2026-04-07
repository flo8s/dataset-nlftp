"""国土数値情報データパイプライン。

1. administrative_boundary: 行政区域データ取得 (N03)
2. mt_city:                 市区町村マスタ取得 (ABR)
3. dbt:                     dbt ビルド
"""

import logging

from dbt.cli.main import dbtRunner

from pipelines.administrative_boundary import download_administrative_boundary
from pipelines.mt_city import download_mt_city

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
    logger.info("1/3: administrative_boundary (行政区域データ)")
    download_administrative_boundary("data/administrative_boundary")

    # 2. 市区町村マスタ (アドレス・ベース・レジストリ)
    logger.info("2/3: mt_city (市区町村マスタ)")
    download_mt_city("data/mt_city")

    # 3. dbt ビルド
    logger.info("3/3: dbt build")
    dbt_build()


if __name__ == "__main__":
    main()
