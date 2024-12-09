import os
from pathlib import Path
from urllib.parse import urljoin
from typing import Optional
import requests
from requests import Response
import json
from cardano_node_tests.utils import configuration


node_socket_path = Path(os.environ["CARDANO_NODE_SOCKET_PATH"])
root_dir, _ = os.path.split(node_socket_path)
admins_file = Path(root_dir) / "admins.txt"
with open(admins_file) as f:
    credentials_line = f.readlines()
credentials = credentials_line[0].split(',')
username = credentials[0]
password = credentials[1].strip()

session = requests.Session()
session.auth = (username, password)
session.headers.update({'Content-Type': 'application/json'})

base_url = 'http://localhost:3100/api/v1/'
status = urljoin(base_url, 'status')
metadata = urljoin(base_url, 'metadata/')
delist = urljoin(base_url, 'delist')
ticker = urljoin(base_url, 'tickers/')
whitelist = urljoin(base_url, 'enlist')
errors = urljoin(base_url, 'errors/')
retired = urljoin(base_url, 'retired')
policies = urljoin(base_url, 'policies')


def get_status() -> Optional[Response]:
    if not configuration.HAS_SMASH:
        return None
    return requests.get(status)


def fetch_metadata(pool_id: str, pool_metadata: str) -> Optional[Response]:
    if not configuration.HAS_SMASH:
        return None
    metadata_url = urljoin(metadata, f"{pool_id}/{pool_metadata}")
    return session.get(metadata_url)


def delist_pool(pool_id: str) -> Optional[Response]:
    if not configuration.HAS_SMASH:
        return None

    return session.patch(delist, json={'poolId': pool_id})


def reserve_ticker(pool_id: str, ticker_name: str) -> Optional[Response]:
    if not configuration.HAS_SMASH:
        return None
    reserve_ticker_url = urljoin(ticker, ticker_name)
    return session.post(reserve_ticker_url, json={'poolId': pool_id})


def whitelist_pool(pool_id: str) -> Optional[Response]:
    if not configuration.HAS_SMASH:
        return None
    return session.patch(whitelist, json={'poolId': pool_id})


def get_errors(pool_id: str) -> Optional[Response]:
    if not configuration.HAS_SMASH:
        return None
    errors_url = urljoin(errors, pool_id)
    return session.get(errors_url)


def get_retired_pools() -> Optional[Response]:
    if not configuration.HAS_SMASH:
        return None
    return session.get(retired)


def fetch_policies(smash_url: str='https://smash.cardano-mainnet.iohk.io') -> Optional[Response]:
    if not configuration.HAS_SMASH:
        return None
    return session.post(policies, json={'smashURL': smash_url})
