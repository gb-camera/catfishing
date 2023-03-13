#!/bin/sh

pico8_file="catfishing.p8"

args="main.py .. $pico8_file main.lua"

python3 $args || python $args