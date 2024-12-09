#!/usr/bin/env python3

import os, sys, getopt
from pathlib import Path


dir_path = os.path.dirname(os.path.realpath(__file__))
parent_dir_path = os.path.abspath(os.path.join(dir_path, os.pardir))
sys.path.insert(0, parent_dir_path)

from utils import set_network, get_network_magic, get_key_deposit, get_pool_deposit, get_slots_per_kes_period, get_epoch_length



def main(argv):

    try:
        opts, args = getopt.getopt(argv,"h:n:",["help=", "network="])
    except getopt.GetoptError:
        print ('txs.py -n network_name')
        sys.exit(2)
    for opt, arg in opts:
        if opt in ("-h", "--help"):
            print ('txs.py -n network_name')
            sys.exit()
        elif opt in ("-n", "--network"):
            network = arg

    set_network(network)
    get_network_magic()
    get_key_deposit()
    get_pool_deposit()
    get_slots_per_kes_period()
    get_epoch_length()

if __name__ == "__main__":
   main(sys.argv[1:])

