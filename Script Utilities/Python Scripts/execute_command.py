import subprocess
import sys
import os
import shlex
import time
import shutil


def execute_command(command):
    cmd = shlex.split(command)
    try:
        process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, encoding="utf-8")
        while process.poll() is None:
            nextline = process.stdout.readline()
            sys.stdout.write(nextline)
            sys.stdout.flush()    
            # Poll process for new output until it is finished
            if nextline == '' and process.poll() is not None:
                print("--- End of cabal build all process", flush=True)
                break           
        exit_code = process.returncode
        if (exit_code != 0):
            print(f"Command {cmd} returned exitCode: {exit_code}")
            #raise Exception(f"Command {cmd} returned exitCode: {exitCode}")
    except subprocess.CalledProcessError as e:
        raise RuntimeError(
            "command '{}' return with error (code {}): {}".format(
                e.cmd, e.returncode, " ".join(str(e.output).split())
            )
        ) 


def execute_command_and_write_to_log(command, log_file_name):
    try:
        cmd = shlex.split(command)
        with open(log_file_name, "w") as f:
            process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, encoding="utf-8")
            while process.poll() is None:
                nextline = process.stdout.readline()
                sys.stdout.write(nextline)
                sys.stdout.flush()    
                f.write(nextline)
                # Poll process for new output until it is finished
                if nextline == '' and process.poll() is not None:
                    print("--- End of cabal build all process", flush=True)
                    break           
            exit_code = process.returncode
            if (exit_code != 0):
                print(f"Command {cmd} returned exitCode: {exit_code}")
                #raise Exception(f"Command {cmd} returned exitCode: {exitCode}")

    except subprocess.CalledProcessError as e:
        raise RuntimeError(
            "command '{}' return with error (code {}): {}".format(
                e.cmd, e.returncode, " ".join(str(e.output).split())
            )
        ) 

execute_command_and_write_to_log('cabal build all', 'artur.log')