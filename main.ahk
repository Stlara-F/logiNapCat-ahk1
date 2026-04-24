#Include <FindText>
#SingleInstance Force
SetBatchLines, -1
CoordMode, Mouse, Screen
CoordMode, Pixel, Screen

WinCapture_mode := "DXGI"

GetBitsFromScreen2(bits, x, y, w, h) {
    global WinCapture_mode
    if (WinCapture_mode = "DXGI")
        return DXGI_Capture(bits, x, y, w, h)
    return 0
}

WinCapture_Load(DLLroot="") {
    if (DLLroot = "")
        DLLroot := A_ScriptDir "\" (A_PtrSize*8) "bit\wincapture.dll"
    if !(hModule := DllCall("LoadLibrary", "Str", DLLroot, "Ptr"))
        return 0
    return hModule
}

DXGI_Capture(bits, x, y, w, h) {
    static init, oldx, oldy, oldw, oldh
    if (!init) {
        if !WinCapture_Load()
            return 0
        hr := DllCall("wincapture\dxgi_start", "UInt")
        if (hr != 0) {
            return 0
        }
        oldx := 0, oldy := 0, oldw := 0, oldh := 0
        init := 1
    }

    VarSetCapacity(box, 16, 0)
    NumPut(x, box, 0, "Int")
    NumPut(y, box, 4, "Int")
    NumPut(x+w, box, 8, "Int")
    NumPut(y+h, box, 12, "Int")

    hr := DllCall("wincapture\dxgi_captureAndSave", "Ptr*", pdata:=0, "Ptr", &box, "UInt", 0, "UInt")
    if (hr = 0x887A0027 && x >= oldx && y >= oldy && x+w <= oldx+oldw && y+h <= oldy+oldh)
        return 1
    oldx := x, oldy := y, oldw := w, oldh := h
    
    if (hr != 0 || pdata = 0)
        return 0

    pBits   := NumGet(pdata+0, "Ptr")
    Pitch   := NumGet(pdata+A_PtrSize, "UInt")
    Width   := NumGet(pdata+A_PtrSize+4, "UInt")
    Height  := NumGet(pdata+A_PtrSize+8, "UInt")
    
    FindText().CopyBits(bits.Scan0, bits.Stride, x, y, pBits, Pitch, 0, 0, Min(w,Width), Min(h,Height))
    return 1
}

; ===================== Config =====================
ChromePath := "" ;Chrome path
MuMuPath := "C:\Program Files\Netease\MuMuPlayerGlobal-12.0\shell\MuMuPlayer.exe"   ;MuMu path
Account := "username"   ;container username
Password := "password"  ;container password
urlLogin := "http://<container-ip>:port/" ;url for login
urlLog := "http://<container-ip>:port/#!/3/docker/containers/<container-id>/logs"   ;url for log
urlRestart := "http://<container-ip>:port/#!/3/docker/containers/<container-id>"    ;url for restart

CHECK_DISCONNECT_INTERVAL := 10000
CHECK_QR_INTERVAL := 30000
SCAN_TASK_COOLDOWN := 60000 
RestartWait := 30000
ScanWait := 30000
CheckTimeout := 30000

