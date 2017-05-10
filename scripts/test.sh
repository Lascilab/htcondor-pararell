#!/bin/bash
set -euo pipefail

for dir in hello integracion
do
    cd /vagrant/ejemplo/${dir}
    rm -f logs.*
    condor_submit submitfile
done

## reconstructPar

watch condor_q
