#Include <FindText>
#SingleInstance Force
SetBatchLines, -1
CoordMode, Mouse, Screen
CoordMode, Pixel, Screen
SendMode Input

WinCapture_mode := "DXGI"
GetBitsFromScreen2(bits, x, y, w, h) {
    global WinCapture_mode
    if (WinCapture_mode = "DXGI")
        return DXGI_Capture(bits, x, y, w, h)
    return 0
}

WinCapture_Load(DLLroot:="") {
    if (DLLroot = "")
        DLLroot := A_ScriptDir "\" (A_PtrSize*8) "bit\wincapture.dll"
    hModule := DllCall("LoadLibrary", "Str", DLLroot, "Ptr")
    return hModule ? hModule : 0
}

DXGI_Capture(bits, x, y, w, h) {
    static init, oldx, oldy, oldw, oldh
    if (!init) {
        if !WinCapture_Load()
            return 0
        hr := DllCall("wincapture\dxgi_start", "UInt")
        if (hr != 0)
            return 0
        oldx := 0, oldy := 0, oldw := 0, oldh := 0
        init := 1
    }

    VarSetCapacity(box, 16, 0)
    NumPut(x,     box, 0,  "Int")
    NumPut(y,     box, 4,  "Int")
    NumPut(x+w,   box, 8,  "Int")
    NumPut(y+h,   box, 12, "Int")

    hr := DllCall("wincapture\dxgi_captureAndSave", "Ptr*", pdata:=0, "Ptr", &box, "UInt", 0, "UInt")

    if (hr = 0x887A0027 && x >= oldx && y >= oldy && x+w <= oldx+oldw && y+h <= oldy+oldh)
        return 1

    oldx := x, oldy := y, oldw := w, oldh := h

    if (hr != 0 || pdata = 0)
        return 0

    pBits  := NumGet(pdata+0, "Ptr")
    Pitch  := NumGet(pdata+A_PtrSize, "UInt")
    Width  := NumGet(pdata+A_PtrSize+4, "UInt")
    Height := NumGet(pdata+A_PtrSize+8, "UInt")

    FindText().CopyBits(bits.Scan0, bits.Stride, x, y, pBits, Pitch, 0, 0, Min(w, Width), Min(h, Height))
    return 1
}

ChromePath := ""
NC_TOKEN := "xx"
QQ_NUMBER := "123"
QQ_PASSWORD := "xx"
WEBUI_URL := "http://<your-nc-ip>:6099/webui?token="NC_TOKEN
MuMuPath := "C:\Program Files\Netease\MuMuPlayerGlobal-12.0\shell\MuMuPlayer.exe"

CLOSE_CHROME_DELAY := 3000
LAUNCH_WAIT := 8000
CLICK_DELAY := 1000
INPUT_DELAY := 500
CONSOLE_DELAY := 2000
RETRY_DELAY := 300
FIND_RETRY := 5
ScanWait := 15000
CHECK_DISCONNECT_INTERVAL := 30000
CHECK_QR_INTERVAL := 45000
SCAN_TASK_COOLDOWN := 90000
SCAN_MAX_TIMEOUT := 120000

TextPwdLogin := "|<>*181$43.000000000M000000C003zkTzzry0EA20MMM861VAAAA0qPs4660P766330NiNXt10AwAnAzw0s63a063by1n0330009U1U0804rykA462M0E6231w08311Ua0A1zzkH1w000M00000000008" 
TextPwdLoginQRcode :="|<>*127$25.00000000000000000000000000000000001zzs0zzw0Tzy0Dzz07U003k001s000w000S000D1z07UzU3kTk1sDs0w7w0S3y0D1z07Uzk" 

