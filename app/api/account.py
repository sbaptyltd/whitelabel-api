from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import text
from sqlalchemy.orm import Session

from app.api.deps import get_current_user
from app.db.session import get_db

router = APIRouter(prefix="/api/account", tags=["account"])


@router.post("/delete")
def delete_my_account(
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    now = datetime.utcnow()
    deletion_reason = "User requested account deletion"

    try:
        original_mobile = current_user.mobile_number
        original_email = current_user.email

        db.execute(
            text(
                """
                INSERT INTO user_deletion_audit
                    (tenant_id, old_user_id, mobile_hash, email_hash, deleted_at, deletion_reason)
                VALUES
                    (
                        :tenant_id,
                        :old_user_id,
                        SHA2(:mobile_number, 256),
                        SHA2(:email, 256),
                        :deleted_at,
                        :deletion_reason
                    )
                """
            ),
            {
                "tenant_id": current_user.tenant_id,
                "old_user_id": current_user.id,
                "mobile_number": original_mobile or "",
                "email": original_email or "",
                "deleted_at": now,
                "deletion_reason": deletion_reason,
            },
        )

        db.execute(
            text(
                """
                UPDATE users
                SET
                    status = 'DELETED',
                    full_name = 'Deleted User',
                    email = :deleted_email,
                    mobile_number = :deleted_mobile,
                    is_mobile_verified = 0,
                    deleted_at = :deleted_at,
                    deletion_reason = :deletion_reason,
                    updated_at = :updated_at
                WHERE id = :user_id
                  AND tenant_id = :tenant_id
                """
            ),
            {
                "deleted_email": f"deleted_{current_user.id}_{int(now.timestamp())}@deleted.local",
                "deleted_mobile": f"deleted_{current_user.id}_{int(now.timestamp())}",
                "deleted_at": now,
                "deletion_reason": deletion_reason,
                "updated_at": now,
                "user_id": current_user.id,
                "tenant_id": current_user.tenant_id,
            },
        )

        db.execute(
            text(
                """
                DELETE FROM user_sessions
                WHERE user_id = :user_id
                  AND tenant_id = :tenant_id
                """
            ),
            {
                "user_id": current_user.id,
                "tenant_id": current_user.tenant_id,
            },
        )

        db.commit()

        return {
            "success": True,
            "message": "Your account has been deleted successfully.",
        }

    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=500,
            detail=f"Failed to delete account: {str(e)}",
        )