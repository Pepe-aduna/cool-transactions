import json

from flask import Blueprint, request, jsonify
from app.services.charge_service import ChargeService
from app.services.fund_service import FundService
from app.services.reversal_service import ReversalService
from app.schemas.transaction_schema import TransactionSchema
from app.utils.DecoratorPattern import try_catch_handler

transaction_bp = Blueprint("transactions", __name__)

transaction_schema = TransactionSchema()
transactions_schema = TransactionSchema(many=True)

"""
En este modulo se declaran los endpoint para funciones basicas
cada endpoint debería ser un microservicio independiente 
con sus respectivas capas (service,repository,etc) 
Se agregan todos los endpoints con fines ilustrativos.
"""

@transaction_bp.route("/transactions/charge", methods=["POST"])
@try_catch_handler(default_response="Operation failed")
def execute_charge():
    data = transaction_schema.load(request.json)
    transaction = json.loads(ChargeService.charge(data))

    return jsonify(transaction), 200

@transaction_bp.route("/transactions/fund", methods=["POST"])
@try_catch_handler(default_response="Operation failed")
def execute_fund():
    data = transaction_schema.load(request.json)
    transaction = json.loads(FundService.refund(data))

    return jsonify(transaction), 200

@transaction_bp.route("/transactions/charge/reversal", methods=["POST"])
@try_catch_handler(default_response="Operation failed")
def charge_reversal():
    data = transaction_schema.load(request.json)
    transaction = json.loads(ReversalService.charge_reversal(data))

    return jsonify(transaction), 200

@transaction_bp.route("/transactions/fund/reversal", methods=["POST"])
@try_catch_handler(default_response="Operation failed")
def fund_reversal():
    data = transaction_schema.load(request.json)
    transaction = json.loads(ReversalService.fund_reversal(data))

    return jsonify(transaction), 200
