.model small
.stack 100h
.data
    menu db 13,10,"================================"
         db 13,10,"       DIGITAL ALARM SYSTEM     "
         db 13,10,"================================"
         db 13,10,"1. Set New Alarm"
         db 13,10,"2. Reset/Clear Alarm"
         db 13,10,"3. Toggle Alarm (ON/OFF)"
         db 13,10,"4. Exit Program"
         db 13,10,"--------------------------------"
         db 13,10,"Status: $"

    msg_hour    db 13,10,"Enter Hour (00-23): $"
    msg_min     db 13,10,"Enter Minute (00-59): $"
    msg_success db 13,10,"[+] Operation Successful!$"
    msg_error   db 13,10,"[!] Invalid Input. Try again.$"
    msg_active  db "ACTIVE$"
    msg_inactive db "INACTIVE$"
    
    alarmHour   db 0
    alarmMin    db 0
    alarmStatus db 0 

.code
DISPLAY MACRO text
    lea dx, text
    mov ah, 09h
    int 21h
ENDM

start:
    mov ax, @data
    mov ds, ax

main_menu:
    DISPLAY menu
    
    cmp alarmStatus, 1
    jne show_off
    DISPLAY msg_active
    jmp get_input
show_off:
    DISPLAY msg_inactive

get_input:
    mov ah, 01h      
    int 21h
    sub al, '0'      

    ; Logic: Instead of jumping far, we check and call right here
    cmp al, 1
    jne check_2
    call set_alarm_proc
    jmp main_menu

check_2:
    cmp al, 2
    jne check_3
    call reset_alarm_proc
    jmp main_menu

check_3:
    cmp al, 3
    jne check_4
    call toggle_alarm_proc
    jmp main_menu

check_4:
    cmp al, 4
    jne invalid_input
    jmp exit_program

invalid_input:
    jmp main_menu    

; --- PROCEDURES ---

set_alarm_proc PROC NEAR
    DISPLAY msg_hour
    call read_input_logic
    cmp al, 23       
    jg  handle_err
    mov alarmHour, al

    DISPLAY msg_min
    call read_input_logic
    cmp al, 59       
    jg  handle_err
    mov alarmMin, al
    
    mov alarmStatus, 1 
    DISPLAY msg_success
    ret
handle_err:
    DISPLAY msg_error
    ret
set_alarm_proc ENDP

read_input_logic PROC NEAR
    mov ah, 01h      
    int 21h
    sub al, '0'
    mov bl, 10
    mul bl           
    mov bh, al       
    
    mov ah, 01h      
    int 21h
    sub al, '0'
    add al, bh       
    ret
read_input_logic ENDP

reset_alarm_proc PROC NEAR
    mov alarmHour, 0
    mov alarmMin, 0
    mov alarmStatus, 0
    DISPLAY msg_success
    ret
reset_alarm_proc ENDP

toggle_alarm_proc PROC NEAR
    xor alarmStatus, 1 
    DISPLAY msg_success
    ret
toggle_alarm_proc ENDP

exit_program:
    mov ax, 4C00h    
    int 21h

END start