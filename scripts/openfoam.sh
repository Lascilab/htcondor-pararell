#!/bin/bash
set -euo pipefail

sudo add-apt-repository http://dl.openfoam.org/ubuntu
sudo sh -c "wget -O - http://dl.openfoam.org/gpg.key | apt-key add -"
sudo apt-get update
sudo apt-get install -y openfoam231

echo ". /opt/openfoam231/etc/bashrc" >> ~/.bashrc
. ~/.bashrc

################################################
## cp -r /opt/OpenFOAM/OpenFOAM-v3.0+/tutorials/multiphase/interFoam/laminar/damBreak/ .
## cp -r /opt/openfoam4/tutorials/multiphase/interFoam/laminar/damBreak/ .
##cp -r /opt/openfoam231/tutorials/multiphase/interFoam/laminar/damBreak/ .

##cd damBreak
##blockMesh
# $ cp -r 0/alpha.water.orig 0/alpha.water
##cp -r 0/alpha.water.org 0/alpha.water 
##setFields
##decomposePar

##cp /usr/share/doc/condor/etc/examples/openmpiscript .
##add . /opt/openfoam231/etc/bashrc

##mpirun -np 4 interFoam -parallel > log
##reconstructPar

