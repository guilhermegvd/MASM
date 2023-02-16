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
_BytesToRead equ 10000 
_wallPath  db "E:\Guilherme\Pictures\MEROMEI - Copia.jpg",0
_agent    db "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36 Edg/110.0.1587.41",0
_endpoint  db "https://www.bing.com/HPImageArchive.aspx?format=xml&idx=0&n=1&mkt=pt-BR",0
_urlTagBegin db "<url>",0
_urlTagEnd db "</url>",0

.DATA?
_InternetHandle DWORD ?
_FileHandle DWORD ?
_Response db 10000 dup(?)
_BytesRead DWORD ?
_imageURL db 200 dup(?)
_urlTagBeginAddress DWORD ?
_urlTagEndAddress DWORD ?
_urlLength DWORD ?

.CODE
_start:

;INCLUDE custom_macros.inc

_GetImageURL:
    ; Get Internet Handler
    invoke InternetOpen, addr _agent, INTERNET_OPEN_TYPE_PRECONFIG, NULL, NULL, NULL
    test eax, eax
    jz _CloseConnection
    mov [_InternetHandle],eax

    ; Call API URL
    invoke InternetOpenUrl, _InternetHandle, addr _endpoint, NULL, NULL, NULL, NULL
    test eax, eax
    jz _CloseConnection
    mov [_FileHandle],eax

    ; Get API Response
    invoke InternetReadFile, _FileHandle, addr _Response, _BytesToRead, addr _BytesRead
    test eax, eax
    jz _CloseConnection
    mov eax,[_BytesRead]

    ; Extract URL from response string
    cld ; clear direction flag
    mov esi, offset _Response ; container string
    mov edi, offset _urlTagBegin ; string to look for
    mov ecx, _BytesRead ; length of container

    search_urlTagBegin:
        push ecx
        push esi
        push edi

        mov ecx, sizeof _urlTagBegin - 1 ; discard null terminator
        repe cmpsb
        je found_urlTagBegin

        pop edi
        pop esi
        pop ecx
        inc esi
        loop search_urlTagBegin ; loop ecx times
        jmp _CloseConnection
        
    found_urlTagBegin:
        mov _urlTagBeginAddress, esi ; keep begin tag address

        cld
        mov esi, offset _Response 
        mov edi, offset _urlTagEnd
        mov ecx, _BytesRead

    search_urlTagEnd:
        push ecx
        push esi
        push edi

        mov ecx, sizeof _urlTagEnd - 1
        repe cmpsb
        je found_urlTagEnd

        pop edi
        pop esi
        pop ecx
        inc esi
        loop search_urlTagEnd
        jmp _CloseConnection

    found_urlTagEnd:
        mov _urlTagEndAddress, esi ; keep end tag address
        sub _urlTagEndAddress, sizeof _urlTagEnd - 1
        mov eax, _urlTagBeginAddress
        mov ebx, _urlTagEndAddress
        sub ebx, eax
        mov _urlLength, ebx

        cld
        mov esi, _urlTagBeginAddress
        lea si, [esi] ;start position
        lea di, _imageURL ;address of string to compose
        mov ecx, _urlLength
        rep movsb
        mov al, 0
        stosb
        invoke MessageBox, 0, addr _imageURL, addr _imageURL, 0h


_SetWallpaper:
    invoke SystemParametersInfo, SPI_SETDESKWALLPAPER, 0, addr _wallPath, SPIF_UPDATEINIFILE
    jmp _CloseConnection


_CloseConnection:

    invoke InternetCloseHandle, [_FileHandle]
    invoke InternetCloseHandle, [_InternetHandle]


_Quit:
    invoke ExitProcess, 0 

END _start