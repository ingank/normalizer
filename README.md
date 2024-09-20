# MXiNG Normalizer
A script-driven (nearly) aural music normalizer.

# Requirements
1. a powershell-capable windows-host
2. an installed ffmpeg suite
3. the tool `ylm2.exe` from `Youlean Loudness Meter 2` in the same directory
4. script `analyze.ps1` in the same folder as the sound-files
5. script `normalize.ps1` in the same folder as the sound-files

# Usage
Analyze all soundfiles in this folder:
```
.\analyze.ps1
```
Normalize all soundfiles in this folder and transcode them into folder `.\normalized`:
```
.\normalize.ps1
```
