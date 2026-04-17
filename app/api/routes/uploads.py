import os
import uuid
from typing import Optional

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile
from google.cloud import storage

from app.api.deps import get_current_user

router = APIRouter(prefix="/api/uploads", tags=["uploads"])

ALLOWED_IMAGE_TYPES = {
    "image/jpeg": ".jpg",
    "image/jpg": ".jpg",
    "image/png": ".png",
    "image/webp": ".webp",
}

GCS_BUCKET_NAME = os.getenv("GCS_BUCKET_NAME", "").strip()
GCS_PUBLIC_BASE_URL = os.getenv("GCS_PUBLIC_BASE_URL", "").strip()


def _sanitize_folder(folder: Optional[str]) -> str:
    if not folder:
        return "general"
    folder = folder.strip().lower().replace("\\", "/")
    folder = folder.replace("..", "")
    folder = folder.strip("/")
    return folder or "general"


def _build_public_url(bucket_name: str, object_name: str) -> str:
    if GCS_PUBLIC_BASE_URL:
        return f"{GCS_PUBLIC_BASE_URL.rstrip('/')}/{object_name}"
    return f"https://storage.googleapis.com/{bucket_name}/{object_name}"


@router.post("/image")
async def upload_image(
    file: UploadFile = File(...),
    folder: str = Form(default="general"),
    current_user=Depends(get_current_user),
):
    if not GCS_BUCKET_NAME:
        raise HTTPException(status_code=500, detail="Missing GCS_BUCKET_NAME")

    if not file.content_type or file.content_type.lower() not in ALLOWED_IMAGE_TYPES:
        raise HTTPException(
            status_code=400,
            detail="Only JPG, PNG, and WEBP images are allowed",
        )

    ext = ALLOWED_IMAGE_TYPES[file.content_type.lower()]
    safe_folder = _sanitize_folder(folder)

    # Example path:
    # tenants/1/categories/uuid.jpg
    object_name = (
        f"tenants/{current_user.tenant_id}/{safe_folder}/{uuid.uuid4().hex}{ext}"
    )

    try:
        content = await file.read()
        if not content:
            raise HTTPException(status_code=400, detail="Uploaded file is empty")

        client = storage.Client()
        bucket = client.bucket(GCS_BUCKET_NAME)
        blob = bucket.blob(object_name)

        blob.upload_from_string(
            content,
            content_type=file.content_type,
        )

        # Optional: make public if your bucket policy allows it
        # If bucket is private, keep this commented and use signed URLs later
        signed_url = blob.generate_signed_url(
            version="v4",
            expiration=3600,  # 1 hour
            method="GET"
        )

        return {
            "message": "Image uploaded successfully",
            "image_url": signed_url,
            "object_name": object_name,
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Upload failed: {e}")