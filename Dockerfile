FROM python:3.9-slim

WORKDIR /app

COPY . .

RUN pip install --upgrade pip

# installer le package du projet
RUN pip install --no-cache-dir -e .

EXPOSE 5000

CMD ["python", "application.py"]