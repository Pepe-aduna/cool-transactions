import json

from app.models.transaction_model import Transaction
from app.repositories.account_repository import AccountRepository
from app.repositories.transaction_repository import TransactionRepository

class ReversalService:

    """
    REVERSAL SERVICE
    SE agrega este servicio para cubrir flujos que se han rota y es necesario
    reversar alguna transacción.
    Se muestra una regla de negocio para una cuenta desahabilitada ya no se debe regresar los
    fondos retirados y se abonan a una cuenta concentradora de la empresa
    Las reversas de ambos tipos se encuentran en esta clase pero deben ser en microsercicios separados.
    """

    @staticmethod
    def charge_reversal(data: dict):
        transaction = Transaction(**data)

        account = AccountRepository.get_by_account(transaction.account_number)
        if account.status == "disabled":
            #Esta parte se usa para mostrar lo que podría ser una regla de negocio
            TransactionRepository.charge_reversal(transaction)
            ReversalService.send_to_cc(transaction)
            return json.dumps({"message": "funds_to_cc", "tx_id": transaction.transaction_id})

        response = json.loads(TransactionRepository.charge_reversal(transaction))
        print("REVERSAL CHARGE RESPONSE::", response)

        return json.dumps({"message": "SUCCESS", "tx_id": transaction.transaction_id})

    @staticmethod
    def fund_reversal(data: dict):
        transaction = Transaction(**data)

        account = AccountRepository.get_by_account(transaction.account_number)
        if account.status == "disabled":
            ReversalService.send_to_cc(transaction)
            return json.dumps({"message": "disposable_reverse_to_cc", "tx_id": transaction.transaction_id})

        response = json.loads(TransactionRepository.fund_reversal(transaction))
        print("REVERSAL FUND RESPONSE::", response)

        return json.dumps({"message": "SUCCESS", "tx_id": transaction.transaction_id})

    @staticmethod
    def send_to_cc(t: Transaction):
        t.description = "from disabled account {}".format(t.account_number)
        t.account_number = "cc_supercool_01"
        print("business rules to send funds: ",t.tx_id)
