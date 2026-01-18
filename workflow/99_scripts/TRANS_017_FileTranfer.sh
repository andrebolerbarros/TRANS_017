#!/bin/bash

# TRANS_017 File Transfer Script
# Purpose: Transfer files from source to 00_rawdata using rsync
# Date: 2026-01-09

MAIN="/ifs/igc/folders/ADA/SHARED"

LOG_DIR="${MAIN}/projects/BSSantos/TRANS_017/workflow/ZZ_logs"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="${LOG_DIR}/${TIMESTAMP}_FileTransfer.out"

mkdir -p ${LOG_DIR}

# --- input folder --- #
SOURCE_DIR="/ifs/igc/folders/ADA/SHARED/SD_20251120490007/X204SC25095469-Z01-F001_multipath/X204SC25095469-Z01-F001_01/01.RawData"

# --- output folder --- #
DEST_DIR="${MAIN}/projects/BSSantos/TRANS_017/data/00_rawdata"

# Create destination subdirectories
mkdir -p "${DEST_DIR}/00a_FB"
mkdir -p "${DEST_DIR}/00b_GEX"
mkdir -p "${DEST_DIR}/00c_VDJ"

#================ File Transfer Script Start =================#

echo -e "============================================================" | tee -a "${LOG_FILE}"
echo -e "                TRANS_017 - File Transfer Script            " | tee -a "${LOG_FILE}"
echo -e "============================================================" | tee -a "${LOG_FILE}"

echo -e "Log File: ${LOG_FILE}" | tee -a "${LOG_FILE}"

# ==== File Transfer - Feature Barcode ==== #

echo -e "~~~ File Transfer - Feature Barcode ~~~~" | tee -a "${LOG_FILE}"

echo "Feature Barcode - Starting rsync transfer at $(date +%Y-%m-%d_%H:%M:%S)" | tee -a "${LOG_FILE}"
time rsync -av ${SOURCE_DIR}/FB_* "${DEST_DIR}/00a_FB/" 2>&1 | tee -a "${LOG_FILE}"

# Check exit status
FB_STATUS=$?
echo "Feature Barcode - Transfer completed with exit status: ${FB_STATUS}" | tee -a "${LOG_FILE}"
echo "Feature Barcode - Finished at $(date +%Y-%m-%d_%H:%M:%S)" | tee -a "${LOG_FILE}"
echo "" | tee -a "${LOG_FILE}"

# ==== File Transfer - Gene Expression ==== #

echo -e "~~~ File Transfer - Gene Expression ~~~~" | tee -a "${LOG_FILE}"

echo "Gene Expression - Starting rsync transfer at $(date +%Y-%m-%d_%H:%M:%S)" | tee -a "${LOG_FILE}"
time rsync -av ${SOURCE_DIR}/GEX_* "${DEST_DIR}/00b_GEX/" 2>&1 | tee -a "${LOG_FILE}"

# Check exit status
GEX_STATUS=$?
echo "Gene Expression - Transfer completed with exit status: ${GEX_STATUS}" | tee -a "${LOG_FILE}"
echo "Gene Expression - Finished at $(date +%Y-%m-%d_%H:%M:%S)" | tee -a "${LOG_FILE}"
echo "" | tee -a "${LOG_FILE}"

# ==== File Transfer - VDJ Receptor ==== #

echo -e "~~~ File Transfer - VDJ Receptor ~~~~" | tee -a "${LOG_FILE}"

echo "VDJ Receptor - Starting rsync transfer at $(date +%Y-%m-%d_%H:%M:%S)" | tee -a "${LOG_FILE}"
time rsync -av ${SOURCE_DIR}/VDJ_* "${DEST_DIR}/00c_VDJ/" 2>&1 | tee -a "${LOG_FILE}"

# Check exit status
VDJ_STATUS=$?
echo "VDJ Receptor - Transfer completed with exit status: ${VDJ_STATUS}" | tee -a "${LOG_FILE}"
echo "VDJ Receptor - Finished at $(date +%Y-%m-%d_%H:%M:%S)" | tee -a "${LOG_FILE}"
echo "" | tee -a "${LOG_FILE}"

# ==== File Transfer - Undetermined ==== #

echo -e "~~~ File Transfer - Undetermined ~~~~" | tee -a "${LOG_FILE}"

echo "Undetermined - Starting rsync transfer at $(date +%Y-%m-%d_%H:%M:%S)" | tee -a "${LOG_FILE}"
time rsync -av ${SOURCE_DIR}/Undetermined "${DEST_DIR}/" 2>&1 | tee -a "${LOG_FILE}"

# Check exit status
UND_STATUS=$?
echo "Undetermined - Transfer completed with exit status: ${UND_STATUS}" | tee -a "${LOG_FILE}"
echo "Undetermined - Finished at $(date +%Y-%m-%d_%H:%M:%S)" | tee -a "${LOG_FILE}"
echo "" | tee -a "${LOG_FILE}"

# ==== Final Summary ==== #

echo "========================================" | tee -a "${LOG_FILE}"
echo "Transfer Summary:" | tee -a "${LOG_FILE}"
echo "Feature Barcode (FB):  Exit status ${FB_STATUS}" | tee -a "${LOG_FILE}"
echo "Gene Expression (GEX): Exit status ${GEX_STATUS}" | tee -a "${LOG_FILE}"
echo "VDJ Receptor (VDJ):    Exit status ${VDJ_STATUS}" | tee -a "${LOG_FILE}"
echo "Undetermined (UND):    Exit status ${UND_STATUS}" | tee -a "${LOG_FILE}"
echo "========================================" | tee -a "${LOG_FILE}"

# Exit with failure if any transfer failed
if [ ${FB_STATUS} -ne 0 ] || [ ${GEX_STATUS} -ne 0 ] || [ ${VDJ_STATUS} -ne 0 ]; then
    echo "ERROR: One or more transfers failed" | tee -a "${LOG_FILE}"
    exit 1
else
    echo "SUCCESS: All transfers completed successfully" | tee -a "${LOG_FILE}"
    exit 0
fi
