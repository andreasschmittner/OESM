#!/bin/bash
ulimit -s unlimited
cd /data2/aschmitt/models/OESM/0.1/oesm_11_t021_exp
python coupler.py 11 t021_exp 1000 10000 1 
