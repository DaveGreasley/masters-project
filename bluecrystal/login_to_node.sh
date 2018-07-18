#!/bin/bash

srun --nodes=1 --partition test --job-name=job --time=00:10:00 --pty bash

