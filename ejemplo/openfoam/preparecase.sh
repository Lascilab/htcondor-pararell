#!/bin/bash
cd /vagrant/ejemplo/openfoam/
rm -rf damBreak/
cp -r /opt/openfoam231/tutorials/multiphase/interFoam/laminar/damBreak/ .
cd damBreak
blockMesh
cp -r 0/alpha.water.org 0/alpha.water
setFields
decomposePar
