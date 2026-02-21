import os
from flask import current_app

class BaseConfig:
    SQLALCHEMY_TRACK_MODIFICATIONS = False

"""
Con este método se obtiene la URL con las credenciales y el host para DB desde variables de entorno,
si no se tienen limitantes, es mas practico cargar las variables consultando
un servicio de Secrets de la nube GCP/AWS, al tener la carga de los secretos directo en el servicio
y no en el despliegue nos permite mayor versatilidad para manejarlos
y por ejemplo si tiene algún cambio se refrescan solo con reiniciar desde la misma nube 
sin necesidad de redesplegar, que implica volver a ejecutar todo el flujo que se tenga de CICD.
"""
def get_value(key):
    print(f"getting secret {key}: ")
    return os.getenv(key)

class DevelopmentConfig(BaseConfig):
    SQLALCHEMY_DATABASE_URI = get_value('DATABASE_URI')
    DEBUG = True

class ProductionConfig(BaseConfig):
    SQLALCHEMY_DATABASE_URI = os.getenv("DATABASE_URL")
    DEBUG = False
