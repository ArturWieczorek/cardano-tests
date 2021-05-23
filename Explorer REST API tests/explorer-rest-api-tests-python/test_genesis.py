import pytest

def test_get_genesis_summary(get_config, run_common_test):
    url = get_config["url"] + '/genesis/summary'
    schema_url = get_config["schema_url"] + 'genesis_summary.json'
    run_common_test(url, schema_url)

def test_get_genesis_address_pages_total(get_config, run_common_test):
    url = get_config["url"] + '/genesis/address/pages/total'
    schema_url = get_config["schema_url"] + 'genesis_address_pages_total.json'
    run_common_test(url, schema_url)

def test_get_genesis_address(get_config, run_common_test):
    url = get_config["url"] + '/genesis/address'
    schema_url = get_config["schema_url"] + 'genesis_address.json'
    run_common_test(url, schema_url)

def test_get_supply_ada(get_config, run_common_test):
    url = get_config["url"] + '/supply/ada'
    schema_url = get_config["schema_url"] + 'supply_ada.json'
    run_common_test(url, schema_url)
