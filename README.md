# Htcondor-pararell
This guide will give you detail instructions on how to setup and use HTCondor for pararell universe and MPI executions.

> Use HTCondor >= 8.6.2

## Setup
Install HTCondor in your machines along with MPI and SSH. Then configure your nodes to allow them to receive pararell jobs creating this file `/etc/condor/config.d/condor_config.local.dedicated.resource`

```
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

Replace `DedicatedScheduler = "DedicatedScheduler@controller"` with your scheduler name, Be careful when specifying the name of the dedicated scheduler as it must match exactly. You can see the name of the scheduler by running `condor_status -schedd`. For example, if the output of the command is:

```
$ condor_status -schedd
Name                 Machine              TotalRunningJobs           TotalIdleJobs     TotalHeldJobs

hpctest0             hpctest0              0                              0                        0
```

Then, the line must be `DedicatedScheduler = "DedicatedScheduler@hpctest0"`.

Restart HTCondor in each node (For Ubuntu `sudo service condor restart`) and check if the nodes are avalaible:
```
condor_status -const '!isUndefined(DedicatedScheduler)' \ 
   -format "%s\t" Machine -format "%s\n" DedicatedScheduler
```

## Test
Lets test a "hello world" program creating a file called: hello.c
```
#include <stdio.h>
#include <unistd.h>
#include <mpi.h>

int main(int argc, char** argv) {
    int myrank, nprocs;
    char hostname[256];

    MPI_Init(&argc, &argv);
    MPI_Comm_size(MPI_COMM_WORLD, &nprocs);
    MPI_Comm_rank(MPI_COMM_WORLD, &myrank);
    gethostname(hostname,255);

    printf("Hello from processor %d of %d on host %s\n", myrank, nprocs,hostname);

    MPI_Finalize();
    return 0;
}
```
Compile it `mpicc hello.c -o hello.mpi` and then create a `submitfile`:
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

Submit to HTCondor `condor_submit submitfile` and wait `condor_q`

## Simple examples
There are a few examples that can help you check MPI config, check it out [here](https://github.com/Lascilab/htcondor-pararell/tree/master/ejemplo)

## Advance examples
In some cases, you need to source an environment file or execute mpi in a NFS folder. For that case you would need to modify a little `openmpiscript`, check the [Openfoam example](https://github.com/Lascilab/htcondor-pararell/tree/master/ejemplo/openfoam). Notice that the line 172 added `-wdir` option that tells mpi to execute in that directory.

```
 mpirun -v -wdir /vagrant/ejemplo/openfoam/damBreak \
      --prefix $MPDIR --mca $mca_ssh_agent $CONDOR_SSH \ 
      -n $_CONDOR_NPROCS -hostfile machines $EXECUTABLE $@ &
```

Also we modify `condor_ssh` in the last line (150) in order to `source /etc/profile` and set many environment variables.



## Vagrant
You can also use vagrant for a quick test, install [vagrant](https://www.vagrantup.com/) and execute `vagrant up`. In a few minutes you will have three virtual machines up and running: a controller and two nodes. Execute `vagrant ssh controller` to get into the controller and submit every example located in "/vagrant"

## Sources
 - [University of York](https://wiki.york.ac.uk/display/RHPC/HTCondor)
 - [HTCondor Manual: user](http://research.cs.wisc.edu/htcondor/manual/v8.6/2_9Parallel_Applications.html)
 - [HTCondor Manual: admin](http://research.cs.wisc.edu/htcondor/manual/v8.6/3_14Setting_Up.html#SECTION004148000000000000000)
 - [Stefano Gariazzo: notes](http://personalpages.to.infn.it/~gariazzo/htcondor/parallel.html)
