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
RestartWait := 30000
ScanWait := 30000
CheckTimeout := 30000

; ===================== Feature codes =====================
TextUser := "|<>**50$36.1lkzzUvHEU0jCyyjScg62jSfRpuU0exHejSfBqujSco7OU0fxpejSeRIudGuho/dGqo7vNSoxq7FEg7TxlzsU"
TextLogin := "|<>**50$40.0000000000000008k0003yq1zy00NX0080X6M00U1sD1zy03zE0080M0k00U300rzzkPzs040080UMEM0U20lX020807s0DzU0q00E00RA00UkC4A0361UEA7zzkD000000008"
TextDisconnect := "|<>**50$49.000s1kCTTzrITjp+s0+u80CZjvzhziyy70503MqoTiuyxff7jk13Ok1vkfiVLTjvXo0Fhc08RGvtiprruRh1huqvbPtzgxEBDJX0gFjoyQk"
TextRestartBtn := "|<>**50$44.00000000003zsS07z0U3wy3XETjk0VjI405zcqN1ivTuD7k80k0Wlw2vhzsyB0U3E2DXkDjpyWNg20BTcfq1yyk2/70E0ByXzU7zzku"
TextTimIcon :="|<>**30$55.00000000001zzzzzy007zzzzzzk07000000S0C0000003UA0000000M600000006600000003200000000n01zzzzs0N03zzzzy0AU3k0007k2E3U0000s1c3U0000C0o1U000030O0k00001kB0E01w00s6U801y00Q3E400n0061c200NU030o100Ak01UO0U06M00kB0E63A3UM6U87laDkA3E43znzw61c23btyC30o11s0071UO0UT00TUkB0E3y1y0M6U80D0s0A3E403UM061c201UA030o101nr01UO0U1ntk0kB0E0niQ0M6U80vXi0A3E40tUvU61c20DkTU30o103k7U3UO0k0k1U1kB0M00000k6UC00000s3E300000w1c1k0000w0o0T0000w0O03zw0Dw0NU0Tz07k0AE001s3006A000S1U0660003Uk071U000wM030M000DA03070001y0700w000T0S003zzzzzs000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001z3Vk00001zzvw00000UPjq00000Sxrn00000DSttU00001jRxk00000rigM00000PrKg00000Bvjq000006xqP000003SvBU00001zzzk00000zzzs000000000008"
TextTimPlus := "|<>**75$30.000000000000A0000A0000C0000C0000C0000C0000C0000C0000C0000C0000C007zzzwDzzzwDzzzw00S0000C0000C0000C0000C0000C0000C0000C0000C0000C0000C0000A000000000000U"
TextTimScan := "|<>*162$137.000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001zzzzs000000000000000003zzzzk0000A00000001U0007zzzzU0000M000000030000Dzzzz00000kzz0000067zs0Tzzzy00001Xzy00000ADzs0zzzzw0000300A00000M00k1zzzzs0001zk0M0000Dz01U3zzzzk0003zU0k0000Dw0307zzzzU0000M01U000030060Dzzzz00000k0300000600A0Tzzzy00001U0600000A00M0zzzzw0000300A00000M01k000000000067zszzzz0kTzU0000000000Djzkzzzy1yzz00000000003z01U0000Ts060zzzzzk000Dk0300001y00A1zzzzzU0001U0600000A00M0000000000300A00000M00k0000000000600M00000k01U0000000000A00k00001U03060001U0000M01U0000300C0A000300000lzz0000067zw0M000600003Xzy00000ADzs0k000A0000T00A00003s00k1U000M0000w00M00003U0103U000k000000000000000007zzzzU00000000000000000Dzzzz00000000000000000000000000000000000000000000000000000000000000000000000000000000000001"
TextTimCam :="|<>*155$22.zzzy1zUM7y1bzzaTzyNzztbzzbzzzzzzzzzzy000M001zzzzzzzzzzzbzzaTzyNzztbzza1zUM7y1zzzy"
TextTimLogin :="|<>*162$103.zzzzzzzzzzzzzzzzzzwTzzznzzzyyzzzzzzyDzzDtzzU2CTzzzzzyDzzXwzzk1UDw001zz7zzswTzzssSz000zz7nzyC01wQQCTzzwTz7szzb00T4T4DzzyTzbyTzz00TkTkDs00DzXz7zzbbzs00Dy007zXzVy3Xnzw007zzznzU00T0ntzwTzUzzztzU00DUTwzsTzsC0007k03XzDyTs00370001zlltza00Cs00zk001zsszzn003wTwTwz7nzwQTztU03yTyDy7XlzyCDzwztzzDz7zVkkzzD7zyTwzzU03zss1zzbXxzDyTzk01zzM1zzXlyTazDzwDVzzUEzznszDkTbzzDlzz0ADzlwTbsDnzzXszy1b3zVzDXsTtzztwzw7nkD1zU1wTwzs000CDty71zk1zTyTw0007z0znnzzzzzzDzzzzzzUTzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzy"
TextQR := "|<>*139$53.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzU000000Dz0000000Ty0000000zw0000001zs0000003zk0000007zU000000Dzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzk7zzzzzzzUDzzzzzzz0Tzzzzzzy0zzzzzzzw1zzzzzzzs3zzzzzzzk7w00007zUDs0000Dz0Tk0000Ty0zU0000zw1z00001zs3y00003zk7w00007zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzs3y0zzzvzk7w1zzzrzUDs3zzzjz0Tk7zzzTy0zUDzzyzw1z0Tzzxzs3y0zzzvzk7w1zzzrzUDs3zzzjz0Tk7zzzTy0zUDzzyzw1z0Tzzxzs3y0zzzvzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw1z0Tzzxzs3y0zzzvzk7w1zzzrzUDs3zzzjz0Tk7zzzTy0zUDzzyzw1z00001"

