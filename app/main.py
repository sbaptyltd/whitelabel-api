from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import settings

# Routers
from app.api.routes.health import router as health_router
from app.api.routes.bootstrap import router as bootstrap_router
from app.api.routes.auth import router as auth_router
from app.api.routes.products import router as products_router
from app.api.routes.cart import router as cart_router
from app.api.routes.orders import router as orders_router
from app.api.routes.payments import router as payments_router
from app.api.routes.categories_admin import router as categories_admin_router
from app.api.routes.products_admin import router as products_admin_router
from app.api.routes.uploads import router as uploads_router



# Create FastAPI app
app = FastAPI(
    title=settings.APP_NAME,
    version="1.0.0",
)


# CORS (adjust for production later)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # TODO: restrict in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Health check (Cloud Run uses this)
@app.get("/")
def root():
    return {"message": f"{settings.APP_NAME} is running"}


# Include routers

app.include_router(health_router)
app.include_router(bootstrap_router)
app.include_router(auth_router)
app.include_router(categories_admin_router)
app.include_router(products_admin_router)
app.include_router(products_router)
app.include_router(cart_router)
app.include_router(orders_router)
app.include_router(payments_router)
app.include_router(uploads_router)



# Optional: startup log (useful in Cloud Run logs)
@app.on_event("startup")
def startup_event():
    print("🚀 Application started successfully")