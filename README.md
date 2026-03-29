# FastAPI White-Label Commerce Backend (Schema-Aligned v3)

This backend starter is aligned to the Cloud SQL MySQL schema discussed in chat.

## Included
- FastAPI app
- SQLAlchemy ORM models aligned to schema
- Tenant bootstrap API
- OTP request/verify APIs
- Product, cart, checkout, and orders APIs
- Cloud Run Dockerfile
- schema.sql
- Cloud Run deployment guide

## Notes
- OTP sending is a stub. Use Secret Manager + Twilio in production.
- Payment confirmation is a stub. Replace with Stripe webhook flow in production.
- Email/SMS notifications are currently logged, not actually sent.

## Run locally
```bash
python -m venv .venv
source .venv/bin/activate  # Windows: .\.venv\Scripts\Activate
pip install -r requirements.txt
cp .env.example .env
uvicorn app.main:app --reload --port 8080
```
