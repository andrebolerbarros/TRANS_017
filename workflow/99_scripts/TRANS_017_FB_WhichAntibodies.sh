#!/bin/bash

# TRANS_017 Feature Barcode Processing
# Purpose: Check antibodies for feature barcode data
# Date: 2026-01-09

MAIN="/ifs/igc/folders/ADA/SHARED/projects/BSSantos/TRANS_017"
LOG_DIR="${MAIN}/workflow/ZZ_logs"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="${LOG_DIR}/${TIMESTAMP}_FB_WhichAntibodies.out"

# --- Input Folders --- #
FB="${MAIN}/data/00_rawdata/00a_FB"

# --- Output Folder --- #
INFO="${MAIN}/data/98_miscellaneous"

mkdir -p "${INFO}"

#================ File Transfer Script Start =================#

echo -e "==========================================================" | tee -a "${LOG_FILE}"
echo -e "                TRANS_017 - Ab Sequence Script            " | tee -a "${LOG_FILE}"
echo -e "==========================================================" | tee -a "${LOG_FILE}"

echo -e "Log File: ${LOG_FILE}" | tee -a "${LOG_FILE}"

# ==== Ab Sequence - Per Sample Info ==== #

echo -e "\n\n~~~ Ab Sequence - Per Sample Information ~~~~\n\n" | tee -a "${LOG_FILE}"

# Print table header
printf "%-50s\t%s\n" "Sample" "Sequence" > "${INFO}/PerSample_ab_sequences.tsv"

# Process each R2 file
for file in ${FB}/FB_*/*_R2_001.fastq.gz; do
  
  echo -e "> Processing ${file}\n" | tee -a "${LOG_FILE}"

  sample=$(basename "$file" | sed 's/_R2_001.fastq.gz//')
  
  # Extract sequences and format as table rows
  zcat "$file" | \
    awk 'NR%4==2 {print substr($0,1,15)}' | \
    sort | uniq -c | sort -rn | head -50 | \
    awk -v sample="$sample" '{printf "%-50s\t%s\n", sample, $2}' | \
    tee -a "${INFO}/PerSample_ab_sequences.tsv"
  
  # Add blank line between samples
  echo "" | tee -a "${INFO}/PerSample_ab_sequences.tsv"

  echo -e "Finished Processing ${file}" | tee -a "${LOG_FILE}"
  echo -e "__________________________________________________________________________\n" | tee -a "${LOG_FILE}"

done

echo "Results saved to: ${INFO}/PerSample_ab_sequences.tsv"

# ==== Ab Sequence - Unique Sequences ==== #

echo -e "~~~ Ab Sequence - Unique Sequences ~~~~" | tee -a "${LOG_FILE}"

echo ""
echo "Extracting unique sequences across all samples..."

# Get unique sequences (skip header and separator lines, extract second column, sort and get unique)
tail -n +3 "${INFO}/PerSample_ab_sequences.tsv" | \
  grep -v "^$" | \
  awk '{print $2}' | \
  sort -u > "${INFO}/unique_ab_sequences.txt"

# Count unique sequences
UNIQUE_COUNT=$(wc -l < "${INFO}/unique_ab_sequences.txt")

echo "\nFound ${UNIQUE_COUNT} unique sequences" | tee -a "${LOG_FILE}"
echo "\nUnique sequences saved to: ${INFO}/unique_ab_sequences.txt" | tee -a "${LOG_FILE}"

echo -e "Script Finished" | tee -a "${LOG_FILE}"
echo -e "__________________________________________________________________________\n" | tee -a "${LOG_FILE}"