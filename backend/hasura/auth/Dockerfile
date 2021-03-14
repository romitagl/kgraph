FROM python:3.8.7-slim-buster

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# add source code
COPY /src /app

WORKDIR /app

ENTRYPOINT [ "python", "auth-service.py" ]
EXPOSE 3000