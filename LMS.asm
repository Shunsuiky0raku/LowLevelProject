section .data
    prompt db "1. Add Book, 2. Display Books, 3. Calculate Total Books, 4. Exit: ", 0
    book_prompt db "Enter book title (max 50 chars): ", 0
    book_added db "Book added successfully!", 10, 0
    total_books db "Total books: ", 0
    display_books_msg db "Displaying books:", 10, 0
    book_number db "Book ", 0
    colon db ": ", 0
    newline db 10, 0
    error_msg db "Invalid input. Please try again.", 10, 0

section .bss
    choice resb 2
    book_title resb 51
    books resb 1020  ; Space for 20 books (50 chars title + 1 newline)
    book_count resb 1
    display_buffer resb 4  ; Buffer for displaying numbers

section .text
    global _start

_start:
    mov byte [book_count], 0  ; Initialize book count to 0

main_loop:
    ; Display prompt
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt
    mov edx, 55
    int 0x80

    ; Get user choice
    mov eax, 3
    mov ebx, 0
    mov ecx, choice
    mov edx, 2
    int 0x80

    ; Check user choice
    mov al, [choice]
    cmp al, '1'
    je add_book
    cmp al, '2'
    je display_books
    cmp al, '3'
    je calculate_total
    cmp al, '4'
    je exit_program

    ; Invalid input
    mov eax, 4
    mov ebx, 1
    mov ecx, error_msg
    mov edx, 34
    int 0x80
    jmp main_loop

add_book:
    ; Prompt for book title
    mov eax, 4
    mov ebx, 1
    mov ecx, book_prompt
    mov edx, 33
    int 0x80

    ; Get book title
    mov eax, 3
    mov ebx, 0
    mov ecx, book_title
    mov edx, 51
    int 0x80

    ; Find the end of the input (remove newline)
    mov edi, book_title
    mov ecx, 50
    mov al, 10  ; newline character
    repne scasb
    dec edi
    mov byte [edi], 0  ; null-terminate the string

    ; Add book to list
    movzx eax, byte [book_count]
    mov ebx, 51  ; 50 (title) + 1 (null terminator)
    mul ebx
    mov edi, books
    add edi, eax
    mov esi, book_title
    mov ecx, 51
    rep movsb

    ; Increment book count
    inc byte [book_count]

    ; Display success message
    mov eax, 4
    mov ebx, 1
    mov ecx, book_added
    mov edx, 25
    int 0x80

    jmp main_loop

display_books:
    ; Display books message
    mov eax, 4
    mov ebx, 1
    mov ecx, display_books_msg
    mov edx, 17
    int 0x80

    ; Check if there are any books
    mov al, [book_count]
    test al, al
    jz .no_books

    ; Loop through books
    xor ecx, ecx  ; Initialize counter
    .loop:
        ; Check if we've displayed all books
        cmp cl, [book_count]
        jge .end

        ; Display book number
        push ecx  ; Save counter
        mov eax, 4
        mov ebx, 1
        mov ecx, book_number
        mov edx, 5
        int 0x80

        ; Convert book number to ASCII
        pop ecx  ; Restore counter
        push ecx  ; Save counter again
        inc cl  ; Book numbers start from 1
        mov al, cl
        add al, '0'
        mov [display_buffer], al
        mov eax, 4
        mov ebx, 1
        mov ecx, display_buffer
        mov edx, 1
        int 0x80

        ; Display colon and space
        mov eax, 4
        mov ebx, 1
        mov ecx, colon
        mov edx, 2
        int 0x80

        ; Calculate book address
        pop ecx  ; Restore counter
        push ecx  ; Save counter again
        mov eax, 51
        mul cl
        mov esi, books
        add esi, eax

        ; Display book title
        mov eax, 4
        mov ebx, 1
        mov ecx, esi
        mov edx, 50
        int 0x80

        ; New line
        mov eax, 4
        mov ebx, 1
        mov ecx, newline
        mov edx, 1
        int 0x80

        pop ecx  ; Restore counter
        inc cl
        jmp .loop

    .no_books:
        mov eax, 4
        mov ebx, 1
        mov ecx, newline
        mov edx, 1
        int 0x80

    .end:
        jmp main_loop

calculate_total:
    ; Display total books message
    mov eax, 4
    mov ebx, 1
    mov ecx, total_books
    mov edx, 13
    int 0x80

    ; Convert book count to ASCII
    movzx eax, byte [book_count]
    mov ebx, 10
    mov edi, display_buffer
    add edi, 3  ; Start from the end of the buffer
    mov byte [edi], 0  ; Null-terminate the string

    .convert_loop:
        xor edx, edx
        div ebx
        add dl, '0'  ; Convert remainder to ASCII
        dec edi
        mov [edi], dl
        test eax, eax
        jnz .convert_loop

    ; Display book count
    mov eax, 4
    mov ebx, 1
    mov ecx, edi
    mov edx, display_buffer
    add edx, 4
    sub edx, edi
    int 0x80

    ; New line
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    jmp main_loop

exit_program:
    ; Exit the program
    mov eax, 1
    xor ebx, ebx
    int 0x80
