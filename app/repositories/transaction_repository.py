import json

from app.models.transaction_model import Transaction
from app.extensions import db
from sqlalchemy import text

class TransactionRepository:

    """
    Transaction Repository
    Clase que contiene las operaciones utilizadas en la base de datos
    esta clase esta pensada mas para ir en una librería que replicarla en cada servicio
    los metodos charge y fund muestran que podríamos tener metodos con diferentes
    parametros e incluso algun manejo de las respuestas, por otra parte los metodos de las reversas
    muestran que hay codigo que se puede reusar, usando funciones con diferentes para agilizar
    y hacer mas descriptivo el llamado a cada stored procedure en lugar de pasarlo directamemnte
    como parametro desde el servicio.
    """
    @staticmethod
    def get_all():
        return Transaction.query.all()

    @staticmethod
    def get_by_id(_id: int):
        return Transaction.query.get(_id)

    @staticmethod
    def get_by_tx_id(transaction_id: str):
        return Transaction.query.filter(text(transaction_id)).first()

    @staticmethod
    def charge(t: Transaction):
        with db.engine.begin() as conn:
            result = conn.execute(text("CALL lock_funds(:account, :amount, :transaction_id, :currency, @result)"),
                                  {"account":t.account_number, "amount":t.amount,
                                   "transaction_id":t.transaction_id, "currency":t.currency,"result":None})

        return json.dumps({"message": "success", "tx_id": t.transaction_id})

    @staticmethod
    def refund(t: Transaction):
        with db.engine.begin() as conn:
            conn.execute(text("CALL fund_account(:account, :amount, :tx_id, :currency)"),
                                  {"account":t.account_number, "amount":t.amount,
                                   "tx_id":t.transaction_id, "currency":t.currency})

        return json.dumps({"message": "success", "tx_id": t.transaction_id})

    @staticmethod
    def charge_reversal(t: Transaction):
        TransactionRepository.execute_sp(t, "reverse_charge")
        return json.dumps({"message": "success", "tx_id": t.transaction_id})

    @staticmethod
    def fund_reversal(t: Transaction):
        TransactionRepository.execute_sp(t, "reverse_fund")
        return json.dumps({"message": "success", "tx_id": t.transaction_id})

    @staticmethod
    def execute_sp(t: Transaction, name: str):
        with db.engine.begin() as conn:
            conn.execute(text("CALL {}(:account, :amount, :tx_id)".format(name)),
                                  {"account":t.account_number, "amount":t.amount,
                                   "tx_id":t.transaction_id})

        return json.dumps({"message": "success", "tx_id": t.transaction_id})