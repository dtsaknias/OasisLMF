#!/bin/bash
SCRIPT=$(readlink -f "$0") && cd $(dirname "$SCRIPT")

# --- Script Init ---

set -e
set -o pipefail
mkdir -p log
rm -R -f log/*


leccalc -r -Kgul_S1_summaryleccalc -m output/gul_S1_leccalc_wheatsheaf_mean_oep.csv & lpid1=$!
leccalc -r -Kfull_correlation/gul_S1_summaryleccalc -m output/full_correlation/gul_S1_leccalc_wheatsheaf_mean_oep.csv & lpid2=$!
wait $lpid1 $lpid2

rm -R -f work/*
rm -R -f fifo/*