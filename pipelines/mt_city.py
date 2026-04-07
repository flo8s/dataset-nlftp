"""アドレス・ベース・レジストリ 市区町村マスタのダウンロード。

デジタル庁「アドレス・ベース・レジストリ」から市区町村マスタ CSV をダウンロードし展開する。
政令指定都市の区→市コード対応に使用。

データソース: https://dataset.address-br.digital.go.jp/
"""

import logging
import zipfile
from io import BytesIO
from pathlib import Path
from urllib.request import Request, urlopen

logger = logging.getLogger("pipelines")

URL = "https://data.address-br.digital.go.jp/mt_city/mt_city_all.csv.zip"

EXPECTED_CSV = "mt_city_all.csv"


def download_mt_city(dest_dir: str) -> None:
    """市区町村マスタ CSV をダウンロードし展開する。

    既にダウンロード済みの場合はスキップする。
    """
    dest = Path(dest_dir)
    dest.mkdir(parents=True, exist_ok=True)

    csv_path = dest / EXPECTED_CSV
    if csv_path.exists():
        logger.info(f"  skip (already exists: {csv_path})")
        return

    logger.info("  downloading mt_city_all.csv.zip...")
    req = Request(URL, headers={"User-Agent": "dataset-nlftp"})
    with urlopen(req) as resp:
        data = resp.read()

    with zipfile.ZipFile(BytesIO(data)) as zf:
        zf.extract(EXPECTED_CSV, dest)

    logger.info(f"  mt_city_all.csv ready in {dest}")
