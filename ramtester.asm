#make_bin#

; BIN is plain binary format similar to .com format, but not limited to 1 segment;
; All values between # are directives, these values are saved into a separate .binf file.
; Before loading .bin file emulator reads .binf file with the same file name.

; All directives are optional, if you don't need them, delete them.

; set loading address, .bin file will be loaded to this address:
#LOAD_SEGMENT=0000h#
#LOAD_OFFSET=0000h#

; set entry point:
#CS=0000h#	; same as loading segment
#IP=0000h#	; same as loading offset

; set segment registers
#DS=0000h#	; same as loading segment
#ES=0000h#	; same as loading segment

; set stack
#SS=0000h#	; same as loading segment
#SP=FFFEh#	; set to top of loading segment

; set general registers (optional)
#AX=0000h#
#BX=0000h#
#CX=0000h#
#DX=0000h#
#SI=0000h#
#DI=0000h#
#BP=0000h#

; add your code here
 jmp     st1 
;proteus allows you to change the reset address - hence changing it to 00000H - so every time 
;system is reset it will go and execute the instruction at address 00000H - which is jmp st1
         db     1021 dup(0)
;jmp st1 will take up 3 bytes in memory - another 509 bytes are filled with '0s'
;1021 + 3 bytes = 1024 bytes
;first 1 k of memory is IVT - 00000 -00002H will now have the jmp instruction. 00003H - 001FFH will
;have 00000 - as vector number 0 to 79H are unused
;IVT entry for 80H - address for entry is 80H x 4 is 00200H       
;code segment will be in ROM         
st1:      cli 
; intialize ds, es,ss to start of RAM - that is 01000h - as you need r/w capability for DS,ES & SS
; pl note you cannot use db to store data in the RAM.You have to use a MOV instruction. 
; so if you want to do dat1 db 69H to the RAM- We have to use the equ command
; dat1 equ 0002h
; mov al,69h
; mov dat1,al
;0002H is the offset in data segmnet where you are storing the data.
;db can be used only to store data in code segment
          mov  ax,01000h ;initialising segments with start of RAM1
          mov  ds,ax
          mov  es,ax
          mov  ss,ax
          mov  sp,0FFFEH
          
		  
          mov  al,10000000b  ;control word of first 8255A initialising port b and c as output.   
      	  out  06h,al        
        
		
          mov  al,10001001b ; control word of second 8255A initialising port a,b as output and port c as input  
          out  0Eh,al        
         
                                                 
POLLING : in   al,0Ch  ; ;Keep polling port C until you get 1 from the Test switch 
          mov  bl,01h
          cmp  bl,al 
          jnz POLLING
TRUE: 
           mov dx,00h

START:     
          mov bh,11111110b ;for comparing 0
          mov ch,00000001b ;for comparing 1
         
          
          mov cl,08			 
                           
          ;for reading and writing 1's
START1:   
          mov al,dl
          out 08h,al
          mov al,dh
          and al,10111111b      ;Turn on write enable of 6164
          or  al,00100000b      ;Turn off read enable!
          and al,01111111b      ;Turn on CE!
          
          out 0Ah,al	
		  
          mov  al,10000000b    ;control word of 3rd 8255A initialising port A as output to write data
          out  16h,al  

          mov al,ch    ; Write from Port A of 3rd 8255 to 6164 
          out 10h,al 
		  
          mov al,dh
          and al,11011111b      ;Turn on read enable
          or  al,01000000b      ;Turn off write enable dash
          and  al,01111111b     ;Turn on CE             
          out 0Ah,al
		  
          mov  al,10010000b    ;control word of 3rd 8255A initialising port A as input to read data
          out  16h,al  
		  
	  in al,10h
          
          mov bl,ch
          cmp al,bl
          jnz FAIL  

         ;for reading and writing 0's	

          mov al,dl
          out 08h,al
 
          mov al,dh
          and al,10111111b      ;Turn on write enable dash
          or  al,00100000b      ;Turn off read enable
          and  al,01111111b     ;Turn on CE
          
          out 0Ah,al
          
	  mov  al,10000000b    ;control word of 3rd 8255A initialising port A as output to write data
          out  16h,al                             
                                      
          mov al,bh     ; Write from Port A of 3rd 8255 to 6164
          out 10h,al    	

          mov al,dh
          and al,11011111b      ;Turn on read enable
          or  al,01000000b      ;Turn off write enable dash  
          and al,01111111b     ;Turn on CE              
          out 0Ah,al
                  
    

          mov  al,10010000b    ;control word of 3rd 8255A initialising port A as input to write data
          out  16h,al         
          
          in al,10h
          
          mov bl,bh
          cmp al,bl
          jnz FAIL   
         
          
          ROL ch,1 
          ROL bh,1
         
          dec cl
          jnz START1
          inc dx   
          cmp dx,8192d
	  jz PASS
          jmp  START
                                 		 
         ;to display FAIL on LED             
           

FAIL:     mov al,0FFh  
          out 04h,al    
          
          
          mov al,01h    
          out 02h,al     
          
          mov al,8eh        ;For displaying  F          
          out 04h,al 
          
          
          mov al,02h
          out 02h,al        
          
          mov al,88h        ;For displaying A
          out 04h,al
          
          mov al,00
          out 02h,al
          
          mov al,0FFh
          out 04h,al 
          
           mov al,04h
          out 02h,al
          
          
          mov al,0F9h        ;For displaying I
          out 04h,al  
          
          
          mov al,08h
          out 02h,al 

          
          mov al,0c7h        ;For displaying L
          out 04h,al 
          
          mov al,00
          out 02h,al
          
          mov al,0ffh
          out 04h,al     
                             ; for the recursion of the program 
          in   al,0Ch
          mov  bl,01h
          cmp  bl,al 
          jz TRUE  
                            
          
          jmp FAIL
                         
         ;to display Pass on LED       

           
                    
PASS:      mov al,0FFh
          out 04,al 
          
          
          mov al,01h
          out 02h,al 
          
          mov al,8ch       ;for displaying  P
          out 04,al 
          
          mov al,02h
          out 02h,al 
          
          mov al,88h       ;for displaying A
          out 04,al
          
          mov al,04h
          out 02h,al 
          
          mov al,92h	   ;for displaying S
          out 04,al         
          
          
          mov al,08h
          out 02h,al 
          
          mov al,92h	  ;for displaying S
          out 04,al 
          
          mov al,00
          out 02h,al
          
          mov al,0ffh
          out 04h,al      
          		;this for the recursion of the program 
          in  al,0Ch
          mov bl,01h
          cmp bl,al 
          jz TRUE  
                            
          
          jmp PASS
                                               
		  
		  