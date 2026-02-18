from marshmallow import Schema, fields

class TransactionSchema(Schema):
    id = fields.Int(dump_only=True)
    transaction_id = fields.Str(required=True)
    account_number = fields.Str(required=True)
    movement_type = fields.Str(required=True)
    description = fields.Str(required=True)
    amount = fields.Decimal(required=True, as_string=True)
    currency = fields.Str(required=True)
    date = fields.DateTime(required=True)