TextUser := "|<>*85$28.zzzzzzzzzwwz01rrxvq21rjPfr01iDRvqvRrjMAr01itRvqvxbjPjqyxUzPvqv3DcTzzzzzzzzy"
TextLogin := "|<>*153$38.00000000000000AE000DtQ3zw06QE010X2800E6UQ3zw0zy0010M0M00EA01jzzazz00U0A0kM8830A3360k308q0Dzk0f00UQ1mM0AA1UVU120UM6DzzUw00000000000000U"
TextDisconnect := "|<>*139$35.zzzzzzyzvzSjRs0CxjPyvvsM0KBh7zSff7jyx07j3uvvyszqk08RTRbTTtxzBitqryEBDJTWzHtnzzzzzy"
TextRestartBtn := "|<>*114$16.zzzzzzzzz3TvpzT7vwzjzzzrwzTXvyjTv3zzzzzzzzy"
TextTimIcon :="|<>*178$41.zzzzzzzzU000Dzw00007zk00007zU00007y00000Dw00000Dk00000TU03s00z007k01y00DU03w00T007s00y00Dk41w10TUC3sD0z0zjny1y1zzzw3w3zzzs7s3zzzUDk1zzw0TU0Tz00z00Tw01y01zw03w03zw07s0Drs0Dk0z7s0TU3y7s0z07sDk1y07UDU3w070A07s00000Ds00000zk00001zk00007zk0000Tzk0001zzzy01zz"
TextTimPlus := "|<>*133$29.00M0000k0001U0003000060000A0000M0000k0001U00030000D007zzzwDzzzs01s0001U0003000060000A0000M0000k0001U00030000600E"
TextTimScan := "|<>*155$81.000000000000000000000000000000000000000001U0000000A0000A00000001U0001Vzy00000ADzk0ADzk00001Vzz01U0600000A00M3zU0k0000Ty030Tw0600001zU0M0A00k00001U0301U0600000A00M0A00k00001U0301U0600000A00M0ADzkzzzy1Uzz01xzy7zzzkDrzs1zU0k00007w030TU0600003w00M0A00k00001U0301U0600000A00M0A00k00001U0301U0600000A00M0A00k00001U0301Xzy00000ADzs0ADzk00001Vzz0DU0600001w00M1k00k0000700200000000000000000000000000000000000000000U"
TextTimCam :="|<>**50$23.0Q0S0c0g1ETM2Ujrx3Tsu4/yrxrlgPivTrRqUish1Zzy3z0001"
TextTimLogin :="|<>*159$51.zzzzzzzzzzzzzzzzzzyTzzzrryTnzz04QzlwTzs0E7z7Xzzz71rwQ03sssQznU0DWDW7zs03y3y1zz7Dzk00T1ltzy003s6TDzVUA70ztzkzzkTbzDw001Xwk01q007za007kzszwk01yDz7zbzDzlzszwztzy007zbzDzs00zwrtzzVwDzUzDzyTXzw7tzzlwTz3zDzyD7zsztzk000TjzDy0003zztzzzzzzzzzzzzzzU"
TextQR := "|<>*133$51.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz0000000zs0000007z0000000zs0000007z0000000zs0000007z0000000zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzs1zzzzzzz0Dzzzzzzs1zzzzzzz0Dzzzzzzs1zzzzzzz0Dzzzzzzs1w00007z0DU0000zs1w00007z0DU0000zs1w00007z0DU0000zs1w00007zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz0DU7zzwzs1w0zzzbz0DU7zzwzs1w0zzzbz0DU7zzwzs1w0zzzbz0DU7zzwzs1w0zzzbz0DU7zzwzs1w0zzzbz0DU7zzwzs1w0zzzbz0DU7zzwzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzs1w0zzzbz0DU7zzwzs1w0zzzbz0DU7zzwzs1w0zzzbz0DU7zzwzs1w00007z0DU0000U"

STATE := "IDLE"
BUSY := false
lastHeartbeat := A_TickCount
disconnectDetected := false
logBuffer := []
LOG_MAX_LINES := 300
lastScanTask := 0

lastCheckDisconnect := A_TickCount
lastCheckQR := A_TickCount
LogFile := A_ScriptDir . "\automation.log"

Gui +Resize +MinSize600x300 +AlwaysOnTop
Gui Font, s9, Consolas
Gui Add, Text, x10 y10 w580 h20 vStateText, State: Idle
Gui Add, Edit, x10 y35 w760 h420 vLogEdit ReadOnly -Wrap HScroll
Gui Show, w780 h470 Minimize, Automation Log
Log("Script started.")

Gosub MainStart 

F12::
    Log("Exit requested.")
    ExitApp
return

GuiClose:
    ExitApp

Log(msg)
{
    global LogFile, logBuffer, LOG_MAX_LINES

    FormatTime ts,, yyyy-MM-dd HH:mm:ss
    line := ts . " | " . msg

    logBuffer.Push(line)
    if (logBuffer.Length() > LOG_MAX_LINES)
        logBuffer.RemoveAt(1)

    FileAppend % line . "`r`n", %LogFile%

    GuiControl,, LogEdit, % JoinLines(logBuffer)
    GuiControl,, StateText, % "State: " . msg
}

JoinLines(arr)
{
    out := ""
    for k,v in arr
        out .= v . "`r`n"
    return out
}

FindStable(feat, count:=3, interval:=300)
{
    success := 0
    lastX := ""
    
    Loop %count%
    {
        ok := FindText(0,0,A_ScreenWidth,A_ScreenHeight,0,0,0,0,feat)
        if (!ok)
            return false

        x := ok[1].x
        
        if (lastX != "" && Abs(x - lastX) > 10)
            return false

        lastX := x
        success++
        Sleep %interval%
    }
    return ok
}

