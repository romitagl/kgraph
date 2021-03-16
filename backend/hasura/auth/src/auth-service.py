# https://hasura.io/docs/latest/graphql/core/auth/authentication/jwt.html
# https://hasura.io/docs/latest/graphql/core/actions/codegen/python-flask.html#actions-codegen-python-flask

import json
import logging
import os
from dataclasses import dataclass

import jwt
import urllib3
from argon2 import PasswordHasher
from argon2.exceptions import VerifyMismatchError
from flask import Flask, request
from urllib3.poolmanager import PoolManager

HASURA_URL = os.getenv(
    "HASURA_GRAPHQL_URL", default="http://graphql-engine:8080/v1/graphql"
)
HASURA_ADMIN_SECRET = os.getenv("HASURA_GRAPHQL_ADMIN_SECRET")
HASURA_HEADERS = {
    "X-Hasura-Admin-Secret": HASURA_ADMIN_SECRET,
    "Content-Type": "application/json",
}
HASURA_JWT_SECRET_KEY = os.getenv("HASURA_GRAPHQL_JWT_SECRET_KEY")
HASURA_JWT_SECRET_TYPE = os.getenv("HASURA_GRAPHQL_JWT_SECRET_TYPE", default="HS256")

http: PoolManager = None

################
# GRAPHQL CLIENT
################


@dataclass
class Client:
    url: str
    headers: dict

    def run_query(self, query: str, variables: dict):
        try:
            payload = {"query": query, "variables": variables}
            encoded_data = json.dumps(payload).encode("utf-8")
            response = http.request(
                method="POST", url=self.url, headers=self.headers, body=encoded_data
            )
            jsonData = json.loads(response.data.decode("utf-8"))
            # logging.info(f"\n\n\nDEBUG jsonData:\n{jsonData}")
            data: list = jsonData.get("data")
            if not data:
                logging.info("no data found in the data json property")
                return None
            return data
        except urllib3.exceptions.HTTPError as e:
            logging.error(f"failed processing HTTP exception: {e}")
            return None
        except Exception as e:
            logging.error(f"failed processing - exception: {e}")
            return None

    def get_default_role(self):
        response = self.run_query(
            """
          query GetDefaultRole {
                kgraph_roles(where: {default: {_eq: true}}, limit: 1) {
                    name
              }
          }
          """,
            {},
        )
        # {'data': {'kgraph_roles': [{'name': 'registred_user'}]}}
        return response.get("kgraph_roles")[0].get("name")

    def find_user_by_username(self, username: str):
        response = self.run_query(
            """
            query UserByUsername($username: String!) {
                kgraph_users(where: {username: {_eq: $username}}, limit: 1) {
                    username
                    password_hash
                    roles_name
                }
            }
        """,
            {"username": username},
        )
        if response is None:
            return None
        password = response.get("kgraph_users")[0].get("password_hash")
        role = response.get("kgraph_users")[0].get("roles_name")
        return {"username": username, "password": password, "role": role}

    def create_user(self, username: str, password: str, roles_name: str):
        response = self.run_query(
            """
            mutation CreateUser($username: String!, $password: String!, $roles_name: String!) {
                insert_kgraph_users_one(object: {username: $username, password_hash: $password, roles_name: $roles_name}) {
                    username
                }
            }
        """,
            {"username": username, "password": password, "roles_name": roles_name},
        )
        # {'data': {'insert_kgraph_users_one': {'username': 'test'}}}
        return response.get("insert_kgraph_users_one").get("username")

    def update_password(self, username: str, password: str):
        self.run_query(
            """
            mutation UpdatePassword($username: String!, $password: String!) {
                update_kgraph_users_by_pk(pk_columns: {username: $username}, _set: {password_hash: $password}) {
                    password_hash
                }
            }
        """,
            {"username": username, "password": password},
        )


#######
# UTILS
#######


Password = PasswordHasher()
client = Client(url=HASURA_URL, headers=HASURA_HEADERS)


def generate_token(user) -> str:
    """
    Generates a JWT compliant with the Hasura spec, given a User object with field "id"
    """
    payload = {
        "https://hasura.io/jwt/claims": {
            "x-hasura-allowed-roles": [user["role"]],
            "x-hasura-default-role": user["role"],
            "X-Hasura-User-Id": user["username"],
        }
    }
    token = jwt.encode(payload, HASURA_JWT_SECRET_KEY, HASURA_JWT_SECRET_TYPE)
    return token


def rehash_and_save_password_if_needed(user, plaintext_password):
    if Password.check_needs_rehash(user["password"]):
        client.update_password(user["username"], Password.hash(plaintext_password))


##############
# MAIN SERVICE
##############


app = Flask(__name__)


@app.route("/signup", methods=["POST"])
def signup_handler():
    args = request.get_json().get("input").get("signupParams")
    hashed_password = Password.hash(args.get("password"))
    roles_name = client.get_default_role()
    if roles_name is None:
        return {"message": "default role not found"}, 400
    else:
        username = client.create_user(args.get("username"), hashed_password, roles_name)
        if username is None:
            return {"message": "failed creating user"}, 400
        else:
            create_user_response = {"username": username}
            return json.dumps(create_user_response).encode("utf-8")


@app.route("/login", methods=["POST"])
def login_handler():
    args = request.get_json().get("input").get("loginParams")
    user = client.find_user_by_username(args.get("username"))
    if user is None:
        return {"message": "user not found"}, 400
    try:
        Password.verify(user.get("password"), args.get("password"))
        rehash_and_save_password_if_needed(user, args.get("password"))
        token = generate_token(user)
        payload = {"token": token}
        return json.dumps(payload).encode("utf-8")
    except VerifyMismatchError:
        return {"message": "invalid credentials"}, 401


if __name__ == "__main__":
    # setup logging config
    logging.basicConfig(
        format="%(asctime)s %(threadName)-2s %(levelname)s: %(message)s",
        level=logging.INFO,
    )
    # create HTTP pool manager
    http = urllib3.PoolManager(timeout=5.0, retries=3, num_pools=20)

    app.run(debug=False, host="0.0.0.0", port=3000)
