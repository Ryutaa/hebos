;the ipl of the hebos
;TAB=4
ORG 0x7c00
BITS 16

;FAT12 BPB
    
BS_JmpBoot      JMP entry
                DB  0x90        ;なんか知らんけどこれが要るらしい。
BS_OEMName      DB  "hebOS   "
BPB_BytsPerSec  DW  512
BPB_SecPerClus  DB  1
BPB_RsvdSecCnt  DW  1           ;予約領域のセクタ数
BPB_NumFATs     DB  2           ;FATの数。予備も含めて2にする。
BPB_RootEntCnt  DW  224         ;ルートディレクトリに含まれるディレクトリエントリ数
BPB_TotSec16    DW  2880        ;総セクタ数
BPB_Media       DB  0xf0        ;メディアのタイプ
BPB_FATSz16     DW  9           ;FAT１個のセクタ数
BPB_SecPerTrk   DW  18          ;1トラックのセクタ数
BPB_NumHeads    DW  2           ;ヘッドの数
BPB_HiddSec     DD  0           ;このボリュームよりも前にあるセクタ数。パーティションを区切ってないので0。
BPB_TotSec32    DD  0           ;総セクタ数。FAT12/16で総セクタ数0x10000未満なら0。

BS_DrvNum       DB  0           ;BIOSで使われるドライブ番号。フロッピーは0x00。
BS_Reserved1    DB  0           ;予約(WindowsNTで使用)。らしいがよくわからない。0でいいらしい。
BS_BootSig      DB  0x29        ;この下の3つのフィールドを使う時、0x29を入れるらしい
BS_VolID        DD  0xffffffff  ;ボリュームのID。多分なんでもいい。
BS_VolLab       DB  "hebOS      "   ;ボリュームラベル。ディスクの名前らしい。
BS_FilSysType   DB  "FAT12   "  ;フォーマット名

putloop:
	MOV AL, [SI]            ;msg文字列の先頭をALに入れる
    MOV AH, 0x0e            ;１文字ずつ表示のするモード
    MOV BX, 15              ;カラーコード
    INT 0x10                ;BIOS割り込み。ALに入ってる文字を表示する。
    ADD SI, 1               ;1文字進める
	CMP AL, 0               ;ALが0かどうか
	JNE putloop
	RET	

error:
	MOV	SI, errmsg
	CALL putloop
	HLT

ltoc:
	XOR	DX, DX
	DIV WORD[BPB_SecPerTrk]	;S = (LBA mod SPT) + 1
	INC DL
	MOV BYTE[physicalS], DL
	XOR DX, DX
	DIV WORD[BPB_NumHeads]
	MOV	BYTE[physicalC], AL
	MOV BYTE[physicalH], DL
	RET
	
physicalS DB 0x00
physicalC DB 0x00
physicalH DB 0x00

loader:
	CALL ltoc
	MOV	AH, 0x02
	MOV	AL, 0x01
	MOV CH, BYTE[physicalC]
	MOV CL, BYTE[physicalS]
	MOV DH, BYTE[physicalH]
	MOV	DL, BYTE[BS_DrvNum]
	MOV BX, WORD[startadd]
	ADD	BX, 0x20
	MOV WORD[startadd], BX
	MOV ES, BX
	MOV BX, 0x0000
	INT 0x13
	JC	error
	RET

startadd DW 0x0800

read:
	MOV AX, WORD[startLBA]
	CALL loader
	ADD WORD[startLBA], 1
	MOV AX, WORD[startLBA]
	MOV DX, WORD[endLBA]
	CMP AX, DX
	JA  fin
	JMP read

startLBA DW 1
endLBA	 DW 359

errmsg:
	DB	0x0a, 0x0a
	DB	"ERROR !"
	DB	0x0a
	DB	0

suc:
	DB	0x0a, 0x0a
	DB	"SUCCESS !"
	DB	0x0a
	DB	0

entry:
    XOR AX, AX              ;レジスタを初期化していく
	MOV SS, AX
	MOV SP, 0x7c00
	MOV DS, AX
	MOV ES, AX

	MOV SI, msg
	CALL putloop
	
	JMP read

fin:
	JMP 0xc200

msg:
    DB  0x0a, 0x0a          ;改行コード2つ
    DB  "Hello !"
    DB  0x0a                ;改行コード
    DB  0                   ;終端



TIMES 510 - ($ - $$) DB 0

	DW	0xAA55
