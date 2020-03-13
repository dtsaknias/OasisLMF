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

mkdir work/gul_S1_summaryleccalc
mkdir work/gul_S1_summaryaalcalc
mkdir work/full_correlation/gul_S1_summaryleccalc
mkdir work/full_correlation/gul_S1_summaryaalcalc
mkdir work/il_S1_summaryleccalc
mkdir work/il_S1_summaryaalcalc
mkdir work/full_correlation/il_S1_summaryleccalc
mkdir work/full_correlation/il_S1_summaryaalcalc

mkfifo fifo/gul_P10

mkfifo fifo/il_P10

mkfifo fifo/gul_S1_summary_P10
mkfifo fifo/gul_S1_summaryeltcalc_P10
mkfifo fifo/gul_S1_eltcalc_P10
mkfifo fifo/gul_S1_summarysummarycalc_P10
mkfifo fifo/gul_S1_summarycalc_P10
mkfifo fifo/gul_S1_summarypltcalc_P10
mkfifo fifo/gul_S1_pltcalc_P10

mkfifo fifo/il_S1_summary_P10
mkfifo fifo/il_S1_summaryeltcalc_P10
mkfifo fifo/il_S1_eltcalc_P10
mkfifo fifo/il_S1_summarysummarycalc_P10
mkfifo fifo/il_S1_summarycalc_P10
mkfifo fifo/il_S1_summarypltcalc_P10
mkfifo fifo/il_S1_pltcalc_P10

mkfifo gul_S1_summary_P10
mkfifo gul_S1_summaryeltcalc_P10
mkfifo gul_S1_eltcalc_P10
mkfifo gul_S1_summarysummarycalc_P10
mkfifo gul_S1_summarycalc_P10
mkfifo gul_S1_summarypltcalc_P10
mkfifo gul_S1_pltcalc_P10

mkfifo il_S1_summary_P10
mkfifo il_S1_summaryeltcalc_P10
mkfifo il_S1_eltcalc_P10
mkfifo il_S1_summarysummarycalc_P10
mkfifo il_S1_summarycalc_P10
mkfifo il_S1_summarypltcalc_P10
mkfifo il_S1_pltcalc_P10



# --- Do insured loss computes ---
eltcalc -s < fifo/il_S1_summaryeltcalc_P10 > work/kat/il_S1_eltcalc_P10 & pid1=$!
summarycalctocsv -s < fifo/il_S1_summarysummarycalc_P10 > work/kat/il_S1_summarycalc_P10 & pid2=$!
pltcalc -s < fifo/il_S1_summarypltcalc_P10 > work/kat/il_S1_pltcalc_P10 & pid3=$!
tee < fifo/il_S1_summary_P10 fifo/il_S1_summaryeltcalc_P10 fifo/il_S1_summarypltcalc_P10 fifo/il_S1_summarysummarycalc_P10 work/il_S1_summaryaalcalc/P10.bin work/il_S1_summaryleccalc/P10.bin > /dev/null & pid4=$!
summarycalc -f  -1 fifo/il_S1_summary_P10 < fifo/il_P10 &

# --- Do ground up loss computes ---
eltcalc -s < fifo/gul_S1_summaryeltcalc_P10 > work/kat/gul_S1_eltcalc_P10 & pid5=$!
summarycalctocsv -s < fifo/gul_S1_summarysummarycalc_P10 > work/kat/gul_S1_summarycalc_P10 & pid6=$!
pltcalc -s < fifo/gul_S1_summarypltcalc_P10 > work/kat/gul_S1_pltcalc_P10 & pid7=$!
tee < fifo/gul_S1_summary_P10 fifo/gul_S1_summaryeltcalc_P10 fifo/gul_S1_summarypltcalc_P10 fifo/gul_S1_summarysummarycalc_P10 work/gul_S1_summaryaalcalc/P10.bin work/gul_S1_summaryleccalc/P10.bin > /dev/null & pid8=$!
summarycalc -i  -1 fifo/gul_S1_summary_P10 < fifo/gul_P10 &

eve 10 40 | getmodel | gulcalc -S100 -L100 -r -j gul_P10 -a1 -i - | tee fifo/gul_P10 | fmcalc -a2 > fifo/il_P10  &

