#!/usr/bin/env bash

# Computes the number of occurrences of each line of the input and outputs
# '<count> <line>'.
# history | cut -c8- | frequency | sort -rn | head

sort | uniq -c | sort -g
