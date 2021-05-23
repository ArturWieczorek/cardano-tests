import pytest

def test_get_adresses_summary_address(get_config, run_common_test, requests_arguments):
    url = get_config["url"] + '/addresses/summary/' + requests_arguments["address"]
    schema_url = get_config["schema_url"] + 'addresses_summary_address.json'
    run_common_test(url, schema_url)

def test_get_block_blockHash_address_address(get_config, run_common_test, requests_arguments):
    url = get_config["url"] + '/block/' + requests_arguments["blockHash"] + '/address/' + requests_arguments["address"]
    schema_url = get_config["schema_url"] + 'block_blockHash_address_address.json'
    run_common_test(url, schema_url)
