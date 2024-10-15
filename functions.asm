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
; void addBigNum()
; Calculate the sum of two big numbers
; First para: esi -> num1
; Second para: edi -> num2
; Third para: reversedNum1
; Fourth para: reversedNum2
; Store result in num1: [esp + 0x4] in the end
; Stack in the end before return will look like that

; [len]                   -> esp
; [edi]
; [esi]
; [edx]
; [ecx]
; [ebx]
; [eax]
; [old ebp]
; [return address]
; [reversedNum2]
; [reversedNum1]
; [num2]
; [num1]          -> it stores the result in the end

addBigNum:
    ; Backup things
    push ebp
    mov ebp, esp
    push eax
    push ebx
    push ecx
    push edx

    mov esi, [ebp+0x14]         ; num1
    mov edi, [ebp+0x10]         ; num2
    push esi                    ; store num1
    push edi                    ; store num2

    call sLen
    mov eax, esi                ; strlen(num1)
    
    mov esi, edi
    call sLen
    mov edx, esi                ; strlen(num2)
    push eax                    ; Suppose it is the max length
    cmp eax, edx                ; Compare to find the max length
    jg reverseStep_addBigNum
    pop eax
    push edx                    ; len = strlen(num2)
    
    reverseStep_addBigNum:    
        mov esi, [esp+0x4]      ; num2
        mov edi, [ebp+0x8]      ; reversedNum2
        call reverseStr         ; if num2 = 30, after that it would be 03

        mov esi, [esp+0x8]      ; num1
        mov edi, [ebp+0xc]      ; reversedNum1
        call reverseStr
    ; appendZeros_addBigNum:
    mov bl, byte "0"
    cmp eax, edx
    jl appendZeros_addBigNum_1
    jmp appendZeros_addBigNum_2 ; if num2 is "03", append zeros to the right until it gets the max length

    appendZeros_addBigNum_1:
        mov [edi + eax], ebx    ; edi is holding reversedNum1 so no need to change
        inc eax
        cmp eax, [esp]
        jl appendZeros_addBigNum_1
        jmp finished_appending_addBigNum

    appendZeros_addBigNum_2:
        mov edi, [ebp+0x8]      ; change to reversedNum2
        mov [edi + edx], ebx
        inc edx
        cmp edx, [esp]
        jl appendZeros_addBigNum_2
        jmp finished_appending_addBigNum

    finished_appending_addBigNum:
        mov esi, [ebp+0xc]      ; make esi -> reversedNum1
        mov edi, [ebp+0x8]      ; make edi -> reversedNum2

        ; this is preparation for calculating and storing result in reversedNum1
        xor eax, eax            ; store digit
        mov bl, 10              ; dividing
        xor ecx, ecx            ; counter: from 0 -> max length stored at [esp]
        xor edx, edx            ; the carry

    addingLoop_addBigNum:
        push edx                ; backup carry
        xor eax, eax            ; cleanning up
        xor edx, edx            ; cleanning up
        mov al, [esi + ecx]
        mov dl, [edi + ecx]
        sub al, "0"             ; num1[i] - "0"
        sub dl, "0"             ; num2[i] - "0"
        add al, dl              ; num1[i] - "0" + num2[i] - "0"
        pop edx                 ; restore carry
        add al, dl              ; digit = num1[i] - "0" + num2[i] - "0" + carry
        div bl
        ; ah = ax % bl
        ; al = ax / bl -> carry
        add ah, "0"             ; (digit % 10) + "0"
        mov [esi + ecx], byte ah; num1[i] = (digit % 10) + "0"
        mov dl, al              ; carry = digit / 10
        inc ecx                 ; i++
        cmp ecx, [esp]          ; cmp i, max length
        jne addingLoop_addBigNum

        cmp edx, 1              ; if there is a carry after adding
        jne finished_addBigNum
        add dl, "0"             ; append the carry to the end of reversed string
        mov [esi + ecx], byte dl
    finished_addBigNum:
        add esp, 0x4            ; skip the max length value
        mov esi, [esp + 0x4*9]  ; point to reversedNum1
        mov edi, [esp + 0x4*11] ; point to num1
        call reverseStr
    ; Restore things
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
; void exit()
; Exit program and restore resources
quit:
    mov ebx, 0
    mov eax, 1
    int 0x80
    ret