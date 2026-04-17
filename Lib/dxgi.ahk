;================================
; FindText + WinCapture 结合使用 By FeiYue
;
; 使用方法：
;   1、保存本脚本到AHK主程序的Lib子目录（可手动建立），重命名为 dxgi.ahk 。
;   2、把包含“wincapture.dll”的“32bit”目录和“64bit”目录拷贝到Lib子目录中。
;   3、在自己的脚本开头使用 #Include <dxgi> 就可以使用各种模式了。
;      全局变量 WinCapture_mode 可以设定几种模式中的一种：""、"DXGI"、"DWM" 、"WGC"
;      后面两种模式 DWM、WGC，需要在 #Include <dxgi> 之后绑定窗口：
;      FindText().BindWindow(WinExist("记事本"))，或者查找前绑定窗口也行。
;================================

#Include <FindText>
SetBatchLines -1

; /* 下面是另外一个脚本调用FindText的例子

; #Include <dxgi>
; 设定几种模式中的一种："DXGI"、"DWM" 、"WGC"，后两种需要绑定窗口
WinCapture_mode := "DXGI"
; SetTitleMatchMode 2
; id:=WinExist("记事本"), FindText().BindWindow(id)
FindText().ScreenShot()  ; 截屏一次可以完成初始化

*F1::  ; 测试全屏截屏一次的耗时
t1:=FindText().QPC()
FindText().ScreenShot(0,0,0,0)  ; 截屏范围：(x1,y1,x2,y2)
t2:=FindText().QPC()
MsgBox, 4096,, % "WinCapture截图耗时：" (t2-t1)
return

*F2::  ; 用于显示后台截屏的图像
FindText().ShowScreenShot(0,0,10000,10000)  ; 截屏范围：(x1,y1,x2,y2)
ToolTip, 当前显示截屏的图像
Sleep 3000
ToolTip
FindText().ShowScreenShot()
return

*/


; FindText内部会尝试调用GetBitsFromScreen2()优先使用外部截屏数据
; return 0 会继续使用FindText内部的GDI模式截屏
GetBitsFromScreen2(bits, x, y, w, h) {
  ; 这个全局变量可以在用户脚本中设置
  global WinCapture_mode
  if (WinCapture_mode = "DXGI")
    return DXGI_Capture(bits, x, y, w, h)
  else if (WinCapture_mode = "DWM")
    return DWM_Capture(bits, x, y, w, h)
  else if (WinCapture_mode = "WGC")
    return WGC_Capture(bits, x, y, w, h)
  else
    return 0
}

; 加载DLL文件
WinCapture_Load(DLL文件路径:="") {
  if (DLL文件路径 = "")
    DLL文件路径 := A_ScriptDir "\Lib\" (A_PtrSize*8) "bit\wincapture.dll"
  if !(h := DllCall("LoadLibrary", "str", DLL文件路径, "ptr"))
    MsgBox, 4096,, % "DLL加载失败：`n" DLL文件路径
  return h
}

; DXGI模式截屏
DXGI_Capture(bits, x, y, w, h) {
  local
  static init, oldx, oldy, oldw, oldh

  ; 初始化
  if (!init) {
    if !WinCapture_Load()
      return 0
    hr:=DllCall("wincapture\dxgi_start", "uint")
    if (hr!=0) {
      MsgBox, 4096,, DXGI模式没有初始化成功！
      return 0
    }
    ; DllCall("wincapture\dxgi_showCursor", "int",1)
    oldx:=oldy:=oldw:=oldh:=0
    , init:=1
  }

  ; 截屏范围：(x1,y1,x2,y2)
  VarSetCapacity(box, 16)
  , NumPut(x, box, 0, "int")
  , NumPut(y, box, 4, "int")
  , NumPut(x+w, box, 8, "int")
  , NumPut(y+h, box, 12, "int")

  ; 截屏并返回数据到pdata
  hr:=DllCall("wincapture\dxgi_captureAndSave", "ptr*",pdata:=0, "ptr",&box, "uint",index:=0, "uint")
  ; 屏幕没变且截屏范围没超出上次的就用上次的图像
  if (hr=0x887A0027) && (x>=oldx && y>=oldy && x+w<=oldx+oldw && y+h<=oldy+oldh)
    return 1
  else
    oldx:=x, oldy:=y, oldw:=w, oldh:=h
  if (hr!=0 or pdata=0)
    return 0

  ; 拷贝pdata数据到FindText内部的bits中
  pBits   :=NumGet(pdata+0, "ptr")
  , Pitch :=NumGet(pdata+A_PtrSize, "uint")
  , Width :=NumGet(pdata+A_PtrSize+4, "uint")
  , Height:=NumGet(pdata+A_PtrSize+8, "uint")
  , FindText().CopyBits(bits.Scan0, bits.Stride, x, y, pBits, Pitch, 0, 0, Min(w,Width), Min(h,Height))

  return 1
}


