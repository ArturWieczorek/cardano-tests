import pytest

def test_get_epochs_epoch(get_config, run_common_test, requests_arguments):
    url = get_config["url"] + '/epochs/' + requests_arguments["epoch"]
    schema_url = get_config["schema_url"] + 'epochs_epoch.json'
    run_common_test(url, schema_url)

def test_get_epochs_epoch_slot(get_config, run_common_test, requests_arguments):
    url = get_config["url"] + '/epochs/' + requests_arguments["epoch"] + '/' + requests_arguments["slot"]
    schema_url = get_config["schema_url"] + 'epochs_epoch_slot.json'
    run_common_test(url, schema_url)
