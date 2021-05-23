# explorer-rest-api-tests-python

This is a Python REST API test suite for [Cardano Explorer](https://github.com/input-output-hk/cardano-rest). 

You will need to install Python3 first, and pytest test framework:
```
pip install -U requests Flask pytest pytest-html
```
or install with pip3 if you have both Python2 and Python3 installed:

```
pip3 install -U requests Flask pytest pytest-html
```

To run all tests in console:

```
$ pytest -sv
```

To run particular test file:

```
$ pytest -sv file_name.py
```

To run against particular network:

```
pytest -sv --base_url https://network_address.com/
```

Other paramaters that can be used are: `--api_version` with default value `api-new/` and `--schema_url` which by default points to `json_schemas` directory 
inside this repository.

```
pytest -sv --base_url https://network_address.com/ --api_version api/ --schema_url location_of_schemas_for_old_api_version
```

To run tests and generate report in HTML file:

```
pytest -v --html report.html
```

After completion there should be `report.html` file in root directory.

#### TO-DO:

Some tests can be parameterized using following approach:

```
@pytest.mark.parametrize("endpoint,json_schema", [("txs/last", 'txs_last.json'), ("txs/summary/", 'txs_summary_txId.json'), ("stats/txs", 'stats_txs.json')])
def test_txs(get_config, run_common_test, endpoint, json_schema):
    url = get_config["url"] + endpoint
    schema_url = get_config["schema_url"] + json_schema
    run_common_test(url, schema_url)
```
