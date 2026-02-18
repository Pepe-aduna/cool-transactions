from sqlalchemy import text

from app.models.account_model import Account

class AccountRepository:
    """
    Account repository
    Esta clase se usa para hacer descriptivas las entidades del flujo.
    """
    @staticmethod
    def get_all():
        return Account.query.all()

    @staticmethod
    def get_by_account(account_number: str):
        return Account.query.filter(
            Account.account_number == account_number).one_or_none()