from functools import lru_cache
from typing import Optional

import opendal

from common.logger import logger
from config.settings import settings


@lru_cache(maxsize=10)
def get_operator(bucket_name: Optional[str] = None) -> opendal.Operator:
    b_n = bucket_name or settings.S3_BUCKET
    return opendal.Operator(
        "s3",
        endpoint=settings.S3_ENDPOINT,
        access_key_id=settings.S3_ACCESS_KEY,
        secret_access_key=settings.S3_SECRET_KEY,
        region="us-east-1",
        bucket=b_n,
        root="/",
        enable_virtual_host_style="false",
    )


def download_from_s3(op: opendal.Operator, s3_path: str, local_path: str):
    try:
        data = op.read(s3_path)
        with open(local_path, "wb") as f:
            f.write(data)
    except Exception as e:
        logger.error(f"Error downloading from S3: {e}")
        pass


def upload_to_s3(op: opendal.Operator, local_path: str, s3_path: str):
    try:
        with open(local_path, "rb") as f:
            op.write(s3_path, f.read())
    except Exception as e:
        logger.error(f"Error uploading from S3: {e}")
        pass


async def presign_url(op: opendal.Operator, s3_path: str):
    return (await op.to_async_operator().presign_read(s3_path, expire=3600)).url


default_operator = get_operator()
