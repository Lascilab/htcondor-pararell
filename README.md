# Htcondor-pararell
This guide will give you detail instructions on how to setup and use HTCondor for pararell universe and MPI executions.

> Use HTCondor >= 8.6.2

## Simple Setup
Install HTCondor in your machines along with MPI and SSH. Then configure your nodes to allow them to receive pararell jobs creating this file `/etc/condor/config.d/condor_config.local.dedicated.resource`

```
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
RANK = Scheduler =?= $(DedicatedScheduler) 
##--------------------------------------------------------------------
MPI_CONDOR_RSH_PATH = $(LIBEXEC)
CONDOR_SSHD = /usr/sbin/sshd
CONDOR_SSH_KEYGEN = /usr/bin/ssh-keygen
STARTD_EXPRS = $(STARTD_EXPRS), DedicatedScheduler
OPENMPI_INSTALL_PATH = /usr
OPENMPI_EXCLUDE_NETWORK_INTERFACES = docker0,virbr0
MOUNT_UNDER_SCRATCH = /
```
Restart HTCondor in each node (For Ubuntu `sudo service condor restart`) and check if the nodes are avalaible:
```
condor_status -const '!isUndefined(DedicatedScheduler)' -format "%s\t" Machine -format "%s\n" DedicatedScheduler
```


To test it with this submit file (note that you need to compile [hello.c](https://github.com/Lascilab/htcondor-pararell/blob/master/ejemplo/hello/mpi_hello.c):

```
######################################
## Example submit description file
## for Open MPI 
## condor_submit submitfile
######################################
universe = parallel
executable = /usr/share/doc/condor/etc/examples/openmpiscript
arguments = hello.mpi
machine_count = 2
# request_cpus = 8
should_transfer_files = yes
when_to_transfer_output = on_exit
log                     = logs.log
output                  = logs.out.$(NODE)
error                   = logs.err.$(NODE)
transfer_input_files = hello.mpi
queue
```
### Test it using vagrant
For a fast test, install [vagrant](https://www.vagrantup.com/) and execute `vagrant up`. In a few minutes you will have three virtual machines running: a controller and two nodes. Execute `vagrant ssh controller` to get into the controller and submit every example located in "/vagrant"

## Simple examples
There are a few examples that can help you check MPI config, check it out [here](https://github.com/Lascilab/htcondor-pararell/tree/master/ejemplo)

## Advance examples
In some cases, you need to source an environment file or execute mpi in a NFS folder. For that case you would need to modify a little `openmpiscript`, check the [Openfoam example](https://github.com/Lascilab/htcondor-pararell/tree/master/ejemplo/openfoam)

## Sources
 - [University of York](https://wiki.york.ac.uk/display/RHPC/HTCondor)
 - [HTCondor Manual: user](http://research.cs.wisc.edu/htcondor/manual/v8.6/2_9Parallel_Applications.html)
 - [HTCondor Manual: admin](http://research.cs.wisc.edu/htcondor/manual/v8.6/3_14Setting_Up.html#SECTION004148000000000000000)
 - [Stefano Gariazzo: notes](http://personalpages.to.infn.it/~gariazzo/htcondor/parallel.html)
