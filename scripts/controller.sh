#!/bin/bash
set -euo pipefail
echo "deb [arch=amd64] http://research.cs.wisc.edu/htcondor/ubuntu/stable/ trusty contrib" | sudo tee -a /etc/apt/sources.list
wget -qO - http://research.cs.wisc.edu/htcondor/ubuntu/HTCondor-Release.gpg.key | sudo apt-key add -
sudo apt-get update
sudo apt-get install -y condor

cat << 'EOF' > /etc/condor/config.d/condor_config.local
ALLOW_READ = *                        
ALLOW_WRITE = * 
HOSTALLOW_READ = *
HOSTALLOW_WRITE = *
ALLOW_NEGOTIATOR = *
ALLOW_ADMINISTRATOR = *
COLLECTOR_DEBUG = D_FULLDEBUG
NEGOTIATOR_DEBUG = D_FULLDEBUG
MATCH_DEBUG = D_FULLDEBUG
SCHEDD_DEBUG = D_FULLDEBUG
START = FALSE
TRUST_UID_DOMAIN = TRUE
CONDOR_HOST = controller
UID_DOMAIN = controller
FILESYSTEM_DOMAIN = controller
NETWORK_INTERFACE = eth1
DAEMON_LIST = COLLECTOR, MASTER, NEGOTIATOR, SCHEDD
ALLOW_WRITE = $(ALLOW_WRITE), $(CONDOR_HOST)
STARTER_ALLOW_RUNAS_OWNER = true
TRUST_UID_DOMAIN = true
USE_SHARED_PORT = FALSE
EOF

sudo service condor restart
