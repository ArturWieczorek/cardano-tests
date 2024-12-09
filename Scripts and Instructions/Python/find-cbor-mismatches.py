import subprocess
import sys
import os
import shlex
import time
import shutil
import json


def execute_command(command):
    cmd = shlex.split(command)
    try:
        process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, encoding="utf-8")
        out, err = (process.strip() for process in process.communicate(timeout=10))
        if err:
            print(f"Error coming from db: {err} for command {cmd}.")
        return out
        
    except subprocess.CalledProcessError as e:
        raise RuntimeError(
            "command '{}' return with error (code {}): {}".format(
                e.cmd, e.returncode, " ".join(str(e.output).split())
            )
        ) 

# To get cbor_all_scripts_hashes.json use:
# psql -qAtX -U username database -c "SELECT json_agg(e) from (select hash from script) e;" >> cbor_all_scripts_hashes.json

# To get only Plutus V2 hashes use:
# psql -qAtX -U username database -c "SELECT json_agg(e) from (select hash from script where type = ANY(enum_range('plutusV2'::scripttype, NULL))) e;" >> cbor_plutus_v2_hashes.json

f = open('cbor_all_scripts_hashes.json')
data = json.load(f)
  
for i in data:
    hash = i['hash']
    #print(f"Checking record for hash {hash}")
    cbor_new = execute_command(f"psql -qAtX -U ubuntu mainnet_13_1_1_0_from_scratch -c \"select bytes from script where hash='\{hash}';\"")
    cbor_old = execute_command(f"psql -qAtX -U ubuntu mainnet_restore_13_1_0_2 -c \"select bytes from script where hash='\{hash}';\"")
    
    if cbor_new != cbor_old:
        print(f"{hash}")
        print("")
        print("13.1.1.0 NEW CBOR:")
        print(f"{cbor_new}")
        print("")
        print("OLD CBOR:")
        print(f"{cbor_old}")
        print("")
        print(f"----------------------------------------------------------------------------------")

f.close()
