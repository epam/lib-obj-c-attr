#!/bin/bash

# =================     Download simian and unzip     ===========
wget http://www.harukizaemon.com/simian/simian-2.3.35.tar.gz > /dev/null
tar xzf simian-2.3.35.tar.gz > /dev/null

# =================     Run simian check     ===========
ant check-simian
