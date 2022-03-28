FROM python:3.9-slim-buster

COPY requirements.txt ./
# RUN python -m pip install --upgrade setuptools pip
RUN pip install --no-cache-dir -r requirements.txt

# add source code
COPY /src /app

WORKDIR /app

ENTRYPOINT [ "python", "auth-service.py" ]
EXPOSE 3000