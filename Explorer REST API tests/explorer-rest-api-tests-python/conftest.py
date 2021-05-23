import pytest
import urllib
import requests
import json
from jsonschema import validate

import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()

config = {}
arguments = {}

def pytest_addoption(parser):
    parser.addoption(
        "--base_url", action = "store", default = "https://explorer.cardano-testnet.iohkdev.io/", help = "base url: url for mainnet, staging or testnet"
    )
    parser.addoption(
        "--api_version", action="store", default = "api-new", help = "api version: api or api-new"
    )
    parser.addoption(
        "--schema_url", action = "store", default = "file:json_schemas/", help = "url where json schemas are being stored"
    )

@pytest.fixture
def base_url(request):
    return request.config.getoption("--base_url")

@pytest.fixture
def api_version(request):
    return request.config.getoption("--api_version")

@pytest.fixture
def schema_url(request):
    return request.config.getoption("--schema_url")

@pytest.fixture
def get_config(pytestconfig):
    if not config:
        base_url = pytestconfig.getoption("--base_url")
        api_version = pytestconfig.getoption("--api_version")
        config["url"] = base_url + api_version
        config["schema_url"] = pytestconfig.getoption("--schema_url")
    return config

@pytest.fixture
def requests_arguments(get_config):
    if not arguments:
        url = get_config["url"]

        txs_last_response = urllib.request.urlopen(url + "/txs/last").read()
        txs_last_response_body = json.loads(txs_last_response.decode('utf-8'))
        arguments["txId"] = txs_last_response_body["Right"][0]["cteId"]

        txs_summary_txId_reponse = urllib.request.urlopen(url + '/txs/summary/' + arguments["txId"]).read()
        txs_summary_txId_reponse_body = json.loads(txs_summary_txId_reponse.decode('utf-8'))

        arguments["blockHash"] = txs_summary_txId_reponse_body["Right"]["ctsBlockHash"]
        arguments["epoch"] = str(txs_summary_txId_reponse_body["Right"]["ctsBlockEpoch"])
        arguments["slot"] = str(txs_summary_txId_reponse_body["Right"]["ctsBlockSlot"])
        arguments["address"] = txs_summary_txId_reponse_body["Right"]["ctsInputs"][0]["ctaAddress"]
    return arguments

def pretty_print_request(request):
    request_body = request.body or "{\"Request with empty body\": null}"
    logger.info('\n{}\n{}\n\n{}\n\n{}\n'.format(
        '-----------Request----------->',
        request.method + ' ' + request.url,
        '\n'.join('{}: {}'.format(k, v) for k, v in request.headers.items()),
        json.dumps(json.loads(request_body), indent=4, sort_keys=True))
    )

def pretty_print_response(response):
    response_text = response.text or "{\"Response with empty body\": null}"
    logger.info('\n{}\n{}\n\n{}\n\n{}\n'.format(
        '<-----------Response-----------',
        'Status code:' + str(response.status_code),
        '\n'.join('{}: {}'.format(k, v) for k, v in response.headers.items()),
        json.dumps(json.loads(response.text), indent=4, sort_keys=True))
    )

@pytest.fixture
def run_common_test():

    def run_common_check(url, schema_url):
        resp = requests.get(url)
        resp_body = resp.json()

        # Validate response
        assert resp.status_code == 200

        # Validate schema
        raw_schema = urllib.request.urlopen(schema_url).read()
        schema = json.loads(raw_schema.decode('utf-8'))
        validate(resp_body, schema)

        # Print full request and response
        pretty_print_request(resp.request)
        pretty_print_response(resp)
        return resp

    return run_common_check
