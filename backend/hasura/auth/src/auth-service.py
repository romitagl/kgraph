# https://hasura.io/docs/latest/graphql/core/auth/authentication/jwt.html
# https://hasura.io/docs/latest/graphql/core/actions/codegen/python-flask.html#actions-codegen-python-flask

import hashlib
import json
import logging
import os
import uuid
from dataclasses import dataclass

import jwt
import urllib3
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
class GraphQLClient:
    url: str
    headers: dict

    def graphql_http_request(self, query: str, variables: dict):
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
                logging.error(
                    f"graphql_http_request - no data found in the data json property: {jsonData}"
                )
                error = jsonData.get("errors", "no data found")[0].get("message")
                return None, error
            return data, None
        except urllib3.exceptions.HTTPError as e:
            logging.error(
                f"graphql_http_request - failed processing HTTP exception: {e}"
            )
            return None, e
        except Exception as e:
            logging.error(f"graphql_http_request - failed processing - exception: {e}")
            return None, e

    def get_default_role(self):
        response, error = self.graphql_http_request(
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
        if response is None:
            return None
        return response.get("kgraph_roles")[0].get("name")

    def find_user_by_username(self, username: str):
        response, error = self.graphql_http_request(
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
        response, error = self.graphql_http_request(
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
        if response is None:
            if "duplicate key value violates unique constraint" in error:
                return None, "username already exists"
            return None, error

        valid_res = response.get("insert_kgraph_users_one")
        if not valid_res:
            return None, response

        return response.get("insert_kgraph_users_one").get("username"), None

    def update_password(self, username: str, password: str):
        response, error = self.graphql_http_request(
            """
            mutation UpdatePassword($username: String!, $password: String!) {
                update_kgraph_users_by_pk(pk_columns: {username: $username}, _set: {password_hash: $password}) {
                    password_hash
                }
            }
        """,
            {"username": username, "password": password},
        )
        # logging.info(f"update_password response:{response}")
        if response is None:
            return None


#######
# UTILS
#######


client = GraphQLClient(url=HASURA_URL, headers=HASURA_HEADERS)


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


# https://www.pythoncentral.io/hashing-strings-with-python/#:~:text=The%20hashlib%20module,%20included%20in%20The%20Python%20Standard,made%20to%20work%20in%20Python%203.2%20and%20above.
def hash_password(password):
    # uuid is used to generate a random number
    password = password.strip()
    salt = uuid.uuid4().hex
    return hashlib.sha256(salt.encode() + password.encode()).hexdigest() + ":" + salt


def check_password_ok(hashed_password, user_password):
    user_password = user_password.strip()
    password, salt = hashed_password.split(":")
    user_password_hash = hashlib.sha256(
        salt.encode() + user_password.encode()
    ).hexdigest()
    return password == user_password_hash


##############
# MAIN SERVICE
##############


app = Flask(__name__)


@app.route("/signup", methods=["POST"])
def signup_handler():
    args = request.get_json().get("input").get("signupParams")
    try:
        user_password = args.get("password")
        hash_pwd = hash_password(user_password)

        roles_name = client.get_default_role()
        if roles_name is None:
            return {"message": "default role not found"}, 400
        else:
            username, error = client.create_user(
                args.get("username"), hash_pwd, roles_name
            )
            if username is None:
                return {"message": f"failed creating user - {error}"}, 400
            else:
                logging.info(f"/signup username: {username}")
                create_user_response = {"username": username}
                return json.dumps(create_user_response).encode("utf-8")
    except Exception as exc:
        logging.error(f"signup exception: {exc}")
        return {"message": f"failed to signup user - {exc}"}, 401


@app.route("/login", methods=["POST"])
def login_handler():
    # logging.info(f"login request args:{request.get_json()}")
    args = request.get_json().get("input").get("loginParams")
    username = args.get("username")
    logging.info(f"/login username: {username}")
    user = client.find_user_by_username(username)
    if user is None:
        return {"message": "user not found"}, 400
    try:
        hashed_password = user.get("password")
        user_password = args.get("password")
        if (
            check_password_ok(
                hashed_password=hashed_password, user_password=user_password
            )
            is False
        ):
            raise Exception("failed verify login credentials")

        token = generate_token(user)
        payload = {"token": token}
        return json.dumps(payload).encode("utf-8")
    except Exception as exc:
        logging.error(f"login exception: {exc}")
        return {"message": f"failed to login - {exc}"}, 401


if __name__ == "__main__":
    # setup logging config
    logging.basicConfig(
        format="%(asctime)s %(threadName)-2s %(levelname)s: %(message)s",
        level=logging.INFO,
    )
    # create HTTP pool manager
    http = urllib3.PoolManager(timeout=5.0, retries=3, num_pools=20)
    from waitress import serve

    serve(app, host="0.0.0.0", port=3000)
