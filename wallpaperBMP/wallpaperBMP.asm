.386
.model flat,stdcall
option casemap:none

INCLUDE C:\masm32\include\windows.inc
INCLUDE C:\masm32\include\user32.inc
INCLUDE C:\masm32\include\kernel32.inc
INCLUDE C:\masm32\include\wininet.inc

INCLUDELIB C:\masm32\lib\kernel32.lib
INCLUDELIB C:\masm32\lib\user32.lib    
INCLUDELIB C:\masm32\lib\wininet.lib    

WinMain proto :DWORD,:DWORD,:DWORD,:DWORD

.DATA                     			  
_BytesToRead equ 1024
_fileName  db "wallpaper.bmp",0
_agent    db "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36 Edg/110.0.1587.56",0
_imageURL  db "http://entertime.com.br/bingImage.php",0

.DATA?
_InternetHandle DWORD ?
_UrlHandle DWORD ?
_FileHandle DWORD ?
_TempDirectory db 1024 dup(?)
_wallpaperPath db 1024 dup(?)
_Response db 1024 dup(?)
_BytesRead DWORD ?
_BytesWritten DWORD ?

.CODE
INCLUDE string_macros.inc

_start:

; OPEN CONNECTION **************************************************************
    invoke MessageBoxA, 0, addr _imageURL, addr _imageURL, 0h
    ; Get Internet Handler
    invoke InternetOpen, addr _agent, INTERNET_OPEN_TYPE_PRECONFIG, NULL, NULL, NULL
    test eax, eax
    jz _CloseConnection
    mov [_InternetHandle],eax

; GET IMAGE STREAM AND WRITE ***************************************************

    ; Call API URL
    invoke InternetOpenUrl, _InternetHandle, addr _imageURL, NULL, NULL, NULL, NULL
    test eax, eax
    jz _CloseConnection
    mov [_UrlHandle],eax
    
    ; Set Filename to write    
    invoke GetTempPath, _BytesToRead, addr _TempDirectory
    str_Concat offset _TempDirectory, offset _fileName, offset _wallpaperPath

    ; Create / overwrite file for append
    invoke CreateFile, addr _wallpaperPath, GENERIC_WRITE, FILE_SHARE_READ, NULL, CREATE_ALWAYS, 
            FILE_ATTRIBUTE_NORMAL, NULL
    test eax, eax
    jz _CloseConnection
    mov [_FileHandle],eax    

    ; Get image stream
    _readImageBytes:

        invoke InternetReadFile, _UrlHandle, addr _Response, _BytesToRead, addr _BytesRead

        invoke WriteFile, _FileHandle, addr _Response, _BytesRead, addr _BytesWritten, NULL

        cmp _BytesRead, 0
        jne _readImageBytes

    ; Close file
    invoke CloseHandle, [_FileHandle]

; SET IMAGE AS WALLPAPER *******************************************************
    
    invoke SystemParametersInfo, SPI_SETDESKWALLPAPER, 0, addr _wallpaperPath, SPIF_UPDATEINIFILE

; QUIT PROGRAM *****************************************************************

    _CloseConnection:
        invoke InternetCloseHandle, [_UrlHandle]
        invoke InternetCloseHandle, [_InternetHandle]

_Quit:
    invoke ExitProcess, 0 

END _start