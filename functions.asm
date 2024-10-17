;----------------------------------------
; void sLen(String message)
; String length calculation function
sLen:
    push ebx
    mov ebx, esi

    nextChar_sLen:
        cmp byte [esi], 0
        jz finished_sLen
        cmp byte [esi], 0xa
        jz finished_sLen
        inc esi
        jmp nextChar_sLen
    
    finished_sLen:
        sub esi, ebx
        pop ebx
        ret

;----------------------------------------
; void sPrint(String message)
; String printing function
; Source: esi
sPrint:
    push eax
    push ebx
    push ecx
    push edx
    
    push esi
    call sLen
    mov edx, esi

    pop esi
    mov ecx, esi
    mov ebx, 1
    mov eax, 4
    int 0x80

    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

;----------------------------------------
; void iPrint(Integer number)
; Integer printing function (itoa)
; Source: eax
iPrint:
    push eax
    push ebx
    push ecx
    push edx
    push esi

    mov ebx, 0  ;sign
    mov ecx, 0

    test eax, eax
    jns divideLoop_iPrint
    mov ebx, 1
    neg eax

    divideLoop_iPrint:
        inc ecx
        mov edx, 0
        mov esi, 10
        idiv esi
        add edx, "0"
        push edx
        cmp eax, 0
        jnz divideLoop_iPrint
    
    pre_printLoop_iPrint:
        cmp ebx, 1
        jne printLoop_iPrint
        push "-"
        inc ecx
    printLoop_iPrint:
        dec ecx
        mov esi, esp
        call sPrint
        pop eax
        cmp ecx, 0
        jnz printLoop_iPrint
    
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
    
;----------------------------------------
; void sScan(String message)
; Get the message from output
; Source: esi
sScan:
    push eax
    push ebx
    push ecx
    push edx

    mov edx, 100
    mov ecx, esi
    mov ebx, 0
    mov eax, 3
    int 0x80

    pop edx
    pop ecx 
    pop ebx
    pop eax

    ret

;----------------------------------------
; int strToInt()
; Convert a string of number to integer (just one)
; Source: esi
; Store in stack
strToInt:
    ; Backup
    push ebp
    mov ebp, esp

    push eax
    push ebx
    push ecx
    push edx
    push esi

    ; Code
    mov eax, 0
    cmp byte [esi], "-" ; Negative or not
    jne getNum_strToInt
    mov ecx, 1
    inc esi
    getNum_strToInt:
        ; Convert to int
        cmp byte [esi], 0xa
        je pre_finished_strToInt
        mov ebx, 10
        mul ebx

        mov dl, byte [esi]
        sub dl, "0"
        add eax, edx

        inc esi
        jmp getNum_strToInt

    pre_finished_strToInt:
        ; Negate or not
        cmp ecx, 1
        jne finished_strToInt
        neg eax
    finished_strToInt:
        mov [ebp+0x8], eax
    ; Restore
    pop esi
    pop edx
    pop ebx
    pop ecx
    pop eax

    mov esp, ebp
    pop ebp
    ret

;----------------------------------------
; Array strToArray()
; Convert a string of numbers to integer array
; Counter: ecx
; Source: esi
; Destination: edi
strToArray:
    ; Backup
    push ebp
    mov ebp, esp

    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    ; Code
    mov eax, 0
    pre_getNum_strToArray:
        ; Determine the number is negative or not
        mov ecx, 0
        cmp byte [esi], "-"
        jne getNum_strToArray
        mov ecx, 1
        inc esi
    getNum_strToArray:
        ; Convert to integers (splitted by spaces)
        cmp byte [esi], 0xa
        je pre_finished_strToArray
        cmp byte [esi], 0x20
        je getMoreNum_strToArray
        mov ebx, 10
        mul ebx

        mov dl, byte [esi]
        sub dl, "0"
        add eax, edx

        inc esi
        jmp getNum_strToArray
    getMoreNum_strToArray:
        ; Negate or not?, and perform a jump to next integer
        cmp ecx, 1
        jne next_strToArray
        neg eax
    next_strToArray:
        mov [edi], eax
        mov eax, 0
        inc esi
        add edi, 4
        jmp pre_getNum_strToArray
    
    pre_finished_strToArray:
        ; Negate or not?, write to destination and restore
        cmp ecx, 1
        jne finished_strToArray
        neg eax
    finished_strToArray:
        mov [edi], eax
        pop edi
        pop esi
        pop edx
        pop ecx
        pop ebx
        pop eax

    mov esp, ebp
    pop ebp
    ret

