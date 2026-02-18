from flask import Flask
from app.config import DevelopmentConfig
from app.extensions import db, migrate
from app.routes.transaction_routes import transaction_bp

def create_app(config_class=DevelopmentConfig):
    app = Flask(__name__)
    app.config.from_object(config_class)

    db.init_app(app)
    migrate.init_app(app, db)

    app.register_blueprint(transaction_bp, url_prefix="/api")

    return app