wait $pid1 $pid2 $pid3 $pid4 $pid5 $pid6 $pid7 $pid8

# --- Do computes for fully correlated output ---

fmcalc-a2 < gul_P10 > il_P10 & fcpid1=$!

wait $fcpid1


# --- Do insured loss computes ---
eltcalc -s < il_S1_summaryeltcalc_P10 > work/full_correlation/kat/il_S1_eltcalc_P10 & pid1=$!
summarycalctocsv -s < il_S1_summarysummarycalc_P10 > work/full_correlation/kat/il_S1_summarycalc_P10 & pid2=$!
pltcalc -s < il_S1_summarypltcalc_P10 > work/full_correlation/kat/il_S1_pltcalc_P10 & pid3=$!
tee < il_S1_summary_P10 il_S1_summaryeltcalc_P10 il_S1_summarypltcalc_P10 il_S1_summarysummarycalc_P10 work/full_correlation/il_S1_summaryaalcalc/P10.bin work/full_correlation/il_S1_summaryleccalc/P10.bin > /dev/null & pid4=$!
summarycalc -f  -1 il_S1_summary_P10 < il_P10 &

# --- Do ground up loss computes ---
eltcalc -s < gul_S1_summaryeltcalc_P10 > work/full_correlation/kat/gul_S1_eltcalc_P10 & pid5=$!
summarycalctocsv -s < gul_S1_summarysummarycalc_P10 > work/full_correlation/kat/gul_S1_summarycalc_P10 & pid6=$!
pltcalc -s < gul_S1_summarypltcalc_P10 > work/full_correlation/kat/gul_S1_pltcalc_P10 & pid7=$!
tee < gul_S1_summary_P10 gul_S1_summaryeltcalc_P10 gul_S1_summarypltcalc_P10 gul_S1_summarysummarycalc_P10 work/full_correlation/gul_S1_summaryaalcalc/P10.bin work/full_correlation/gul_S1_summaryleccalc/P10.bin > /dev/null & pid8=$!
summarycalc -i  -1 gul_S1_summary_P10 < gul_P10 &

wait $pid1 $pid2 $pid3 $pid4 $pid5 $pid6 $pid7 $pid8


# --- Do insured loss kats ---

kat work/kat/il_S1_eltcalc_P10 > output/il_S1_eltcalc.csv & kpid1=$!
kat work/kat/il_S1_pltcalc_P10 > output/il_S1_pltcalc.csv & kpid2=$!
kat work/kat/il_S1_summarycalc_P10 > output/il_S1_summarycalc.csv & kpid3=$!

# --- Do insured loss kats for fully correlated output ---

kat work/full_correlation/kat/il_S1_eltcalc_P10 > output/full_correlation/il_S1_eltcalc.csv & kpid4=$!
kat work/full_correlation/kat/il_S1_pltcalc_P10 > output/full_correlation/il_S1_pltcalc.csv & kpid5=$!
kat work/full_correlation/kat/il_S1_summarycalc_P10 > output/full_correlation/il_S1_summarycalc.csv & kpid6=$!

# --- Do ground up loss kats ---

kat work/kat/gul_S1_eltcalc_P10 > output/gul_S1_eltcalc.csv & kpid7=$!
kat work/kat/gul_S1_pltcalc_P10 > output/gul_S1_pltcalc.csv & kpid8=$!
kat work/kat/gul_S1_summarycalc_P10 > output/gul_S1_summarycalc.csv & kpid9=$!

# --- Do ground up loss kats for fully correlated output ---

kat work/full_correlation/kat/gul_S1_eltcalc_P10 > output/full_correlation/gul_S1_eltcalc.csv & kpid10=$!
kat work/full_correlation/kat/gul_S1_pltcalc_P10 > output/full_correlation/gul_S1_pltcalc.csv & kpid11=$!
kat work/full_correlation/kat/gul_S1_summarycalc_P10 > output/full_correlation/gul_S1_summarycalc.csv & kpid12=$!
wait $kpid1 $kpid2 $kpid3 $kpid4 $kpid5 $kpid6 $kpid7 $kpid8 $kpid9 $kpid10 $kpid11 $kpid12
