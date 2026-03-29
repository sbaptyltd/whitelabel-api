
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.core.config import settings

def _database_url() -> str:
    if settings.DB_HOST.startswith("/cloudsql/"):
        socket_path = settings.DB_HOST
        return (
            f"mysql+pymysql://{settings.DB_USER}:{settings.DB_PASSWORD}"
            f"@localhost/{settings.DB_NAME}?unix_socket={socket_path}"
        )
    return (
        f"mysql+pymysql://{settings.DB_USER}:{settings.DB_PASSWORD}"
        f"@{settings.DB_HOST}:{settings.DB_PORT}/{settings.DB_NAME}"
    )

engine = create_engine(_database_url(), pool_pre_ping=True)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