;----------------------------------------
; void selectionSort(n, array)
; Perform selection sort
selectionSort:
    ; Source/Destination: edi
    ; Number of ele: [ebp + 8]
    ; Counter i: ecx
    ; Counter j: esi
    push ebp
    mov ebp, esp

    push eax
    push ebx
    push ecx
    push edx
    push esi

    mov ecx, 0          ; i
    mov esi, 0          ; j
    mov eax, 0          ; a[min_index]
    mov ebx, 0          ; min_index
    mov edx, 0          ; tmp


    loopForI:
        cmp ecx, [ebp + 8]
        jge finished_loopForI
        mov eax, [edi + ecx*4]      ; eax = a[i]
        mov ebx, ecx                ; min_index = i
        mov esi, ecx
        inc esi                     ; j = i+1
        loopForJ:
            cmp esi, [ebp + 8]
            jge finished_loopForJ
            cmp eax, [edi + esi*4]  ; cmp a[min_index], a[j]
            jle next_loopForJ
            mov ebx, esi            ; min_index = j
            mov eax, [edi + ebx*4]  ; eax = a[min_index]
            next_loopForJ:
                inc esi
                jmp loopForJ
        finished_loopForJ:
            mov edx, [edi + ecx*4]  ; tmp = a[i]
            mov [edi + ecx*4], eax  ; a[i] = a[min_index]
            mov [edi + ebx*4], edx  ; a[min_index] = a[i]

            inc ecx
            jmp loopForI
    finished_loopForI:
        pop esi
        pop edx
        pop ecx
        pop ebx
        pop eax

        mov esp, ebp
        pop ebp
    ret

;------------------------------------------
; void reverseStr(String message)
; Reverse a string
; Source: esi
; Destination: edi
reverseStr:
    push eax
    push ecx
    push edi
    push esi

    push esi
    call sLen

    mov ecx, esi    ; n
    dec ecx
    pop esi 

    next_reverseStr:
        cmp ecx, -1
        je finished_reverseStr
        mov al, byte [esi + ecx]
        mov [edi], al
        inc edi
        dec ecx
        jmp next_reverseStr

    finished_reverseStr:
        mov [edi], byte 0
        pop esi
        pop edi
        pop ecx
        pop eax
    ret

;----------------------------------------
; int sumBigNum()
; Calculate the sum of two big numbers
; First para: sum -> destination to store
; Next paras: num2, num1
; After finished label, num1 holds result reversed, sum holds the right one
sumBigNum:
    ; Backup things
    push ebp
    mov ebp, esp
    push eax
    push ebx
    push ecx
    push edx

    ; Code
    ; First to reverse the two string
    ; sum = reversedStr(num1)
    ; num1 = reversedStr(num2)
    mov esi, [ebp+0x10] ; num1
    mov edi, [ebp+0x8]  ; sum
    call reverseStr
    mov esi, edi
    call sLen
    mov edx, esi
    push edx            ; suppose it is max_len

    mov esi, [ebp+0xc]  ; num2
    mov edi, [ebp+0x10] ; num1
    call reverseStr
    mov esi, edi
    call sLen
    mov eax, esi
    cmp eax, edx
    jl pre_appendZeros
    pop edx
    push eax            ; change max_len if eax > edx

    pre_appendZeros:
        mov esi, [ebp+0x10] ; point to num1
        mov edi, [ebp+0x8]  ; point to sum
        mov bl, byte "0"    ; prepare byte to append
        cmp eax, [esp]      ; compare to add "0"
        jl appendZeros_num1
        jmp appendZeros_sum

    appendZeros_num1:
        mov [esi + eax], ebx
        inc eax
        cmp eax, [esp]
        jl appendZeros_num1
        jmp pre_addLoop

    appendZeros_sum:
        mov [edi + edx], ebx
        inc edx
        cmp edx, [esp]
        jl appendZeros_sum
        jmp pre_addLoop

    pre_addLoop:
        ; this is preparation for calculating and storing result in reversedNum1
        xor eax, eax            ; store digit
        mov bl, 10              ; dividing
        xor ecx, ecx            ; counter: from 0 -> max length stored at [esp]
        xor edx, edx            ; the carry
    
    addLoop:
        push edx
        xor eax, eax
        xor edx, edx
        mov al, [esi + ecx]
        mov dl, [edi + ecx]
        sub al, "0"             ; num1[i] - "0"
        sub dl, "0"             ; sum[i] - "0"
        add al, dl              ; num1[i] - "0" + sum[i] - "0"
        pop edx                 ; restore carry
        add al, dl              ; digit = num1[i] - "0" + sum[i] - "0" + carry
        div bl
        ; ah = ax % bl
        ; al = ax / bl -> carry
        add ah, "0"             ; (digit % 10) + "0"
        mov [esi + ecx], byte ah; num1[i] = (digit % 10) + "0"
        mov dl, al              ; carry = digit / 10
        inc ecx                 ; i++
        cmp ecx, [esp]          ; cmp i, max_len
        jne addLoop

        cmp edx, 1              ; if there is a carry after adding
        jne finished
        add dl, "0"             ; append the carry to the end of reversed string
        mov [esi + ecx], byte dl
    finished:
        add esp, 0x4            ; skip the max_len
        ; mov esi, [ebp + 0x10]   ; num1
        ; mov edi, [ebp + 0x8]    ; sum
        ; but no need to do that
        call reverseStr         ; sum = reversed(num1)

    pop edx
    pop ecx
    pop ebx
    pop eax
    mov esp, ebp
    pop ebp
    ret

;----------------------------------------
; void exit()
; Exit program and restore resources
quit:
    mov ebx, 0
    mov eax, 1
    int 0x80
    ret
