# LogiNapCat-ahk1
Auto login for Napcat docker
### ABC
- Monitor Offline Logs.
- Restart the container to retrieve the QR code.
- Using the Android Emulator's Screen Camera to Scan the code.
## ENV：
- Windows10 (Display 1920x1080)
- Chrome (Dark theme)
- MuMuPlayer 3.1.7.0 Display Mobilemode 540x260(DPI240)
- TIM 3.5.8
- AHK v1
- Portainer
### Guide：
1. Download the ZIP file and extract it to the root directory of the AHK v1 program.
2. Modify the global variable configuration in `main.ahk` as follows:
   ```
   MuMuPath := "C:\Program Files\Netease\MuMuPlayerGlobal-12.0\shell\MuMuPlayer.exe"   ;MuMu path
   Account := "username"   ;container username
   Password := "password"  ;container password
   urlLogin := "http://<container-ip>:port/" ;url for login
   urlLog := "http://<container-ip>:port/#!/3/docker/containers/<container-id>/logs"   ;url for log
   urlRestart := "http://<container-ip>:port/#!/3/docker/containers/<container-id>"    ;url for restart
   ```
3. Run main.ahk; press F8 to start, F12 to stop.
# Thanks
- FeiYue  / Descolada  / c4p  / ed1chandler
- Findtext
- https://github.com/thqby/ahk2_lib/tree/master/wincapture
