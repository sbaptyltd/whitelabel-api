import hashlib
import logging
import os
import uuid
from datetime import datetime
from io import BytesIO

from fastapi import HTTPException
from google.cloud import storage
from PIL import Image, UnidentifiedImageError

logger = logging.getLogger(__name__)

MAX_FILE_BYTES = 8 * 1024 * 1024
MAX_IMAGE_PIXELS = 20_000_000

IMAGE_FORMATS = {
    "JPEG": ("image/jpeg", ".jpg"),
    "PNG": ("image/png", ".png"),
    "WEBP": ("image/webp", ".webp"),
}

EVIDENCE_TYPES = {
    "FRONT_PHOTO",
    "BACK_PHOTO",
    "SIDE_PHOTO",
    "EXTRA_PHOTO",
    "CUSTOMER_SIGNATURE",
}


def upload_order_evidence(
    *,
    content: bytes,
    tenant_id: int,
    order_id: int,
    actor_user_id: int,
    evidence_type: str,
    original_filename: str | None = None,
) -> dict:
    """
    Internal helper. The calling route must first authorize the user
    for this order. Do not expose this helper as an unrestricted upload.
    """
    bucket_name = os.getenv("ORDER_EVIDENCE_BUCKET", "").strip()
    if not bucket_name:
        raise HTTPException(
            status_code=503,
            detail="Order evidence storage is not configured",
        )

    if evidence_type not in EVIDENCE_TYPES:
        raise HTTPException(400, "Invalid evidence type")

    if not content:
        raise HTTPException(400, "Image is empty")

    if len(content) > MAX_FILE_BYTES:
        raise HTTPException(413, "Each image must be 8 MB or smaller")

    # Inspect the actual file rather than trusting its filename/MIME header.
    try:
        with Image.open(BytesIO(content)) as image:
            image_format = image.format
            if image_format not in IMAGE_FORMATS:
                raise HTTPException(400, "Use JPG, PNG or WEBP images")

            if image.width * image.height > MAX_IMAGE_PIXELS:
                raise HTTPException(400, "Image must be 20 megapixels or smaller")

            if getattr(image, "n_frames", 1) != 1:
                raise HTTPException(400, "Animated images are not allowed")

            image.verify()

        # Decode as well to detect damaged image data.
        with Image.open(BytesIO(content)) as image:
            image.load()

    except HTTPException:
        raise
    except (
        UnidentifiedImageError,
        OSError,
        ValueError,
        SyntaxError,
        Image.DecompressionBombError,
    ) as exc:
        raise HTTPException(400, "Invalid or damaged image") from exc

    content_type, extension = IMAGE_FORMATS[image_format]
    digest = hashlib.sha256(content).hexdigest()

    object_name = (
        f"tenants/{tenant_id}/orders/{order_id}/"
        f"{evidence_type.lower()}/{uuid.uuid4().hex}{extension}"
    )

    try:
        client = storage.Client()
        blob = client.bucket(bucket_name).blob(object_name)
        blob.cache_control = "private, no-store"
        blob.metadata = {
            "tenant_id": str(tenant_id),
            "order_id": str(order_id),
            "actor_user_id": str(actor_user_id),
            "evidence_type": evidence_type,
            "sha256": digest,
        }

        # Create only: never replace an existing object.
        blob.upload_from_string(
            content,
            content_type=content_type,
            if_generation_match=0,
            checksum="auto",
            timeout=60,
        )

        if blob.generation is None:
            raise RuntimeError("Storage did not return an object generation")

    except Exception as exc:
        logger.exception(
            "Order evidence upload failed: tenant=%s order=%s",
            tenant_id,
            order_id,
        )
        raise HTTPException(
            status_code=503,
            detail="Photo upload failed. Please retry.",
        ) from exc

    filename = (
        original_filename.replace("\\", "/").split("/")[-1][:255]
        if original_filename else None
    )

    return {
        "evidence_type": evidence_type,
        "storage_bucket": bucket_name,
        "storage_object": object_name,
        "storage_generation": str(blob.generation),
        "original_filename": filename,
        "content_type": content_type,
        "file_size_bytes": len(content),
        "sha256_hash": digest,
        "uploaded_at": datetime.utcnow(),
    }