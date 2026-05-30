"""国土数値情報データパイプライン。

1. administrative_boundary: 行政区域データ取得 (N03)
2. mt_city:                 市区町村マスタ取得 (ABR)
3. dbt build
4. snapshot MotherDuck catalog to R2 (same Python process)
"""

from __future__ import annotations

import importlib.util
import logging
import os
import sys
from pathlib import Path

from dbt.cli.main import dbtRunner

from pipelines.administrative_boundary import download_administrative_boundary
from pipelines.mt_city import extract_mt_city

logger = logging.getLogger("pipelines")

SHARED_SCRIPTS = Path(__file__).resolve().parent / "shared" / "scripts"
_spec = importlib.util.spec_from_file_location(
    "snapshot_to_r2", SHARED_SCRIPTS / "snapshot-to-r2.py"
)
assert _spec and _spec.loader
snapshot_to_r2 = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(snapshot_to_r2)


def main() -> None:
    target = os.environ.get("DBT_TARGET", sys.argv[1] if len(sys.argv) > 1 else "default")

    logger.info("1/4: administrative_boundary (行政区域データ)")
    download_administrative_boundary("data/administrative_boundary")

    logger.info("2/4: mt_city (市区町村マスタ)")
    extract_mt_city("data/mt_city")

    logger.info("3/4: dbt build")
    dbt = dbtRunner()
    for cmd in (
        ["deps"],
        ["build", "--target", target],
        ["docs", "generate", "--target", target],
    ):
        result = dbt.invoke(cmd)
        if not result.success:
            raise SystemExit(f"dbt {' '.join(cmd)} failed")

    logger.info("4/4: snapshot to R2")
    snapshot_to_r2.run(target)


if __name__ == "__main__":
    main()
