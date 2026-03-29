# Deploy to Cloud Run

## 1. Enable APIs
```bash
gcloud services enable run.googleapis.com sqladmin.googleapis.com secretmanager.googleapis.com cloudbuild.googleapis.com artifactregistry.googleapis.com
```

## 2. Secrets
```bash
echo -n "YOUR_DB_PASSWORD" | gcloud secrets create DB_PASSWORD --data-file=- || echo -n "YOUR_DB_PASSWORD" | gcloud secrets versions add DB_PASSWORD --data-file=-
echo -n "YOUR_JWT_SECRET" | gcloud secrets create JWT_SECRET --data-file=- || echo -n "YOUR_JWT_SECRET" | gcloud secrets versions add JWT_SECRET --data-file=-
echo -n "123456" | gcloud secrets create OTP_BYPASS_CODE --data-file=- || echo -n "123456" | gcloud secrets versions add OTP_BYPASS_CODE --data-file=-
```

## 3. Grant secret access
```bash
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:YOUR_PROJECT_NUMBER-compute@developer.gserviceaccount.com" \
  --role="roles/secretmanager.secretAccessor"
```

## 4. Grant Cloud SQL access
```bash
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:YOUR_PROJECT_NUMBER-compute@developer.gserviceaccount.com" \
  --role="roles/cloudsql.client"
```

## 5. Deploy
```bash
gcloud run deploy commerce-api \
  --source . \
  --region australia-southeast2 \
  --platform managed \
  --allow-unauthenticated \
  --add-cloudsql-instances YOUR_PROJECT_ID:australia-southeast2:YOUR_SQL_INSTANCE \
  --set-env-vars APP_ENV=prod,DB_USER=app_user,DB_NAME=white_label_commerce,DB_HOST=/cloudsql/YOUR_PROJECT_ID:australia-southeast2:YOUR_SQL_INSTANCE,DB_PORT=3306,ACCESS_TOKEN_EXPIRE_MINUTES=43200 \
  --set-secrets DB_PASSWORD=DB_PASSWORD:latest,JWT_SECRET=JWT_SECRET:latest,OTP_BYPASS_CODE=OTP_BYPASS_CODE:latest
```