TextTimIcon :="|<>*178$41.zzzzzzzzU000Dzw00007zk00007zU00007y00000Dw00000Dk00000TU03s00z007k01y00DU03w00T007s00y00Dk41w10TUC3sD0z0zjny1y1zzzw3w3zzzs7s3zzzUDk1zzw0TU0Tz00z00Tw01y01zw03w03zw07s0Drs0Dk0z7s0TU3y7s0z07sDk1y07UDU3w070A07s00000Ds00000zk00001zk00007zk0000Tzk0001zzzy01zz" 
TextTimPlus := "|<>*133$29.00M0000k0001U0003000060000A0000M0000k0001U00030000D007zzzwDzzzs01s0001U0003000060000A0000M0000k0001U00030000600E"
TextTimScan := "|<>*155$81.000000000000000000000000000000000000000001U0000000A0000A00000001U0001Vzy00000ADzk0ADzk00001Vzz01U0600000A00M3zU0k0000Ty030Tw0600001zU0M0A00k00001U0301U0600000A00M0A00k00001U0301U0600000A00M0ADzkzzzy1Uzz01xzy7zzzkDrzs1zU0k00007w030TU0600003w00M0A00k00001U0301U0600000A00M0A00k00001U0301U0600000A00M0A00k00001U0301Xzy00000ADzs0ADzk00001Vzz0DU0600001w00M1k00k0000700200000000000000000000000000000000000000000U" 
TextTimCam :="|<>**50$23.0Q0S0c0g1ETM2Ujrx3Tsu4/yrxrlgPivTrRqUish1Zzy3z0001"
TextTimLogin :="|<>*159$51.zzzzzzzzzzzzzzzzzzyTzzzrryTnzz04QzlwTzs0E7z7Xzzz71rwQ03sssQznU0DWDW7zs03y3y1zz7Dzk00T1ltzy003s6TDzVUA70ztzkzzkTbzDw001Xwk01q007za007kzszwk01yDz7zbzDzlzszwztzy007zbzDzs00zwrtzzVwDzUzDzyTXzw7tzzlwTz3zDzyD7zsztzk000TjzDy0003zztzzzzzzzzzzzzzzU"

STATE := "IDLE"
BUSY := false
lastHeartbeat := A_TickCount
logBuffer := []
LOG_MAX_LINES := 300
lastCheckDisconnect := A_TickCount
lastCheckQR := A_TickCount
lastScanTask := 0
LogFile := A_ScriptDir . "\napcat_auto.log"
disconnectDetected := false
QR_WINDOW := "Real-time screenshot ahk_class Qt5156QWindow ahk_exe MuMuPlayer.exe"

Gui +Resize +MinSize600x300 +AlwaysOnTop
Gui Font, s9, Consolas
Gui Add, Text, x10 y10 w580 h20 vStateText, State: Idle
Gui Add, Edit, x10 y35 w760 h420 vLogEdit ReadOnly -Wrap HScroll
Gui Show, w780 h470 Minimize, NapCat Auto Log
Log("Script started.")

Gosub, MainStart

F12::
    Log("Exit requested.")
    ExitApp
return

GuiClose:
    ExitApp
return

Log(msg) {
    global LogFile, logBuffer, LOG_MAX_LINES, STATE
    FormatTime, ts,, yyyy-MM-dd HH:mm:ss
    line := ts . " | " msg

    logBuffer.Push(line)
    if (logBuffer.Length() > LOG_MAX_LINES)
        logBuffer.RemoveAt(1)

    FileAppend, %line%`r`n, %LogFile%
    GuiControl,, LogEdit, % JoinLines(logBuffer)
    GuiControl,, StateText, % "State: " . STATE . " | " . msg
}

JoinLines(arr) {
    out := ""
    for k, v in arr
        out .= v . "`r`n"
    return out
}

FindStable(feat, count=3, interval=300) {
    lastX := ""
    Loop, %count% {
        ok := FindText(0, 0, A_ScreenWidth, A_ScreenHeight, 0, 0, 0, 0, feat)
        if (!ok)
            return false

        x := ok[1].x
        if (lastX != "" && Abs(x - lastX) > 10)
            return false

        lastX := x
        Sleep, %interval%
    }
    return ok
}

ClickStable(feat, count=2, interval=300, afterSleep=0) {
    ok := FindStable(feat, count, interval)
    if (!ok)
        return false

    Click, % ok[1].x "," ok[1].y
    if (afterSleep > 0)
        Sleep, %afterSleep%
    return true
}

MainStart:
    StartMain()
