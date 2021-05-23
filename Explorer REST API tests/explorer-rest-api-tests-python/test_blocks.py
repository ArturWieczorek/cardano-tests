import pytest

def test_get_blocks_pages(get_config, run_common_test):
    url = get_config["url"] + '/blocks/pages'
    schema_url = get_config["schema_url"] + 'blocks_pages.json'
    run_common_test(url, schema_url)

def test_get_blocks_pages_total(get_config, run_common_test):
    url = get_config["url"] + '/blocks/pages/total'
    schema_url = get_config["schema_url"] + 'blocks_pages_total.json'
    run_common_test(url, schema_url)

def test_get_blocks_summary_blockHash(get_config, run_common_test, requests_arguments):
    url = get_config["url"] + '/blocks/summary/' + requests_arguments["blockHash"]
    schema_url = get_config["schema_url"] + 'blocks_summary_blockHash.json'
    run_common_test(url, schema_url)

def test_get_blocks_txs_blockHash(get_config, run_common_test, requests_arguments):
    url = get_config["url"] + '/blocks/txs/' + requests_arguments["blockHash"]
    schema_url = get_config["schema_url"] + 'blocks_txs_blockHash.json'
    run_common_test(url, schema_url)
    #Example of accessing response from running common test: 
    #response = run_common_test(url, schema_url);
    #print("GET TX ID: " + r.json()["Right"][0]["ctbId"])
