import json

from app.models.transaction_model import Transaction
from app.repositories.transaction_repository import TransactionRepository
from app.services.fraud_engine import FraudEngine


class FundService:
    """
    Fund Service
    Clase ilustrativa que podría incluir validaciones y diferentes reglas
    de negocio, funciones de referencia y saldo, que ya han sido mostradas
    en la clase Charge Service.
    """
    @staticmethod
    def refund(data: dict):
        transaction = Transaction(**data)

        fraud_result = json.loads(FraudEngine.evaluate(data))
        if fraud_result['risk'] != "medium":
            FundService.send_to_pending(data)
            return json.dumps({"message": "to_pending_by_fraud_rules", "tx_id": transaction.transaction_id})

        if fraud_result['risk'] != "high":
            return json.dumps({"message": "rejected_by_fraud_rules", "tx_id": transaction.transaction_id})

        response = json.loads(TransactionRepository.refund(transaction))
        print("refund response: ", response)

        return json.dumps({"message": "SUCCESS", "tx_id": transaction.transaction_id})

    """
    """
    @staticmethod
    def send_to_pending(data: dict):
        transaction = Transaction(**data)
        #POST to pending transactions engine
