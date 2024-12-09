#!/usr/bin/python3

import json
import re
import shutil
import subprocess
import os

global network
global protocol_params


def set_network(network_name):
    global network
    network=network_name
    print(f"Network set to: {network}")


def get_network_params():
    global protocol_params

    try:
        protocol_params
    except NameError:
        genesis_filepath = f"cardano-node/{network}/{network}-shelley-genesis.json"
        with open(genesis_filepath, 'r') as shelley_genesis_file:
            data = shelley_genesis_file.read()
        protocol_params = json.loads(data)
        return protocol_params

    return protocol_params


def get_network_magic():
    get_network_params()
    print ("networkMagic " + str(protocol_params["networkMagic"]))
    return protocol_params["networkMagic"]

def get_key_deposit():
    get_network_params()
    print ("keyDeposit " + str(protocol_params["protocolParams"]["keyDeposit"]))
    return protocol_params["protocolParams"]["keyDeposit"]

def get_pool_deposit():
    get_network_params()
    print ("keyDeposit " + str(protocol_params["protocolParams"]["poolDeposit"]))
    return protocol_params["protocolParams"]["poolDeposit"]

def get_slots_per_kes_period():
    get_network_params()
    print ("slotsPerKESPeriod " + str(protocol_params["slotsPerKESPeriod"]))
    return protocol_params["slotsPerKESPeriod"]

def get_epoch_length():
    get_network_params()
    print ("epochLength " + str(protocol_params["epochLength"]))
    return protocol_params["epochLength"]


#==============================================================================================


def create_payment_key_pair(location="/cardano-node/keys", key_name):
    try:
        cmd = "cardano-cli address key-gen" + \
              " --verification-key-file " + location + "/" + key_name + ".vkey" + \
              " --signing-key-file " + location + "/" + key_name + ".skey"
        subprocess.check_output(cmd, shell=True, stderr=subprocess.STDOUT).decode("utf-8").strip()
        return location + "/" + key_name + ".vkey", location + "/" + key_name + ".skey"
    except subprocess.CalledProcessError as e:
        raise RuntimeError("command '{}' return with error (code {}): {}".format(e.cmd, e.returncode,
                                                                                 ' '.join(str(e.output).split())))


def build_payment_address(location, addr_name):
    try:
        cmd = "cardano-cli shelley address build" + \
              " --payment-verification-key-file " + location + "/" + addr_name + ".vkey" + \
              " --testnet-magic " + TESTNET_MAGIC + \
              " --out-file " + location + "/" + addr_name + ".addr"
        subprocess.check_output(cmd, shell=True, stderr=subprocess.STDOUT).decode("utf-8").strip()
        return read_address_from_file(location, addr_name + ".addr")
    except subprocess.CalledProcessError as e:
        raise RuntimeError("command '{}' return with error (code {}): {}".format(e.cmd, e.returncode,
                                                                                 ' '.join(str(e.output).split())))


def create_payment_key_pair_and_address(location, addr_name):
    addr_vkey, addr_skey = create_payment_key_pair(location, addr_name)
    addr = build_payment_address(location, addr_name)
    return addr, addr_vkey, addr_skey
