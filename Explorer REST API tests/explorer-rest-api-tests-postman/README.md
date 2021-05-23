# explorer-rest-api-tests-postman

This repository contains tests for Explorer Web Api created with Postman. It can be downloaded for free: `https://www.postman.com/downloads/ `
and is available for Windows, Linux and macOS.

Tests defined in Postman can be publicly shared, exported as json collection files and imported by other users. Just download latest collection file located in `postman-collections` and import it in Postman to run tests in GUI application. There is also a tool called `newman` which can be used for running collections from command line. Examples are listed below.

# To run tests defined as Postman collections in newman:

### Locally - without using docker

Install Newman (command-line collection runner for Postman) using NPM.

`$ npm install -g newman`

This installs Newman globally on your system allowing you to run it from anywhere. 
If you want to install it locally, just remove the -g flag.


##### Run collection:

Collection (test suite) is located in postman-collections directory.

`newman run postman-collections/cardano-explorer-webapi.postman-collection-v2.json`

Collection is also vailable online: `https://www.getpostman.com/collections/133e09b49487e0e9ac9d`
and can be run by issuing following command:
```
newman run https://www.getpostman.com/collections/133e09b49487e0e9ac9d --env-var "BASE_URL=https://explorer.cardano-testnet.iohkdev.io" --env-var "API_VERSION=api-new" --env-var "SCHEMA_URL=https://raw.githubusercontent.com/ArturWieczorek/explorer-rest-api-tests-python/master/json_schemas/"
```

### Using docker container

- With command line only report:
```
docker run -it --rm --init --entrypoint "" postman/newman /bin/sh -e -c "npm install -g newman-reporter-html; \ 
newman run https://www.getpostman.com/collections/133e09b49487e0e9ac9d \
--env-var "BASE_URL=https://explorer.cardano-testnet.iohkdev.io" \
--env-var "API_VERSION=api-new" \
--env-var "SCHEMA_URL=https://raw.githubusercontent.com/ArturWieczorek/explorer-rest-api-tests-python/master/json_schemas/""
```

- with HTML reports:

```
docker run -it --rm --init --entrypoint "" --volume /tmp/postman-newman-cardano-explorer-web-api-tests:/workdir \
--workdir /workdir postman/newman /bin/sh -e -c "npm install -g newman-reporter-html; \
newman run https://www.getpostman.com/collections/133e09b49487e0e9ac9d \
--env-var "BASE_URL=https://explorer.cardano-testnet.iohkdev.io" \
--env-var "API_VERSION=api-new" \
--env-var "SCHEMA_URL=https://raw.githubusercontent.com/ArturWieczorek/explorer-rest-api-tests-python/master/json_schemas/" \
--reporters cli,html --reporter-html-export explorer-web-api-tests-report.html"
```
Check `/tmp/postman-newman-cardano-explorer-web-api-tests` directory (or whatever place you mounted when issuing docker command) for generated HTML report.

- with extended HTML reports using `https://github.com/DannyDainton/newman-reporter-htmlextra`

```
docker run -it --rm --init --entrypoint "" --volume /tmp/postman-newman-cardano-explorer-web-api-tests:/workdir \
--workdir /workdir postman/newman /bin/sh -e -c "npm install -g newman-reporter-htmlextra; \
newman run https://www.getpostman.com/collections/133e09b49487e0e9ac9d \
--env-var "BASE_URL=https://explorer.cardano-testnet.iohkdev.io" \
--env-var "API_VERSION=api-new" \
--env-var "SCHEMA_URL=https://raw.githubusercontent.com/ArturWieczorek/explorer-rest-api-tests-python/master/json_schemas/" \
--reporters cli,htmlextra --reporter-htmlextra-export explorer-web-api-tests-report-with-extra-reporter.html"
```
