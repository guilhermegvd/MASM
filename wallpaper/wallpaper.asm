.386
.model flat,stdcall
option casemap:none

INCLUDE C:\masm32\include\windows.inc
INCLUDE C:\masm32\include\user32.inc
INCLUDE C:\masm32\include\kernel32.inc
INCLUDE C:\masm32\include\wininet.inc

INCLUDELIB \kernel32.lib
INCLUDELIB \user32.lib    
INCLUDELIB \wininet.lib    

WinMain proto :DWORD,:DWORD,:DWORD,:DWORD

.DATA                     			  
_BytesToRead equ 1024
_fileName  db "\wallpaper.jpg",0
_agent    db "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36 Edg/110.0.1587.41",0
_endpoint  db "https://www.bing.com/HPImageArchive.aspx?format=xml&idx=0&n=1&mkt=pt-BR",0
_baseURL  db "https://www.bing.com",0
_urlTagBegin db "<url>",0
_urlTagEnd db "</url>",0

.DATA?
_InternetHandle DWORD ?
_UrlHandle DWORD ?
_FileHandle DWORD ?
_CurrentDirectory db 1024 dup(?)
_wallpaperPath db 1024 dup(?)
_Response db 1024 dup(?)
_BytesRead DWORD ?
_BytesWritten DWORD ?
_imageURL db 300 dup(?)
_imageURLComplete db 300 dup(?)
_urlTagBeginAddress DWORD ?
_urlTagEndAddress DWORD ?
_urlLength DWORD ?

.CODE
INCLUDE string_macros.inc

_start:

; OPEN CONNECTION **************************************************************

    ; Get Internet Handler
    invoke InternetOpen, addr _agent, INTERNET_OPEN_TYPE_PRECONFIG, NULL, NULL, NULL
    test eax, eax
    jz _CloseConnection
    mov [_InternetHandle],eax


; GET WALLPAPER URL ************************************************************

    ; Call API URL
    invoke InternetOpenUrl, _InternetHandle, addr _endpoint, NULL, NULL, NULL, NULL
    test eax, eax
    jz _CloseConnection
    mov [_UrlHandle],eax

    ; Get API Response
    invoke InternetReadFile, _UrlHandle, addr _Response, _BytesToRead, addr _BytesRead
    test eax, eax
    jz _CloseConnection

    ; Extract URL from response string    
    str_InStr offset _Response, sizeof _Response, offset _urlTagBegin, sizeof _urlTagBegin, 0h, _urlTagBeginAddress
    jne _CloseConnection
    
    str_InStr offset _Response, sizeof _Response, offset _urlTagEnd, sizeof _urlTagEnd, 0h, _urlTagEndAddress
    jne _CloseConnection

    add _urlTagBeginAddress, sizeof _urlTagBegin - 1
    mov eax, _urlTagBeginAddress
    mov ebx, _urlTagEndAddress
    sub ebx, eax
    mov _urlLength, ebx

    str_Mid _urlTagBeginAddress, _urlLength, _imageURL

    str_Concat offset _baseURL, offset _imageURL, offset _imageURLComplete


; GET IMAGE STREAM AND WRITE ***************************************************

    ; Set Filename to write    
    invoke GetCurrentDirectory, _BytesToRead, addr _CurrentDirectory

    str_Concat offset _CurrentDirectory, offset _fileName, offset _wallpaperPath

    ; Call API URL
    invoke InternetOpenUrl, _InternetHandle, addr _imageURLComplete, NULL, NULL, NULL, NULL
    test eax, eax
    jz _CloseConnection
    mov [_UrlHandle],eax

    ; Create / overwrite file for append
    invoke CreateFile, addr _wallpaperPath, FILE_APPEND_DATA, FILE_SHARE_READ, NULL, CREATE_ALWAYS, 
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


; SET IMAGE AS WALLPAPER *******************************************************

    invoke SystemParametersInfo, SPI_SETDESKWALLPAPER, 0, addr _wallpaperPath, SPIF_UPDATEINIFILE
    jmp _CloseConnection


; QUIT PROGRAM *****************************************************************

_CloseConnection:

    invoke InternetCloseHandle, [_FileHandle]
    invoke InternetCloseHandle, [_InternetHandle]

_Quit:
    invoke ExitProcess, 0 

END _start