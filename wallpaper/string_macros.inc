str_InStr MACRO stringPtr1, lenString1, stringPtr2, lenString2, startPos, outIndex
  local search ;force masm to generate unique labels each time macro is expanded
  local found
  local notFound
  local endMacro

  cld ; clear direction flag
  mov esi, stringPtr1 ; container string
  mov edi, stringPtr2 ; string to look for
  mov ecx, lenString1 - 1; length of container

  search:
    push ecx
    push esi
    push edi

    mov ecx, lenString2 - 1 ; discard null terminator
    repe cmpsb
    je found

    pop edi
    pop esi
    pop ecx
    inc esi
    loop search ; loop ecx times
    jmp notFound
      
  found:
    sub esi, lenString2 - 1
    mov outIndex, esi ; return index
    cmp esi, esi
    jmp endMacro
    
  notFound:
    cmp esi, 0

  endMacro:
ENDM


str_Mid MACRO startPos, lengthToGet, outSubstr
  cld
  mov esi, startPos
  lea si, [esi] ;start position
  lea di, outSubstr ;address of string to compose
  mov ecx, lengthToGet
  rep movsb
  mov al, 0
  stosb
ENDM


str_Concat MACRO stringPtr1, stringPtr2, outStringPtr
  local moveStr1
  local moveStr2

  cld
  mov esi, stringPtr1
  mov edi, outStringPtr

  moveStr1:
    lodsb
    stosb
    cmp al, NULL
    jne moveStr1

  dec edi
  mov esi, stringPtr2

  moveStr2:
    lodsb
    stosb
    cmp al, NULL
    jne moveStr2
ENDM