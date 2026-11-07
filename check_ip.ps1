$Host.UI.RawUI.WindowTitle = "IP Checker - Gemini & Antigravity"

function Write-Header {
    Clear-Host
    Write-Host ""
    Write-Host "  +=========================================================+" -ForegroundColor DarkCyan
    Write-Host "  |        IP CHECKER  --  Gemini  vs  Antigravity          |" -ForegroundColor Cyan
    Write-Host "  +=========================================================+" -ForegroundColor DarkCyan
    Write-Host ""
}

function Get-MyIP {
    Write-Host "  Checking external IP..." -ForegroundColor DarkYellow
    $ip = $null
    try { $ip = Invoke-RestMethod "https://ipinfo.io/json" -TimeoutSec 6 } catch {}
    if (-not $ip) {
        try { $ip = Invoke-RestMethod "https://ipapi.co/json/" -TimeoutSec 6 } catch {}
    }
    if (-not $ip) {
        Write-Host "  [X] No internet connection or blocked." -ForegroundColor Red
        return $null
    }
    Write-Host ""
    Write-Host ("  IP:       {0}" -f $ip.ip) -ForegroundColor White
    Write-Host ("  Country:  {0} / {1} / {2}" -f $ip.country, $ip.region, $ip.city) -ForegroundColor White
    Write-Host ("  Provider: {0}" -f $ip.org) -ForegroundColor White
    Write-Host ""
    return $ip
}

function Test-Endpoint($url) {
    try {
        $req = [System.Net.HttpWebRequest]::Create($url)
        $req.Timeout = 6000
        $req.UserAgent = "Mozilla/5.0"
        $req.AllowAutoRedirect = $true
        $resp = $req.GetResponse()
        $code = [int]$resp.StatusCode
        $resp.Close()
        return @{ ok = $true; code = $code; note = "Reachable" }
    } catch [System.Net.WebException] {
        if ($_.Response -ne $null) {
            $code = [int]$_.Response.StatusCode
            $_.Response.Close()
            # 403 = GeoBlocked / Forbidden!
            if ($code -eq 403) {
                return @{ ok = $false; code = 403; note = "403 GEOBLOCKED" }
            }
            # 400, 404, 405 etc. mean server is alive and reachable
            return @{ ok = $true; code = $code; note = "HTTP $code (Reachable)" }
        }
        return @{ ok = $false; code = 0; note = "Connection failed / Timeout" }
    } catch {
        return @{ ok = $false; code = 0; note = $_.Exception.Message }
    }
}

function Show-Row($label, $res) {
    if ($res.ok) {
        Write-Host "    " -NoNewline
        Write-Host " OK  " -NoNewline -BackgroundColor DarkGreen -ForegroundColor White
        Write-Host "  $label" -ForegroundColor Gray
    } else {
        Write-Host "    " -NoNewline
        Write-Host " ERR " -NoNewline -BackgroundColor DarkRed -ForegroundColor White
        Write-Host "  $label" -ForegroundColor DarkGray
        Write-Host "          └─ $($res.note)" -ForegroundColor Red
    }
}

function Show-Verdict($label, $ok) {
    Write-Host ""
    Write-Host "    " -NoNewline
    if ($ok) {
        Write-Host "  $label  -->  WORKS  " -BackgroundColor DarkGreen -ForegroundColor White
    } else {
        Write-Host "  $label  -->  BLOCKED / NOT WORKING  " -BackgroundColor DarkRed -ForegroundColor White
    }
    Write-Host ""
}

function Run-Checks {
    # === GEMINI ===
    Write-Host "  --[ GEMINI  (browser + API) ]" -ForegroundColor Magenta
    Write-Host ("  " + "-"*55) -ForegroundColor DarkGray
    Write-Host ""

    $g1 = Test-Endpoint "https://gemini.google.com/"
    $g2 = Test-Endpoint "https://generativelanguage.googleapis.com/"
    $g3 = Test-Endpoint "https://accounts.google.com/"

    Show-Row "gemini.google.com                  (Gemini web UI)" $g1
    Show-Row "generativelanguage.googleapis.com  (Gemini model API)" $g2
    Show-Row "accounts.google.com                (Google auth)" $g3

    $geminiOk = $g1.ok -and $g2.ok -and $g3.ok
    Show-Verdict "GEMINI" $geminiOk

    # === ANTIGRAVITY ===
    Write-Host "  --[ ANTIGRAVITY  (AGY IDE) ]" -ForegroundColor Cyan
    Write-Host ("  " + "-"*55) -ForegroundColor DarkGray
    Write-Host ""

    $a1 = Test-Endpoint "https://antigravity.google.com/"
    $a2 = Test-Endpoint "https://cloudcode-pa.googleapis.com/"
    $a3 = Test-Endpoint "https://oauth2.googleapis.com/"
    $a4 = Test-Endpoint "https://generativelanguage.googleapis.com/"

    Show-Row "antigravity.google.com             (AGY service)" $a1
    Show-Row "agy-backend.googleapis.com         (AGY IDE backend)" $a2
    Show-Row "oauth2.googleapis.com              (AGY auth tokens)" $a3
    Show-Row "generativelanguage.googleapis.com  (model API, shared)" $a4

    $agyOk = $a1.ok -and $a2.ok -and $a3.ok -and $a4.ok
    Show-Verdict "ANTIGRAVITY" $agyOk

    # === SUMMARY ===
    Write-Host "  +=========================================================+" -ForegroundColor DarkCyan
    if ($geminiOk -and $agyOk) {
        Write-Host "  |  OK: Both GEMINI and ANTIGRAVITY work on this IP!      |" -ForegroundColor Green
    } elseif ($geminiOk -and (-not $agyOk)) {
        Write-Host "  |  Gemini OK  |  Antigravity BLOCKED                     |" -ForegroundColor Yellow
        Write-Host "  |  --> AGY backend blocked. Switch VPN server/region.    |" -ForegroundColor DarkYellow
    } elseif ((-not $geminiOk) -and $agyOk) {
        Write-Host "  |  Gemini BLOCKED  |  Antigravity OK                     |" -ForegroundColor Yellow
    } else {
        Write-Host "  |  Both BLOCKED on this IP. Enable or switch VPN.        |" -ForegroundColor Red
    }
    Write-Host "  +=========================================================+" -ForegroundColor DarkCyan
}

# MAIN LOOP
while ($true) {
    Write-Header
    $ipInfo = Get-MyIP
    if ($ipInfo -ne $null) {
        Run-Checks
    }
    Write-Host ""
    Write-Host "  [R] Check again (Enter)    [Q] Quit" -ForegroundColor DarkCyan
    Write-Host ""
    Write-Host "  > " -NoNewline -ForegroundColor Cyan

    $gotKey = $false
    while (-not $gotKey) {
        $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        $vk = $key.VirtualKeyCode
        if ($vk -eq 81) { # Q
            Write-Host ""
            Write-Host "  Bye!" -ForegroundColor DarkGray
            Start-Sleep -Milliseconds 600
            exit 0
        }
        if ($vk -eq 82 -or $vk -eq 13) { # R or Enter / К на русской раскладке
            $gotKey = $true
        }
    }
}