MainStart:
    Log("System starting...")

    if (!OpenChromeLogin(urlLogin))
    {
        Log("Chrome init failed.")
        Process, Close, chrome.exe
        Sleep 1000
        Sleep 5000
        Gosub MainStart
    }

    STATE := "MONITOR"

    SetTimer MonitorLoop, 1000
    SetTimer Watchdog, 10000
return

MonitorLoop:
    if (BUSY)
        return

    now := A_TickCount

    if (now - lastCheckDisconnect > CHECK_DISCONNECT_INTERVAL)
    {
        lastCheckDisconnect := now

        if (CheckLogDisconnect())
        {
            BUSY := true
            STATE := "RESTART"
            Log("Disconnect detected.")
            GoSub DoRestart
            return
        }
    }

    if (now - lastCheckQR > CHECK_QR_INTERVAL)
    {
        lastCheckQR := now

        if (now - lastScanTask < SCAN_TASK_COOLDOWN)
        {
            Log("Scan cooldown active, skip QR check.")
            return
        }

        if (CheckQRCode())
        {
            BUSY := true
            STATE := "SCAN"
            Log("QR detected.")
            GoSub DoScan
            return
        }
    }
return

CheckLogDisconnect()
{
    global TextDisconnect, disconnectDetected

    ok := FindStable(TextDisconnect, 2)

    if (ok && !disconnectDetected)
    {
        disconnectDetected := true
        return true
    }
    else if (!ok && disconnectDetected)
    {
        disconnectDetected := false
    }

    return false
}

CheckQRCode()
{
    global TextQR
    return FindStable(TextQR, 3)
}

DoRestart:
    Log("Executing restart task...")
    RestartContainer()
    FinishTask()
return

DoScan:
    lastScanTask := A_TickCount
    start := A_TickCount
    MAX := 1200000

    Log("Executing scan task...")

    Process, Exist, MuMuPlayer.exe
    if (ErrorLevel)
    {
        Log("Killing existing MuMu...")
        Process, Close, MuMuPlayer.exe
        Sleep 3000
    }

    if (!OperateMuMuAndTim_SAFE(start, MAX))
    {
        Log("Scan flow failed.")
    }

    FinishTask()
return

FinishTask()
{
    global BUSY, STATE, lastHeartbeat

    STATE := "MONITOR"
    BUSY := false
    lastHeartbeat := A_TickCount

    Log("Task finished, back to monitor.")
}

Watchdog:
    if (A_TickCount - lastHeartbeat > 900000)
    {
        Log("Watchdog: system stuck, reloading...")
        Reload
    }
return

OperateMuMuAndTim_SAFE(start, MAX)
{
    if (A_TickCount - start > MAX)
        return false

    OperateMuMuAndTim()
    return true
}

OpenChromeLogin(Url)
{
    global ChromePath, Account, Password, urlLog, TextUser, TextLogin

    if (ChromePath = "")
    {
        if FileExist("C:\Program Files\Google\Chrome\Application\chrome.exe")
            ChromePath := "C:\Program Files\Google\Chrome\Application\chrome.exe"
        else if FileExist("C:\Program Files (x86)\Google\Chrome\Application\chrome.exe")
            ChromePath := "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
        else
            ChromePath := chrome.exe
    }

    if (!FileExist(ChromePath))
    {
        Log("Chrome not found.")
        return false
    }

    Run %ChromePath% -incognito "%Url%", , , ChromePID
    Log("Chrome launched. PID=" . ChromePID)
    WinWait ahk_pid %ChromePID%, , 5
    if ErrorLevel
    {
        Log("Chrome window wait timeout.")
        return false
    }

    WinActivate ahk_pid %ChromePID%
    Sleep 8000

    ok := FindStable(TextUser, 2)
    if (!ok)
    {
        Log("Username input not found.")
        return false
    }

    x := ok[1].x
    y := ok[1].y
    Log("Username input found at " . x . "," . y)
    Click %x%, %y%
    Sleep 500
    Send ^a
    Sleep 300
    Send %Account%
    Sleep 500
    Send {Tab}
    Sleep 300
    Send %Password%
    Sleep 800

    okLogin := FindStable(TextLogin, 2)
    if (!okLogin)
    {
        Log("Login button not found.")
        return false
    }

    x := okLogin[1].x
    y := okLogin[1].y
    Log("Login button found at " . x . "," . y)
    Click %x%, %y%
    Sleep 3000

    Send ^l
    Sleep 1000
    Send ^a
    Sleep 500
    Clipboard := urlLog
    ClipWait 1
    Send ^v
    Sleep 800
    Send {Enter}
    Sleep 2000
    Send {Space}

    Log("Chrome navigation complete.")
    return true
}