; DWM模式截屏
DWM_Capture(bits, x, y, w, h) {
  local
  static init, dwm

  ; 使用FindText查找前必须先绑定窗口：
  ; SetTitleMatchMode, 2
  ; id:=WinExist("记事本"), FindText().BindWindow(id)
  hwnd:=FindText().bind.id

  ; 初始化
  if (!init) {
    if !WinCapture_Load()
      return 0
    hr:=DllCall("wincapture\dwm_init", "ptr*", dwm:=0)
    if (hr!=0 or dwm=0) {
      MsgBox, 4096,, DWM模式没有初始化成功！
      return 0
    }
    init:=1
  }

  ; 截屏范围：(x1,y1,x2,y2)
  VarSetCapacity(box, 16)
  , NumPut(x, box, 0, "int")
  , NumPut(y, box, 4, "int")
  , NumPut(x+w, box, 8, "int")
  , NumPut(y+h, box, 12, "int")

  ; 截屏并返回数据到pdata
  VarSetCapacity(data,32,0), pdata:=&data
  , hr:=DllCall("wincapture\dwm_capture", "ptr",dwm, "ptr",hwnd, "ptr",&box, "ptr",pdata)
  if (hr!=0)
    return 0

  ; 拷贝pdata数据到FindText内部的bits中
  pBits   :=NumGet(pdata+0, "ptr")
  , Pitch :=NumGet(pdata+A_PtrSize, "uint")
  , Width :=NumGet(pdata+A_PtrSize+4, "uint")
  , Height:=NumGet(pdata+A_PtrSize+8, "uint")
  , FindText().CopyBits(bits.Scan0, bits.Stride, x, y, pBits, Pitch, 0, 0, Min(w,Width), Min(h,Height))

  return 1
}

; WGC模式截屏
WGC_Capture(bits, x, y, w, h) {
  local
  static old_hwnd, wgc

  ; 使用FindText查找前必须先绑定窗口：
  ; SetTitleMatchMode, 2
  ; id:=WinExist("记事本"), FindText().BindWindow(id)
  hwnd_or_monitor_or_index:=FindText().bind.id

  ; 初始化
  if (old_hwnd != hwnd_or_monitor_or_index) {
    if !WinCapture_Load()
      return 0
    if (wgc)
      DllCall("wincapture\wgc_free", "ptr", wgc)
    SysGet, MonitorGetCount, MonitorCount
    if (hwnd_or_monitor_or_index <= MonitorGetCount)  ; 使用屏幕序号从0开始
      wgc:=DllCall("wincapture\wgc_init_monitorindex", "int", hwnd_or_monitor_or_index, "int", persistent:=1, "ptr")
    else if DllCall("IsWindow", "ptr", hwnd_or_monitor_or_index)  ; 基本上都使用hwnd
      wgc:=DllCall("wincapture\wgc_init_window", "ptr", hwnd_or_monitor_or_index, "int", persistent:=1, "ptr")
    else
      wgc:=DllCall("wincapture\wgc_init_monitor", "ptr", hwnd_or_monitor_or_index, "int", persistent:=1, "ptr")
    if (!wgc) {
      MsgBox, 4096,, WGC模式没有初始化成功！
      return 0
    }
    ; DllCall("wincapture\wgc_showCursor", "ptr",wgc, "int",1)
    old_hwnd := hwnd_or_monitor_or_index
  }

  ; 截屏范围：(x1,y1,x2,y2)
  VarSetCapacity(box, 16)
  , NumPut(x, box, 0, "int")
  , NumPut(y, box, 4, "int")
  , NumPut(x+w, box, 8, "int")
  , NumPut(y+h, box, 12, "int")

  ; 截屏并返回数据到pdata
  VarSetCapacity(data,32,0), pdata:=&data
  , hr:=DllCall("wincapture\wgc_capture", "ptr",wgc, "ptr",&box, "ptr",pdata)
  if (hr!=0)
    return 0

  ; 拷贝pdata数据到FindText内部的bits中
  pBits   :=NumGet(pdata+0, "ptr")
  , Pitch :=NumGet(pdata+A_PtrSize, "uint")
  , Width :=NumGet(pdata+A_PtrSize+4, "uint")
  , Height:=NumGet(pdata+A_PtrSize+8, "uint")
  , FindText().CopyBits(bits.Scan0, bits.Stride, x, y, pBits, Pitch, 0, 0, Min(w,Width), Min(h,Height))

  return 1
}