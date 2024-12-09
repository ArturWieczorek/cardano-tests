import subprocess
import sys
import os
import shlex
import time
import shutil
import git 
import fileinput
from git import Repo
from assertpy import assert_that, assert_warn


def is_dir(dir):
    return os.path.isdir(dir)


def git_clone_iohk_repo(repo_name, repo_dir, repo_branch):
    repo = Repo.clone_from(f"https://github.com/input-output-hk/{repo_name}.git", repo_dir)
    repo.git.checkout(repo_branch)
    print(f"Repo: {repo_name} cloned to: {repo_dir}")
    return repo

repo_name = 'cardano-node'
repo_dir = 'cardano_node_dir'
node_rev_1 = 'tags/1.35.5'
node_rev_2 = 'tags/1.35.6-rc1'

#cardano_node_repo = git_clone_iohk_repo(repo_name, repo_dir, node_rev_1)
#cardano_node_repo.git.checkout(node_rev_2)

if is_dir('test') is True:
    print("OK")
else:
    print("NOT OK")


for line in fileinput.input("cabal.project", inplace=True):
    print(line.replace("tests: True", "tests: False"), end="")


with open("config.json", "r") as f:
    lines = f.readlines()
with open("config2.json", "w") as f:
    for line in lines:
        if 'ConwayGenesis' not in line.strip("\n"):
            f.write(line)


