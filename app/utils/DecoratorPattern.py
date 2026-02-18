from functools import wraps
from flask import jsonify

"""
Modulo utilizada para implementar el patron que es de gran ayuda
al manejar excepciones, en este caso se utiliza una general pero 
se podría tener un manejo mas preciso con tipos de cada una.
"""
def try_catch_handler(default_response="An error occurred"):
    def decorator(f):
        @wraps(f)
        def wrapper(*args, **kwargs):
            try:
                return f(*args, **kwargs)
            except Exception as e:
                # Log the error (optional)
                print(f"Exception in {f.__name__}: {e}")
                # Return a custom response
                return jsonify({"error": str(e),
                                "cause": str(e.__cause__),
                                "message": default_response}), 500
        return wrapper
    return decorator