from sqlalchemy import Column, BigInteger, String, Boolean, Text, ForeignKey, TIMESTAMP
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.db.base import Base


class Store(Base):
    __tablename__ = "stores"

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    tenant_id = Column(BigInteger, nullable=False)
    store_name = Column(String(255), nullable=False)
    store_email = Column(String(255), nullable=False)
    store_phone = Column(String(30), nullable=True)
    address = Column(Text, nullable=True)
    is_active = Column(Boolean, nullable=False, default=True)
    created_at = Column(TIMESTAMP, server_default=func.now())

    pincodes = relationship("StorePincode", back_populates="store")


class StorePincode(Base):
    __tablename__ = "store_pincodes"

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    store_id = Column(BigInteger, ForeignKey("stores.id"), nullable=False)
    pincode = Column(String(20), nullable=False)
    is_active = Column(Boolean, nullable=False, default=True)
    created_at = Column(TIMESTAMP, server_default=func.now())

    store = relationship("Store", back_populates="pincodes")