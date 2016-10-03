#!/usr/bin/env bash
source ./constants.sh
vagrant halt
vagrant up --provision
