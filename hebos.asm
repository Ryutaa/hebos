ORG 0xc200
BITS 16

    CLI
    LGDT gdt_info
    MOV EAX, CR0
    OR EAX, 1
    MOV CR0, EAX
    JMP 0x08:Protected_Mode     ;Code descriptor(0x08)をセレクト

    

gdt_info:
    DW 8*3  ;GDTのサイズ 8byte*3
    DD _gdt ;GDTのアドレス

_gdt:					;GDT
	; Null descriptor
    DW 0x0000
    DW 0x0000
    DW 0x0000		
    DW 0x0000		
		
    ; Code descriptor				
    DW 0xFFFF			; Segment Limit Low
    DW 0x0000		; Base Address Low
    DB 0x00			; Base Address Mid
    DB 10011010b		; P, DPL(6 ~ 5), S, Type(3 ~ 0)
    DB 11001111b		; G, D/B, AVL (53 ~ 52), Segment Limit High(51 ~ 48)
    DB 0x00             ; Base Address High

    ; Data descriptor
    DW 0xFFFF			; Segment Limit Low
    DW 0x0000		; Base Address Low
    DB 0x00			; Base Address Mid
    DB 10010010b		; P, DPL(6 ~ 5), S, Type(3 ~ 0)
    DB 11001111b		; G, D/B, AVL (53 ~ 52), Segment Limit High(51 ~ 48)
    DB 0x00			; Base Address High	

BITS 32
Protected_Mode:
    ;Data descriptorをセレクト
    MOV AX, 0x10
    MOV SS, AX
    MOV ES, AX
    MOV FS, AX
    MOV GS, AX
    MOV DS, AX

    MOV ESP, 90000h     ;ESPの値は考え直した方がいいかも