return

StartMain() {
    global ChromePath, WEBUI_URL, CLOSE_CHROME_DELAY, LAUNCH_WAIT
    global QQ_NUMBER, QQ_PASSWORD, TextPwdLogin

    Log("System starting...")
    SetTimer, MonitorLoop, 1000
    SetTimer, Watchdog, 10000

    Process, Close, chrome.exe
    Process, WaitClose, chrome.exe, 5
    Sleep, %CLOSE_CHROME_DELAY%

    if (ChromePath = "") {
        if FileExist("C:\Program Files\Google\Chrome\Application\chrome.exe")
            ChromePath := "C:\Program Files\Google\Chrome\Application\chrome.exe"
        else if FileExist("C:\Program Files (x86)\Google\Chrome\Application\chrome.exe")
            ChromePath := "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
        else
            ChromePath := "chrome.exe"
    }

    Run, "%ChromePath%" --incognito "%WEBUI_URL%", , , ChromePID
    WinWait, ahk_pid %ChromePID%, , 20
    if ErrorLevel {
        Log("Chrome launch timeout, retrying...")
        Sleep, %RETRY_DELAY%
        StartMain()
        return
    }

    WinActivate, ahk_pid %ChromePID%
    Sleep, %LAUNCH_WAIT%

    if (!ClickStable(TextPwdLogin, 5, 300, 1000)) {
        Log("Login button not found, retrying")
        StartMain()
        return
    }

    Send, {Tab}
    Sleep, %INPUT_DELAY%
    SendInput, %QQ_NUMBER%
    Send, {Tab 2}
    Sleep, %INPUT_DELAY%
    SendInput, %QQ_PASSWORD%
    Send, {Tab}
    Sleep, %INPUT_DELAY%
    Send, {Enter}

    Log("Account login completed")
    Sleep, %LAUNCH_WAIT%

    JS_CODE =
    (
const panel = document.querySelector('.flex.flex-col.items-center.gap-3');
if (panel) {
    document.body.innerHTML = '';
    document.body.appendChild(panel);
    document.body.style.display = 'flex';
    document.body.style.justifyContent = 'flex-start';
    document.body.style.alignItems = 'flex-end';
    document.body.style.minHeight = '100vh';
    panel.style.margin = '40px';
}
    )

    Send, ^+i
    Sleep, %CONSOLE_DELAY%
    Sleep, 2000
    Send, ^v
    SendInput, allow pasting
    Send, {Enter}
    Sleep, 200
    clipboard := JS_CODE
    ClipWait, 1
    Sleep, 500
    Send, ^v
    Sleep, 1000
    Send, ^{Enter}

    Log("JS injection completed")
    STATE := "MONITOR"
}

MonitorLoop:
    MonitorLoopTick()
return

MonitorLoopTick() {
    global BUSY, STATE, lastHeartbeat
    global lastCheckDisconnect, lastCheckQR, lastScanTask
    global CHECK_DISCONNECT_INTERVAL, CHECK_QR_INTERVAL, SCAN_TASK_COOLDOWN

    if (BUSY)
        return

    lastHeartbeat := A_TickCount
    now := A_TickCount

    if (now - lastCheckDisconnect > CHECK_DISCONNECT_INTERVAL) {
        lastCheckDisconnect := now
        if (CheckLogDisconnect()) {
            BUSY := true
            STATE := "RESTART"
            Log("Disconnect detected.")
            DoRestart()
            return
        }
    }

    if (now - lastCheckQR > CHECK_QR_INTERVAL) {
        lastCheckQR := now
        if (now - lastScanTask < SCAN_TASK_COOLDOWN) {
            Log("Scan cooldown active, skip QR check.")
            return
        }

        if (CheckPwdLoginQR()) {
            BUSY := true
            STATE := "SCAN"
            Log("QR detected.")
            DoScan()
            return
        }
    }
}

CheckPwdLoginQR() {
    global TextPwdLoginQRcode
    return FindStable(TextPwdLoginQRcode, 3)
}

