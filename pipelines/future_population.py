"""国土数値情報 1kmメッシュ別将来推計人口（R6国政局推計）のダウンロード。

国土交通省「国土数値情報ダウンロードサイト」から全国版の将来推計人口メッシュ
データ (Shapefile) をダウンロードし展開する。全国版 zip は 47 都道府県別 zip を
内包する入れ子構造のため、内側の zip も展開する。

データソース: 1kmメッシュ別将来推計人口データ（R6国政局推計、2025〜2070年）
https://nlftp.mlit.go.jp/ksj/gml/datalist/KsjTmplt-mesh1000r6.html
"""

import logging
import zipfile
from pathlib import Path
from urllib.request import Request, urlopen

logger = logging.getLogger("pipelines")

URL = "https://nlftp.mlit.go.jp/ksj/gml/data/m1kr6/m1kr6-24/1km_mesh_2024_SHP.zip"

# 展開後に生成される代表ファイル（存在すればダウンロード済みとみなす）
EXPECTED_SHP = (
    "1km_mesh_2024_SHP/1km_mesh_2024_01_SHP/1km_mesh_2024_01.shp"
)


def download_future_population(dest_dir: str) -> None:
    """全国版の将来推計人口メッシュデータをダウンロードし展開する。

    全国版 zip は都道府県別 zip を内包するため、内側の zip も展開する。
    既にダウンロード済みの場合はスキップする。
    """
    dest = Path(dest_dir)
    dest.mkdir(parents=True, exist_ok=True)

    if (dest / EXPECTED_SHP).exists():
        logger.info(f"  skip (already exists: {dest / EXPECTED_SHP})")
        return

    zip_path = dest / "1km_mesh_2024_SHP.zip"

    logger.info("  downloading 1km mesh future population data...")
    req = Request(URL, headers={"User-Agent": "dataset-nlftp"})
    with urlopen(req) as resp, open(zip_path, "wb") as f:
        f.write(resp.read())

    with zipfile.ZipFile(zip_path) as zf:
        zf.extractall(dest)
    zip_path.unlink()

    # 都道府県別の入れ子 zip を展開する
    inner_dir = dest / "1km_mesh_2024_SHP"
    for inner_zip in sorted(inner_dir.glob("*.zip")):
        with zipfile.ZipFile(inner_zip) as zf:
            zf.extractall(inner_dir)
        inner_zip.unlink()

    logger.info(f"  future population data ready in {dest}")
