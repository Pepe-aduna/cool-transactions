import json

from app.models.transaction_model import Transaction
from app.repositories.transaction_repository import TransactionRepository
from app.repositories.account_repository import AccountRepository
from app.services.fraud_engine import FraudEngine


class ChargeService:

    """
    Charge Service
    Esta clase muestra posibles validaciones a la cuenta y reglas de negocio
    como evaluación de fraude o transacciones sospechosas
    se utiliza la función reversal para implementar una estrategia transaccional
    y en caso de cualquier error no controlado se rechace la petición y regrese
    el saldo a su estado anterior, como error controlado se incluye validación de error
    por fondos insuficientes, en tal caso se responde con el error correspondiente.
    Al final se lanza un evento/mensaje/queue para registrar la data completa de la transaccion
    en una base de datos no relacional para que lo relacionado con la consulta de transacciones
    y los beneficios de este tipo de bases de datos sin los afectarnos por la eventual persistencia.
    """

    @staticmethod
    def charge(data: dict):
        try:
            transaction = Transaction(**data)

            account = AccountRepository.get_by_account(transaction.account_number)
            if account.status != "enabled":
                return json.dumps({"message": "invalid account", "tx_id": transaction.transaction_id})

            fraud_result = json.loads(FraudEngine.evaluate(data))
            if fraud_result['message'] != "SUCCESS":
                return json.dumps({"message": "rejected_by_fraud_rules", "tx_id": transaction.transaction_id})

            response = json.loads(TransactionRepository.charge(transaction))
            print("charge response: ", response)
            if response.get('error') is not None:
                print("rejected_by_charge")
                return json.dumps({"error": response.get("error"), "tx_id": transaction.transaction_id})

            ChargeService.event(data)
        except Exception as e:
            print(f"Exception in CHARGE: {e.__cause__}")
            if 'Insufficient' in str(e.__cause__):
                return json.dumps({"cause": str(e.__cause__), "tx_id": data.get("transaction_id")})

            ChargeService.reversal(data)
            return json.dumps({"cause": str(e), "tx_id": data.get("transaction_id")})

        return json.dumps({"message": "SUCCESS", "tx_id": transaction.transaction_id})

    @staticmethod
    def reversal(data: dict):
        print("Entrando a reversal")
        transaction = Transaction(**data)
        TransactionRepository.charge_reversal(transaction)

        return json.dumps({"message": "REVERSED", "tx_id": transaction.transaction_id})

    @staticmethod
    def event(data: dict):
        """
        Este metodo se utiliza para registrar en una base de datos no relacional
        de forma asincrona los datos no escenciales para el ledger,
        como descripciones, referencias, mcc, etc...
        """
        print("Registro asíncrono de transacciones")
