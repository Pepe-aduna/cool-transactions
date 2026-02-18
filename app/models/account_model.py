from app.extensions import db

class Account(db.Model):
    __tablename__ = "account"

    id = db.Column(db.Integer, primary_key=True)
    account_number = db.Column(db.String(45), nullable=False)
    status = db.Column(db.String(45), nullable=False)
    created_at = db.Column(db.DateTime(), nullable=False)

    def __repr__(self):
        return f"<account {self.account_number}>"
