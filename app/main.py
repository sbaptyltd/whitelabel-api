
from fastapi import FastAPI
from app.core.config import settings
from app.api.routes.health import router as health_router
from app.api.routes.bootstrap import router as bootstrap_router
from app.api.routes.auth import router as auth_router
from app.api.routes.products import router as products_router
from app.api.routes.cart import router as cart_router
from app.api.routes.orders import router as orders_router

app = FastAPI(title=settings.APP_NAME)

app.include_router(health_router)
app.include_router(bootstrap_router)
app.include_router(auth_router)
app.include_router(products_router)
app.include_router(cart_router)
app.include_router(orders_router)