CheckLogDisconnect() {
    global ChromePID, disconnectDetected
    if (!ChromePID)
        return false

    isExist := WinExist("ahk_pid " . ChromePID)
    if (!isExist && !disconnectDetected) {
        disconnectDetected := true
        return true
    } else if (isExist && disconnectDetected)
        disconnectDetected := false
    return false
}

DoRestart() {
    global lastHeartbeat
    lastHeartbeat := A_TickCount
    Log("Restarting service...")
    FinishTask()
}

DoScan() {
    global lastScanTask, lastHeartbeat, SCAN_MAX_TIMEOUT
    lastScanTask := A_TickCount
    lastHeartbeat := A_TickCount

    Log("Executing scan task...")

    Process, Exist, MuMuPlayer.exe
    if (ErrorLevel) {
        Log("Killing existing MuMu process...")
        Process, Close, MuMuPlayer.exe
        Sleep, 3000
    }

    if (!OperateMuMuAndTim_SAFE(A_TickCount, SCAN_MAX_TIMEOUT))
        Log("Scan flow failed!")

    FinishTask()
}

OperateMuMuAndTim_SAFE(start, MAX) {
    if (A_TickCount - start > MAX)
        return false
    OperateMuMuAndTim()
    return true
}

MoveWindowToQRAnchor()
{
    global TextPwdLoginQRcode

    WinWait Real-time screenshot ahk_class Qt5156QWindow ahk_exe MuMuPlayer.exe, , 25
    if ErrorLevel
    {
        Log("QR anchor window not found.")
        return false
    }

    WinActivate Real-time screenshot ahk_class Qt5156QWindow ahk_exe MuMuPlayer.exe
    WinWaitActive Real-time screenshot ahk_class Qt5156QWindow ahk_exe MuMuPlayer.exe, , 25
    Sleep 1000

    okQR := FindStable(TextPwdLoginQRcode, 2)
    if (!okQR)
    {
        Log("QR anchor not found.")
        return false
    }

    qrX := okQR[1].x
    qrY := okQR[1].y
    targetX := qrX - 150
    targetY := qrY - 100

    Log("Dragging window to " . targetX . "," . targetY)

    WinGetPos winX, winY, winW, winH, Real-time screenshot ahk_class Qt5156QWindow ahk_exe MuMuPlayer.exe
    
    titleBarOffsetX := 50
    titleBarOffsetY := 10
    
    startX := winX + titleBarOffsetX
    startY := winY + titleBarOffsetY
    endX := targetX + titleBarOffsetX
    endY := targetY + titleBarOffsetY

    MouseMove %startX%, %startY%, 20
    Sleep 100
    Click down left
    Sleep 100
    
    MouseMove %endX%, %endY%, 100
    Sleep 100
    
    Click up left
    Sleep 1000

    return true
}

