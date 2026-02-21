import json

from app.models.transaction_model import Transaction
from app.extensions import db
from sqlalchemy import text

class TransactionRepository:

    """
    Transaction Repository
    Clase que contiene las operaciones utilizadas en la base de datos
    esta clase esta pensada mas para ir en una librería para no replicarla en cada servicio,
    los metodos charge y fund muestran que es mejor práctica tener cada operación en metodos separados
    por el número de parámetros por ejemplo e incluso algún manejo de las respuestas, por otra parte,
    los metodos de las reversas muestran que código del llamado a los SP se puede reusar, pero manteniendo
    nombres de funciones con diferentes lo que hace mas descriptivo el llamado a cada stored procedure
    en lugar de tener una sola función y pasar como parámetro el nombre del SP a ejecutar.
    Las razones a destacar para delegar las operaciones en un SP en de base de datos son:
     - Evitar errores de precisión (punto flotante)
     - Reducir la probabilidad de error al codificar, eficiencia de mantenimiento al tener la operación en un solo lugar.
     - Si tenemos diferentes servicios con diferentes tecnologías, solo se tiene que implementer
        el llamado a los SP que es un estándar.
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