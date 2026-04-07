"""アドレス・ベース・レジストリ 市区町村マスタの展開。

data/mt_city/mt_city_all.csv.zip（リポジトリにコミット済み）を展開する。
政令指定都市の区→市コード対応に使用。

データ更新手順:
  ABR サイト (https://dataset.address-br.digital.go.jp/) から最新の zip をダウンロードし、
  data/mt_city/ に配置してコミットする。
"""

import logging
import zipfile
from pathlib import Path

logger = logging.getLogger("pipelines")

EXPECTED_CSV = "mt_city_all.csv"


def extract_mt_city(dest_dir: str) -> None:
    """市区町村マスタ zip を CSV に展開する。CSV が既に存在すればスキップ。"""
    dest = Path(dest_dir)
    csv_path = dest / EXPECTED_CSV
    zip_path = dest / f"{EXPECTED_CSV}.zip"

    if csv_path.exists():
        logger.info(f"  skip (already exists: {csv_path})")
        return

    if not zip_path.exists():
        raise FileNotFoundError(f"{zip_path} not found. Download from ABR site.")

    logger.info(f"  extracting {zip_path.name}...")
    with zipfile.ZipFile(zip_path) as zf:
        zf.extract(EXPECTED_CSV, dest)
