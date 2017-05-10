#!/bin/bash
set -euo pipefail
echo "deb [arch=amd64] http://research.cs.wisc.edu/htcondor/ubuntu/stable/ trusty contrib" | sudo tee -a /etc/apt/sources.list
wget -qO - http://research.cs.wisc.edu/htcondor/ubuntu/HTCondor-Release.gpg.key | sudo apt-key add -
sudo apt-get update
sudo apt-get install -y condor openmpi-bin openmpi-doc libopenmpi-dev
# sudo apt-get install libcr-dev mpich2 mpich2-doc
# http://www.simunano.com/2015/07/how-to-install-openmpi.html
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
TRUST_UID_DOMAIN = TRUE
CONDOR_HOST = controller
UID_DOMAIN = controller
FILESYSTEM_DOMAIN = controller
DAEMON_LIST = MASTER, STARTD
ALLOW_WRITE = $(ALLOW_WRITE), $(CONDOR_HOST)
STARTER_ALLOW_RUNAS_OWNER = true
USE_SHARED_PORT = FALSE
NETWORK_INTERFACE = eth1
EOF

cat << 'EOF' > /etc/condor/config.d/condor_config.local.dedicated.resource
DedicatedScheduler = "DedicatedScheduler@controller"
##-------------------------------------------------------------------
## 2) Always run jobs, but prefer dedicated ones
##--------------------------------------------------------------------
START          = True
SUSPEND        = False
CONTINUE       = True
PREEMPT        = False
KILL           = False
WANT_SUSPEND   = False
WANT_VACATE    = False
RANK           = Scheduler =?= $(DedicatedScheduler) 

MPI_CONDOR_RSH_PATH = $(LIBEXEC)
CONDOR_SSHD = /usr/sbin/sshd
CONDOR_SSH_KEYGEN = /usr/bin/ssh-keygen
STARTD_EXPRS = $(STARTD_EXPRS), DedicatedScheduler
OPENMPI_INSTALL_PATH = /usr
OPENMPI_EXCLUDE_NETWORK_INTERFACES = docker0,virbr0,eth0
MOUNT_UNDER_SCRATCH = /
EOF

sudo service condor restart
