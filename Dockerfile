FROM python:3.12
WORKDIR /
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["python", "run.py"]

#Este dato vendría de algun servicio de manejo de contraseñas
ENV DATABASE_URI=mysql+pymysql://clames:clames1!@host.docker.internal:3306/transaction_data