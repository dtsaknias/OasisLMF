#!/bin/bash
SCRIPT=$(readlink -f "$0") && cd $(dirname "$SCRIPT")

# --- Script Init ---

set -e
set -o pipefail
mkdir -p log
rm -R -f log/*

# --- Setup run dirs ---

find output/* ! -name '*summary-info*' -type f -exec rm -f {} +
mkdir output/full_correlation/

rm -R -f work/*
mkdir work/kat/
mkdir work/full_correlation/
mkdir work/full_correlation/kat/

mkdir work/il_S1_summaryaalcalc
mkdir work/full_correlation/il_S1_summaryaalcalc

mkfifo fifo/il_P15

mkfifo fifo/il_S1_summary_P15

mkfifo il_S1_summary_P15



# --- Do insured loss computes ---
tee < fifo/il_S1_summary_P15 work/il_S1_summaryaalcalc/P15.bin > /dev/null & pid1=$!
summarycalc -f  -1 fifo/il_S1_summary_P15 < fifo/il_P15 &

eve 15 20 | getmodel | gulcalc -S100 -L100 -r -j gul_P15 -a1 -i - | fmcalc -a2 > fifo/il_P15  &

wait $pid1

# --- Do computes for fully correlated output ---

fmcalc-a2 < gul_P15 > il_P15 & fcpid1=$!

wait $fcpid1


# --- Do insured loss computes ---
tee < il_S1_summary_P15 work/full_correlation/il_S1_summaryaalcalc/P15.bin > /dev/null & pid1=$!
summarycalc -f  -1 il_S1_summary_P15 < il_P15 &

wait $pid1


# --- Do insured loss kats ---


# --- Do insured loss kats for fully correlated output ---
