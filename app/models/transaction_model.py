from sqlalchemy import Numeric
from app.extensions import db


class Transaction(db.Model):
    __tablename__ = "ledger"

    id = db.Column(db.Integer, primary_key=True)
    account_number = db.Column(db.String(45), nullable=False)
    transaction_id = db.Column(db.String(45), nullable=False)
    amount = db.Column(Numeric(precision=10, scale=2, asdecimal=True), nullable=False)
    currency = db.Column(db.String(10), nullable=False)
    movement_type = db.Column(db.String(20), nullable=False)
    description = db.Column(db.String(150), nullable=False)
    date = db.Column(db.DateTime(), nullable=False)

    def __repr__(self):
        return f"<tx_id {self.transaction_id}>"
