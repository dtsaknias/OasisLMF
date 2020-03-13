#!/bin/bash
SCRIPT=$(readlink -f "$0") && cd $(dirname "$SCRIPT")

# --- Script Init ---

set -e
set -o pipefail
mkdir -p log
rm -R -f log/*

# --- Setup run dirs ---

find output/* ! -name '*summary-info*' -type f -exec rm -f {} +

rm -R -f work/*
mkdir work/kat/


mkfifo fifo/il_P10

mkfifo fifo/il_S1_summary_P10
mkfifo fifo/il_S1_summarypltcalc_P10
mkfifo fifo/il_S1_pltcalc_P10



# --- Do insured loss computes ---
pltcalc -s < fifo/il_S1_summarypltcalc_P10 > work/kat/il_S1_pltcalc_P10 & pid1=$!
tee < fifo/il_S1_summary_P10 fifo/il_S1_summarypltcalc_P10 > /dev/null & pid2=$!
summarycalc -f  -1 fifo/il_S1_summary_P10 < fifo/il_P10 &

eve 10 20 | getmodel | gulcalc -S100 -L100 -r -i - | fmcalc -a2 > fifo/il_P10  &

wait $pid1 $pid2


# --- Do insured loss kats ---

kat work/kat/il_S1_pltcalc_P10 > output/il_S1_pltcalc.csv & kpid1=$!
wait $kpid1