; ===================== Global state =====================
lastCheckDisconnect := A_TickCount
lastCheckQR := A_TickCount
LogFile := A_ScriptDir . "\automation.log"

; ===================== GUI =====================
Gui +Resize +MinSize600x300 +AlwaysOnTop
Gui Font, s9, Consolas
Gui Add, Text, x10 y10 w580 h20 vStateText, State: Idle
Gui Add, Edit, x10 y35 w760 h420 vLogEdit ReadOnly -Wrap HScroll
Gui Show, w780 h470, Automation Log
Log("Script started.")

; ===================== Hotkeys =====================
F8::
    Log("Manual run requested.")
    Gosub MainStart
return

F12::
    Log("Exit requested.")
    ExitApp
return

GuiClose:
    ExitApp

; ===================== Helpers =====================
Log(msg)
{
    global LogFile
    FormatTime ts,, yyyy-MM-dd HH:mm:ss
    line := ts . " | " . msg . "`r`n"
    FileAppend %line%, %LogFile%

    GuiControlGet old,, LogEdit
    newText := old . line
    GuiControl,, LogEdit, %newText%
    GuiControl,, StateText, % "State: " . msg
}

FindTextWait(feat, timeout=15000)
{
    start := A_TickCount
    Loop
    {
        if (A_TickCount - start >= timeout)
            return false
        ok := FindText(0, 0, A_ScreenWidth, A_ScreenHeight, 0, 0, 0, 0, feat)
        if (ok)
            return ok
        Sleep 500
    }
}

; ===================== Main =====================
MainStart:
    Log("Launching Chrome and login page.")
    if (!OpenChromeLogin(urlLogin))
    {
        Log("OpenChromeLogin failed.")
        MsgBox 16, Error, Failed to start Chrome.
        ExitApp
    }

    Log("Entering monitoring loop.")
    Loop
    {
        currentTime := A_TickCount

        if (currentTime - lastCheckDisconnect >= CHECK_DISCONNECT_INTERVAL)
        {
            lastCheckDisconnect := currentTime
            Log("Checking disconnect status.")
            if (CheckLogDisconnect())
            {
                Log("Disconnect detected.")
                RestartContainer()
                lastCheckDisconnect := A_TickCount
                lastCheckQR := A_TickCount
                Continue
            }
        }

        if (currentTime - lastCheckQR >= CHECK_QR_INTERVAL)
        {
            lastCheckQR := currentTime
            Log("Checking QR status.")
            if (CheckQRCode())
            {
                Log("QR detected.")
                OperateMuMuAndTim()
                lastCheckDisconnect := A_TickCount
                lastCheckQR := A_TickCount
                Continue
            }
            else
            {
                Log("QR not detected.")
            }
        }

        Sleep 1000
    }
return

; ===================== Chrome login =====================
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
            ChromePath := "chrome.exe"
    }

    if (!FileExist(ChromePath))
    {
        Log("Chrome not found.")
        return false
    }

    Run %ChromePath% -incognito "%Url%", , , ChromePID
    Log("Chrome launched. PID=" . ChromePID)
    WinWait ahk_pid %ChromePID%, , 15
    if ErrorLevel
    {
        Log("Chrome window wait timeout.")
        return false
    }

    WinActivate ahk_pid %ChromePID%
    Sleep 8000

    ok := FindTextWait(TextUser, 15000)
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

    okLogin := FindTextWait(TextLogin, 15000)
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

