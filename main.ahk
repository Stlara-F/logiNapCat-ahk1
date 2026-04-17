#Include <FindText>
#SingleInstance Force
SetBatchLines, -1
CoordMode, Mouse, Screen

ChromePath := "C:\Program Files\Google\Chrome\Application\chrome.exe"

Account := "admin"
Password := "YourPasswordHere"
urlLogin  := "http://your-server-ip:port"
urlTarget := "http://your-server-ip:port/#!/3/docker/containers/your-container-id/logs"

OpenChromeLogin(Url, ChromeExe := "") {
    if (ChromeExe = "") {
        possiblePaths := [ "C:\Program Files\Google\Chrome\Application\chrome.exe"
                         , "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
                         , "chrome.exe" ]
        for index, path in possiblePaths {
            if FileExist(path) {
                ChromeExe := path
                break
            }
        }
    }

    if (ChromeExe = "" or !FileExist(ChromeExe)) {
        MsgBox, 48, Error, Chrome executable not found.`nPlease check ChromePath variable.
        return false
    }

    Run, %ChromeExe% -incognito "%Url%", , , ChromePID
    if ErrorLevel {
        MsgBox, 48, Error, Failed to run Chrome.`nPath: %ChromeExe%`nURL: %Url%
        return false
    }

    WinWait, ahk_pid %ChromePID%, , 10
    if ErrorLevel {
        MsgBox, 48, Error, Chrome incognito window did not appear within 10 seconds.
        return false
    }

    WinActivate, ahk_pid %ChromePID%
    WinWaitActive, ahk_pid %ChromePID%, , 5
    if ErrorLevel {
        MsgBox, 48, Warning, Window found but could not be activated.
        return false
    }

    return true
}

if !OpenChromeLogin(urlLogin, ChromePath) {
    MsgBox, 48, Error, Failed to open login URL in Chrome incognito mode.
    ExitApp
}

Sleep, 3000

TextUser := "|<>**50$36.1lkzzUvHEU0jCyyjScg62jSfRpuU0exHejSfBqujSco7OU0fxpejSeRIudGuho/dGqo7vNSoxq7FEg7TxlzsU"
ok := FindText(X:="wait", Y:=3, 0, 0, 0, 0, 0, 0, TextUser)
if !ok {
    MsgBox, 48, Warning, Account input area not found.
    ExitApp
}
xUser := ok[1].x, yUser := ok[1].y
Click, %xUser%, %yUser%
Sleep, 200
SendInput, ^a{Del}
SendInput, %Account%
Sleep, 150
SendInput, {Tab}
Sleep, 120
SendInput, %Password%
Sleep, 200

TextLogin := "|<>**50$37.02A0007xg3zw06Mk0216Ak010S3kTzU7yU00E60A008601jzzazy0100E10kUk80UAMk40E0Dk3zs0BU0UA0uM08A3V306A30UNzzw3k1"
okLogin := FindText(X:="wait", Y:=3, 0, 0, 0, 0, 0, 0, TextLogin)
if okLogin {
    xLogin := okLogin[1].x, yLogin := okLogin[1].y
    Click, %xLogin%, %yLogin%
    Sleep, 2000
} else {
    MsgBox, 48, Warning, Login button not found.
    ExitApp
}

SendInput, ^l
Sleep, 200
Clipboard := urlTarget
SendInput, ^v
Sleep, 100
SendInput, {Enter}
Sleep, 1000
SendInput, {Space}

MsgBox, 64, Done, All steps completed.
ExitApp
