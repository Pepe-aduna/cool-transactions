import json

from app.models.transaction_model import Transaction
from app.repositories.transaction_repository import TransactionRepository

class FraudEngine:
    """
    Esta clase simula el llamado un motor que evalua las transacciones
    con las reglas de negocio necesarias para identificar posibles fraudes
    internos o ataques externos
    """
    @staticmethod
    def evaluate(data: dict):
        print("POST/CALL to Fraud Engine")
        return json.dumps({"message":"SUCCESS"})
