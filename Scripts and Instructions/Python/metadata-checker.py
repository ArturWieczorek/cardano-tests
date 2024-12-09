import os
import requests
import urllib.request
import cloudscraper
import json

#To get errors from database:
#psql -P pager=off -U artur -d "mainnet_restoration" -c "select fetch_error from pool_offline_fetch_error where fetch_error like '%exceeded 512 bytes%';;"
#Example of error form the past: https://atompool.info/atom.metadata.json DOES NOT EXCEED 512 limit

metadata_filename = 'metadata_urls.txt'

with open(metadata_filename) as metadata_file:
    scraper = cloudscraper.create_scraper()

    for metadata_url in metadata_file:
        file_name = metadata_url.split("/")[-1]
        metadata_request = requests.get(metadata_url.strip(), allow_redirects=True)

        metadata_content = None
        metadata_json_content = None

        try:
            metadata_content = scraper.get(metadata_request.url).text
            metadata_json_content = json.loads(metadata_content)
        except Exception as e:
            print(f"Error: {e}. Location probably not availabe, exceeded max retries or other related error")
            continue

        try:
            with open(file_name, 'w') as json_metadata_file:
                json.dump(metadata_json_content, json_metadata_file, indent=2)
        except Exception as e:
            print(e)
            continue

        print(f"metadata name: {file_name}")
        print(f"metadata content:\n{json.dumps(metadata_json_content, indent=2)}\n")

        file_stats = os.stat(file_name)
        print(f"File size: {file_stats.st_size}\n")
        if file_stats.st_size <= 512: 
            print(f"ERROR: File size DOES NOT exceed 512 bytes limit: {file_stats.st_size}\n")
        print("---------------------------------------------------------------------------")