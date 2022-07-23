;;;;;;;;;;;;;;;;;;;;;;________define macros_________;;;;;;;;;;;;;;;;;;;;;;;;
%macro readStdin 2
mov rbx,%1 ; reserved address for stdin
mov rcx,%2 ; number of bytes to read
call readStdin_
%endmacro

%macro newLine 0
mov rbx,nl
mov rcx,1
call write1
%endmacro

%macro write 2
mov rbx,%1
mov rcx,%2
call write1 
%endmacro

%macro itoa 1
mov rax,%1
call itoa1 
%endmacro

%macro atoi 1
mov r11,%1
call atoi_ 
%endmacro


%macro exit 0
;mov rdi,1%
call exit_
%endmacro

%macro readfile 2
mov rdi,%1
mov rsi,%2
call read_file
%endmacro

%macro fileSize 1 ; file path 
mov rdi,%1
call file_size
%endmacro

%macro strcmp 2  
mov r12,%1
mov r13,%2
call strcmp_
%endmacro

%macro printn 1 ;print null terminated string
mov r13,%1
call pnt
%endmacro

;;;;;;;;;;;;;;;;;;;;;;________ data section_________;;;;;;;;;;;;;;;;;;;;;;;;

section .data
asciiError   db    "Number containing non-digits characters",0x0A
asciiErrorLen   equ   $-asciiError
nl  db  0x0A
o_rdonly  equ   0q

;;;;;;;;;;;;;;;;;;;;;;________ uninitialized data __________;;;;;;;;;;;;;;;;;;;;;;;;

section .bss
result resb     128
temp resb  128
stat  resb   144

;;;;;;;;;;;;;;;;;;;;;;________ code section __________;;;;;;;;;;;;;;;;;;;;;;;;
section .text
;;;;;;;;;;;;;;;;;;;;;;________ print null terminated string __________;;;;;;;;;;;;;;;;;;;;;;;;



pnt:; string address in r13

cmp byte [r13],0x00
je pnt_end

mov rax,1
mov rdi,1
mov rsi,r13
mov rdx,1
syscall

inc r13
jmp pnt
pnt_end:
ret




;;;;;;;;;;;;;;;;;;;;;;________ strings compare function __________;;;;;;;;;;;;;;;;;;;;;;;;
strcmp_:;strcmp_( str1 , str2 ) : return value in r9 , returns 2 if equal , 1 not equal two strings with different lenghts  , 0 not equal the two strings have same lenght

mov r8,0
mov r9,0
mov r10,0
mov rax,0
mov rbx,0
mov r11,1

strcmp1:

mov al,byte [r12 + r8]
mov bl,byte [r13 + r8]


cmp rax,0x0A
cmove  r9,r11


cmp rbx,0x00
cmove  r10,r11

add r9,r10
cmp r9,2
je end



inc r8

sub bl,al
je strcmp1

end:
ret
;;;;;;;;;;;;;;;;;;;;;;________ get file size __________;;;;;;;;;;;;;;;;;;;;;;;;

file_size:
;stat	sys_newstat	fs/stat.c     code        4
;%rdi                        	%rsi
;const char __user * filename	struct stat __user * statbuf
mov rax,4
mov rsi,stat
syscall
mov rbx,[stat + 48 ]
ret
;;;;;;;;;;;;;;;;;;;;;;________ read file __________;;;;;;;;;;;;;;;;;;;;;;;;

read_file: ; read_file(file path , file buffer address)
push rsi
;open the file and get the file descriptor
mov rax,2
;mov rdi,fileName
mov rsi,o_rdonly ; read only
syscall


push rax

;read file contents and stores it in fileBuffer memory address
mov rax,0
pop rdi
pop rsi
mov rdx,1000
syscall

ret
;;;;;;;;;;;;;;;;;;;;;;________ read from stdin_________;;;;;;;;;;;;;;;;;;;;;;;;
readStdin_:
mov rax,0
mov rdi,0
mov rsi,rbx
mov rdx,rcx
syscall
ret
;;;;;;;;;;;;;;;;;;;;;;________write to screen_________;;;;;;;;;;;;;;;;;;;;;;;;
write1:;write(rbx=string eddress,rcx=number of characters to print) > prints chars

mov rax,1
mov rdi,1
mov rsi,rbx
mov rdx,rcx
syscall
ret

;;;;;;;;;;;;;;;;;;;;;;________integer to ascii function_________;;;;;;;;;;;;;;;;;;;;;;;;

itoa1:;itoa(rax=integer number) returns the string address  in 
     ; rdi and the string length in  r9 
     
mov r9,0    
mov rbx,10
mov r12,0
l1:
mov rdx,0
;div explained : div x  ;divides rax by x and stores the result in rax and the remainder in rdx
;You're actually dividing a 128-bit number in RDX:RAX by RCX. So if RDX is uninitialized the result will likely ;be larger than 64-bits, resulting in an overflow exception. Try adding a CQO before the division to sign-extend RAX into RDX.
div rbx ;rax=12,rdx=1;

add rdx,48
mov byte [result + r9],dl
inc r9
cmp rax,0
jne l1

lea rdx,[temp]
;mov rdi,result
mov rcx,r9
dec rcx
l2:

mov r12b,byte [result+rcx]
mov byte [rdx],r12b
inc rdx
dec rcx
cmp rcx,0
jge l2

mov rdi,temp
ret

;;;;;;;;;;;;;;;;;;;;;;________ascii to to integer function_________;;;;;;;;;;;;;;;;;;;;;;;;

atoi_:;atoi(r11= ascii number address ) result returned in r9  , a null byte should be placed at the end 
     ; of the string number for length calculation
		mov rcx,0

		mov r8,0
		mov r9,0
		mov rax,1
		mov r12,10

calc_length: ;  calculate the length of the "string" number
		
		cmp byte [r11+rcx],0x0A
		
		je atoi1
		inc rcx
		
		jmp calc_length
atoi1: ;lets convert the number from ascii to decimal and  eliminate none-digits strings
            
		dec rcx          

		mov r8b,byte [r11+rcx] 
		
		
        cmp r8,47
        jbe atoi_error
        
        cmp r8,58
        jae atoi_error
		
		sub r8,48 
		push rax  
		mul r8 
		add r9,rax  
		
		pop rax 
		mul r12 

		mov r8,0 
    
		cmp rcx,0         
		jne atoi1
		
		ret
atoi_error:
;mov rbx,asciiError
;mov rcx,asciiErrorLen
;call write1
ret



;;;;;;;;;;;;;;;;;;;;;;________exit function_________;;;;;;;;;;;;;;;;;;;;;;;;
exit_:
mov rax,60
mov rdi,0

syscall
