import mmap
import requests
import json
import urllib

print("Getting the topology.json file...")
env = 'preprod'
urllib.request.urlretrieve("https://raw.githubusercontent.com/ArturWieczorek/node-topology-files/main/" + env + "/topology.json", "topology.json",)