OperateMuMuAndTim()
{
    global MuMuPath, TextTimIcon, TextTimPlus, TextTimScan, TextTimCam, TextTimLogin, ScanWait

    Log("Launching MuMu emulator.")
    Run, %MuMuPath%

    WinWait, ahk_exe MuMuPlayer.exe, , 120
    if ErrorLevel
    {
        Log("MuMu window not found.")
        return
    }

    WinActivate, ahk_exe MuMuPlayer.exe
    WinSet, AlwaysOnTop, On, ahk_exe MuMuPlayer.exe
    WinWaitActive, ahk_exe MuMuPlayer.exe, , 90
    Log("MuMu window active.")

    Sleep, 45000

    steps := [ {feat: TextTimIcon, label: "TIM icon"}
              , {feat: TextTimPlus, label: "Plus button"}
              , {feat: TextTimScan, label: "Scan button"}
              , {feat: TextTimCam, label: "Camera button"} ]
    
    currentStep := 1
    maxRetries := 5
    retryCount := 0

    Loop
    {
        rollbackStep := 0
        Loop, % currentStep - 1
        {
            checkStep := A_Index
            if (checkStep = 1 || checkStep = 2)
                Continue
            if (FindStable(steps[checkStep].feat, 1))
            {
                rollbackStep := checkStep
                break
            }
        }

        if (rollbackStep > 0)
        {
            Log("Detected rollback to " . steps[rollbackStep].label . ", resetting workflow.")
            currentStep := rollbackStep
            retryCount := 0
        }

        feat := steps[currentStep].feat
        label := steps[currentStep].label

        Log("Processing step " . currentStep . "/" . steps.Length() . ": " . label . " (Attempt " . (retryCount+1) . "/" . maxRetries . ")")

        ok := FindStable(feat, 2)
        if (!ok)
        {
            Log(label . " not found.")
            retryCount++
            if (retryCount >= maxRetries)
            {
                Log("Max retries reached for " . label . ", exiting workflow.")
                CleanupMuMu()
                return
            }
            Sleep, 2000
            Continue
        }

        x := ok[1].x
        y := ok[1].y
        Log(label . " found at " . x . "," . y . ", clicking...")
        Click, %x%, %y%
        Sleep, 5000

        if (label = "Scan button")
        {
            Log("Waiting 5s for camera to load...")
            Sleep, 5000
            stillExists := false
        }
        else if (label = "Plus button")
        {
            stillExists := !FindStable(TextTimScan, 5)
        }
        else if (label = "Camera button")
        {
            Log("Camera opened, starting QR window drag...")
            stillExists := false
        }
        else
        {
            stillExists := FindStable(feat, 5)
        }

        if (stillExists)
        {
            Log(label . " not completed, retrying...")
            retryCount++
            if (retryCount >= maxRetries)
            {
                Log("Max retries reached for " . label . ", exiting workflow.")
                CleanupMuMu()
                return
            }
        }
        else
        {
            Log(label . " completed, moving to next step.")
            currentStep++
            retryCount := 0
            
            if (currentStep > steps.Length())
            {
                Log("All MuMu steps completed successfully.")
                break
            }
        }
    }

    Log("Aligning QR anchor.")
    if (!MoveWindowToQRAnchor())
    {
        Log("MoveWindowToQRAnchor failed.")
        CleanupMuMu()
        return
    }

    WinActivate, ahk_exe MuMuPlayer.exe
    WinWaitActive, ahk_exe MuMuPlayer.exe, , 5
    Sleep, 1000

    Log("Waiting for QR scan complete, searching login button...")
    loginTimeout := 30
    startTime := A_TickCount
    ok := ""
    while (A_TickCount - startTime < loginTimeout * 1000)
    {
        attempt := FindStable(TextTimLogin, 1)
        if (attempt)
        {
            Sleep, 1000
            ok := FindStable(TextTimLogin, 2, 2000)
            if (ok)
            {
                Log("Login button appeared at " . ok[1].x . "," . ok[1].y)
                break
            }
        }
        Sleep, 2000
    }

    if (!ok)
    {
        Log("Login button not found within " . loginTimeout . " seconds.")
        CleanupMuMu()
        return
    }

    Loop, 5
    {
        fresh := FindStable(TextTimLogin, 1)
        if (!fresh)
        {
            Log("Login button disappeared, assuming login success.")
            break
        }
        x := fresh[1].x
        y := fresh[1].y
        Log("Clicking login button (Attempt " . A_Index . ") | Pos: " . x . "," . y)
        Click, %x%, %y%
        Sleep, 2000
    }

    Sleep, 75000

    WinSet, AlwaysOnTop, Off, ahk_exe MuMuPlayer.exe
    Log("TIM flow completed.")

    CleanupMuMu()
    return
}

CleanupMuMu()
{
    Log("Force closing MuMu emulator process...")
    Process, Close, MuMuPlayer.exe
    Process, WaitClose, MuMuPlayer.exe, 45
    Sleep, 5000
    Log("MuMu closed successfully.")
}

FinishTask() {
    global BUSY, STATE, lastHeartbeat
    STATE := "MONITOR"
    BUSY := false
    lastHeartbeat := A_TickCount
    Log("Back to monitor mode")
}

Watchdog:
    WatchdogTick()
return

WatchdogTick() {
    global lastHeartbeat
    if (A_TickCount - lastHeartbeat > 900000) {
        Log("Watchdog: System stuck, reloading...")
        Reload
    }
}
