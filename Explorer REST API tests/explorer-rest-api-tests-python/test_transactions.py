import pytest

def test_get_txs_last(get_config, run_common_test):
    url = get_config["url"] + '/txs/last'
    schema_url = get_config["schema_url"] + 'txs_last.json'
    run_common_test(url, schema_url)

def test_get_txs_summary_txId(get_config, run_common_test, requests_arguments):
    url = get_config["url"] + '/txs/summary/' + requests_arguments["txId"]
    schema_url = get_config["schema_url"] + 'txs_summary_txId.json'
    run_common_test(url, schema_url)

def test_get_stats_txs(get_config, run_common_test):
    url = get_config["url"] + '/stats/txs'
    schema_url = get_config["schema_url"] + 'stats_txs.json'
    run_common_test(url, schema_url)
