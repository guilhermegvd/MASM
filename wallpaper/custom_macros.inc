str_InStr PROC string1:DWORD, string2:DWORD, startPos:DWORD, outIndex:DWORD
  cld ; clear direction flag
  mov esi, offset string1 ; container string
  mov edi, offset string2 ; string to look for
  mov ecx, 2000 ; length of container

  search:
    push ecx
    push esi
    push edi

    mov ecx, sizeof string2 - 1 ; discard null terminator
    repe cmpsb
    je found

    pop edi
    pop esi
    pop ecx
    inc esi
    loop search ; loop ecx times
    jmp notFound
      
  found:
    mov outIndex, esi ; return index
    cmp esi, esi
    ret
    
  notFound:
    cmp esi, 0
    ret
str_InStr ENDP