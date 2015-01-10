#!/bin/bash

# Check if argument ($1) is a valid year (4 digits starting with 19 or 20)
[[ $1 =~ ^(19|20)[0-9]{2}$ ]] && YEAR=$1
# If argument is not present or is invalid, use year 2014
[[ -z $YEAR ]] && YEAR=2014


#http://www.cetip.com.br/astec/series_v05/paginas/taxadi_i1.htm
URL=ftp://ftp.cetip.com.br/MediaCDI

CSV_FILE=CDI_${YEAR}.csv

OFFSET=86400  # 24*60*60
INITIAL_TS=$(date -j -f "%Y-%m-%d %H:%M:%S" "${YEAR}-01-01 00:00:00" "+%s")
TODAY=$(date "+%Y-%m-%d")
TODAY_TS=$(date -j -f "%Y-%m-%d %H:%M:%S" "${TODAY} 00:00:00" "+%s")
END_TS=$((TODAY_TS + OFFSET))

echo "Date,CDI" > ${CSV_FILE}

CURRENT_TS=$INITIAL_TS
while [[ "${CURRENT_TS}" -le "${END_TS}" ]] ; do
    CURRENT_DATE=$(date -j -f "%s" "${CURRENT_TS}" "+%Y%m%d")
    FILENAME=${CURRENT_DATE}.txt

    # Download file only if it does not exist and if day is not Saturday (6) nor Sunday (7)
    [[ ! -e ${FILENAME} && $(date -j -f "%s" "${CURRENT_TS}" "+%u") -lt 6 ]] && wget -q "${URL}/${FILENAME}"

    [[ -e ${FILENAME} ]] && echo -n "${CURRENT_DATE}," >> ${CSV_FILE}
    [[ -e ${FILENAME} ]] && cat "${FILENAME}" >> ${CSV_FILE}

    CURRENT_TS=$((CURRENT_TS + OFFSET))
done