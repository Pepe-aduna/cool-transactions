from app.models.transaction_model import Transaction
from app.repositories.transaction_repository import TransactionRepository

class FundService:
    """
    Fund Service
    Clase ilustrativa que podría incluir validaciones y diferentes reglas
    de negocio, funciones de referencia y saldo, que ya han sido mostradas
    en la clase Charge Service.
    """
    @staticmethod
    def refund(data: dict) -> Transaction:
        transaction = Transaction(**data)
        return TransactionRepository.refund(transaction)
