#!/bin/bash

srun --nodes=1 --partition cpu_test --job-name=job --time=01:00:00 --mem 40000 --pty bash