; ===================== Disconnect check =====================
CheckLogDisconnect()
{
    global TextDisconnect
    WinGet activePID, PID, A
    WinActivate ahk_exe chrome.exe
    Sleep 1000
    ok := FindText(0,0,A_ScreenWidth,A_ScreenHeight,0,0,0,0,TextDisconnect)
    WinActivate ahk_pid %activePID%
    return ok
}

; ===================== QR check =====================
CheckQRCode()
{
    global TextQR
    WinGet activePID, PID, A
    WinActivate ahk_exe chrome.exe
    Sleep 1000
    ok := FindText(0,0,A_ScreenWidth,A_ScreenHeight,0,0,0,0,TextQR)
    WinActivate ahk_pid %activePID%
    return ok
}

; ===================== Restart container =====================
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
    Sleep 2000
    Send {Space}

    ok := FindTextWait(TextRestartBtn, 15000)
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

; ===================== Move window to QR anchor =====================
MoveWindowToQRAnchor()
{
    global TextQR

    WinWait Real-time screenshot ahk_class Qt5156QWindow ahk_exe MuMuPlayer.exe, , 15
    if ErrorLevel
    {
        Log("QR anchor window not found.")
        return false
    }

    WinActivate Real-time screenshot ahk_class Qt5156QWindow ahk_exe MuMuPlayer.exe
    WinWaitActive Real-time screenshot ahk_class Qt5156QWindow ahk_exe MuMuPlayer.exe, , 8
    Sleep 800

    okQR := FindTextWait(TextQR, 15000)
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
    Sleep 800

    return true
}

OperateMuMuAndTim()
{
    global MuMuPath, TextTimIcon, TextTimPlus, TextTimScan, TextTimCam, TextTimLogin, ScanWait

    Log("Launching MuMu emulator.")
    Run %MuMuPath%

    WinWait ahk_exe MuMuPlayer.exe, , 30
    if ErrorLevel
    {
        Log("MuMu window not found.")
        return
    }

    WinActivate ahk_exe MuMuPlayer.exe
    WinSet AlwaysOnTop, On, ahk_exe MuMuPlayer.exe
    WinWaitActive ahk_exe MuMuPlayer.exe, , 10
    Log("MuMu window active.")

    Sleep 30000

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
            if (FindText(0, 0, A_ScreenWidth, A_ScreenHeight, 0, 0, 0, 0, steps[checkStep].feat))
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

        ok := FindTextWait(feat, 15000)
        if (!ok)
        {
            Log(label . " not found.")
            retryCount++
            if (retryCount >= maxRetries)
            {
                Log("Max retries reached for " . label . ", exiting workflow.")
                Gosub CleanupMuMu
                return
            }
            Sleep 1000
            Continue
        }

        x := ok[1].x
        y := ok[1].y
        Log(label . " found at " . x . "," . y . ", clicking...")
        Click %x%, %y%
        Sleep 2000

        if (label = "Scan button")
        {
            Log("Waiting 10s for camera to load...")
            Sleep 10000
            stillExists := false
        }
        else
        {
            stillExists := FindText(0, 0, A_ScreenWidth, A_ScreenHeight, 0, 0, 0, 0, feat)
        }

        if (stillExists)
        {
            Log(label . " still present, retrying...")
            retryCount++
            if (retryCount >= maxRetries)
            {
                Log("Max retries reached for " . label . ", exiting workflow.")
                Gosub CleanupMuMu
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
        Gosub CleanupMuMu
        return
    }

    WinActivate ahk_exe MuMuPlayer.exe
    WinWaitActive ahk_exe MuMuPlayer.exe, , 5
    Sleep 1000

    Log("Waiting for QR scan complete, searching login button...")
    ok := FindTextWait(TextTimLogin, 60000) 

    if (!ok)
    {
        Log("Login button not found.")
        Gosub CleanupMuMu
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

    Sleep 20000

    WinSet AlwaysOnTop, Off, ahk_exe MuMuPlayer.exe
    Log("TIM flow completed.")

    Gosub CleanupMuMu
    return

CleanupMuMu:
    Log("Force closing MuMu emulator process...")
    Process, Close, MuMuPlayer.exe
    Process, WaitClose, MuMuPlayer.exe, 5
    Sleep 3000
    Log("MuMu closed successfully.")
return
}