RestartContainer()
{
    global urlRestart, urlLog, TextRestartBtn, RestartWait

    Log("Restarting container page.")
    WinActivate ahk_exe chrome.exe
    Sleep 1500

    Send ^l
    Sleep 1000
    Send ^a
    Sleep 500
    Clipboard := urlRestart
    ClipWait 1
    Send ^v
    Sleep 800
    Send {Enter}
    Sleep 8000

    ok := FindStable(TextRestartBtn, 2)
    if (ok)
    {
        x := ok[1].x
        y := ok[1].y
        Log("Restart button found at " . x . "," . y)
        Click %x%, %y%
        Sleep %RestartWait%
    }
    else
    {
        Log("Restart button not found.")
    }

    Send ^l
    Sleep 1000
    Send ^a
    Sleep 500
    Clipboard := urlLog
    ClipWait 1
    Send ^v
    Sleep 800
    Send {Enter}
    Sleep 8000
    Sleep 2000
    Send {Space}

    Log("Returned to log page.")
}

MoveWindowToQRAnchor()
{
    global TextQR

    WinWait Real-time screenshot ahk_class Qt5156QWindow ahk_exe MuMuPlayer.exe, , 25
    if ErrorLevel
    {
        Log("QR anchor window not found.")
        return false
    }

    WinActivate Real-time screenshot ahk_class Qt5156QWindow ahk_exe MuMuPlayer.exe
    WinWaitActive Real-time screenshot ahk_class Qt5156QWindow ahk_exe MuMuPlayer.exe, , 25
    Sleep 1000

    okQR := FindStable(TextQR, 2)
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
    Run %MuMuPath%

    WinWait ahk_exe MuMuPlayer.exe, , 120
    if ErrorLevel
    {
        Log("MuMu window not found.")
        return
    }

    WinActivate ahk_exe MuMuPlayer.exe
    WinSet AlwaysOnTop, On, ahk_exe MuMuPlayer.exe
    WinWaitActive ahk_exe MuMuPlayer.exe, , 90
    Log("MuMu window active.")

    Sleep 45000

    steps := [ {feat: TextTimIcon, label: "TIM icon"}
              , {feat: TextTimPlus, label: "Plus button"}
              , {feat: TextTimScan, label: "Scan button"}
              , {feat: TextTimCam, label: "Camera button"} ]
    
    currentStep := 1
    maxRetries := 3
    retryCount := 0

    Loop
    {
        rollbackStep := 0
        Loop % currentStep - 1
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
                return
            }
            Sleep 2000
            Continue
        }

        x := ok[1].x
        y := ok[1].y
        Log(label . " found at " . x . "," . y . ", clicking...")
        Click %x%, %y%
        Sleep 5000

        if (label = "Scan button")
        {
            Log("Waiting 3s for camera to load...")
            Sleep 3000
            stillExists := false
        }
        else if (label = "Plus button")
        {
            stillExists := !FindStable(TextTimScan, 3)
        }
        else if (label = "Camera button")
        {
            Log("Camera opened, starting QR window drag...")
            stillExists := false
        }
        else
        {
            stillExists := FindStable(feat, 3)
        }

        if (stillExists)
        {
            Log(label . " not completed, retrying...")
            retryCount++
            if (retryCount >= maxRetries)
            {
                Log("Max retries reached for " . label . ", exiting workflow.")
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
        return
    }

    WinActivate ahk_exe MuMuPlayer.exe
    WinWaitActive ahk_exe MuMuPlayer.exe, , 5
    Sleep 1000

    Log("Waiting for QR scan complete, searching login button...")
    ok := FindStable(TextTimLogin, 3, 2000) 

    if (!ok)
    {
        Log("Login button not found.")
        return
    }

    Loop, 3
    {
        x := ok[1].x
        y := ok[1].y
        Log("Clicking login button (Attempt " A_Index ") | Pos: " x "," y)
        Click %x%, %y%
        Sleep 2000
    }

    Sleep 75000

    WinSet AlwaysOnTop, Off, ahk_exe MuMuPlayer.exe
    Log("TIM flow completed.")

    Gosub CleanupMuMu
    return

CleanupMuMu:
    Log("Force closing MuMu emulator process...")
    Process, Close, MuMuPlayer.exe
    Process, WaitClose, MuMuPlayer.exe, 45
    Sleep 5000
    Log("MuMu closed successfully.")
return
}
