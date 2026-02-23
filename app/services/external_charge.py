import json
from abc import ABC, abstractmethod

from app.repositories.transaction_repository import TransactionRepository


"""
Este modulo contiene las clases para implementar el patron estrategia y registro, 
usando como ejemplo ejecutar cargos a la cuenta en divisa diferente a MXN.
"""
class ExternalCharge(ABC):
    @abstractmethod
    def charge(self, amount):
        pass

    @abstractmethod
    def getName(self):
        pass

class USDCharge(ExternalCharge):
    def charge(self, transaction):
        print(f"Charge {transaction.amount} to USD Account")
        return json.dumps({"message": "success", "tx_id": transaction.transaction_id,
                           "detail":"Mock"})

    def getName(self):
        return "USD"

class EURCharge(ExternalCharge):
    def charge(self, transaction):
        print(f"Charge {transaction.amount} to EUR Account")
        return json.dumps({"message": "success", "tx_id": transaction.transaction_id,
                           "detail":"Mock"})

    def getName(self):
        return "EUR"

class Charge(ExternalCharge):
    def charge(self, transaction):
        print(f"Charge {transaction.amount} to MXN Account")
        return TransactionRepository.charge(transaction)

    def getName(self):
        return "MXN"

# Registry
PAYMENT_REGISTRY = {
    "840": USDCharge(),
    "978": EURCharge(),
}
