
;CodeVisionAVR C Compiler V2.05.0 Professional
;(C) Copyright 1998-2010 Pavel Haiduc, HP InfoTech s.r.l.
;http://www.hpinfotech.com

;Chip type                : ATmega16L
;Program type             : Application
;Clock frequency          : 8,000000 MHz
;Memory model             : Small
;Optimize for             : Size
;(s)printf features       : int, width
;(s)scanf features        : int, width
;External RAM size        : 0
;Data Stack size          : 256 byte(s)
;Heap size                : 0 byte(s)
;Promote 'char' to 'int'  : Yes
;'char' is unsigned       : Yes
;8 bit enums              : Yes
;global 'const' stored in FLASH: No
;Enhanced core instructions    : On
;Smart register allocation     : On
;Automatic register allocation : On

	#pragma AVRPART ADMIN PART_NAME ATmega16L
	#pragma AVRPART MEMORY PROG_FLASH 16384
	#pragma AVRPART MEMORY EEPROM 512
	#pragma AVRPART MEMORY INT_SRAM SIZE 1119
	#pragma AVRPART MEMORY INT_SRAM START_ADDR 0x60

	#define CALL_SUPPORTED 1

	.LISTMAC
	.EQU UDRE=0x5
	.EQU RXC=0x7
	.EQU USR=0xB
	.EQU UDR=0xC
	.EQU SPSR=0xE
	.EQU SPDR=0xF
	.EQU EERE=0x0
	.EQU EEWE=0x1
	.EQU EEMWE=0x2
	.EQU EECR=0x1C
	.EQU EEDR=0x1D
	.EQU EEARL=0x1E
	.EQU EEARH=0x1F
	.EQU WDTCR=0x21
	.EQU MCUCR=0x35
	.EQU GICR=0x3B
	.EQU SPL=0x3D
	.EQU SPH=0x3E
	.EQU SREG=0x3F

	.DEF R0X0=R0
	.DEF R0X1=R1
	.DEF R0X2=R2
	.DEF R0X3=R3
	.DEF R0X4=R4
	.DEF R0X5=R5
	.DEF R0X6=R6
	.DEF R0X7=R7
	.DEF R0X8=R8
	.DEF R0X9=R9
	.DEF R0XA=R10
	.DEF R0XB=R11
	.DEF R0XC=R12
	.DEF R0XD=R13
	.DEF R0XE=R14
	.DEF R0XF=R15
	.DEF R0X10=R16
	.DEF R0X11=R17
	.DEF R0X12=R18
	.DEF R0X13=R19
	.DEF R0X14=R20
	.DEF R0X15=R21
	.DEF R0X16=R22
	.DEF R0X17=R23
	.DEF R0X18=R24
	.DEF R0X19=R25
	.DEF R0X1A=R26
	.DEF R0X1B=R27
	.DEF R0X1C=R28
	.DEF R0X1D=R29
	.DEF R0X1E=R30
	.DEF R0X1F=R31

	.EQU __SRAM_START=0x0060
	.EQU __SRAM_END=0x045F
	.EQU __DSTACK_SIZE=0x0100
	.EQU __HEAP_SIZE=0x0000
	.EQU __CLEAR_SRAM_SIZE=__SRAM_END-__SRAM_START+1

	.MACRO __CPD1N
	CPI  R30,LOW(@0)
	LDI  R26,HIGH(@0)
	CPC  R31,R26
	LDI  R26,BYTE3(@0)
	CPC  R22,R26
	LDI  R26,BYTE4(@0)
	CPC  R23,R26
	.ENDM

	.MACRO __CPD2N
	CPI  R26,LOW(@0)
	LDI  R30,HIGH(@0)
	CPC  R27,R30
	LDI  R30,BYTE3(@0)
	CPC  R24,R30
	LDI  R30,BYTE4(@0)
	CPC  R25,R30
	.ENDM

	.MACRO __CPWRR
	CP   R@0,R@2
	CPC  R@1,R@3
	.ENDM

	.MACRO __CPWRN
	CPI  R@0,LOW(@2)
	LDI  R30,HIGH(@2)
	CPC  R@1,R30
	.ENDM

	.MACRO __ADDB1MN
	SUBI R30,LOW(-@0-(@1))
	.ENDM

	.MACRO __ADDB2MN
	SUBI R26,LOW(-@0-(@1))
	.ENDM

	.MACRO __ADDW1MN
	SUBI R30,LOW(-@0-(@1))
	SBCI R31,HIGH(-@0-(@1))
	.ENDM

	.MACRO __ADDW2MN
	SUBI R26,LOW(-@0-(@1))
	SBCI R27,HIGH(-@0-(@1))
	.ENDM

	.MACRO __ADDW1FN
	SUBI R30,LOW(-2*@0-(@1))
	SBCI R31,HIGH(-2*@0-(@1))
	.ENDM

	.MACRO __ADDD1FN
	SUBI R30,LOW(-2*@0-(@1))
	SBCI R31,HIGH(-2*@0-(@1))
	SBCI R22,BYTE3(-2*@0-(@1))
	.ENDM

	.MACRO __ADDD1N
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	SBCI R22,BYTE3(-@0)
	SBCI R23,BYTE4(-@0)
	.ENDM

	.MACRO __ADDD2N
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	SBCI R24,BYTE3(-@0)
	SBCI R25,BYTE4(-@0)
	.ENDM

	.MACRO __SUBD1N
	SUBI R30,LOW(@0)
	SBCI R31,HIGH(@0)
	SBCI R22,BYTE3(@0)
	SBCI R23,BYTE4(@0)
	.ENDM

	.MACRO __SUBD2N
	SUBI R26,LOW(@0)
	SBCI R27,HIGH(@0)
	SBCI R24,BYTE3(@0)
	SBCI R25,BYTE4(@0)
	.ENDM

	.MACRO __ANDBMNN
	LDS  R30,@0+(@1)
	ANDI R30,LOW(@2)
	STS  @0+(@1),R30
	.ENDM

	.MACRO __ANDWMNN
	LDS  R30,@0+(@1)
	ANDI R30,LOW(@2)
	STS  @0+(@1),R30
	LDS  R30,@0+(@1)+1
	ANDI R30,HIGH(@2)
	STS  @0+(@1)+1,R30
	.ENDM

	.MACRO __ANDD1N
	ANDI R30,LOW(@0)
	ANDI R31,HIGH(@0)
	ANDI R22,BYTE3(@0)
	ANDI R23,BYTE4(@0)
	.ENDM

	.MACRO __ANDD2N
	ANDI R26,LOW(@0)
	ANDI R27,HIGH(@0)
	ANDI R24,BYTE3(@0)
	ANDI R25,BYTE4(@0)
	.ENDM

	.MACRO __ORBMNN
	LDS  R30,@0+(@1)
	ORI  R30,LOW(@2)
	STS  @0+(@1),R30
	.ENDM

	.MACRO __ORWMNN
	LDS  R30,@0+(@1)
	ORI  R30,LOW(@2)
	STS  @0+(@1),R30
	LDS  R30,@0+(@1)+1
	ORI  R30,HIGH(@2)
	STS  @0+(@1)+1,R30
	.ENDM

	.MACRO __ORD1N
	ORI  R30,LOW(@0)
	ORI  R31,HIGH(@0)
	ORI  R22,BYTE3(@0)
	ORI  R23,BYTE4(@0)
	.ENDM

	.MACRO __ORD2N
	ORI  R26,LOW(@0)
	ORI  R27,HIGH(@0)
	ORI  R24,BYTE3(@0)
	ORI  R25,BYTE4(@0)
	.ENDM

	.MACRO __DELAY_USB
	LDI  R24,LOW(@0)
__DELAY_USB_LOOP:
	DEC  R24
	BRNE __DELAY_USB_LOOP
	.ENDM

	.MACRO __DELAY_USW
	LDI  R24,LOW(@0)
	LDI  R25,HIGH(@0)
__DELAY_USW_LOOP:
	SBIW R24,1
	BRNE __DELAY_USW_LOOP
	.ENDM

	.MACRO __GETD1S
	LDD  R30,Y+@0
	LDD  R31,Y+@0+1
	LDD  R22,Y+@0+2
	LDD  R23,Y+@0+3
	.ENDM

	.MACRO __GETD2S
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	LDD  R24,Y+@0+2
	LDD  R25,Y+@0+3
	.ENDM

	.MACRO __PUTD1S
	STD  Y+@0,R30
	STD  Y+@0+1,R31
	STD  Y+@0+2,R22
	STD  Y+@0+3,R23
	.ENDM

	.MACRO __PUTD2S
	STD  Y+@0,R26
	STD  Y+@0+1,R27
	STD  Y+@0+2,R24
	STD  Y+@0+3,R25
	.ENDM

	.MACRO __PUTDZ2
	STD  Z+@0,R26
	STD  Z+@0+1,R27
	STD  Z+@0+2,R24
	STD  Z+@0+3,R25
	.ENDM

	.MACRO __CLRD1S
	STD  Y+@0,R30
	STD  Y+@0+1,R30
	STD  Y+@0+2,R30
	STD  Y+@0+3,R30
	.ENDM

	.MACRO __POINTB1MN
	LDI  R30,LOW(@0+(@1))
	.ENDM

	.MACRO __POINTW1MN
	LDI  R30,LOW(@0+(@1))
	LDI  R31,HIGH(@0+(@1))
	.ENDM

	.MACRO __POINTD1M
	LDI  R30,LOW(@0)
	LDI  R31,HIGH(@0)
	LDI  R22,BYTE3(@0)
	LDI  R23,BYTE4(@0)
	.ENDM

	.MACRO __POINTW1FN
	LDI  R30,LOW(2*@0+(@1))
	LDI  R31,HIGH(2*@0+(@1))
	.ENDM

	.MACRO __POINTD1FN
	LDI  R30,LOW(2*@0+(@1))
	LDI  R31,HIGH(2*@0+(@1))
	LDI  R22,BYTE3(2*@0+(@1))
	LDI  R23,BYTE4(2*@0+(@1))
	.ENDM

	.MACRO __POINTB2MN
	LDI  R26,LOW(@0+(@1))
	.ENDM

	.MACRO __POINTW2MN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	.ENDM

	.MACRO __POINTBRM
	LDI  R@0,LOW(@1)
	.ENDM

	.MACRO __POINTWRM
	LDI  R@0,LOW(@2)
	LDI  R@1,HIGH(@2)
	.ENDM

	.MACRO __POINTBRMN
	LDI  R@0,LOW(@1+(@2))
	.ENDM

	.MACRO __POINTWRMN
	LDI  R@0,LOW(@2+(@3))
	LDI  R@1,HIGH(@2+(@3))
	.ENDM

	.MACRO __POINTWRFN
	LDI  R@0,LOW(@2*2+(@3))
	LDI  R@1,HIGH(@2*2+(@3))
	.ENDM

	.MACRO __GETD1N
	LDI  R30,LOW(@0)
	LDI  R31,HIGH(@0)
	LDI  R22,BYTE3(@0)
	LDI  R23,BYTE4(@0)
	.ENDM

	.MACRO __GETD2N
	LDI  R26,LOW(@0)
	LDI  R27,HIGH(@0)
	LDI  R24,BYTE3(@0)
	LDI  R25,BYTE4(@0)
	.ENDM

	.MACRO __GETB1MN
	LDS  R30,@0+(@1)
	.ENDM

	.MACRO __GETB1HMN
	LDS  R31,@0+(@1)
	.ENDM

	.MACRO __GETW1MN
	LDS  R30,@0+(@1)
	LDS  R31,@0+(@1)+1
	.ENDM

	.MACRO __GETD1MN
	LDS  R30,@0+(@1)
	LDS  R31,@0+(@1)+1
	LDS  R22,@0+(@1)+2
	LDS  R23,@0+(@1)+3
	.ENDM

	.MACRO __GETBRMN
	LDS  R@0,@1+(@2)
	.ENDM

	.MACRO __GETWRMN
	LDS  R@0,@2+(@3)
	LDS  R@1,@2+(@3)+1
	.ENDM

	.MACRO __GETWRZ
	LDD  R@0,Z+@2
	LDD  R@1,Z+@2+1
	.ENDM

	.MACRO __GETD2Z
	LDD  R26,Z+@0
	LDD  R27,Z+@0+1
	LDD  R24,Z+@0+2
	LDD  R25,Z+@0+3
	.ENDM

	.MACRO __GETB2MN
	LDS  R26,@0+(@1)
	.ENDM

	.MACRO __GETW2MN
	LDS  R26,@0+(@1)
	LDS  R27,@0+(@1)+1
	.ENDM

	.MACRO __GETD2MN
	LDS  R26,@0+(@1)
	LDS  R27,@0+(@1)+1
	LDS  R24,@0+(@1)+2
	LDS  R25,@0+(@1)+3
	.ENDM

	.MACRO __PUTB1MN
	STS  @0+(@1),R30
	.ENDM

	.MACRO __PUTW1MN
	STS  @0+(@1),R30
	STS  @0+(@1)+1,R31
	.ENDM

	.MACRO __PUTD1MN
	STS  @0+(@1),R30
	STS  @0+(@1)+1,R31
	STS  @0+(@1)+2,R22
	STS  @0+(@1)+3,R23
	.ENDM

	.MACRO __PUTB1EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMWRB
	.ENDM

	.MACRO __PUTW1EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMWRW
	.ENDM

	.MACRO __PUTD1EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMWRD
	.ENDM

	.MACRO __PUTBR0MN
	STS  @0+(@1),R0
	.ENDM

	.MACRO __PUTBMRN
	STS  @0+(@1),R@2
	.ENDM

	.MACRO __PUTWMRN
	STS  @0+(@1),R@2
	STS  @0+(@1)+1,R@3
	.ENDM

	.MACRO __PUTBZR
	STD  Z+@1,R@0
	.ENDM

	.MACRO __PUTWZR
	STD  Z+@2,R@0
	STD  Z+@2+1,R@1
	.ENDM

	.MACRO __GETW1R
	MOV  R30,R@0
	MOV  R31,R@1
	.ENDM

	.MACRO __GETW2R
	MOV  R26,R@0
	MOV  R27,R@1
	.ENDM

	.MACRO __GETWRN
	LDI  R@0,LOW(@2)
	LDI  R@1,HIGH(@2)
	.ENDM

	.MACRO __PUTW1R
	MOV  R@0,R30
	MOV  R@1,R31
	.ENDM

	.MACRO __PUTW2R
	MOV  R@0,R26
	MOV  R@1,R27
	.ENDM

	.MACRO __ADDWRN
	SUBI R@0,LOW(-@2)
	SBCI R@1,HIGH(-@2)
	.ENDM

	.MACRO __ADDWRR
	ADD  R@0,R@2
	ADC  R@1,R@3
	.ENDM

	.MACRO __SUBWRN
	SUBI R@0,LOW(@2)
	SBCI R@1,HIGH(@2)
	.ENDM

	.MACRO __SUBWRR
	SUB  R@0,R@2
	SBC  R@1,R@3
	.ENDM

	.MACRO __ANDWRN
	ANDI R@0,LOW(@2)
	ANDI R@1,HIGH(@2)
	.ENDM

	.MACRO __ANDWRR
	AND  R@0,R@2
	AND  R@1,R@3
	.ENDM

	.MACRO __ORWRN
	ORI  R@0,LOW(@2)
	ORI  R@1,HIGH(@2)
	.ENDM

	.MACRO __ORWRR
	OR   R@0,R@2
	OR   R@1,R@3
	.ENDM

	.MACRO __EORWRR
	EOR  R@0,R@2
	EOR  R@1,R@3
	.ENDM

	.MACRO __GETWRS
	LDD  R@0,Y+@2
	LDD  R@1,Y+@2+1
	.ENDM

	.MACRO __PUTBSR
	STD  Y+@1,R@0
	.ENDM

	.MACRO __PUTWSR
	STD  Y+@2,R@0
	STD  Y+@2+1,R@1
	.ENDM

	.MACRO __MOVEWRR
	MOV  R@0,R@2
	MOV  R@1,R@3
	.ENDM

	.MACRO __INWR
	IN   R@0,@2
	IN   R@1,@2+1
	.ENDM

	.MACRO __OUTWR
	OUT  @2+1,R@1
	OUT  @2,R@0
	.ENDM

	.MACRO __CALL1MN
	LDS  R30,@0+(@1)
	LDS  R31,@0+(@1)+1
	ICALL
	.ENDM

	.MACRO __CALL1FN
	LDI  R30,LOW(2*@0+(@1))
	LDI  R31,HIGH(2*@0+(@1))
	CALL __GETW1PF
	ICALL
	.ENDM

	.MACRO __CALL2EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMRDW
	ICALL
	.ENDM

	.MACRO __GETW1STACK
	IN   R26,SPL
	IN   R27,SPH
	ADIW R26,@0+1
	LD   R30,X+
	LD   R31,X
	.ENDM

	.MACRO __GETD1STACK
	IN   R26,SPL
	IN   R27,SPH
	ADIW R26,@0+1
	LD   R30,X+
	LD   R31,X+
	LD   R22,X
	.ENDM

	.MACRO __NBST
	BST  R@0,@1
	IN   R30,SREG
	LDI  R31,0x40
	EOR  R30,R31
	OUT  SREG,R30
	.ENDM


	.MACRO __PUTB1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RNS
	MOVW R26,R@0
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RNS
	MOVW R26,R@0
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RNS
	MOVW R26,R@0
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	CALL __PUTDP1
	.ENDM


	.MACRO __GETB1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R30,Z
	.ENDM

	.MACRO __GETB1HSX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R31,Z
	.ENDM

	.MACRO __GETW1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R0,Z+
	LD   R31,Z
	MOV  R30,R0
	.ENDM

	.MACRO __GETD1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R0,Z+
	LD   R1,Z+
	LD   R22,Z+
	LD   R23,Z
	MOVW R30,R0
	.ENDM

	.MACRO __GETB2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R26,X
	.ENDM

	.MACRO __GETW2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	.ENDM

	.MACRO __GETD2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R1,X+
	LD   R24,X+
	LD   R25,X
	MOVW R26,R0
	.ENDM

	.MACRO __GETBRSX
	MOVW R30,R28
	SUBI R30,LOW(-@1)
	SBCI R31,HIGH(-@1)
	LD   R@0,Z
	.ENDM

	.MACRO __GETWRSX
	MOVW R30,R28
	SUBI R30,LOW(-@2)
	SBCI R31,HIGH(-@2)
	LD   R@0,Z+
	LD   R@1,Z
	.ENDM

	.MACRO __GETBRSX2
	MOVW R26,R28
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	LD   R@0,X
	.ENDM

	.MACRO __GETWRSX2
	MOVW R26,R28
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	LD   R@0,X+
	LD   R@1,X
	.ENDM

	.MACRO __LSLW8SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R31,Z
	CLR  R30
	.ENDM

	.MACRO __PUTB1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __CLRW1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X,R30
	.ENDM

	.MACRO __CLRD1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X+,R30
	ST   X+,R30
	ST   X,R30
	.ENDM

	.MACRO __PUTB2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z,R26
	.ENDM

	.MACRO __PUTW2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z+,R26
	ST   Z,R27
	.ENDM

	.MACRO __PUTD2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z+,R26
	ST   Z+,R27
	ST   Z+,R24
	ST   Z,R25
	.ENDM

	.MACRO __PUTBSRX
	MOVW R30,R28
	SUBI R30,LOW(-@1)
	SBCI R31,HIGH(-@1)
	ST   Z,R@0
	.ENDM

	.MACRO __PUTWSRX
	MOVW R30,R28
	SUBI R30,LOW(-@2)
	SBCI R31,HIGH(-@2)
	ST   Z+,R@0
	ST   Z,R@1
	.ENDM

	.MACRO __PUTB1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __MULBRR
	MULS R@0,R@1
	MOVW R30,R0
	.ENDM

	.MACRO __MULBRRU
	MUL  R@0,R@1
	MOVW R30,R0
	.ENDM

	.MACRO __MULBRR0
	MULS R@0,R@1
	.ENDM

	.MACRO __MULBRRU0
	MUL  R@0,R@1
	.ENDM

	.MACRO __MULBNWRU
	LDI  R26,@2
	MUL  R26,R@0
	MOVW R30,R0
	MUL  R26,R@1
	ADD  R31,R0
	.ENDM

;NAME DEFINITIONS FOR GLOBAL VARIABLES ALLOCATED TO REGISTERS
	.DEF _font_epp=R5
	.DEF _meny=R4
	.DEF _sek=R7
	.DEF _chislo=R6
	.DEF _mesec=R9
	.DEF _god=R8
	.DEF _den_nedeli=R11
	.DEF _bud_temp=R10
	.DEF _button=R13
	.DEF _but_pause=R12

	.CSEG
	.ORG 0x00

;START OF CODE MARKER
__START_OF_CODE:

;INTERRUPT VECTORS
	JMP  __RESET
	JMP  0x00
	JMP  0x00
	JMP  _timer2_comp_isr
	JMP  _timer2_ovf_isr
	JMP  0x00
	JMP  _timer1_compa_isr
	JMP  0x00
	JMP  0x00
	JMP  _timer0_ovf_isr
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  _ana_comp_isr
	JMP  0x00
	JMP  0x00
	JMP  _timer0_comp_isr
	JMP  0x00

_den_nedeli_txt:
	.DB  0x19,0x18,0x17,0xF,0xE,0xF,0x15,0x26
	.DB  0x17,0x12,0x14,0xFF,0xC,0x1C,0x18,0x1A
	.DB  0x17,0x12,0x14,0xFF,0x0,0x0,0x0,0x0
	.DB  0x1B,0x1A,0xF,0xE,0xA,0xFF,0x0,0x0
	.DB  0x0,0x0,0x0,0x0,0x21,0xF,0x1C,0xC
	.DB  0xF,0x1A,0xD,0xFF,0x0,0x0,0x0,0x0
	.DB  0x19,0x29,0x1C,0x17,0x12,0x20,0xA,0xFF
	.DB  0x0,0x0,0x0,0x0,0x1B,0x1D,0xB,0xB
	.DB  0x18,0x1C,0xA,0xFF,0x0,0x0,0x0,0x0
	.DB  0xC,0x18,0x1B,0x14,0x1A,0xF,0x1B,0xF
	.DB  0x17,0x26,0xF,0xFF
_den_nedeli_letter:
	.DB  0x19,0x17,0xC,0x1C,0x1B,0x1A,0x21,0x1C
	.DB  0x19,0x1C,0x1B,0xB,0xC,0x1B
_name_mesec_txt:
	.DB  0x29,0x17,0xC,0xA,0x1A,0x29,0xFF,0x0
	.DB  0x0,0x1E,0xF,0xC,0x1A,0xA,0x15,0x29
	.DB  0xFF,0x0,0x16,0xA,0x1A,0x1C,0xA,0xFF
	.DB  0x0,0x0,0x0,0xA,0x19,0x1A,0xF,0x15
	.DB  0x29,0xFF,0x0,0x0,0x16,0xA,0x29,0xFF
	.DB  0x0,0x0,0x0,0x0,0x0,0x12,0x28,0x17
	.DB  0x29,0xFF,0x0,0x0,0x0,0x0,0x12,0x28
	.DB  0x15,0x29,0xFF,0x0,0x0,0x0,0x0,0xA
	.DB  0xC,0xD,0x1D,0x1B,0x1C,0xA,0xFF,0x0
	.DB  0x1B,0xF,0x17,0x1C,0x29,0xB,0x1A,0x29
	.DB  0xFF,0x18,0x14,0x1C,0x29,0xB,0x1A,0x29
	.DB  0xFF,0x0,0x17,0x18,0x29,0xB,0x1A,0x29
	.DB  0xFF,0x0,0x0,0xE,0xF,0x14,0xA,0xB
	.DB  0x1A,0x29,0xFF,0x0
_symbols:
	.DB  0x3E,0x51,0x49,0x45,0x3E,0x0,0x42,0x7F
	.DB  0x40,0x0,0x42,0x61,0x51,0x49,0x46,0x21
	.DB  0x41,0x45,0x4B,0x31,0x18,0x14,0x12,0x7F
	.DB  0x10,0x27,0x45,0x45,0x45,0x39,0x3C,0x4A
	.DB  0x49,0x49,0x30,0x1,0x71,0x9,0x5,0x3
	.DB  0x36,0x49,0x49,0x49,0x36,0x6,0x49,0x49
	.DB  0x29,0x1E,0x7F,0x7F,0x41,0x7F,0x7F,0x0
	.DB  0x0,0x7F,0x7F,0x0,0x61,0x71,0x59,0x4F
	.DB  0x47,0x41,0x49,0x49,0x7F,0x7F,0x1F,0x1F
	.DB  0x10,0x7F,0x7F,0x4F,0x4F,0x49,0x79,0x79
	.DB  0x7F,0x7F,0x49,0x79,0x79,0x1,0x71,0x79
	.DB  0xF,0x7,0x7F,0x7F,0x49,0x7F,0x7F,0x5F
	.DB  0x5F,0x51,0x7F,0x7F,0x7F,0x7F,0x41,0x7F
	.DB  0x7F,0x0,0x1,0x7F,0x7F,0x0,0x63,0x73
	.DB  0x59,0x4F,0x47,0x63,0x63,0x49,0x7F,0x77
	.DB  0x1F,0x1F,0x10,0x7F,0x7F,0x6F,0x6F,0x49
	.DB  0x79,0x79,0x7F,0x7F,0x49,0x7B,0x7B,0x3
	.DB  0x73,0x79,0xF,0x7,0x77,0x7F,0x49,0x7F
	.DB  0x77,0x6F,0x6F,0x49,0x7F,0x7F,0x7F,0x41
	.DB  0x41,0x7F,0x7F,0x0,0x0,0x7F,0x7F,0x0
	.DB  0x61,0x71,0x59,0x4F,0x47,0x41,0x49,0x49
	.DB  0x7F,0x7F,0x1F,0x10,0x10,0x7F,0x7F,0x4F
	.DB  0x49,0x49,0x79,0x79,0x7F,0x49,0x49,0x79
	.DB  0x79,0x1,0x1,0x1,0x7F,0x7F,0x7F,0x49
	.DB  0x49,0x7F,0x7F,0x1F,0x11,0x11,0x7F,0x7F
	.DB  0x7F,0x41,0x41,0x7F,0x7F,0x0,0x1,0x7F
	.DB  0x7F,0x0,0x63,0x71,0x59,0x4F,0x47,0x63
	.DB  0x41,0x49,0x7F,0x7F,0x1F,0x10,0x10,0x7F
	.DB  0x7F,0x6F,0x49,0x49,0x79,0x79,0x7F,0x49
	.DB  0x49,0x7B,0x7B,0x3,0x1,0x1,0x7F,0x7F
	.DB  0x7F,0x49,0x49,0x7F,0x7F,0x1F,0x11,0x11
	.DB  0x7F,0x7F,0x3E,0x7F,0x41,0x7F,0x3E,0x0
	.DB  0x2,0x7F,0x7F,0x0,0x62,0x73,0x59,0x4F
	.DB  0x46,0x22,0x63,0x49,0x7F,0x36,0x18,0x14
	.DB  0x12,0x7F,0x7F,0x2F,0x6F,0x45,0x7D,0x39
	.DB  0x3E,0x7F,0x49,0x7B,0x32,0x3,0x73,0x79
	.DB  0xF,0x7,0x36,0x7F,0x49,0x7F,0x36,0x2E
	.DB  0x6F,0x49,0x7F,0x3E,0x3E,0x41,0x41,0x7F
	.DB  0x3E,0x0,0x2,0x7F,0x7F,0x0,0x62,0x71
	.DB  0x59,0x4F,0x46,0x22,0x41,0x49,0x7F,0x36
	.DB  0x18,0x14,0x12,0x7F,0x7F,0x2F,0x45,0x45
	.DB  0x7D,0x39,0x3E,0x49,0x49,0x7B,0x32,0x3
	.DB  0x71,0x79,0xF,0x7,0x36,0x49,0x49,0x7F
	.DB  0x36,0x26,0x49,0x49,0x7F,0x3E
_simvol_buk:
	.DB  0x7C,0x12,0x12,0x7C,0xAA,0x7E,0x4A,0x4A
	.DB  0x32,0xAA,0x7E,0x4A,0x4A,0x34,0xAA,0x7E
	.DB  0x2,0x2,0xAA,0x0,0x60,0x3C,0x22,0x3E
	.DB  0x60,0x7E,0x4A,0x4A,0xAA,0x0,0x24,0x42
	.DB  0x4A,0x34,0xAA,0x66,0x18,0x7E,0x18,0x66
	.DB  0x7E,0x10,0x8,0x7E,0xAA,0x7C,0x11,0x9
	.DB  0x7C,0xAA,0x7E,0x18,0x24,0x42,0xAA,0x78
	.DB  0x4,0x2,0x7E,0xAA,0x7E,0x4,0x8,0x4
	.DB  0x7E,0x7E,0x8,0x8,0x7E,0xAA,0x3C,0x42
	.DB  0x42,0x3C,0xAA,0x7E,0x2,0x2,0x7E,0xAA
	.DB  0x7E,0x12,0x12,0xC,0xAA,0x3C,0x42,0x42
	.DB  0x24,0xAA,0x2,0x7E,0x2,0xAA,0x0,0x4E
	.DB  0x50,0x50,0x3E,0xAA,0xC,0x12,0x7E,0x12
	.DB  0xC,0x66,0x18,0x18,0x66,0xAA,0x7E,0x40
	.DB  0x40,0x7E,0xC0,0xE,0x10,0x10,0x7E,0xAA
	.DB  0x7E,0x40,0x7E,0x40,0x7E,0x7E,0x40,0x7E
	.DB  0x40,0xFE,0x2,0x7E,0x48,0x30,0xAA,0x7E
	.DB  0x48,0x30,0x0,0x7E,0x7E,0x48,0x30,0xAA
	.DB  0x0,0x24,0x42,0x4A,0x3C,0xAA,0x7E,0x8
	.DB  0x3C,0x42,0x3C,0x4C,0x32,0x12,0x7E,0xAA
	.DB  0x0,0x0,0xAA,0xAA,0x0,0x40,0xAA,0xAA
	.DB  0xAA,0x0,0x7E,0x4,0x8,0x10,0x7E,0x0
	.DB  0x0,0x0,0x0,0x0,0x8,0x8,0x8,0x8
	.DB  0x8,0x8,0x8,0x3E,0x8,0x8,0x6,0x9
	.DB  0x9,0x6,0xAA,0x3E,0x41,0x41,0x41,0x22
	.DB  0x4,0x3F,0x44,0x20,0xAA,0x8,0x8,0x8
	.DB  0xAA,0x0,0x4C,0x52,0x52,0x4C,0xAA,0x0
	.DB  0xAA,0xAA,0xAA,0xAA,0x0,0x5F,0xAA,0x0
	.DB  0x0,0x24,0x48,0x48,0x24,0x48,0x0,0x24
	.DB  0x0,0x0,0x0,0x0,0x18,0x3C,0x42,0xFF
_dnei_v_mesc:
	.DB  0x1F,0x1D,0x1F,0x1E,0x1F,0x1E,0x1F,0x1F
	.DB  0x1E,0x1F,0x1E,0x1F
_banya_prognoz:
	.DB  0xB,0xA,0x17,0x29,0x2A,0xB,0x1D,0xE
	.DB  0xF,0x1C,0x2A,0x37,0x2A,0xC,0x2A,0xFF
_banya_add:
	.DB  0x19,0x18,0xE,0x14,0x12,0x17,0x26,0x2A
	.DB  0xE,0x1A,0x18,0xC,0xA,0x2A,0xFF
_pump_is_on:
	.DB  0xC,0x14,0x15,0x28,0x21,0xF,0x17,0x2A
	.DB  0x17,0xA,0x1B,0x18,0x1B,0xFF
_sensors_txt:
	.DB  0xE,0xA,0x1C,0x21,0x12,0x14,0x12,0x2A
	.DB  0xFF
_banya_txt:
	.DB  0xB,0xA,0x17,0x29,0x2A,0xFF
_outside_txt:
	.DB  0x1D,0x15,0x12,0x20,0xA,0x2A,0xFF
_underground_txt:
	.DB  0x19,0x18,0xE,0x19,0x18,0x15,0x2A,0xFF
_bez_banya_txt:
	.DB  0xB,0xF,0x10,0x1D,0x16,0x17,0xA,0x29
	.DB  0x2A,0xB,0xA,0x17,0x29,0x2A,0xFF
_home_txt:
	.DB  0xE,0x18,0x16,0x2A,0xFF
_water_txt:
	.DB  0xC,0x18,0xE,0xA,0x2A,0xFF
_budilnik_txt:
	.DB  0xB,0x1D,0xE,0x12,0x15,0x26,0x17,0x12
	.DB  0x14,0x2A,0xFF
_korekt_txt:
	.DB  0x14,0x18,0x1A,0x1A,0xF,0x14,0x20,0x12
	.DB  0x29,0x2A,0x2A,0xFF
_nastroiki_txt:
	.DB  0x1D,0x1B,0x1C,0xA,0x17,0x18,0xC,0x14
	.DB  0x12,0x2A,0xFF
_den_txt:
	.DB  0xE,0xF,0x17,0x26,0xFF
_data_txt:
	.DB  0xE,0xA,0x1C,0xA,0xFF
_god_txt:
	.DB  0xD,0x18,0xE,0xFF
_font_zifr_txt:
	.DB  0x0,0x1,0x2,0x3,0x4,0x5,0x6,0x7
	.DB  0x8,0x9,0x2A,0xFF
_nastr_stroki_txt:
	.DB  0x17,0xA,0x1B,0x1C,0x1A,0x18,0x13,0x14
	.DB  0xA,0x2A,0xFF
_animation_txt:
	.DB  0xA,0x17,0x12,0x16,0xA,0x20,0x12,0x29
	.DB  0x2A,0xFF
_complete_txt:
	.DB  0xD,0x18,0x1C,0x18,0xC,0x17,0x18,0x1B
	.DB  0x1C,0x26,0x2A,0x19,0x1A,0x12,0x2A,0x32
	.DB  0x2A,0xFF
_turning_txt:
	.DB  0xC,0x14,0x15,0x28,0x21,0xF,0x17,0x12
	.DB  0xF,0x2A,0x19,0x1A,0x12,0x2A,0x32,0x2A
	.DB  0xFF
_delay_time_txt:
	.DB  0xC,0x1A,0xF,0x16,0x29,0x2A,0x19,0x1A
	.DB  0x18,0xD,0x1A,0xF,0xC,0xA,0x2A,0xFF
_bit_mask_G100:
	.DB  0xF8,0xFF,0xFC,0xFF,0xFE,0xFF,0xFF,0xFF

;REGISTER BIT VARIABLES INITIALIZATION
__REG_BIT_VARS:
	.DW  0x8120

;DATA STACK END MARKER INITIALIZATION
__DSTACK_END_INIT:
	.DB  'D','S','T','A','C','K','E','N','D',0

;HARDWARE STACK END MARKER INITIALIZATION
__HSTACK_END_INIT:
	.DB  'H','S','T','A','C','K','E','N','D',0

_0x3:
	.DB  0x0
_0x4:
	.DB  0x0
_0x5:
	.DB  0x1
_0x6:
	.DB  0x1C
_0x7:
	.DB  0x5
_0x8:
	.DB  0x0
_0x9:
	.DB  0x2
_0xA:
	.DB  0x0
_0xB:
	.DB  0x78
_0xC:
	.DB  0x0
_0xD:
	.DB  0x0
_0xE:
	.DB  0xA
_0xF:
	.DB  0x0
_0x10:
	.DB  0x0
_0x11:
	.DB  0x0
_0x12:
	.DB  0x0
_0x13:
	.DB  0x0,0x1,0x2,0x3,0x4,0x5,0x6,0x7
	.DB  0x8
_0x14:
	.DB  0x0
_0x15:
	.DB  0xCE,0x2
_0x16:
	.DB  0x0,0x0
_0x17:
	.DB  0x0,0x0
_0x18:
	.DB  0x58,0x2
_0x19:
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0
_0x1A:
	.DB  0x2C,0x1
_0x1B:
	.DB  0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	.DB  0x0,0x0
_0x1C:
	.DB  0x0,0x0,0x0,0x0,0x0,0x0
_0x1D:
	.DB  0x0
_0x1E:
	.DB  0x0
_0x1F:
	.DB  0x0,0x0
_0x2D:
	.DB  0x0
_0x2E:
	.DB  0x0
_0x2F:
	.DB  0x0
_0x30:
	.DB  0x0
_0x31:
	.DB  0x0,0x0
_0x32:
	.DB  0x0,0x0
_0xA1:
	.DB  0x26,0x4,0x61,0x4,0x9F,0x4,0xDA,0x4
	.DB  0x10,0x5,0x20,0x5,0xFA,0x4,0xB3,0x4
	.DB  0x65,0x4,0x1B,0x4,0xEB,0x3,0xEF,0x3
	.DB  0x1D,0x2,0xE0,0x1,0x92,0x1,0x49,0x1
	.DB  0x13,0x1,0xE,0x1,0x39,0x1,0x74,0x1
	.DB  0xAD,0x1,0xEB,0x1,0x25,0x2,0x3F,0x2
	.DB  0x52,0xB8,0xDE,0x3F,0x85,0xEB,0x1,0x40
	.DB  0x0,0x0,0x0,0x40,0x48,0xE1,0xFA,0x3F
	.DB  0x52,0xB8,0xDE,0x3F,0x14,0xAE,0x7,0x3F
	.DB  0xF6,0x28,0x9C,0xBF,0x5C,0x8F,0x12,0xC0
	.DB  0x66,0x66,0x26,0xC0,0xEC,0x51,0x18,0xC0
	.DB  0xCD,0xCC,0xCC,0xBF,0x8F,0xC2,0xF5,0x3D
	.DB  0x1F,0x85,0x8B,0xBF,0x66,0x66,0x6,0xC0
	.DB  0xD7,0xA3,0x20,0xC0,0x1F,0x85,0x1B,0xC0
	.DB  0x52,0xB8,0xDE,0xBF,0xA,0xD7,0x23,0xBE
	.DB  0xD7,0xA3,0xB0,0x3F,0x33,0x33,0xF3,0x3F
	.DB  0x33,0x33,0xF3,0x3F,0x0,0x0,0x0,0x40
	.DB  0x3D,0xA,0xF7,0x3F,0xE1,0x7A,0x54,0x3F
_0xE2:
	.DB  0x0
_0xE3:
	.DB  0x0
_0xE4:
	.DB  0x0
_0x29F:
	.DB  0xA,0x2,0x1A,0x0,0x14,0xA,0x0,0x0
	.DB  0x0

__GLOBAL_INI_TBL:
	.DW  0x02
	.DW  0x02
	.DW  __REG_BIT_VARS*2

	.DW  0x09
	.DW  __SRAM_START
	.DW  __DSTACK_END_INIT*2

	.DW  0x09
	.DW  0x44F
	.DW  __HSTACK_END_INIT*2

	.DW  0x01
	.DW  _temp1
	.DW  _0x3*2

	.DW  0x01
	.DW  _temp2
	.DW  _0x4*2

	.DW  0x01
	.DW  _flg_korr
	.DW  _0x5*2

	.DW  0x01
	.DW  _speed
	.DW  _0x6*2

	.DW  0x01
	.DW  _font_
	.DW  _0x7*2

	.DW  0x01
	.DW  _delayBan
	.DW  _0x8*2

	.DW  0x01
	.DW  _delayTime
	.DW  _0x9*2

	.DW  0x01
	.DW  _str_sec
	.DW  _0xA*2

	.DW  0x01
	.DW  _lightTime
	.DW  _0xB*2

	.DW  0x01
	.DW  _completeBeepTime
	.DW  _0xC*2

	.DW  0x01
	.DW  _timerLight
	.DW  _0xD*2

	.DW  0x01
	.DW  _alertTime
	.DW  _0xE*2

	.DW  0x01
	.DW  _timerAlert
	.DW  _0xF*2

	.DW  0x01
	.DW  _timerDrova
	.DW  _0x10*2

	.DW  0x01
	.DW  _tone
	.DW  _0x11*2

	.DW  0x01
	.DW  _timeToComplete
	.DW  _0x12*2

	.DW  0x09
	.DW  _ds_ar
	.DW  _0x13*2

	.DW  0x01
	.DW  _sensorsReadCount
	.DW  _0x14*2

	.DW  0x02
	.DW  _time
	.DW  _0x15*2

	.DW  0x02
	.DW  _sunriseToday
	.DW  _0x16*2

	.DW  0x02
	.DW  _sunsetToday
	.DW  _0x17*2

	.DW  0x02
	.DW  _tempComplete
	.DW  _0x18*2

	.DW  0x0C
	.DW  _temperature
	.DW  _0x19*2

	.DW  0x02
	.DW  _tempMin
	.DW  _0x1A*2

	.DW  0x0A
	.DW  _historyTemp
	.DW  _0x1B*2

	.DW  0x06
	.DW  _averageTemp
	.DW  _0x1C*2

	.DW  0x01
	.DW  _devices
	.DW  _0x1D*2

	.DW  0x01
	.DW  _animation
	.DW  _0x1E*2

	.DW  0x02
	.DW  _str_time
	.DW  _0x1F*2

	.DW  0x01
	.DW  _stroka_S0000004000
	.DW  _0x2D*2

	.DW  0x01
	.DW  _i_S0000004000
	.DW  _0x2E*2

	.DW  0x01
	.DW  _checkButton_S0000004000
	.DW  _0x2F*2

	.DW  0x01
	.DW  _checkEnd1_S0000004000
	.DW  _0x30*2

	.DW  0x02
	.DW  _pump_pause_S0000004000
	.DW  _0x31*2

	.DW  0x02
	.DW  _endSwitch1Pause_S0000004000
	.DW  _0x32*2

	.DW  0x01
	.DW  _count_S0000014000
	.DW  _0xE2*2

	.DW  0x01
	.DW  _tryCount_S0000014000
	.DW  _0xE3*2

	.DW  0x01
	.DW  _j_S0000014000
	.DW  _0xE4*2

	.DW  0x09
	.DW  0x04
	.DW  _0x29F*2

_0xFFFFFFFF:
	.DW  0

__RESET:
	CLI
	CLR  R30
	OUT  EECR,R30

;INTERRUPT VECTORS ARE PLACED
;AT THE START OF FLASH
	LDI  R31,1
	OUT  GICR,R31
	OUT  GICR,R30
	OUT  MCUCR,R30

;DISABLE WATCHDOG
	LDI  R31,0x18
	OUT  WDTCR,R31
	OUT  WDTCR,R30

;GLOBAL VARIABLES INITIALIZATION
	LDI  R30,LOW(__GLOBAL_INI_TBL*2)
	LDI  R31,HIGH(__GLOBAL_INI_TBL*2)
__GLOBAL_INI_NEXT:
	LPM  R24,Z+
	LPM  R25,Z+
	SBIW R24,0
	BREQ __GLOBAL_INI_END
	LPM  R26,Z+
	LPM  R27,Z+
	LPM  R0,Z+
	LPM  R1,Z+
	MOVW R22,R30
	MOVW R30,R0
__GLOBAL_INI_LOOP:
	LPM  R0,Z+
	ST   X+,R0
	SBIW R24,1
	BRNE __GLOBAL_INI_LOOP
	MOVW R30,R22
	RJMP __GLOBAL_INI_NEXT
__GLOBAL_INI_END:

;HARDWARE STACK POINTER INITIALIZATION
	LDI  R30,LOW(__SRAM_END-__HEAP_SIZE)
	OUT  SPL,R30
	LDI  R30,HIGH(__SRAM_END-__HEAP_SIZE)
	OUT  SPH,R30

;DATA STACK POINTER INITIALIZATION
	LDI  R28,LOW(__SRAM_START+__DSTACK_SIZE)
	LDI  R29,HIGH(__SRAM_START+__DSTACK_SIZE)

	JMP  _main

	.ESEG
	.ORG 0

	.DSEG
	.ORG 0x160

	.CSEG
;#define GETBIT(data, index) ((data & (1 << index)) == 0 ? 0 : 1)
;#include <mega16.h>
	#ifndef __SLEEP_DEFINED__
	#define __SLEEP_DEFINED__
	.EQU __se_bit=0x40
	.EQU __sm_mask=0xB0
	.EQU __sm_powerdown=0x20
	.EQU __sm_powersave=0x30
	.EQU __sm_standby=0xA0
	.EQU __sm_ext_standby=0xB0
	.EQU __sm_adc_noise_red=0x10
	.SET power_ctrl_reg=mcucr
	#endif
;#include <1wire.h>
;#include <ds18b20_.h>
;#include <delay.h>
;#define   BUT_OK      button==1
;#define   BUT_STEP    button==2
;#define   POWER       power
;#define   ON          1
;#define   OFF         0
;
;//*********************************************************************************************/
;unsigned char  error_ds18b20[], font_epp=2;
;
;bit  mig, flg_min=0, bud_flg=0, but_flg=0,  zv_kn=0,  zv_chs=1, but_on=0, line=0, power=1, temp5, flg_ds18b20=0,
;	pumpStatus=0, /*Состояние выхода насоса*/
;	banya_is_complete=0, //готова ли баня
;	needDrova=0,//Нужны ли дрова
;    endSwitch=0, //Состояние концевиков
;    noticeBanya=1 //Уведомления о бане
;;
;
;unsigned char       meny=10, sek=0, chislo=26, mesec=10, god=20, den_nedeli, bud_temp, button, but_pause=0,  z, z1, bud, temp, temp1=0, temp2=0, t, flg_korr=1, speed=28,  font_=5,

	.DSEG
;                    delayBan=0,
;                    delayTime=2,
;                    str_sec=0,
;                    ekran            [24],         // Экранный  буфер
;                    beg_info         [280],        // Бегущая строка в основном режиме
;                    rom_code         [2][9],       // массив с адресами найденых датчиков DS18B20
;                    budilnik_Install [9],          // храним настройки будильников
;                    budilnik_Interval[9],         // храним значение длительности сигнала будильника
;                    lightTime=120,/*Время освещения в секундах */
;                    completeBeepTime=0,
;                    timerLight=0,/*Время отчитываемое в системе на освещение*/
;                    alertTime=10, // Время работы тревожного сигнала из бани в секундах
;                    timerAlert=0, // отсчитываемое время  тревожного сигнала из бани в секундах
;                    timerDrova=0,
;                    tone=0, //Выбор тона звучания
;                    timeToComplete=0, //Время до готовности бани
;                        ;
;unsigned   int      budilnik_time    [9];          // храним время сработки будильников
;unsigned char ds_ar[]={0,1,2,3,4,5,6,7,8}, // Датчики привязанные к названиям
;                        sensorsReadCount=0; //
;
;
;flash const unsigned char
;        den_nedeli_txt  [7][12]= {{25,24,23,15,14,15,21,38,23,18,20,255},   // Понедельник     //  названия дней недели
;                                 {12,28,24,26,23,18,20,255},                // Вторник         //
;                                 {27,26,15,14,10,255},                      // Среда           //
;                                 {33,15,28,12,15,26,13,255},                // Четверг         //
;                                 {25,41,28,23,18,32,10,255},                // Пятница         //
;                                 {27,29,11,11,24,28,10,255},                // Суббота         //
;                                 {12,24,27,20,26,15,27,15,23,38,15,255}},   // Воскресенье     //
;        den_nedeli_letter[7][2]= {{25,23},                     // Пн              //  сокращенные названия дней недели
;                                 {12,28},                                   // Вт              //
;                                 {27,26},                                   // Ср              //
;                                 {33,28},                                   // Чт              //
;                                 {25,28},                                   // Пт              //
;                                 {27,11},                                   // Сб              //
;                                 {12,27}},                                 // Вс              //
;        name_mesec_txt  [12][9]= {{41,23,12,10,26,41,255},                  // Января
;                                 {30,15,12,26,10,21,41,255},                // Февраля
;                                 {22,10,26,28,10,255},                      // Марта
;                                 {10,25,26,15,21,41,255},                   // Апреля
;                                 {22,10,41,255},                            // Мая
;                                 {18,40,23,41,255},                         // Июня
;                                 {18,40,21,41,255},                         // Июля
;                                 {10,12,13,29,27,28,10,255},                // Августа
;                                 {27,15,23,28,41,11,26,41,255},             // Сентября
;                                 {24,20,28,41,11,26,41,255},                // Октября
;                                 {23,24,41,11,26,41,255},                   // Ноября
;                                 {14,15,20,10,11,26,41,255}},            // Декабря
;        symbols [7][10][5]=
;        {
;                    {
;                        { 0x3E, 0x51, 0x49, 0x45, 0x3E },  // 0
;                        { 0x00, 0x42, 0x7F, 0x40, 0x00 },  // 1
;                        { 0x42, 0x61, 0x51, 0x49, 0x46 },  // 2
;                        { 0x21, 0x41, 0x45, 0x4B, 0x31 },  // 3
;                        { 0x18, 0x14, 0x12, 0x7F, 0x10 },  // 4
;                        { 0x27, 0x45, 0x45, 0x45, 0x39 },  // 5
;                        { 0x3C, 0x4A, 0x49, 0x49, 0x30 },  // 6
;                        { 0x01, 0x71, 0x09, 0x05, 0x03 },  // 7
;                        { 0x36, 0x49, 0x49, 0x49, 0x36 },  // 8
;                        { 0x06, 0x49, 0x49, 0x29, 0x1E }  // 9
;                    }
;                    ,
;                    {
;                        //# if FONT==1    //  Шрифт цифр №1
;                        { 0x7F, 0x7F, 0x41, 0x7F, 0x7F },
;                        { 0x00, 0x00, 0x7F, 0x7F, 0x00 },
;                        { 0x61, 0x71, 0x59, 0x4F, 0x47 },
;                        { 0x41, 0x49, 0x49, 0x7F, 0x7F },
;                        { 0x1F, 0x1F, 0x10, 0x7F, 0x7F },
;                        { 0x4F, 0x4F, 0x49, 0x79, 0x79 },
;                        { 0x7F, 0x7F, 0x49, 0x79, 0x79 },
;                        { 0x01, 0x71, 0x79, 0x0F, 0x07 },
;                        { 0x7F, 0x7F, 0x49, 0x7F, 0x7F },
;                        { 0x5F, 0x5F, 0x51, 0x7F, 0x7F }
;                       // # endif
;                    }
;                    ,
;                       {
;                            // # if FONT==2    //  Шрифт цифр №2
;                            { 0x7F, 0x7F, 0x41, 0x7F, 0x7F },
;                            { 0x00, 0x01, 0x7F, 0x7F, 0x00 },
;                            { 0x63, 0x73, 0x59, 0x4F, 0x47 },
;                            { 0x63, 0x63, 0x49, 0x7F, 0x77 },
;                            { 0x1F, 0x1F, 0x10, 0x7F, 0x7F },
;                            { 0x6F, 0x6F, 0x49, 0x79, 0x79 },
;                            { 0x7F, 0x7F, 0x49, 0x7B, 0x7B },
;                            { 0x03, 0x73, 0x79, 0x0F, 0x07 },
;                            { 0x77, 0x7F, 0x49, 0x7F, 0x77 },
;                            { 0x6F, 0x6F, 0x49, 0x7F, 0x7F }
;                            // # endif
;                        }
;                        ,
;                         {
;                            // # if FONT==3    //  Шрифт цифр №3
;                            { 0x7F, 0x41, 0x41, 0x7F, 0x7F },
;                            { 0x00, 0x00, 0x7F, 0x7F, 0x00 },
;                            { 0x61, 0x71, 0x59, 0x4F, 0x47 },
;                            { 0x41, 0x49, 0x49, 0x7F, 0x7F },
;                            { 0x1F, 0x10, 0x10, 0x7F, 0x7F },
;                            { 0x4F, 0x49, 0x49, 0x79, 0x79 },
;                            { 0x7F, 0x49, 0x49, 0x79, 0x79 },
;                            { 0x01, 0x01, 0x01, 0x7F, 0x7F },
;                            { 0x7F, 0x49, 0x49, 0x7F, 0x7F },
;                            { 0x1F, 0x11, 0x11, 0x7F, 0x7F }
;                            //# endif
;                        }
;                            ,
;                            {
;                                    // # if FONT==4    //  Шрифт цифр №4
;                                    { 0x7F, 0x41, 0x41, 0x7F, 0x7F },
;                                    { 0x00, 0x01, 0x7F, 0x7F, 0x00 },
;                                    { 0x63, 0x71, 0x59, 0x4F, 0x47 },
;                                    { 0x63, 0x41, 0x49, 0x7F, 0x7F },
;                                    { 0x1F, 0x10, 0x10, 0x7F, 0x7F },
;                                    { 0x6F, 0x49, 0x49, 0x79, 0x79 },
;                                    { 0x7F, 0x49, 0x49, 0x7B, 0x7B },
;                                    { 0x03, 0x01, 0x01, 0x7F, 0x7F },
;                                    { 0x7F, 0x49, 0x49, 0x7F, 0x7F },
;                                    { 0x1F, 0x11, 0x11, 0x7F, 0x7F }
;                                    //# endif
;                            }
;                            ,
;                                {
;                                        //  FONT==5    //  Шрифт цифр №5
;                                        { 0x3E, 0x7F, 0x41, 0x7F, 0x3E },
;                                        { 0x00, 0x02, 0x7F, 0x7F, 0x00 },
;                                        { 0x62, 0x73, 0x59, 0x4F, 0x46 },
;                                        { 0x22, 0x63, 0x49, 0x7F, 0x36 },
;                                        { 0x18, 0x14, 0x12, 0x7F, 0x7F },
;                                        { 0x2F, 0x6F, 0x45, 0x7D, 0x39 },
;                                        { 0x3E, 0x7F, 0x49, 0x7B, 0x32 },
;                                        { 0x03, 0x73, 0x79, 0x0F, 0x07 },
;                                        { 0x36, 0x7F, 0x49, 0x7F, 0x36 },
;                                        { 0x2E, 0x6F, 0x49, 0x7F, 0x3E }
;                                }
;                                ,
;                                {
;                                    { 0x3E, 0x41, 0x41, 0x7F, 0x3E },
;                                    { 0x00, 0x02, 0x7F, 0x7F, 0x00 },
;                                    { 0x62, 0x71, 0x59, 0x4F, 0x46 },
;                                    { 0x22, 0x41, 0x49, 0x7F, 0x36 },
;                                    { 0x18, 0x14, 0x12, 0x7F, 0x7F },
;                                    { 0x2F, 0x45, 0x45, 0x7D, 0x39 },
;                                    { 0x3E, 0x49, 0x49, 0x7B, 0x32 },
;                                    { 0x03, 0x71, 0x79, 0x0F, 0x07 },
;                                    { 0x36, 0x49, 0x49, 0x7F, 0x36 },
;                                    { 0x26, 0x49, 0x49, 0x7F, 0x3E }
;                                }
;  },
;
;  simvol_buk [][5]=
;  {
;	{ 0x7C, 0x12, 0x12, 0x7C, 0xAA },  // А  10
;	{ 0x7E, 0x4A, 0x4A, 0x32, 0xAA },  // Б  11
;	{ 0x7E, 0x4A, 0x4A, 0x34, 0xAA },  // В  12
;	{ 0x7E, 0x02, 0x02, 0xAA, 0x00 },  // Г  13
;	{ 0x60, 0x3C, 0x22, 0x3E, 0x60 },  // Д  14
;	{ 0x7E, 0x4A, 0x4A, 0xAA, 0x00 },  // Е  15
;	{ 0x24, 0x42, 0x4A, 0x34, 0xAA },  // З  16
;	{ 0x66, 0x18, 0x7E, 0x18, 0x66 },  // Ж  17
;	{ 0x7E, 0x10, 0x08, 0x7E, 0xAA },  // И  18
;	{ 0x7C, 0x11, 0x09, 0x7C, 0xAA },  // И  19
;	{ 0x7E, 0x18, 0x24, 0x42, 0xAA },  // К  20
;	{ 0x78, 0x04, 0x02, 0x7E, 0xAA },  // Л  21
;	{ 0x7E, 0x04, 0x08, 0x04, 0x7E },  // М  22
;	{ 0x7E, 0x08, 0x08, 0x7E, 0xAA },  // Н  23
;	{ 0x3C, 0x42, 0x42, 0x3C, 0xAA },  // О  24
;	{ 0x7E, 0x02, 0x02, 0x7E, 0xAA },  // П  25
;	{ 0x7E, 0x12, 0x12, 0x0C, 0xAA },  // Р  26
;	{ 0x3C, 0x42, 0x42, 0x24, 0xAA },  // С  27
;	{ 0x02, 0x7E, 0x02, 0xAA, 0x00 },  // Т  28
;	{ 0x4E, 0x50, 0x50, 0x3E, 0xAA },  // У  29
;	{ 0x0C, 0x12, 0x7E, 0x12, 0x0C },  // Ф  30
;	{ 0x66, 0x18, 0x18, 0x66, 0xAA },  // Х  31
;	{ 0x7E, 0x40, 0x40, 0x7E, 0xC0 },  // Ц  32
;	{ 0x0E, 0x10, 0x10, 0x7E, 0xAA },  // Ч  33
;	{ 0x7E, 0x40, 0x7E, 0x40, 0x7E },  // Ш  34
;	{ 0x7E, 0x40, 0x7E, 0x40, 0xFE },  // Щ  35
;	{ 0x02, 0x7E, 0x48, 0x30, 0xAA },  // Ъ  36
;	{ 0x7E, 0x48, 0x30, 0x00, 0x7E },  // Ы  37
;	{ 0x7E, 0x48, 0x30, 0xAA, 0x00 },  // Ь  38
;	{ 0x24, 0x42, 0x4A, 0x3C, 0xAA },  // Э  39
;	{ 0x7E, 0x08, 0x3C, 0x42, 0x3C },  // Ю  40
;	{ 0x4C, 0x32, 0x12, 0x7E, 0xAA },  // Я  41
;	{ 0x00, 0x00, 0xAA, 0xAA, 0x00 },  // пробел              42
;    { 0x40, 0xAA, 0xAA, 0xAA, 0x00 },  // точка               43
;     { 0x7E, 0x04, 0x08, 0x10, 0x7E  },  //  Буква N   44
;    { 0x00, 0x00, 0x00, 0x00, 0x00 },  // "полный" пробел     45
;    { 0x08, 0x08, 0x08, 0x08, 0x08 },  // минус               46
;	{ 0x08, 0x08, 0x3E, 0x08, 0x08 },  // плюс                47
;	{ 0x06, 0x09, 0x09, 0x06, 0xAA },  // знак градуса        48
;    { 0x3E, 0x41, 0x41, 0x41, 0x22 },  // большая C           49
;    { 0x04, 0x3F, 0x44, 0x20, 0xAA },  // прописная t         50
;    { 0x08, 0x08, 0x08, 0xAA, 0x00 },  // маленький минус     51
;
;    { 0x4C, 0x52, 0x52, 0x4C, 0xAA  },  //Продолжение для No.        52
;
;    { 0x00, 0xAA, 0xAA, 0xAA, 0xAA },  // точка внизу _       53
;    { 0x00, 0x5F, 0xAA, 0x00, 0x00 },  // восклиц знак        54
;    { 0x24, 0x48, 0x48, 0x24, 0x48 },  // знак примерно        55
;    { 0x00, 0x24,0x00, 0x00, 0x00 },  // двоеточие        56
;    { 0x00, 0x18, 0x3c, 0x42, 0xff  }, // Иконка динамик 57
;
;    },
;dnei_v_mesc     []= {31,29,31,30,31,30,31,31,30,31,30,31},           // Количества дней по месяцам
;        banya_prognoz[]={11,10,23,41,42,11,29,14,15,28,42,55,42,12,42,255}, /*Баня будет  ~~ в */
;        banya_add[]={25,24,14,20,18,23,38,42,14,26,24,12,10,42,255}, /*Подкинь дрова!*/
;        pump_is_on[]={12,20,21,40,33,15,23,42,23,10,27,24,27,255},/*Включен насос*/
;        sensors_txt[]={14,10,28,33,18,20,18,42,255},
;        banya_txt[]={11,10,23,41,42,255},
;        outside_txt[]={29,21,18,32,10,42,255},
;        underground_txt[]={25,24,14,25,24,21,42,255},
;        bez_banya_txt[]={11,15,16,29,22,23,10,41,42,11,10,23,41,42,255},
;        home_txt[]={14,24,22,42,255},
;        water_txt[]={12,24,14,10,42,255},
;        budilnik_txt         [11]= {11,29,14,18,21,38,23,18,20,42,255},       // текст "Будильник"
;        korekt_txt           [12]= {20,24,26,26,15,20,32,18,41,42,42,255},    // текст "Коррекция"
;        nastroiki_txt       [11]= {29,27,28,10,23,24,12,20,18,42,255},       // текст "Установки"
;        den_txt              [5]= {14,15,23,38,255},                         // текст "День"
;        data_txt             [5]= {14,10,28,10,255},                         // текст "Дата"
;        god_txt              [4]= {13,24,14,255},                            // текст "Год"
;        font_zifr_txt         []= {0,1,2,3,4,5,6,7,8,9,42,255},         // Набор цифер
;        nastr_stroki_txt     [11]= {23,10,27,28,26,24,19,20,10,42,255},      // текст "Настройки"
;        animation_txt[]={10,23,18,22,10,32,18,41,42,255},
;        complete_txt[]={13,24,28,24,12,23,24,27,28,38,42,25,26,18,42,50,42,255},
;        turning_txt[] ={12,20,21,40,33,15,23,18,15,42,25,26,18,42,50,42,255},
;        delay_time_txt[] ={12,26,15,22,41,42,25,26,24,13,26,15,12,10,42,255},
;          ;
;
;eeprom signed int       korr_den=0, brigh_up_time=360, brigh_down_time=1380;
;eeprom unsigned char    brigh_up=9, str_period=61,  str=0x1B; //0x18;
;
;int
;    time=718,
;    sunriseToday=0,//Время восхода сегодня
;	sunsetToday=0,//Время заката сегодня
;    tempComplete=600,//  температура готовности бани
;    temperature [6]={0,0,0,0,0,0},
;    tempMin=300,
;    historyTemp[5]={0,0,0,0,0}, //История градусов в бане для прогноза
;    averageTemp[3]={0,0,0}; // Массив для усреденения значений от температуры
;unsigned char devices=0, simvol [58][5], animation=0;
;unsigned   int   Interval , Interval_2, data1, str_time=0;
;
;
;//___________________________Возвращает абсолютное значение числа_____________________________________
;signed int abs (signed int x)
; 0000 0111 {

	.CSEG
_abs:
; 0000 0112 if (x<0) x=(x*(-1));
;	x -> Y+0
	LDD  R26,Y+1
	TST  R26
	BRPL _0x20
	LD   R30,Y
	LDD  R31,Y+1
	LDI  R26,LOW(65535)
	LDI  R27,HIGH(65535)
	CALL __MULW12
	ST   Y,R30
	STD  Y+1,R31
; 0000 0113 return x;
_0x20:
	LD   R30,Y
	LDD  R31,Y+1
	ADIW R28,2
	RET
; 0000 0114 }
;
;//______вычислить день недели по дате(спасибо форумчанину DANKO c сайта "радиокот"за формулу  )_________
;unsigned char Day_week (void)
; 0000 0118 {
_Day_week:
; 0000 0119     unsigned char y=god, m=mesec, myday;
; 0000 011A    if (m > 2) { m -= 2;       }
	CALL __SAVELOCR4
;	y -> R17
;	m -> R16
;	myday -> R19
	MOV  R17,R8
	MOV  R16,R9
	CPI  R16,3
	BRLO _0x21
	CALL SUBOPT_0x0
	SBIW R30,2
	MOV  R16,R30
; 0000 011B    else       { m += 10; y--; }
	RJMP _0x22
_0x21:
	SUBI R16,-LOW(10)
	SUBI R17,1
_0x22:
; 0000 011C    myday = ((chislo + y + (y>>2) + ((31 * m) / 12)) % 7);
	MOV  R26,R6
	CLR  R27
	CLR  R30
	ADD  R26,R17
	ADC  R27,R30
	CALL SUBOPT_0x1
	CALL __ASRW2
	ADD  R30,R26
	ADC  R31,R27
	MOVW R22,R30
	LDI  R26,LOW(31)
	MUL  R16,R26
	MOVW R30,R0
	MOVW R26,R30
	LDI  R30,LOW(12)
	LDI  R31,HIGH(12)
	CALL __DIVW21
	MOVW R26,R22
	ADD  R26,R30
	ADC  R27,R31
	LDI  R30,LOW(7)
	LDI  R31,HIGH(7)
	CALL __MODW21
	MOV  R19,R30
; 0000 011D    return (myday) ? myday-1: 6;
	CPI  R19,0
	BREQ _0x23
	CALL SUBOPT_0x2
	SBIW R30,1
	RJMP _0x24
_0x23:
	LDI  R30,LOW(6)
_0x24:
	CALL __LOADLOCR4
	ADIW R28,4
	RET
; 0000 011E }
;
;//___________________________________________коррекция времени___________________________________________
;void correkt (void)
; 0000 0122 {
_correkt:
; 0000 0123         if(korr_den<0) {
	CALL SUBOPT_0x3
	BRPL _0x26
; 0000 0124         TCNT2=255+((korr_den%10)*25);
	CALL SUBOPT_0x4
	CALL SUBOPT_0x5
	SUBI R30,-LOW(255)
	OUT  0x24,R30
; 0000 0125          sek=59+((korr_den%600)/10);
	CALL SUBOPT_0x4
	CALL SUBOPT_0x6
	SUBI R30,-LOW(59)
	MOV  R7,R30
; 0000 0126          if (sek==60) {sek=0;}
	LDI  R30,LOW(60)
	CP   R30,R7
	BRNE _0x27
	CLR  R7
; 0000 0127             time=1439;
_0x27:
	LDI  R30,LOW(1439)
	LDI  R31,HIGH(1439)
	STS  _time,R30
	STS  _time+1,R31
; 0000 0128          }
; 0000 0129         else {
	RJMP _0x28
_0x26:
; 0000 012A          TCNT2=25*(korr_den%10);
	CALL SUBOPT_0x4
	CALL SUBOPT_0x5
	OUT  0x24,R30
; 0000 012B          sek=((korr_den%600)/10);
	CALL SUBOPT_0x4
	CALL SUBOPT_0x6
	MOV  R7,R30
; 0000 012C          }
_0x28:
; 0000 012D }
	RET
;
;//____________________________Гасим индикацию. (регулирую яркость индикации)________________________________
;interrupt [TIM0_COMP] void timer0_comp_isr(void)
; 0000 0131 {
_timer0_comp_isr:
; 0000 0132     PORTD.7=0;
	CBI  0x12,7
; 0000 0133     PORTD.7=1;
	SBI  0x12,7
; 0000 0134 }
	RETI
;
;//________Диамическая индикация.   вывод данных из экранного буфера на светодиодную матрицу_______________
;interrupt [TIM0_OVF] void timer0_ovf_isr(void)
; 0000 0138 {
_timer0_ovf_isr:
	ST   -Y,R0
	ST   -Y,R1
	ST   -Y,R15
	ST   -Y,R26
	ST   -Y,R27
	ST   -Y,R30
	ST   -Y,R31
	IN   R30,SREG
	ST   -Y,R30
; 0000 0139         static unsigned char stroka=0, i=0,checkButton=0,checkEnd1=0;

	.DSEG

	.CSEG

	.DSEG

	.CSEG

	.DSEG

	.CSEG

	.DSEG

	.CSEG
; 0000 013A         static unsigned int pump_pause=0,endSwitch1Pause=0;

	.DSEG

	.CSEG

	.DSEG

	.CSEG
; 0000 013B         bit pumpButtonClick=0;
; 0000 013C 
; 0000 013D         if (++stroka==8)  stroka=0;
;	pumpButtonClick -> R15.0
	CLR  R15
	LDS  R26,_stroka_S0000004000
	SUBI R26,-LOW(1)
	STS  _stroka_S0000004000,R26
	CPI  R26,LOW(0x8)
	BRNE _0x33
	LDI  R30,LOW(0)
	STS  _stroka_S0000004000,R30
; 0000 013E         PORTD.7=1;
_0x33:
	SBI  0x12,7
; 0000 013F         //включение напряжения на индикацию
; 0000 0140         PORTD.6=1;
	SBI  0x12,6
; 0000 0141         //Здесь должен быть построчный запуск матрицы
; 0000 0142         PORTC.1=0;
	CBI  0x15,1
; 0000 0143         for(i=0;i<=24;i++){
	LDI  R30,LOW(0)
	STS  _i_S0000004000,R30
_0x3B:
	LDS  R26,_i_S0000004000
	CPI  R26,LOW(0x19)
	BRSH _0x3C
; 0000 0144          PORTC.0=1;
	SBI  0x15,0
; 0000 0145          PORTA=0+(GETBIT((ekran [i]),stroka)<<stroka);
	LDS  R30,_i_S0000004000
	CALL SUBOPT_0x7
	LD   R1,Z
	LDS  R30,_stroka_S0000004000
	CALL SUBOPT_0x8
	BRNE _0x3F
	LDI  R30,LOW(0)
	RJMP _0x40
_0x3F:
	LDI  R30,LOW(1)
_0x40:
	MOV  R26,R30
	LDS  R30,_stroka_S0000004000
	CALL __LSLB12
	OUT  0x1B,R30
; 0000 0146          PORTC.0=0;
	CBI  0x15,0
; 0000 0147         }
	LDS  R30,_i_S0000004000
	SUBI R30,-LOW(1)
	STS  _i_S0000004000,R30
	RJMP _0x3B
_0x3C:
; 0000 0148         PORTC.1=1;
	SBI  0x15,1
; 0000 0149         PORTD.7=0;
	CBI  0x12,7
; 0000 014A 
; 0000 014B 
; 0000 014C 		/*Отслеживание кнопки насоса*/
; 0000 014D  		pumpButtonClick=PIND.5;
	CLT
	SBIC 0x10,5
	SET
	BLD  R15,0
; 0000 014E        	if(pumpButtonClick){
	SBRS R15,0
	RJMP _0x48
; 0000 014F             pump_pause++;
	LDI  R26,LOW(_pump_pause_S0000004000)
	LDI  R27,HIGH(_pump_pause_S0000004000)
	CALL SUBOPT_0x9
; 0000 0150        	        if(pump_pause>800 && !checkButton){
	CALL SUBOPT_0xA
	CPI  R26,LOW(0x321)
	LDI  R30,HIGH(0x321)
	CPC  R27,R30
	BRLO _0x4A
	LDS  R30,_checkButton_S0000004000
	CPI  R30,0
	BREQ _0x4B
_0x4A:
	RJMP _0x49
_0x4B:
; 0000 0151        		        pump_pause=0;
	CALL SUBOPT_0xB
; 0000 0152                     checkButton=1;
	LDI  R30,LOW(1)
	STS  _checkButton_S0000004000,R30
; 0000 0153        		        pumpStatus=!pumpStatus; /*Смена состояния насоса*/
	LDI  R30,LOW(8)
	EOR  R3,R30
; 0000 0154        		        PORTD.1=pumpStatus; //Включение/отключение насоса
	SBRC R3,3
	RJMP _0x4C
	CBI  0x12,1
	RJMP _0x4D
_0x4C:
	SBI  0x12,1
_0x4D:
; 0000 0155        	        }
; 0000 0156                 if(pump_pause>1000){pump_pause=801;}
_0x49:
	CALL SUBOPT_0xA
	CPI  R26,LOW(0x3E9)
	LDI  R30,HIGH(0x3E9)
	CPC  R27,R30
	BRLO _0x4E
	LDI  R30,LOW(801)
	LDI  R31,HIGH(801)
	STS  _pump_pause_S0000004000,R30
	STS  _pump_pause_S0000004000+1,R31
; 0000 0157         }
_0x4E:
; 0000 0158         else
	RJMP _0x4F
_0x48:
; 0000 0159         {
; 0000 015A             if(checkButton>0)
	LDS  R26,_checkButton_S0000004000
	CPI  R26,LOW(0x1)
	BRLO _0x50
; 0000 015B             {
; 0000 015C                 checkButton=0;
	LDI  R30,LOW(0)
	STS  _checkButton_S0000004000,R30
; 0000 015D                 pump_pause=0;
	CALL SUBOPT_0xB
; 0000 015E             }
; 0000 015F             //дребезг
; 0000 0160             if(pump_pause<20)
_0x50:
	CALL SUBOPT_0xA
	SBIW R26,20
	BRSH _0x51
; 0000 0161        	    {
; 0000 0162        		    pump_pause=0;
	CALL SUBOPT_0xB
; 0000 0163        	    }
; 0000 0164             else
	RJMP _0x52
_0x51:
; 0000 0165        	    /*тревога*/
; 0000 0166             {
; 0000 0167                 pump_pause=0;
	CALL SUBOPT_0xB
; 0000 0168                 timerAlert=alertTime;
	LDS  R30,_alertTime
	STS  _timerAlert,R30
; 0000 0169             }
_0x52:
; 0000 016A 
; 0000 016B         }
_0x4F:
; 0000 016C 
; 0000 016D 
; 0000 016E         //Концевик дома
; 0000 016F          if(PINC.4)
	SBIS 0x13,4
	RJMP _0x53
; 0000 0170          {      endSwitch1Pause++;
	LDI  R26,LOW(_endSwitch1Pause_S0000004000)
	LDI  R27,HIGH(_endSwitch1Pause_S0000004000)
	CALL SUBOPT_0x9
; 0000 0171                  if(endSwitch1Pause>800 && !checkEnd1)
	CALL SUBOPT_0xC
	CPI  R26,LOW(0x321)
	LDI  R30,HIGH(0x321)
	CPC  R27,R30
	BRLO _0x55
	LDS  R30,_checkEnd1_S0000004000
	CPI  R30,0
	BREQ _0x56
_0x55:
	RJMP _0x54
_0x56:
; 0000 0172                  {
; 0000 0173                         endSwitch1Pause=0;
	CALL SUBOPT_0xD
; 0000 0174                         checkEnd1=1;
	LDI  R30,LOW(1)
	STS  _checkEnd1_S0000004000,R30
; 0000 0175                         endSwitch=!endSwitch;
	LDI  R30,LOW(64)
	EOR  R3,R30
; 0000 0176                  }
; 0000 0177                  if(endSwitch1Pause>900) endSwitch1Pause=801;
_0x54:
	CALL SUBOPT_0xC
	CPI  R26,LOW(0x385)
	LDI  R30,HIGH(0x385)
	CPC  R27,R30
	BRLO _0x57
	LDI  R30,LOW(801)
	LDI  R31,HIGH(801)
	STS  _endSwitch1Pause_S0000004000,R30
	STS  _endSwitch1Pause_S0000004000+1,R31
; 0000 0178          }
_0x57:
; 0000 0179          else
	RJMP _0x58
_0x53:
; 0000 017A          {
; 0000 017B             if(checkEnd1){
	LDS  R30,_checkEnd1_S0000004000
	CPI  R30,0
	BREQ _0x59
; 0000 017C                 checkEnd1=0;
	LDI  R30,LOW(0)
	STS  _checkEnd1_S0000004000,R30
; 0000 017D                 endSwitch1Pause=0;
	CALL SUBOPT_0xD
; 0000 017E             }
; 0000 017F             if(endSwitch1Pause>0)
_0x59:
	CALL SUBOPT_0xC
	CALL __CPW02
	BRSH _0x5A
; 0000 0180             {
; 0000 0181                 endSwitch1Pause=0;
	CALL SUBOPT_0xD
; 0000 0182             }
; 0000 0183          }
_0x5A:
_0x58:
; 0000 0184 
; 0000 0185 
; 0000 0186        	//Если сработал концевик дома или в бане
; 0000 0187        	if( endSwitch && timerLight==0 ){
	SBRS R3,6
	RJMP _0x5C
	LDS  R26,_timerLight
	CPI  R26,LOW(0x0)
	BREQ _0x5D
_0x5C:
	RJMP _0x5B
_0x5D:
; 0000 0188        		timerLight=lightTime;
	LDS  R30,_lightTime
	STS  _timerLight,R30
; 0000 0189        	}
; 0000 018A        	//Если время истекло отключаем концевики
; 0000 018B        	if(timerLight==0 || endSwitch==0){
_0x5B:
	LDS  R26,_timerLight
	CPI  R26,LOW(0x0)
	BREQ _0x5F
	LDI  R26,0
	SBRC R3,6
	LDI  R26,1
	CPI  R26,LOW(0x0)
	BRNE _0x5E
_0x5F:
; 0000 018C             timerLight=0;
	LDI  R30,LOW(0)
	STS  _timerLight,R30
; 0000 018D        		endSwitch=0;
	CLT
	BLD  R3,6
; 0000 018E        	}
; 0000 018F         but_pause++;  if (but_pause==100)      { but_pause=0; but_on=1; }                 // если с момента прошлого нажатия кнопки прошло больше 0,3 сек - разрешаю очередное чтение кнопок
_0x5E:
	INC  R12
	LDI  R30,LOW(100)
	CP   R30,R12
	BRNE _0x61
	CLR  R12
	SET
	BLD  R2,6
; 0000 0190         if ((but_pause==30)&&(but_flg))        { but_flg=0; PORTB.5=0; TIMSK&=0xEF;}       // выключаю "писк" при нажатии кнопки
_0x61:
	LDI  R30,LOW(30)
	CP   R30,R12
	BRNE _0x63
	SBRC R2,3
	RJMP _0x64
_0x63:
	RJMP _0x62
_0x64:
	CLT
	BLD  R2,3
	CBI  0x18,5
	IN   R30,0x39
	ANDI R30,0xEF
	OUT  0x39,R30
; 0000 0191 
; 0000 0192         Interval++;   Interval_2++;                                                       //  отсчитываем интервал для бегущих строк и прочих нужд
_0x62:
	LDI  R26,LOW(_Interval)
	LDI  R27,HIGH(_Interval)
	CALL SUBOPT_0x9
	LDI  R26,LOW(_Interval_2)
	LDI  R27,HIGH(_Interval_2)
	CALL SUBOPT_0x9
; 0000 0193 }
	LD   R30,Y+
	OUT  SREG,R30
	LD   R31,Y+
	LD   R30,Y+
	LD   R27,Y+
	LD   R26,Y+
	LD   R15,Y+
	LD   R1,Y+
	LD   R0,Y+
	RETI
;
;//___________________________________Чтение состояния кнопок_______________________________________________
;unsigned char  button_read (void)
; 0000 0197 {
_button_read:
; 0000 0198     button=0;
	CLR  R13
; 0000 0199 
; 0000 019A     if ( (PIND.2==1 || PIND.4==1 ) && (but_on)){
	SBIC 0x10,2
	RJMP _0x68
	SBIS 0x10,4
	RJMP _0x6A
_0x68:
	SBRC R2,6
	RJMP _0x6B
_0x6A:
	RJMP _0x67
_0x6B:
; 0000 019B         if(PIND.2==1){
	SBIS 0x10,2
	RJMP _0x6C
; 0000 019C             button=2;
	LDI  R30,LOW(2)
	MOV  R13,R30
; 0000 019D         }
; 0000 019E         if(PIND.4==1){
_0x6C:
	SBIS 0x10,4
	RJMP _0x6D
; 0000 019F             button=1;
	LDI  R30,LOW(1)
	MOV  R13,R30
; 0000 01A0         }
; 0000 01A1         but_on=0;  but_pause=0;
_0x6D:
	CLT
	BLD  R2,6
	CLR  R12
; 0000 01A2 
; 0000 01A3         if (zv_kn) {but_flg=1; TIMSK|=0x10;}// Если не отключен - короткий писк динамика при нажатии кнопки .
	SBRS R2,4
	RJMP _0x6E
	SET
	BLD  R2,3
	IN   R30,0x39
	ORI  R30,0x10
	OUT  0x39,R30
; 0000 01A4         if (bud_flg) {bud_flg=0; button=0;} // Выключаем (если был включен) сигнал будильника.  это нужно чтоб можно было выключить сигнал будильника просто нажатием любой кнопки.
_0x6E:
	SBRS R2,2
	RJMP _0x6F
	CLT
	BLD  R2,2
	CLR  R13
; 0000 01A5         bud_flg=0;
_0x6F:
	CLT
	BLD  R2,2
; 0000 01A6     }
; 0000 01A7     return  button;
_0x67:
	MOV  R30,R13
	RET
; 0000 01A8 }
;
;//_____________________выщитываем время, следующего запуска бегущей строки _________________________________
;void str_pause (void)
; 0000 01AC {
_str_pause:
; 0000 01AD     str_time=time+(str_period/60);
	CALL SUBOPT_0xE
	CALL __DIVW21
	CALL SUBOPT_0xF
	ADD  R30,R26
	ADC  R31,R27
	STS  _str_time,R30
	STS  _str_time+1,R31
; 0000 01AE     str_sec=sek+(str_period%60);  if (str_sec >= 60) {str_sec=str_sec%60;  str_time++;}
	CALL SUBOPT_0xE
	CALL __MODW21
	ADD  R30,R7
	STS  _str_sec,R30
	LDS  R26,_str_sec
	CPI  R26,LOW(0x3C)
	BRLO _0x70
	CALL SUBOPT_0x10
	STS  _str_sec,R30
	LDI  R26,LOW(_str_time)
	LDI  R27,HIGH(_str_time)
	CALL SUBOPT_0x9
; 0000 01AF     if (str_time >=1440) {str_time-=1440;}
_0x70:
	LDS  R26,_str_time
	LDS  R27,_str_time+1
	CPI  R26,LOW(0x5A0)
	LDI  R30,HIGH(0x5A0)
	CPC  R27,R30
	BRLO _0x71
	LDS  R30,_str_time
	LDS  R31,_str_time+1
	SUBI R30,LOW(1440)
	SBCI R31,HIGH(1440)
	STS  _str_time,R30
	STS  _str_time+1,R31
; 0000 01B0 }
_0x71:
	RET
;
;
;
;//______________________________________Копируем буквы из Flash памяти в ОЗУ
;void font_cifri (void)
; 0000 01B6 {
_font_cifri:
; 0000 01B7         unsigned char temp,temp_srift,i;
; 0000 01B8         for (temp=0; temp<61; temp++) {
	CALL __SAVELOCR4
;	temp -> R17
;	temp_srift -> R16
;	i -> R19
	LDI  R17,LOW(0)
_0x73:
	CPI  R17,61
	BRLO PC+3
	JMP _0x74
; 0000 01B9             if(temp<10){
	CPI  R17,10
	BRSH _0x75
; 0000 01BA                 for (temp_srift=0; temp_srift<5; temp_srift++){
	LDI  R16,LOW(0)
_0x77:
	CPI  R16,5
	BRSH _0x78
; 0000 01BB                     simvol[temp] [temp_srift]=symbols[font_][temp] [temp_srift];
	LDI  R26,LOW(5)
	MUL  R17,R26
	MOVW R30,R0
	SUBI R30,LOW(-_simvol)
	SBCI R31,HIGH(-_simvol)
	MOVW R26,R30
	CALL SUBOPT_0x0
	ADD  R30,R26
	ADC  R31,R27
	PUSH R31
	PUSH R30
	LDS  R30,_font_
	LDI  R26,LOW(50)
	MUL  R30,R26
	MOVW R30,R0
	SUBI R30,LOW(-_symbols*2)
	SBCI R31,HIGH(-_symbols*2)
	MOVW R26,R30
	CALL SUBOPT_0x1
	MOVW R22,R26
	CALL SUBOPT_0x11
	MOVW R26,R22
	ADD  R26,R30
	ADC  R27,R31
	CALL SUBOPT_0x0
	ADD  R30,R26
	ADC  R31,R27
	LPM  R30,Z
	POP  R26
	POP  R27
	ST   X,R30
; 0000 01BC                 }
	SUBI R16,-1
	RJMP _0x77
_0x78:
; 0000 01BD             }
; 0000 01BE             else{
	RJMP _0x79
_0x75:
; 0000 01BF                     for (i=0; i<5; i++){
	LDI  R19,LOW(0)
_0x7B:
	CPI  R19,5
	BRSH _0x7C
; 0000 01C0                         simvol [temp] [i]= simvol_buk[temp-10] [i];
	LDI  R26,LOW(5)
	MUL  R17,R26
	MOVW R30,R0
	SUBI R30,LOW(-_simvol)
	SBCI R31,HIGH(-_simvol)
	MOVW R26,R30
	CALL SUBOPT_0x2
	ADD  R30,R26
	ADC  R31,R27
	MOVW R22,R30
	CALL SUBOPT_0x1
	SBIW R30,10
	CALL SUBOPT_0x11
	SUBI R30,LOW(-_simvol_buk*2)
	SBCI R31,HIGH(-_simvol_buk*2)
	MOVW R26,R30
	CALL SUBOPT_0x2
	ADD  R30,R26
	ADC  R31,R27
	LPM  R30,Z
	MOVW R26,R22
	ST   X,R30
; 0000 01C1                     }
	SUBI R19,-1
	RJMP _0x7B
_0x7C:
; 0000 01C2             }
_0x79:
; 0000 01C3         }
	SUBI R17,-1
	RJMP _0x73
_0x74:
; 0000 01C4 }
	CALL __LOADLOCR4
	RJMP _0x2020008
;
;//______Прерывание от компаратора(заходим сюда когда пропадает и когда появляется внешнее напряжение)______
;interrupt [ANA_COMP] void ana_comp_isr(void)
; 0000 01C8 {
_ana_comp_isr:
	CALL SUBOPT_0x12
; 0000 01C9         char j=0;
; 0000 01CA         if(ACSR&0x20)                // если пропало внешнее питания
	ST   -Y,R17
;	j -> R17
	LDI  R17,0
	SBIS 0x8,5
	RJMP _0x7D
; 0000 01CB         {
; 0000 01CC         banya_is_complete=1;
	SET
	BLD  R3,4
; 0000 01CD         POWER = OFF;                 // переходим на резервное питание от батареек
	CLT
	BLD  R3,0
; 0000 01CE         MCUCR=0b01110000;            // разрешаем усыплять контроллер по команде SLEEP (для мега16)
	LDI  R30,LOW(112)
	OUT  0x35,R30
; 0000 01CF         TCCR0=0x00;                  // останавливаем Т/С0
	LDI  R30,LOW(0)
	OUT  0x33,R30
; 0000 01D0         ADCSRA=0x00;                 // выключаю АЦП
	OUT  0x6,R30
; 0000 01D1         TIMSK&=0x7f;                 // запрещаю прерывание по совпадению Т2
	IN   R30,0x39
	ANDI R30,0x7F
	OUT  0x39,R30
; 0000 01D2         ADMUX= 0b00100111;           // выключаю ИОН для АЦП
	LDI  R30,LOW(39)
	OUT  0x7,R30
; 0000 01D3         PORTA=0;  DDRB=0b11110111;   // перевожу порты в состояние наменьшего потребления
	LDI  R30,LOW(0)
	OUT  0x1B,R30
	LDI  R30,LOW(247)
	OUT  0x17,R30
; 0000 01D4         PORTB=0; PORTC=0; PORTD=0;
	LDI  R30,LOW(0)
	OUT  0x18,R30
	OUT  0x15,R30
	OUT  0x12,R30
; 0000 01D5         }
; 0000 01D6         else                         // если  внешнее питания  появилось
	RJMP _0x7E
_0x7D:
; 0000 01D7         {
; 0000 01D8         POWER = ON;                  // переходим на внешнее питание
	SET
	BLD  R3,0
; 0000 01D9         MCUCR=0b00110000;            // запрещаем усыплять контроллер по команде  SLEEP
	LDI  R30,LOW(48)
	OUT  0x35,R30
; 0000 01DA         DDRB=0xE3;                   // возвращаем конфигурацию портов в рабочее состояние
	LDI  R30,LOW(227)
	OUT  0x17,R30
; 0000 01DB         TCCR0=0x03;                  // запускаем Т/С0
	LDI  R30,LOW(3)
	OUT  0x33,R30
; 0000 01DC         ADCSRA=0b10000011;           // включаю АЦП
	LDI  R30,LOW(131)
	OUT  0x6,R30
; 0000 01DD         TIMSK|=0x80;                 // разрешаю прерывание по совпадению Т2
	IN   R30,0x39
	ORI  R30,0x80
	OUT  0x39,R30
; 0000 01DE         ADMUX= 0b01100111;           // включаю ИОН для АЦП
	LDI  R30,LOW(103)
	OUT  0x7,R30
; 0000 01DF         str_pause ();                // выщитываем время, следующего запуска бегущей строки
	RCALL _str_pause
; 0000 01E0         devices=w1_search(0xf0,rom_code);
	CALL SUBOPT_0x13
; 0000 01E1             for(j=0;j<devices;j++){
	LDI  R17,LOW(0)
_0x80:
	LDS  R30,_devices
	CP   R17,R30
	BRSH _0x81
; 0000 01E2                 ds18b20_init( &rom_code[j][0], -45, 90, DS18B20_11BIT_RES );
	CALL SUBOPT_0x14
	CALL SUBOPT_0x15
; 0000 01E3             }
	SUBI R17,-1
	RJMP _0x80
_0x81:
; 0000 01E4         }
_0x7E:
; 0000 01E5 
; 0000 01E6 }
	LD   R17,Y+
	RJMP _0x29E
;
;//__________________________________________пищу динамиком__________________________________________________
;interrupt [TIM1_COMPA] void timer1_compa_isr(void)
; 0000 01EA {
_timer1_compa_isr:
	ST   -Y,R26
	ST   -Y,R30
	ST   -Y,R31
	IN   R30,SREG
	ST   -Y,R30
; 0000 01EB  OCR1A = tone;
	LDS  R30,_tone
	LDI  R31,0
	OUT  0x2A+1,R31
	OUT  0x2A,R30
; 0000 01EC  PORTB ^= (1 << 5);
	IN   R30,0x18
	LDI  R26,LOW(32)
	EOR  R30,R26
	OUT  0x18,R30
; 0000 01ED }
	LD   R30,Y+
	OUT  SREG,R30
	LD   R31,Y+
	LD   R30,Y+
	LD   R26,Y+
	RETI
;
;//____________________________управляем яркостью индикатора________________________________
;interrupt [TIM2_COMP] void timer2_comp_isr(void)
; 0000 01F1 {
_timer2_comp_isr:
	ST   -Y,R0
	ST   -Y,R1
	ST   -Y,R26
	ST   -Y,R27
	ST   -Y,R30
	ST   -Y,R31
	IN   R30,SREG
	ST   -Y,R30
; 0000 01F2 
; 0000 01F3     if (brigh_down_time<brigh_up_time)// если время снижать яркость "раньше" времени восстанавливать  (в сутках)
	CALL SUBOPT_0x16
	MOVW R0,R30
	CALL SUBOPT_0x17
	CP   R0,R30
	CPC  R1,R31
	BRGE _0x82
; 0000 01F4         {
; 0000 01F5         if ( (time>=brigh_down_time)&&(time<brigh_up_time) )//
	CALL SUBOPT_0x16
	CALL SUBOPT_0x18
	BRLT _0x84
	CALL SUBOPT_0x17
	CALL SUBOPT_0x18
	BRLT _0x85
_0x84:
	RJMP _0x83
_0x85:
; 0000 01F6             {
; 0000 01F7             OCR0=(brigh_up*23)+1;     // пропорционально снижаем яркость индикатора.
	CALL SUBOPT_0x19
; 0000 01F8             TIMSK|=0x02;              // разрешаем прерывание по совпадению Т0
	RJMP _0x28F
; 0000 01F9             }
; 0000 01FA         else                          //
_0x83:
; 0000 01FB             {
; 0000 01FC             TIMSK&=0xFD;              // индикаторы горят в полную силу (запрещаем прерывание по совпадению ТО )
	IN   R30,0x39
	ANDI R30,0xFD
_0x28F:
	OUT  0x39,R30
; 0000 01FD             }
; 0000 01FE         }
; 0000 01FF     else                              // если время снижать яркость "позже" времени восстанавливать  (в сутках)
	RJMP _0x87
_0x82:
; 0000 0200         {
; 0000 0201         if ( (time<brigh_down_time)&&(time>=brigh_up_time) )//
	CALL SUBOPT_0x16
	CALL SUBOPT_0x18
	BRGE _0x89
	CALL SUBOPT_0x17
	CALL SUBOPT_0x18
	BRGE _0x8A
_0x89:
	RJMP _0x88
_0x8A:
; 0000 0202             {
; 0000 0203             TIMSK&=0xFD;              // индикаторы горят в полную силу (запрещаем прерывание по совпадению ТО )
	IN   R30,0x39
	ANDI R30,0xFD
	RJMP _0x290
; 0000 0204             }
; 0000 0205         else                          //
_0x88:
; 0000 0206             {
; 0000 0207             OCR0=(brigh_up*23)+1;     // пропорционально снижаем яркость индикатора.
	CALL SUBOPT_0x19
; 0000 0208             TIMSK|=0x02;              // разрешаем прерывание по совпадению Т0
_0x290:
	OUT  0x39,R30
; 0000 0209             }
; 0000 020A         }
_0x87:
; 0000 020B }
	LD   R30,Y+
	OUT  SREG,R30
	LD   R31,Y+
	LD   R30,Y+
	LD   R27,Y+
	LD   R26,Y+
	LD   R1,Y+
	LD   R0,Y+
	RETI
;
;
;
;//____________________________________________отсчет времени________________________________________________
;interrupt [TIM2_OVF] void timer2_ovf_isr(void)
; 0000 0211 {
_timer2_ovf_isr:
	CALL SUBOPT_0x12
; 0000 0212 	mig++;
	LDI  R30,LOW(1)
	EOR  R2,R30
; 0000 0213 
; 0000 0214     //подсчет секунд для тревоги
; 0000 0215     if(timerAlert>0){
	LDS  R26,_timerAlert
	CPI  R26,LOW(0x1)
	BRLO _0x8C
; 0000 0216 		timerAlert--;
	LDS  R30,_timerAlert
	SUBI R30,LOW(1)
	STS  _timerAlert,R30
; 0000 0217     }
; 0000 0218     //Подсчет секунд для освещения
; 0000 0219     if(timerLight>0){
_0x8C:
	LDS  R26,_timerLight
	CPI  R26,LOW(0x1)
	BRLO _0x8D
; 0000 021A         timerLight--;
	LDS  R30,_timerLight
	SUBI R30,LOW(1)
	STS  _timerLight,R30
; 0000 021B     }
; 0000 021C     //Подсчет секунд для добавления дров
; 0000 021D     if(timerDrova>0){
_0x8D:
	LDS  R26,_timerDrova
	CPI  R26,LOW(0x1)
	BRLO _0x8E
; 0000 021E         timerDrova--;
	LDS  R30,_timerDrova
	SUBI R30,LOW(1)
	STS  _timerDrova,R30
; 0000 021F     }
; 0000 0220 
; 0000 0221     if(completeBeepTime>0 && delayBan==0){
_0x8E:
	LDS  R26,_completeBeepTime
	CPI  R26,LOW(0x1)
	BRLO _0x90
	LDS  R26,_delayBan
	CPI  R26,LOW(0x0)
	BREQ _0x91
_0x90:
	RJMP _0x8F
_0x91:
; 0000 0222         completeBeepTime--;
	LDS  R30,_completeBeepTime
	SUBI R30,LOW(1)
	STS  _completeBeepTime,R30
; 0000 0223     }
; 0000 0224 
; 0000 0225 if (++sek==60) {    //  Инкреминируем секунды
_0x8F:
	INC  R7
	LDI  R30,LOW(60)
	CP   R30,R7
	BREQ PC+3
	JMP _0x92
; 0000 0226     if(delayBan>0){delayBan--;}
	LDS  R26,_delayBan
	CPI  R26,LOW(0x1)
	BRLO _0x93
	LDS  R30,_delayBan
	SUBI R30,LOW(1)
	STS  _delayBan,R30
; 0000 0227 
; 0000 0228 	sek=0; time++; flg_min=1;
_0x93:
	CLR  R7
	LDI  R26,LOW(_time)
	LDI  R27,HIGH(_time)
	CALL SUBOPT_0x9
	SET
	BLD  R2,1
; 0000 0229      if (time==1440){
	CALL SUBOPT_0xF
	CPI  R26,LOW(0x5A0)
	LDI  R30,HIGH(0x5A0)
	CPC  R27,R30
	BRNE _0x94
; 0000 022A                 banya_is_complete=0;
	CLT
	BLD  R3,4
; 0000 022B                 needDrova=0;
	BLD  R3,5
; 0000 022C                 if(flg_korr)  {correkt(); flg_korr=0;  if(korr_den<0) goto m2;}  //  в 00-00, если еще сегодня не проводилась коррекция - провести коррекцию.
	LDS  R30,_flg_korr
	CPI  R30,0
	BREQ _0x95
	RCALL _correkt
	LDI  R30,LOW(0)
	STS  _flg_korr,R30
	CALL SUBOPT_0x3
	BRMI _0x97
; 0000 022D                 time=0;  chislo++;
_0x95:
	LDI  R30,LOW(0)
	STS  _time,R30
	STS  _time+1,R30
	INC  R6
; 0000 022E                 if (chislo > dnei_v_mesc[mesec-1])
	CALL SUBOPT_0x1A
	SUBI R30,LOW(-_dnei_v_mesc*2)
	SBCI R31,HIGH(-_dnei_v_mesc*2)
	LPM  R30,Z
	CP   R30,R6
	BRSH _0x98
; 0000 022F                 {
; 0000 0230                         chislo=1;
	LDI  R30,LOW(1)
	MOV  R6,R30
; 0000 0231                          if (++mesec==13){
	INC  R9
	LDI  R30,LOW(13)
	CP   R30,R9
	BRNE _0x99
; 0000 0232                                 mesec=1;
	LDI  R30,LOW(1)
	MOV  R9,R30
; 0000 0233                                 god++;
	INC  R8
; 0000 0234                          }
; 0000 0235                 }
_0x99:
; 0000 0236                 if ( (god%4) && (mesec==2) && (chislo==29) )  {mesec=3; chislo=1;}      // если НЕвысокосный год, то 29.02>>>>>01.03
_0x98:
	MOV  R26,R8
	CLR  R27
	LDI  R30,LOW(4)
	LDI  R31,HIGH(4)
	CALL __MODW21
	SBIW R30,0
	BREQ _0x9B
	LDI  R30,LOW(2)
	CP   R30,R9
	BRNE _0x9B
	LDI  R30,LOW(29)
	CP   R30,R6
	BREQ _0x9C
_0x9B:
	RJMP _0x9A
_0x9C:
	LDI  R30,LOW(3)
	MOV  R9,R30
	LDI  R30,LOW(1)
	MOV  R6,R30
; 0000 0237                 flg_korr=1;
_0x9A:
	LDI  R30,LOW(1)
	STS  _flg_korr,R30
; 0000 0238                 m2:
_0x97:
; 0000 0239                 }
; 0000 023A         }
_0x94:
; 0000 023B 
; 0000 023C         if(sek%2==0){
_0x92:
	MOV  R26,R7
	CLR  R27
	LDI  R30,LOW(2)
	LDI  R31,HIGH(2)
	CALL __MODW21
	SBIW R30,0
	BRNE _0x9D
; 0000 023D             flg_ds18b20=1;
	SET
	BLD  R3,2
; 0000 023E         }
; 0000 023F 
; 0000 0240 }
_0x9D:
_0x29E:
	LD   R30,Y+
	OUT  SREG,R30
	LD   R31,Y+
	LD   R30,Y+
	LD   R27,Y+
	LD   R26,Y+
	LD   R25,Y+
	LD   R24,Y+
	LD   R23,Y+
	LD   R22,Y+
	LD   R15,Y+
	LD   R1,Y+
	LD   R0,Y+
	RETI
;
;//Обновление восхода и заката
;void sunrise_update()
; 0000 0244 {
_sunrise_update:
; 0000 0245 float daySunrise[12]={-1.09, -2.1, -2.51, -2.43, -1.74, -0.16, 1.38, 1.90, 1.9,2, 1.93,0.83},
; 0000 0246                      daySunset[12]={1.74,2.03,2,1.96,1.74,0.53,-1.22,-2.29,-2.6,-2.38,-1.6,0.12};
; 0000 0247 int
; 0000 0248 	sunrise[12]={541,480,402,329,275,270,313,372,429,491,549,575},//Восход
; 0000 0249 	sunset[12]={1062,1121,1183,1242,1296,1312,1274,1203,1125,1051,1003,1007};//Закат
; 0000 024A 
; 0000 024B int curMonth=mesec-1, neighborMonth=(curMonth==0) ? 11: curMonth-1;
; 0000 024C  sunriseToday= sunrise[neighborMonth]+(int)(daySunrise[curMonth]*chislo);
	SBIW R28,63
	SBIW R28,63
	SBIW R28,18
	LDI  R24,144
	LDI  R26,LOW(0)
	LDI  R27,HIGH(0)
	LDI  R30,LOW(_0xA1*2)
	LDI  R31,HIGH(_0xA1*2)
	CALL __INITLOCB
	CALL __SAVELOCR4
;	daySunrise -> Y+100
;	daySunset -> Y+52
;	sunrise -> Y+28
;	sunset -> Y+4
;	curMonth -> R16,R17
;	neighborMonth -> R18,R19
	CALL SUBOPT_0x1A
	MOVW R16,R30
	CLR  R0
	CP   R0,R16
	CPC  R0,R17
	BRNE _0x9E
	LDI  R30,LOW(11)
	LDI  R31,HIGH(11)
	RJMP _0x9F
_0x9E:
	MOVW R30,R16
	SBIW R30,1
_0x9F:
	MOVW R18,R30
	MOVW R30,R18
	MOVW R26,R28
	ADIW R26,28
	CALL SUBOPT_0x1B
	PUSH R31
	PUSH R30
	MOVW R30,R16
	MOVW R26,R28
	SUBI R26,LOW(-(100))
	SBCI R27,HIGH(-(100))
	CALL SUBOPT_0x1C
	POP  R26
	POP  R27
	ADD  R30,R26
	ADC  R31,R27
	STS  _sunriseToday,R30
	STS  _sunriseToday+1,R31
; 0000 024D  sunsetToday=sunset[neighborMonth]+(int)(daySunset[curMonth]*chislo);
	MOVW R30,R18
	MOVW R26,R28
	ADIW R26,4
	CALL SUBOPT_0x1B
	PUSH R31
	PUSH R30
	MOVW R30,R16
	MOVW R26,R28
	ADIW R26,52
	CALL SUBOPT_0x1C
	POP  R26
	POP  R27
	ADD  R30,R26
	ADC  R31,R27
	STS  _sunsetToday,R30
	STS  _sunsetToday+1,R31
; 0000 024E }
	CALL __LOADLOCR4
	ADIW R28,63
	ADIW R28,63
	ADIW R28,22
	RET
;
;
;char timeToSymbol(int data1, char digit)
; 0000 0252 {
_timeToSymbol:
; 0000 0253 char symbol=45;
; 0000 0254         if(digit==1){symbol=((data1/600)==0)? 45: (data1/600);}
	ST   -Y,R17
;	data1 -> Y+2
;	digit -> Y+1
;	symbol -> R17
	LDI  R17,45
	LDD  R26,Y+1
	CPI  R26,LOW(0x1)
	BRNE _0xA2
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	CALL SUBOPT_0x1D
	MOVW R26,R30
	SBIW R30,0
	BRNE _0xA3
	LDI  R30,LOW(45)
	RJMP _0xA4
_0xA3:
	MOVW R30,R26
_0xA4:
	RJMP _0x291
; 0000 0255         else if(digit==2){symbol= (data1%600)/60;}
_0xA2:
	LDD  R26,Y+1
	CPI  R26,LOW(0x2)
	BRNE _0xA7
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	LDI  R30,LOW(600)
	LDI  R31,HIGH(600)
	CALL __MODW21
	MOVW R26,R30
	CALL SUBOPT_0x1E
	RJMP _0x291
; 0000 0256         else if(digit==3){symbol=(data1%60)/10;}
_0xA7:
	LDD  R26,Y+1
	CPI  R26,LOW(0x3)
	BRNE _0xA9
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	LDI  R30,LOW(60)
	LDI  R31,HIGH(60)
	CALL SUBOPT_0x1F
	RJMP _0x291
; 0000 0257         else if(digit==4){symbol=data1%10;}
_0xA9:
	LDD  R26,Y+1
	CPI  R26,LOW(0x4)
	BRNE _0xAB
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	CALL SUBOPT_0x20
_0x291:
	MOV  R17,R30
; 0000 0258  return symbol;
_0xAB:
	MOV  R30,R17
	RJMP _0x2020007
; 0000 0259 }
;
;
;//______________________загрузка в экранный буфер символов + мигающая точка в центре_________________________
; void ekran_cifri (unsigned  int data)
; 0000 025E {
_ekran_cifri:
; 0000 025F     unsigned char i,point[5]={0,0,6,13,19};
; 0000 0260     static unsigned char    Shift_zn;
; 0000 0261     if (data != data1){
	SBIW R28,5
	LDI  R30,LOW(0)
	ST   Y,R30
	STD  Y+1,R30
	LDI  R30,LOW(6)
	STD  Y+2,R30
	LDI  R30,LOW(13)
	STD  Y+3,R30
	LDI  R30,LOW(19)
	STD  Y+4,R30
	ST   -Y,R17
;	data -> Y+6
;	i -> R17
;	point -> Y+1
	CALL SUBOPT_0x21
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	CP   R30,R26
	CPC  R31,R27
	BREQ _0xAC
; 0000 0262     if(Interval_2>40){
	LDS  R26,_Interval_2
	LDS  R27,_Interval_2+1
	SBIW R26,41
	BRLO _0xAD
; 0000 0263         Interval_2=0;
	LDI  R30,LOW(0)
	STS  _Interval_2,R30
	STS  _Interval_2+1,R30
; 0000 0264         Shift_zn++;
	LDS  R30,_Shift_zn_S000000E000
	SUBI R30,-LOW(1)
	STS  _Shift_zn_S000000E000,R30
; 0000 0265         if(Shift_zn==8) {
	LDS  R26,_Shift_zn_S000000E000
	CPI  R26,LOW(0x8)
	BRNE _0xAE
; 0000 0266         Shift_zn=0;
	LDI  R30,LOW(0)
	STS  _Shift_zn_S000000E000,R30
; 0000 0267         data1=data;
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	CALL SUBOPT_0x22
; 0000 0268         }
; 0000 0269     }
_0xAE:
; 0000 026A     }
_0xAD:
; 0000 026B     else
	RJMP _0xAF
_0xAC:
; 0000 026C     {
; 0000 026D         Interval_2=0;
	LDI  R30,LOW(0)
	STS  _Interval_2,R30
	STS  _Interval_2+1,R30
; 0000 026E     }
_0xAF:
; 0000 026F 
; 0000 0270         for (temp=0; temp<5; temp++)
	LDI  R30,LOW(0)
	STS  _temp,R30
_0xB1:
	LDS  R26,_temp
	CPI  R26,LOW(0x5)
	BRLO PC+3
	JMP _0xB2
; 0000 0271         {
; 0000 0272           for(i=1;i<5;i++){
	LDI  R17,LOW(1)
_0xB4:
	CPI  R17,5
	BRLO PC+3
	JMP _0xB5
; 0000 0273             if( timeToSymbol(data,i) != timeToSymbol(data1,i) ) {
	CALL SUBOPT_0x23
	PUSH R30
	CALL SUBOPT_0x24
	POP  R26
	CP   R30,R26
	BRNE PC+3
	JMP _0xB6
; 0000 0274                 //Водопад
; 0000 0275                 if(animation==0){
	LDS  R30,_animation
	CPI  R30,0
	BRNE _0xB7
; 0000 0276                     ekran [temp+point[i]] =  (   (simvol [timeToSymbol(data1,i) ][temp]<<Shift_zn)  +   (simvol [timeToSymbol(data,i) ][temp]>>(8-Shift_zn))   );
	CALL SUBOPT_0x25
	CALL SUBOPT_0x26
	PUSH R31
	PUSH R30
	CALL SUBOPT_0x24
	CALL SUBOPT_0x27
	LD   R26,X
	LDS  R30,_Shift_zn_S000000E000
	CALL __LSLB12
	PUSH R30
	CALL SUBOPT_0x23
	CALL SUBOPT_0x27
	LD   R22,X
	CLR  R23
	LDS  R30,_Shift_zn_S000000E000
	LDI  R31,0
	LDI  R26,LOW(8)
	LDI  R27,HIGH(8)
	CALL SUBOPT_0x28
	MOVW R26,R22
	CALL __ASRW12
	POP  R26
	ADD  R30,R26
	POP  R26
	POP  R27
	RJMP _0x292
; 0000 0277                 }
; 0000 0278                 //Слева
; 0000 0279                 else if(animation==1 && Shift_zn==temp){
_0xB7:
	LDS  R26,_animation
	CPI  R26,LOW(0x1)
	BRNE _0xBA
	LDS  R30,_temp
	LDS  R26,_Shift_zn_S000000E000
	CP   R30,R26
	BREQ _0xBB
_0xBA:
	RJMP _0xB9
_0xBB:
; 0000 027A                     ekran [temp+point[i]] =simvol [timeToSymbol(data,i) ][temp];
	CALL SUBOPT_0x25
	CALL SUBOPT_0x26
	PUSH R31
	PUSH R30
	CALL SUBOPT_0x23
	CALL SUBOPT_0x27
	LD   R30,X
	POP  R26
	POP  R27
	RJMP _0x292
; 0000 027B                 }
; 0000 027C                 //Замена
; 0000 027D                 else if(animation==2){
_0xB9:
	LDS  R26,_animation
	CPI  R26,LOW(0x2)
	BRNE _0xBD
; 0000 027E                         ekran [temp+point[i]] &= (~(1<<Shift_zn));    //Очистка бита
	CALL SUBOPT_0x25
	CALL SUBOPT_0x26
	CALL SUBOPT_0x29
	CALL SUBOPT_0x2A
; 0000 027F                         if ((simvol [timeToSymbol(data,i) ][temp] & (1<<Shift_zn)) == 0){
	CALL SUBOPT_0x27
	LD   R1,X
	LDS  R30,_Shift_zn_S000000E000
	CALL SUBOPT_0x8
	BRNE _0xBE
; 0000 0280                                   ekran [temp+point[i]] |=(0<<Shift_zn);
	CALL SUBOPT_0x25
	CALL SUBOPT_0x26
	MOVW R26,R30
	LD   R30,X
	RJMP _0x293
; 0000 0281                         }
; 0000 0282                         else{
_0xBE:
; 0000 0283                                ekran [temp+point[i]] |=(1<<Shift_zn);
	CALL SUBOPT_0x25
	CALL SUBOPT_0x26
	CALL SUBOPT_0x29
	OR   R30,R1
	MOVW R26,R22
_0x293:
	ST   X,R30
; 0000 0284                         }
; 0000 0285                 }
; 0000 0286                 //Сползание вниз влево
; 0000 0287                 else if(animation==3){
	RJMP _0xC0
_0xBD:
	LDS  R26,_animation
	CPI  R26,LOW(0x3)
	BRNE _0xC1
; 0000 0288                         ekran [temp+point[i]] &= (~(1<<Shift_zn));    //Очистка бита
	CALL SUBOPT_0x25
	CALL SUBOPT_0x26
	CALL SUBOPT_0x29
	CALL SUBOPT_0x2A
; 0000 0289                         if ((simvol [timeToSymbol(data,i) ][temp] & (1<<Shift_zn)) == 0){
	CALL SUBOPT_0x27
	LD   R1,X
	LDS  R30,_Shift_zn_S000000E000
	CALL SUBOPT_0x8
	BRNE _0xC2
; 0000 028A                                   ekran [temp+point[i]] |=(0<<Shift_zn);
	CALL SUBOPT_0x25
	CALL SUBOPT_0x26
	MOVW R26,R30
	LD   R30,X
	RJMP _0x294
; 0000 028B                         }
; 0000 028C                         else{
_0xC2:
; 0000 028D                                ekran [temp+point[i]] |=(1<<Shift_zn);
	CALL SUBOPT_0x25
	CALL SUBOPT_0x26
	CALL SUBOPT_0x29
	OR   R30,R1
	MOVW R26,R22
_0x294:
	ST   X,R30
; 0000 028E                         }
; 0000 028F                         if(Shift_zn==temp){
	LDS  R30,_temp
	LDS  R26,_Shift_zn_S000000E000
	CP   R30,R26
	BRNE _0xC4
; 0000 0290                                 ekran [temp+point[i]] =simvol [timeToSymbol(data,i) ][temp];
	CALL SUBOPT_0x25
	CALL SUBOPT_0x26
	PUSH R31
	PUSH R30
	CALL SUBOPT_0x23
	CALL SUBOPT_0x27
	LD   R30,X
	POP  R26
	POP  R27
	ST   X,R30
; 0000 0291                         }
; 0000 0292                 }
_0xC4:
; 0000 0293                 //Без анимации
; 0000 0294                 else{
	RJMP _0xC5
_0xC1:
; 0000 0295                       ekran [temp+point[i]]=(simvol [timeToSymbol(data,i) ][temp]);
	CALL SUBOPT_0x25
	CALL SUBOPT_0x26
	PUSH R31
	PUSH R30
	CALL SUBOPT_0x23
	CALL SUBOPT_0x27
	LD   R30,X
	POP  R26
	POP  R27
_0x292:
	ST   X,R30
; 0000 0296                 }
_0xC5:
_0xC0:
; 0000 0297             }
; 0000 0298             else  {
	RJMP _0xC6
_0xB6:
; 0000 0299                 ekran [temp+point[i]]=(simvol [timeToSymbol(data,i) ][temp]);
	CALL SUBOPT_0x25
	CALL SUBOPT_0x26
	PUSH R31
	PUSH R30
	CALL SUBOPT_0x23
	CALL SUBOPT_0x27
	LD   R30,X
	POP  R26
	POP  R27
	ST   X,R30
; 0000 029A             }
_0xC6:
; 0000 029B         }
	SUBI R17,-1
	RJMP _0xB4
_0xB5:
; 0000 029C         }
	CALL SUBOPT_0x2B
	RJMP _0xB1
_0xB2:
; 0000 029D // перемигивание точек в основном режиме.
; 0000 029E if (mig) {
	SBRS R2,0
	RJMP _0xC7
; 0000 029F     ekran [12]=0;
	LDI  R30,LOW(0)
	__PUTB1MN _ekran,12
; 0000 02A0     ekran [11]=128;
	LDI  R30,LOW(128)
	RJMP _0x295
; 0000 02A1 }
; 0000 02A2 else {
_0xC7:
; 0000 02A3     ekran [12]=128;
	LDI  R30,LOW(128)
	__PUTB1MN _ekran,12
; 0000 02A4     ekran [11]=0;
	LDI  R30,LOW(0)
_0x295:
	__PUTB1MN _ekran,11
; 0000 02A5 }
; 0000 02A6 }
	LDD  R17,Y+0
	ADIW R28,8
	RET
;
;//___________________________загрузка в отределенное место экрана 1 символа_________________________________
; void ekran_1_figure (unsigned char x,unsigned char x1,)
; 0000 02AA {
_ekran_1_figure:
; 0000 02AB    unsigned char temp;
; 0000 02AC    for (temp=0; temp<5; temp++){
	ST   -Y,R17
;	x -> Y+2
;	x1 -> Y+1
;	temp -> R17
	LDI  R17,LOW(0)
_0xCA:
	CPI  R17,5
	BRSH _0xCB
; 0000 02AD    if (simvol [x][temp]==0xAA) return;
	CALL SUBOPT_0x2C
	LD   R26,X
	CPI  R26,LOW(0xAA)
	BREQ _0x2020009
; 0000 02AE    ekran [temp+x1]=(simvol [x][temp])  +(128*mig*line);
	CALL SUBOPT_0x2D
	CALL SUBOPT_0x2C
	CALL SUBOPT_0x2E
	MOV  R26,R30
	LDI  R30,0
	SBRC R2,7
	LDI  R30,1
	MULS R30,R26
	MOVW R30,R0
	CALL SUBOPT_0x2F
; 0000 02AF    }
	SUBI R17,-1
	RJMP _0xCA
_0xCB:
; 0000 02B0 }
_0x2020009:
	LDD  R17,Y+0
	ADIW R28,3
	RET
;
;//_______________________________________Гасим весь экран__________________________________________________
;void ochistka (void)
; 0000 02B4 {
_ochistka:
; 0000 02B5 unsigned char temp=0;
; 0000 02B6 while( temp<24) {ekran[temp++]=0  ;}
	ST   -Y,R17
;	temp -> R17
	LDI  R17,0
_0xCD:
	CPI  R17,24
	BRSH _0xCF
	MOV  R30,R17
	SUBI R17,-1
	CALL SUBOPT_0x7
	LDI  R26,LOW(0)
	STD  Z+0,R26
	RJMP _0xCD
_0xCF:
; 0000 02B7 }
	LD   R17,Y+
	RET
;
;//_________________________________________установки__2_символа____________________________________________
;  unsigned  char ystanovki_2 (unsigned  char x,unsigned  char x1,unsigned  char x2)
; 0000 02BB   {
_ystanovki_2:
; 0000 02BC         unsigned  char temp;
; 0000 02BD         while ( (button_read() != 2)  &&  POWER )  // POWER
	ST   -Y,R17
;	x -> Y+3
;	x1 -> Y+2
;	x2 -> Y+1
;	temp -> R17
_0xD0:
	RCALL _button_read
	CPI  R30,LOW(0x2)
	BREQ _0xD3
	SBRC R3,0
	RJMP _0xD4
_0xD3:
	RJMP _0xD2
_0xD4:
; 0000 02BE         {
; 0000 02BF         if (BUT_OK) {x++;   if (x>x1) x=0;}
	LDI  R30,LOW(1)
	CP   R30,R13
	BRNE _0xD5
	LDD  R30,Y+3
	SUBI R30,-LOW(1)
	STD  Y+3,R30
	LDD  R30,Y+2
	LDD  R26,Y+3
	CP   R30,R26
	BRSH _0xD6
	LDI  R30,LOW(0)
	STD  Y+3,R30
_0xD6:
; 0000 02C0                 for (temp=0; temp<5; temp++)
_0xD5:
	LDI  R17,LOW(0)
_0xD8:
	CPI  R17,5
	BRSH _0xD9
; 0000 02C1                 {
; 0000 02C2                 ekran [temp+x2]  =(simvol [x/10][temp])   +(128*mig);
	CALL SUBOPT_0x2D
	LDD  R26,Y+3
	CALL SUBOPT_0x30
	CALL SUBOPT_0x11
	CALL SUBOPT_0x31
	CALL SUBOPT_0x2F
; 0000 02C3                 ekran [temp+x2+6]=(simvol [x%10][temp])   +(128*mig);
	MOV  R26,R17
	CLR  R27
	LDD  R30,Y+1
	CALL SUBOPT_0x32
	__ADDW1MN _ekran,6
	__PUTW1R 23,24
	LDD  R26,Y+3
	CLR  R27
	CALL SUBOPT_0x20
	CALL SUBOPT_0x11
	CALL SUBOPT_0x31
	CALL SUBOPT_0x2F
; 0000 02C4                 }
	SUBI R17,-1
	RJMP _0xD8
_0xD9:
; 0000 02C5         }
	RJMP _0xD0
_0xD2:
; 0000 02C6   ochistka();  return x;
	RCALL _ochistka
	LDD  R30,Y+3
_0x2020007:
	LDD  R17,Y+0
_0x2020008:
	ADIW R28,4
	RET
; 0000 02C7   }
;
;//___________________________________________установки______________________________________________________
;  unsigned  int ystanovki_23_59 (unsigned  int x)
; 0000 02CB   {
_ystanovki_23_59:
; 0000 02CC   ochistka();
;	x -> Y+0
	RCALL _ochistka
; 0000 02CD   ekran_1_figure((x%60)/10,13);  ekran_1_figure(x%10,19);
	CALL SUBOPT_0x33
	MOVW R26,R30
	LDI  R30,LOW(10)
	LDI  R31,HIGH(10)
	CALL __DIVW21U
	CALL SUBOPT_0x34
	LD   R26,Y
	LDD  R27,Y+1
	LDI  R30,LOW(10)
	LDI  R31,HIGH(10)
	CALL __MODW21U
	CALL SUBOPT_0x35
; 0000 02CE   x = (x%60)+   (ystanovki_2 ((x/60),23, 0))*60;
	CALL SUBOPT_0x33
	PUSH R31
	PUSH R30
	CALL SUBOPT_0x36
	ST   -Y,R30
	LDI  R30,LOW(23)
	CALL SUBOPT_0x37
	MUL  R30,R26
	MOVW R30,R0
	POP  R26
	POP  R27
	ADD  R30,R26
	ADC  R31,R27
	ST   Y,R30
	STD  Y+1,R31
; 0000 02CF   ekran_1_figure(x/600,0);  ekran_1_figure((x/60)%10,6);
	LD   R26,Y
	LDD  R27,Y+1
	LDI  R30,LOW(600)
	LDI  R31,HIGH(600)
	CALL __DIVW21U
	CALL SUBOPT_0x38
	CALL SUBOPT_0x36
	MOVW R26,R30
	LDI  R30,LOW(10)
	LDI  R31,HIGH(10)
	CALL __MODW21U
	CALL SUBOPT_0x39
; 0000 02D0   x = (x/60*60)+(ystanovki_2 ((x%60),59,13));
	CALL SUBOPT_0x36
	LDI  R26,LOW(60)
	LDI  R27,HIGH(60)
	CALL __MULW12U
	PUSH R31
	PUSH R30
	CALL SUBOPT_0x33
	CALL SUBOPT_0x3A
	LDI  R31,0
	POP  R26
	POP  R27
	ADD  R30,R26
	ADC  R31,R27
	ST   Y,R30
	STD  Y+1,R31
; 0000 02D1   return x;
	RJMP _0x2020006
; 0000 02D2   }
;
;//_________________________________________бегущая строка___________________________________________________
;unsigned char beg_stroka (flash unsigned char x[],)
; 0000 02D6 {
_beg_stroka:
; 0000 02D7   static unsigned char temp;
; 0000 02D8   for (temp=0; temp<23; temp++)  {  ekran[temp]=ekran[temp+1]; }
	LDI  R30,LOW(0)
	STS  _temp_S0000013000,R30
_0xDB:
	LDS  R26,_temp_S0000013000
	CPI  R26,LOW(0x17)
	BRSH _0xDC
	LDI  R27,0
	SUBI R26,LOW(-_ekran)
	SBCI R27,HIGH(-_ekran)
	LDS  R30,_temp_S0000013000
	CALL SUBOPT_0x3B
	LDS  R30,_temp_S0000013000
	SUBI R30,-LOW(1)
	STS  _temp_S0000013000,R30
	RJMP _0xDB
_0xDC:
; 0000 02D9   if ((z==5)||(simvol[x[z1]][z]==0xAA)) {
	LDS  R26,_z
	CPI  R26,LOW(0x5)
	BREQ _0xDE
	CALL SUBOPT_0x3C
	CALL SUBOPT_0x3D
	LD   R26,X
	CPI  R26,LOW(0xAA)
	BRNE _0xDD
_0xDE:
; 0000 02DA     ekran[23]=0;
	CALL SUBOPT_0x3E
; 0000 02DB     z=0; z1++;
; 0000 02DC         if (x[z1]==255){
	CALL SUBOPT_0x3C
	LPM  R26,Z
	CPI  R26,LOW(0xFF)
	BRNE _0xE0
; 0000 02DD         z1=0;
	LDI  R30,LOW(0)
	STS  _z1,R30
; 0000 02DE         return 255;
	LDI  R30,LOW(255)
	RJMP _0x2020006
; 0000 02DF         }
; 0000 02E0     }
_0xE0:
; 0000 02E1     else{
	RJMP _0xE1
_0xDD:
; 0000 02E2         ekran[23]=simvol[x[z1]][z];
	CALL SUBOPT_0x3C
	CALL SUBOPT_0x3D
	CALL SUBOPT_0x3F
; 0000 02E3         z++;
; 0000 02E4     }
_0xE1:
; 0000 02E5 }
_0x2020006:
	ADIW R28,2
	RET
;
;
;unsigned char beg_stroka_not (unsigned char x[],)
; 0000 02E9 {
_beg_stroka_not:
; 0000 02EA   static unsigned char temp,count=0,tryCount=0,j=0;

	.DSEG

	.CSEG

	.DSEG

	.CSEG

	.DSEG

	.CSEG
; 0000 02EB   char i=0;
; 0000 02EC   float     temperature_temp=0;
; 0000 02ED   float  arifMin=0;
; 0000 02EE   for (temp=0; temp<23; temp++)  {  ekran[temp]=ekran[temp+1]; }
	SBIW R28,8
	LDI  R30,LOW(0)
	ST   Y,R30
	STD  Y+1,R30
	STD  Y+2,R30
	STD  Y+3,R30
	STD  Y+4,R30
	STD  Y+5,R30
	STD  Y+6,R30
	STD  Y+7,R30
	ST   -Y,R17
;	x -> Y+9
;	i -> R17
;	temperature_temp -> Y+5
;	arifMin -> Y+1
	LDI  R17,0
	STS  _temp_S0000014000,R30
_0xE6:
	LDS  R26,_temp_S0000014000
	CPI  R26,LOW(0x17)
	BRSH _0xE7
	LDI  R27,0
	SUBI R26,LOW(-_ekran)
	SBCI R27,HIGH(-_ekran)
	LDS  R30,_temp_S0000014000
	CALL SUBOPT_0x3B
	LDS  R30,_temp_S0000014000
	SUBI R30,-LOW(1)
	STS  _temp_S0000014000,R30
	RJMP _0xE6
_0xE7:
; 0000 02EF    if(ekran[temp]==0x00){
	LDS  R30,_temp_S0000014000
	CALL SUBOPT_0x7
	LD   R30,Z
	CPI  R30,0
	BRNE _0xE8
; 0000 02F0        count++;
	LDS  R30,_count_S0000014000
	SUBI R30,-LOW(1)
	RJMP _0x296
; 0000 02F1    }
; 0000 02F2    else{
_0xE8:
; 0000 02F3         count=0;
	LDI  R30,LOW(0)
_0x296:
	STS  _count_S0000014000,R30
; 0000 02F4    }
; 0000 02F5 
; 0000 02F6   if(count>24 && flg_ds18b20){
	LDS  R26,_count_S0000014000
	CPI  R26,LOW(0x19)
	BRLO _0xEB
	SBRC R3,2
	RJMP _0xEC
_0xEB:
	RJMP _0xEA
_0xEC:
; 0000 02F7         if(tryCount<2){tryCount++;}
	LDS  R26,_tryCount_S0000014000
	CPI  R26,LOW(0x2)
	BRSH _0xED
	LDS  R30,_tryCount_S0000014000
	SUBI R30,-LOW(1)
	STS  _tryCount_S0000014000,R30
; 0000 02F8         count=0;
_0xED:
	LDI  R30,LOW(0)
	STS  _count_S0000014000,R30
; 0000 02F9         flg_ds18b20=0;
	CLT
	BLD  R3,2
; 0000 02FA         #asm("cli");
	cli
; 0000 02FB         for ( i=0;i<devices;i++){
	LDI  R17,LOW(0)
_0xEF:
	LDS  R30,_devices
	CP   R17,R30
	BRLO PC+3
	JMP _0xF0
; 0000 02FC                 error_ds18b20[i]++;                                                               // инкременируем счетчик ошибочных чтений  DS18B20
	MOV  R26,R17
	LDI  R27,0
	SUBI R26,LOW(-_error_ds18b20)
	SBCI R27,HIGH(-_error_ds18b20)
	LD   R30,X
	SUBI R30,-LOW(1)
	ST   X,R30
; 0000 02FD                 temperature_temp=ds18b20_read_temp (&rom_code[i][0]);                             // читаю датчик температуры DS18B20
	CALL SUBOPT_0x14
	CALL _ds18b20_read_temp
	__PUTD1S 5
; 0000 02FE                 if (temperature_temp!=(-9999) && tryCount>1)                                                    // если температура прочиталась правильно,
	__GETD2S 5
	__CPD2N 0xC61C3C00
	BREQ _0xF2
	LDS  R26,_tryCount_S0000014000
	CPI  R26,LOW(0x2)
	BRSH _0xF3
_0xF2:
	RJMP _0xF1
_0xF3:
; 0000 02FF                 {
; 0000 0300                 temperature[i]=temperature_temp*10;// temperature[i]+=5;// то сохраняем её значение в "temperature"
	CALL SUBOPT_0x40
	CALL SUBOPT_0x41
	PUSH R31
	PUSH R30
	__GETD2S 5
	__GETD1N 0x41200000
	CALL __MULF12
	POP  R26
	POP  R27
	CALL __CFD1
	ST   X+,R30
	ST   X,R31
; 0000 0301 
; 0000 0302                     //Если это датчик от бани
; 0000 0303                     if(i==ds_ar[0]){
	LDS  R30,_ds_ar
	CP   R30,R17
	BREQ PC+3
	JMP _0xF4
; 0000 0304                                 averageTemp[sensorsReadCount++]=temperature[i];
	LDS  R30,_sensorsReadCount
	SUBI R30,-LOW(1)
	STS  _sensorsReadCount,R30
	SUBI R30,LOW(1)
	LDI  R26,LOW(_averageTemp)
	LDI  R27,HIGH(_averageTemp)
	CALL SUBOPT_0x42
	MOVW R0,R30
	CALL SUBOPT_0x40
	CALL SUBOPT_0x1B
	MOVW R26,R0
	ST   X+,R30
	ST   X,R31
; 0000 0305                                 //Расчет для безумной бани
; 0000 0306                                 if(sensorsReadCount==3){
	LDS  R26,_sensorsReadCount
	CPI  R26,LOW(0x3)
	BREQ PC+3
	JMP _0xF5
; 0000 0307                                     sensorsReadCount=0;
	LDI  R30,LOW(0)
	STS  _sensorsReadCount,R30
; 0000 0308                                              //Заполнение истории показаний бани
; 0000 0309                                             for( j=0;j<4;j++) {
	STS  _j_S0000014000,R30
_0xF7:
	LDS  R26,_j_S0000014000
	CPI  R26,LOW(0x4)
	BRSH _0xF8
; 0000 030A                                                 historyTemp[j]=historyTemp[j+1];
	CALL SUBOPT_0x43
	CALL SUBOPT_0x42
	MOVW R0,R30
	CALL SUBOPT_0x44
	CALL __GETW1P
	MOVW R26,R0
	ST   X+,R30
	ST   X,R31
; 0000 030B                                             }
	CALL SUBOPT_0x45
	RJMP _0xF7
_0xF8:
; 0000 030C 
; 0000 030D                                             arifMin=0;
	CALL SUBOPT_0x46
; 0000 030E                                             for( j=0;j<3;j++) {
_0xFA:
	LDS  R26,_j_S0000014000
	CPI  R26,LOW(0x3)
	BRSH _0xFB
; 0000 030F                                                 arifMin+=averageTemp[j];
	LDS  R30,_j_S0000014000
	LDI  R26,LOW(_averageTemp)
	LDI  R27,HIGH(_averageTemp)
	CALL SUBOPT_0x47
	CALL SUBOPT_0x48
	CALL SUBOPT_0x49
; 0000 0310                                             }
	CALL SUBOPT_0x45
	RJMP _0xFA
_0xFB:
; 0000 0311                                             historyTemp[4]=  arifMin/3;
	CALL SUBOPT_0x48
	__GETD1N 0x40400000
	CALL __DIVF21
	__POINTW2MN _historyTemp,8
	CALL __CFD1
	ST   X+,R30
	ST   X,R31
; 0000 0312 
; 0000 0313                                             arifMin=0;
	CALL SUBOPT_0x46
; 0000 0314                                             for( j=0;j<3;j++) {
_0xFD:
	LDS  R26,_j_S0000014000
	CPI  R26,LOW(0x3)
	BRSH _0xFE
; 0000 0315                                                 arifMin+=historyTemp[j+1]-historyTemp[j];
	CALL SUBOPT_0x44
	LD   R0,X+
	LD   R1,X
	CALL SUBOPT_0x43
	CALL SUBOPT_0x47
	MOVW R26,R30
	MOVW R30,R0
	SUB  R30,R26
	SBC  R31,R27
	CALL SUBOPT_0x48
	CALL SUBOPT_0x49
; 0000 0316                                             }
	CALL SUBOPT_0x45
	RJMP _0xFD
_0xFE:
; 0000 0317                                             arifMin/=4.0;
	CALL SUBOPT_0x48
	__GETD1N 0x40800000
	CALL __DIVF21
	__PUTD1S 1
; 0000 0318                                             //Прогноз для бани
; 0000 0319                                             if(temperature[ds_ar[0]]<tempComplete && temperature[ds_ar[0]]>tempMin && banya_is_complete!=1){
	CALL SUBOPT_0x4A
	MOVW R0,R30
	CALL SUBOPT_0x4B
	BRGE _0x100
	CALL SUBOPT_0x4C
	CP   R30,R0
	CPC  R31,R1
	BRGE _0x100
	SBRS R3,4
	RJMP _0x101
_0x100:
	RJMP _0xFF
_0x101:
; 0000 031A                                                 //Добавь дрова в печку
; 0000 031B                                                 if((((historyTemp[4]-historyTemp[3])+ (historyTemp[3]-historyTemp[2]))/2.0)<arifMin && historyTemp[4]<historyTemp[3] ){
	__GETW1MN _historyTemp,8
	__GETW2MN _historyTemp,6
	SUB  R30,R26
	SBC  R31,R27
	MOVW R0,R30
	__GETW1MN _historyTemp,6
	__GETW2MN _historyTemp,4
	SUB  R30,R26
	SBC  R31,R27
	ADD  R30,R0
	ADC  R31,R1
	CALL __CWD1
	CALL __CDF1
	MOVW R26,R30
	MOVW R24,R22
	__GETD1N 0x40000000
	CALL __DIVF21
	MOVW R26,R30
	MOVW R24,R22
	__GETD1S 1
	CALL __CMPF12
	BRSH _0x103
	__GETW2MN _historyTemp,8
	__GETW1MN _historyTemp,6
	CP   R26,R30
	CPC  R27,R31
	BRLT _0x104
_0x103:
	RJMP _0x102
_0x104:
; 0000 031C                                                     needDrova=1;
	SET
	BLD  R3,5
; 0000 031D                                                     timerDrova=4;
	LDI  R30,LOW(4)
	STS  _timerDrova,R30
; 0000 031E                                                 }
; 0000 031F                                                 else{
	RJMP _0x105
_0x102:
; 0000 0320                                                     needDrova=0;
	CLT
	BLD  R3,5
; 0000 0321                                                 }
_0x105:
; 0000 0322                                                 //Готовность бани в минутах + задержка
; 0000 0323                                                 if(arifMin>0){
	CALL SUBOPT_0x48
	CALL __CPD02
	BRGE _0x106
; 0000 0324                                                      timeToComplete=(int)((tempComplete-temperature[ds_ar[0]])/(arifMin))+delayBan;
	CALL SUBOPT_0x4A
	CALL SUBOPT_0x4D
	SUB  R26,R30
	SBC  R27,R31
	__GETD1S 1
	CALL __CWD2
	CALL __CDF2
	CALL __DIVF21
	CALL __CFD1
	LDS  R26,_delayBan
	ADD  R30,R26
	STS  _timeToComplete,R30
; 0000 0325                                                 }
; 0000 0326                                                 banya_is_complete=0;
_0x106:
	CLT
	BLD  R3,4
; 0000 0327                                             }
; 0000 0328                                             //Баня готова
; 0000 0329                                             else if(temperature[ds_ar[0]]>=tempComplete && banya_is_complete!=1){
	RJMP _0x107
_0xFF:
	CALL SUBOPT_0x4A
	CALL SUBOPT_0x4B
	BRLT _0x109
	SBRS R3,4
	RJMP _0x10A
_0x109:
	RJMP _0x108
_0x10A:
; 0000 032A                                                 needDrova=0;
	CLT
	BLD  R3,5
; 0000 032B                                                 completeBeepTime=3;
	LDI  R30,LOW(3)
	STS  _completeBeepTime,R30
; 0000 032C                                                 banya_is_complete=1;
	SET
	BLD  R3,4
; 0000 032D                                                 delayBan=delayTime;
	LDS  R30,_delayTime
	STS  _delayBan,R30
; 0000 032E                                             }
; 0000 032F                                             else if(banya_is_complete==1){
	RJMP _0x10B
_0x108:
	SBRC R3,4
; 0000 0330                                                 needDrova=0;
	RJMP _0x297
; 0000 0331                                             }else
; 0000 0332                                             {
; 0000 0333                                                 //обнуление истории бани
; 0000 0334                                                 for(j=0;j<5;j++) {historyTemp[j]=-100;}
	LDI  R30,LOW(0)
	STS  _j_S0000014000,R30
_0x10F:
	LDS  R26,_j_S0000014000
	CPI  R26,LOW(0x5)
	BRSH _0x110
	CALL SUBOPT_0x43
	LDI  R31,0
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	LDI  R30,LOW(65436)
	LDI  R31,HIGH(65436)
	ST   X+,R30
	ST   X,R31
	CALL SUBOPT_0x45
	RJMP _0x10F
_0x110:
; 0000 0335                                                 needDrova=0;
_0x297:
	CLT
	BLD  R3,5
; 0000 0336                                             }
_0x10B:
_0x107:
; 0000 0337                     }
; 0000 0338                 }
_0xF5:
; 0000 0339                 error_ds18b20[i]=0;                                   // обнуляем счетчик ошибочных чтений  DS18B20
_0xF4:
	CALL SUBOPT_0x1
	SUBI R30,LOW(-_error_ds18b20)
	SBCI R31,HIGH(-_error_ds18b20)
	LDI  R26,LOW(0)
	STD  Z+0,R26
; 0000 033A                 }
; 0000 033B                 if(error_ds18b20[i]==255)  temperature[i]=-999;                                   // если датчик DS18B20 за 5 мин ни разу правильно не прочитался, то подаём сигнал тревоги(выводим температуру -99,9 градуса)
_0xF1:
	CALL SUBOPT_0x1
	SUBI R30,LOW(-_error_ds18b20)
	SBCI R31,HIGH(-_error_ds18b20)
	LD   R26,Z
	CPI  R26,LOW(0xFF)
	BRNE _0x111
	CALL SUBOPT_0x40
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	LDI  R30,LOW(64537)
	LDI  R31,HIGH(64537)
	ST   X+,R30
	ST   X,R31
; 0000 033C                 ds18b20_convert_temp(&rom_code[i][0]);                                            // команда на измерение температуры
_0x111:
	CALL SUBOPT_0x14
	CALL _ds18b20_convert_temp
; 0000 033D         }
	SUBI R17,-1
	RJMP _0xEF
_0xF0:
; 0000 033E         #asm("sei");
	sei
; 0000 033F   }
; 0000 0340   if ((z==5)||(simvol[x[z1]][z]==0xAA)) {
_0xEA:
	LDS  R26,_z
	CPI  R26,LOW(0x5)
	BREQ _0x113
	CALL SUBOPT_0x4E
	CALL SUBOPT_0x4F
	LD   R26,X
	CPI  R26,LOW(0xAA)
	BRNE _0x112
_0x113:
; 0000 0341     ekran[23]=0;
	CALL SUBOPT_0x3E
; 0000 0342     z=0; z1++;
; 0000 0343 
; 0000 0344         if (x[z1]==255){
	CALL SUBOPT_0x4E
	LD   R26,X
	CPI  R26,LOW(0xFF)
	BRNE _0x115
; 0000 0345         z1=0;
	LDI  R30,LOW(0)
	STS  _z1,R30
; 0000 0346         return 255;
	LDI  R30,LOW(255)
	RJMP _0x2020005
; 0000 0347         }
; 0000 0348     }
_0x115:
; 0000 0349     else{
	RJMP _0x116
_0x112:
; 0000 034A         ekran[23]=simvol[x[z1]][z];
	CALL SUBOPT_0x4E
	CALL SUBOPT_0x4F
	CALL SUBOPT_0x3F
; 0000 034B         z++;
; 0000 034C     }
_0x116:
; 0000 034D }
_0x2020005:
	LDD  R17,Y+0
	ADIW R28,11
	RET
;
;
;//__________________________________вывод неподвижного текста_______________________________________________
;void txt_ekran (flash unsigned char x[],)
; 0000 0352 {
_txt_ekran:
; 0000 0353 unsigned char temp =0,  temp1=0, temp2=0;
; 0000 0354 
; 0000 0355     for(temp=0;temp<24;temp++)
	CALL __SAVELOCR4
;	temp -> R17
;	temp1 -> R16
;	temp2 -> R19
	LDI  R17,0
	LDI  R16,0
	LDI  R19,0
	LDI  R17,LOW(0)
_0x118:
	CPI  R17,24
	BRSH _0x119
; 0000 0356     {
; 0000 0357     if ((temp2==5) || (simvol[x[temp1]][temp2] == 0xAA)) {ekran[temp]=0;   temp2=0; temp1++;} else {ekran[temp]=simvol[x[temp1]][temp2]; temp2++;}
	CPI  R19,5
	BREQ _0x11B
	CALL SUBOPT_0x50
	CALL SUBOPT_0x51
	LD   R26,X
	CPI  R26,LOW(0xAA)
	BRNE _0x11A
_0x11B:
	CALL SUBOPT_0x1
	SUBI R30,LOW(-_ekran)
	SBCI R31,HIGH(-_ekran)
	LDI  R26,LOW(0)
	STD  Z+0,R26
	LDI  R19,LOW(0)
	SUBI R16,-1
	RJMP _0x11D
_0x11A:
	CALL SUBOPT_0x1
	SUBI R30,LOW(-_ekran)
	SBCI R31,HIGH(-_ekran)
	MOVW R22,R30
	CALL SUBOPT_0x50
	CALL SUBOPT_0x51
	LD   R30,X
	MOVW R26,R22
	ST   X,R30
	SUBI R19,-1
_0x11D:
; 0000 0358     if (x[temp1]==255) return ;
	CALL SUBOPT_0x50
	LPM  R26,Z
	CPI  R26,LOW(0xFF)
	BREQ _0x2020004
; 0000 0359     }
	SUBI R17,-1
	RJMP _0x118
_0x119:
; 0000 035A }
_0x2020004:
	CALL __LOADLOCR4
	ADIW R28,6
	RET
;
;
;//*****************************************************************************************************************//
;//*****************************************************************************************************************//
;//*****************************************************************************************************************//
;//*****************************************************************************************************************//
;void main(void)
; 0000 0362 {
_main:
; 0000 0363 int timeComplete=0;
; 0000 0364 char j=0,i=0,moonDay=1,moonYear=17, temp5;
; 0000 0365 
; 0000 0366 
; 0000 0367 PORTA=0x00; DDRA=0xFF;
	SBIW R28,1
;	timeComplete -> R16,R17
;	j -> R19
;	i -> R18
;	moonDay -> R21
;	moonYear -> R20
;	temp5 -> Y+0
	__GETWRN 16,17,0
	LDI  R19,0
	LDI  R18,0
	LDI  R21,1
	LDI  R20,17
	LDI  R30,LOW(0)
	OUT  0x1B,R30
	LDI  R30,LOW(255)
	OUT  0x1A,R30
; 0000 0368 PORTB=0x00; DDRB=0xE3;
	LDI  R30,LOW(0)
	OUT  0x18,R30
	LDI  R30,LOW(227)
	OUT  0x17,R30
; 0000 0369 PORTC=0x00; DDRC=0x3F;
	LDI  R30,LOW(0)
	OUT  0x15,R30
	LDI  R30,LOW(63)
	OUT  0x14,R30
; 0000 036A PORTD=0x00; DDRD=0xC0;
	LDI  R30,LOW(0)
	OUT  0x12,R30
	LDI  R30,LOW(192)
	OUT  0x11,R30
; 0000 036B 
; 0000 036C TCCR0=0x03;           // Частота Т0 125,000 kHz   (8000000/64)
	LDI  R30,LOW(3)
	OUT  0x33,R30
; 0000 036D OCR0=254;             //
	LDI  R30,LOW(254)
	OUT  0x3C,R30
; 0000 036E 
; 0000 036F TCCR1B=0x0C;          // Частота Т1 125,000 kHz   (8000000/64)
	LDI  R30,LOW(12)
	OUT  0x2E,R30
; 0000 0370 OCR1A=20;
	LDI  R30,LOW(20)
	LDI  R31,HIGH(20)
	OUT  0x2A+1,R31
	OUT  0x2A,R30
; 0000 0371 
; 0000 0372 ASSR=0x08;            // Такт от ног TOSC1,2 с кварцем на 32768
	LDI  R30,LOW(8)
	OUT  0x22,R30
; 0000 0373 TCCR2=0x05;           // 32768/128=256
	LDI  R30,LOW(5)
	OUT  0x25,R30
; 0000 0374 OCR1A=127;            //
	LDI  R30,LOW(127)
	LDI  R31,HIGH(127)
	OUT  0x2A+1,R31
	OUT  0x2A,R30
; 0000 0375 
; 0000 0376 TIMSK=0xC3;           // Конфигурирую прерывания от таймеров
	LDI  R30,LOW(195)
	OUT  0x39,R30
; 0000 0377 
; 0000 0378 ACSR= 0x48;           // Компаратор.
	LDI  R30,LOW(72)
	OUT  0x8,R30
; 0000 0379 SFIOR=0x00;
	LDI  R30,LOW(0)
	OUT  0x30,R30
; 0000 037A 
; 0000 037B MCUCR|=0b00110000;    // выбираю режим пониженного энергопотребления - Power Sawe
	IN   R30,0x35
	ORI  R30,LOW(0x30)
	OUT  0x35,R30
; 0000 037C 
; 0000 037D ADCSRA=0b10000011;    // разрешаю АЦП.  частота преобразования - 1МГЦ.
	LDI  R30,LOW(131)
	OUT  0x6,R30
; 0000 037E ADMUX= 0b01100111;    // ИОН-AVcc.  меряем на пин 7, порт А
	LDI  R30,LOW(103)
	OUT  0x7,R30
; 0000 037F 
; 0000 0380 #asm                                // настраиваю шину   1 Wire
; 0000 0381    .equ __w1_port=0x18 ;PORTB       // на работу с портов В
   .equ __w1_port=0x18 ;PORTB       // на работу с портов В
; 0000 0382    .equ __w1_bit=4                  // бит 4
   .equ __w1_bit=4                  // бит 4
; 0000 0383 #endasm
; 0000 0384 
; 0000 0385 for (temp=0;temp<9;temp++){budilnik_time [temp] = budilnik_Install [temp] = budilnik_Interval[temp]= 0;}  bud_flg=0;   // "выключаем" все будильники
	LDI  R30,LOW(0)
	STS  _temp,R30
_0x120:
	LDS  R26,_temp
	CPI  R26,LOW(0x9)
	BRSH _0x121
	LDS  R30,_temp
	LDI  R26,LOW(_budilnik_time)
	LDI  R27,HIGH(_budilnik_time)
	CALL SUBOPT_0x42
	MOVW R22,R30
	LDS  R30,_temp
	CALL SUBOPT_0x52
	MOVW R0,R30
	CALL SUBOPT_0x53
	SUBI R26,LOW(-_budilnik_Interval)
	SBCI R27,HIGH(-_budilnik_Interval)
	LDI  R30,LOW(0)
	ST   X,R30
	MOVW R26,R0
	ST   X,R30
	MOVW R26,R22
	LDI  R31,0
	ST   X+,R30
	ST   X,R31
	CALL SUBOPT_0x2B
	RJMP _0x120
_0x121:
	CLT
	BLD  R2,2
; 0000 0386 den_nedeli=Day_week ();             // Вычисляем день недели
	CALL _Day_week
	MOV  R11,R30
; 0000 0387 
; 0000 0388 brigh_up=9;   //
	LDI  R26,LOW(_brigh_up)
	LDI  R27,HIGH(_brigh_up)
	LDI  R30,LOW(9)
	CALL __EEPROMWRB
; 0000 0389 sunrise_update();
	RCALL _sunrise_update
; 0000 038A ochistka();  // Очищаем весь зкран
	RCALL _ochistka
; 0000 038B //#asm("cli")
; 0000 038C devices=w1_search(0xf0,rom_code);
	CALL SUBOPT_0x13
; 0000 038D for(j=0;j<devices;j++){
	LDI  R19,LOW(0)
_0x123:
	LDS  R30,_devices
	CP   R19,R30
	BRSH _0x124
; 0000 038E     ds18b20_init( &rom_code[j][0], -45, 90, DS18B20_11BIT_RES );
	LDI  R26,LOW(9)
	MUL  R19,R26
	MOVW R30,R0
	SUBI R30,LOW(-_rom_code)
	SBCI R31,HIGH(-_rom_code)
	ST   -Y,R31
	ST   -Y,R30
	CALL SUBOPT_0x15
; 0000 038F }
	SUBI R19,-1
	RJMP _0x123
_0x124:
; 0000 0390 #asm("sei")
	sei
; 0000 0391 
; 0000 0392 if(font_epp<0 || font_epp>6) font_epp=5;
	LDI  R30,LOW(0)
	CP   R5,R30
	BRLO _0x126
	LDI  R30,LOW(6)
	CP   R30,R5
	BRSH _0x125
_0x126:
	LDI  R30,LOW(5)
	MOV  R5,R30
; 0000 0393 if (str_period <0 || str_period >255) str_period =15;
_0x125:
	LDI  R26,LOW(_str_period)
	LDI  R27,HIGH(_str_period)
	CALL __EEPROMRDB
	CPI  R30,0
	BRLO _0x129
	MOV  R26,R30
	LDI  R30,LOW(255)
	CP   R30,R26
	BRSH _0x128
_0x129:
	LDI  R26,LOW(_str_period)
	LDI  R27,HIGH(_str_period)
	LDI  R30,LOW(15)
	CALL __EEPROMWRB
; 0000 0394 font_=font_epp;
_0x128:
	STS  _font_,R5
; 0000 0395 font_cifri();
	CALL _font_cifri
; 0000 0396 
; 0000 0397 ochistka();    // Очищаем весь зкран
	RCALL _ochistka
; 0000 0398 str_pause ();  // Вычисляем время запуска бег строки.
	CALL _str_pause
; 0000 0399 
; 0000 039A //*****************************************************************************************************************//
; 0000 039B //*****************************************************************************************************************//
; 0000 039C 
; 0000 039D while (1)
_0x12B:
; 0000 039E {
; 0000 039F button_read();   // Опрос кнопок
	CALL _button_read
; 0000 03A0 switch (meny)
	MOV  R30,R4
	LDI  R31,0
; 0000 03A1         {
; 0000 03A2         case 10: //______основной режим
	CPI  R30,LOW(0xA)
	LDI  R26,HIGH(0xA)
	CPC  R31,R26
	BRNE _0x131
; 0000 03A3                 ekran_cifri(time);  // отображаем время
	CALL SUBOPT_0x54
	RCALL _ekran_cifri
; 0000 03A4                 //______запуск бегущей строки
; 0000 03A5                 if ( ((sek >= str_sec) && (time == str_time))    &&  (str != 0) )   {meny=11 ;z=0; z1=0; temp2=str;}           // Запускаем бегущую строку
	LDS  R30,_str_sec
	CP   R7,R30
	BRLO _0x133
	LDS  R30,_str_time
	LDS  R31,_str_time+1
	CALL SUBOPT_0x55
	BREQ _0x134
_0x133:
	RJMP _0x135
_0x134:
	CALL SUBOPT_0x56
	CPI  R30,0
	BRNE _0x136
_0x135:
	RJMP _0x132
_0x136:
	CALL SUBOPT_0x57
	CALL SUBOPT_0x56
	STS  _temp2,R30
; 0000 03A6                 if (BUT_STEP) {meny=30; z=0; z1=0; ochistka();  bud_flg=0;data1=(((time-(time/60*60))*60)+sek);}
_0x132:
	LDI  R30,LOW(2)
	CP   R30,R13
	BRNE _0x137
	CALL SUBOPT_0x58
	CLT
	BLD  R2,2
	CALL SUBOPT_0x59
	CALL SUBOPT_0x5A
	CALL SUBOPT_0x22
; 0000 03A7                 if (BUT_OK)   {meny=11 ;z=0; z1=0; temp2=0x18;}
_0x137:
	LDI  R30,LOW(1)
	CP   R30,R13
	BRNE _0x138
	CALL SUBOPT_0x57
	LDI  R30,LOW(24)
	STS  _temp2,R30
; 0000 03A8         break;
_0x138:
	JMP  _0x130
; 0000 03A9 
; 0000 03AA         case 11: //______Формируем и вывожу бег строку.
_0x131:
	CPI  R30,LOW(0xB)
	LDI  R26,HIGH(0xB)
	CPC  R31,R26
	BREQ PC+3
	JMP _0x139
; 0000 03AB                 t=0; temp1=0;  den_nedeli=Day_week ();
	CALL SUBOPT_0x5B
	CALL _Day_week
	MOV  R11,R30
; 0000 03AC                 beg_info[t++]=45;  beg_info[t++]=45;  beg_info[t++]=45;  beg_info[t++]=45;  beg_info[t++]=45;
	CALL SUBOPT_0x5C
	CALL SUBOPT_0x5C
	CALL SUBOPT_0x5C
	CALL SUBOPT_0x5C
	CALL SUBOPT_0x5C
; 0000 03AD                 /*Уведомление о включеном насосе*/
; 0000 03AE              	if(pumpStatus)
	SBRS R3,3
	RJMP _0x13A
; 0000 03AF             	{
; 0000 03B0             		temp1=t;
	CALL SUBOPT_0x5D
; 0000 03B1                     while (pump_is_on[(t-temp1)] != 255)
_0x13B:
	CALL SUBOPT_0x5E
	SUBI R30,LOW(-_pump_is_on*2)
	SBCI R31,HIGH(-_pump_is_on*2)
	LPM  R26,Z
	CPI  R26,LOW(0xFF)
	BREQ _0x13D
; 0000 03B2 					{
; 0000 03B3                         beg_info[t]=pump_is_on[t++-temp1];
	CALL SUBOPT_0x5F
	SUBI R30,LOW(-_pump_is_on*2)
	SBCI R31,HIGH(-_pump_is_on*2)
	LPM  R30,Z
	MOVW R26,R22
	ST   X,R30
; 0000 03B4                     }
	RJMP _0x13B
_0x13D:
; 0000 03B5             	}
; 0000 03B6  				beg_info[t++] = 42;
_0x13A:
	CALL SUBOPT_0x60
	LDI  R26,LOW(42)
	STD  Z+0,R26
; 0000 03B7 
; 0000 03B8 
; 0000 03B9                 /*Отображение температуры в бане */
; 0000 03BA                 if(historyTemp[0]>tempMin && banya_is_complete==0){
	CALL SUBOPT_0x4C
	LDS  R26,_historyTemp
	LDS  R27,_historyTemp+1
	CP   R30,R26
	CPC  R31,R27
	BRGE _0x13F
	LDI  R26,0
	SBRC R3,4
	LDI  R26,1
	CPI  R26,LOW(0x0)
	BREQ _0x140
_0x13F:
	RJMP _0x13E
_0x140:
; 0000 03BB 					//  Баня вывод прогноза
; 0000 03BC                 	if(timeToComplete+time<1440 && timeToComplete>0){
	CALL SUBOPT_0x61
	ADD  R26,R30
	ADC  R27,R31
	CPI  R26,LOW(0x5A0)
	LDI  R30,HIGH(0x5A0)
	CPC  R27,R30
	BRGE _0x142
	LDS  R26,_timeToComplete
	CPI  R26,LOW(0x1)
	BRSH _0x143
_0x142:
	RJMP _0x141
_0x143:
; 0000 03BD 	                	temp1=t;
	CALL SUBOPT_0x5D
; 0000 03BE                         while (banya_prognoz[(t-temp1)] != 255)
_0x144:
	CALL SUBOPT_0x5E
	SUBI R30,LOW(-_banya_prognoz*2)
	SBCI R31,HIGH(-_banya_prognoz*2)
	LPM  R26,Z
	CPI  R26,LOW(0xFF)
	BREQ _0x146
; 0000 03BF 						{
; 0000 03C0                                 beg_info[t]=banya_prognoz[t++-temp1];
	CALL SUBOPT_0x5F
	SUBI R30,LOW(-_banya_prognoz*2)
	SBCI R31,HIGH(-_banya_prognoz*2)
	LPM  R30,Z
	MOVW R26,R22
	ST   X,R30
; 0000 03C1                         }
	RJMP _0x144
_0x146:
; 0000 03C2 	                	timeComplete=time+timeToComplete;
	CALL SUBOPT_0x61
	ADD  R30,R26
	ADC  R31,R27
	MOVW R16,R30
; 0000 03C3 
; 0000 03C4 						//составление прогноза готовности бани
; 0000 03C5                         for(i=1;i<5;i++){
	LDI  R18,LOW(1)
_0x148:
	CPI  R18,5
	BRSH _0x149
; 0000 03C6                              beg_info[t++]=timeToSymbol(timeComplete,i);             //    десятки часов
	CALL SUBOPT_0x60
	PUSH R31
	PUSH R30
	ST   -Y,R17
	ST   -Y,R16
	ST   -Y,R18
	RCALL _timeToSymbol
	POP  R26
	POP  R27
	ST   X,R30
; 0000 03C7                              if(i==2){
	CPI  R18,2
	BRNE _0x14A
; 0000 03C8                                    beg_info[t++]=43;
	CALL SUBOPT_0x60
	LDI  R26,LOW(43)
	STD  Z+0,R26
; 0000 03C9                              }
; 0000 03CA                         }
_0x14A:
	SUBI R18,-1
	RJMP _0x148
_0x149:
; 0000 03CB 
; 0000 03CC                 	}
; 0000 03CD 
; 0000 03CE                     beg_info[t++] = 42;
_0x141:
	CALL SUBOPT_0x60
	LDI  R26,LOW(42)
	STD  Z+0,R26
; 0000 03CF                 	//Уведомление о необходимости добавления дров
; 0000 03D0                 	if(needDrova==1)
	SBRS R3,5
	RJMP _0x14B
; 0000 03D1                 	{
; 0000 03D2                 		temp1=t;
	CALL SUBOPT_0x5D
; 0000 03D3                         while (banya_add[(t-temp1)] != 255)
_0x14C:
	CALL SUBOPT_0x5E
	SUBI R30,LOW(-_banya_add*2)
	SBCI R31,HIGH(-_banya_add*2)
	LPM  R26,Z
	CPI  R26,LOW(0xFF)
	BREQ _0x14E
; 0000 03D4 						{
; 0000 03D5                             beg_info[t]=banya_add[t++-temp1];
	CALL SUBOPT_0x5F
	SUBI R30,LOW(-_banya_add*2)
	SBCI R31,HIGH(-_banya_add*2)
	LPM  R30,Z
	MOVW R26,R22
	ST   X,R30
; 0000 03D6                         }
	RJMP _0x14C
_0x14E:
; 0000 03D7                 	}
; 0000 03D8 
; 0000 03D9                 beg_info[t++] = 42;
_0x14B:
	CALL SUBOPT_0x60
	LDI  R26,LOW(42)
	STD  Z+0,R26
; 0000 03DA                 }
; 0000 03DB 
; 0000 03DC 
; 0000 03DD                 if (temp2 & 0x01)// если "день недели" нужно выводить
_0x13E:
	LDS  R30,_temp2
	ANDI R30,LOW(0x1)
	BREQ _0x14F
; 0000 03DE                         {
; 0000 03DF                         temp1=t;
	CALL SUBOPT_0x5D
; 0000 03E0                         while (den_nedeli_txt[den_nedeli][t-temp1] != 255)         //
_0x150:
	CALL SUBOPT_0x62
	CALL SUBOPT_0x5E
	ADD  R30,R22
	ADC  R31,R23
	LPM  R26,Z
	CPI  R26,LOW(0xFF)
	BREQ _0x152
; 0000 03E1                                 {                                              //
; 0000 03E2                                 beg_info[t]=den_nedeli_txt[den_nedeli][t++-temp1]; //
	CALL SUBOPT_0x63
	CALL SUBOPT_0x62
	CALL SUBOPT_0x64
	ADD  R30,R22
	ADC  R31,R23
	LPM  R30,Z
	MOVW R26,R24
	ST   X,R30
; 0000 03E3                                 } beg_info[t++] = 42;                          //  пробел
	RJMP _0x150
_0x152:
	CALL SUBOPT_0x60
	LDI  R26,LOW(42)
	STD  Z+0,R26
; 0000 03E4                         }
; 0000 03E5                 if (temp2 & 0x02)                                              //  Если "дату" нужно выводить
_0x14F:
	LDS  R30,_temp2
	ANDI R30,LOW(0x2)
	BREQ _0x153
; 0000 03E6                         {                                                      //
; 0000 03E7                         if (chislo>9) {beg_info[t++]=chislo/10;}               //  Если число больше 9, выводим "десятки" числа
	LDI  R30,LOW(9)
	CP   R30,R6
	BRSH _0x154
	CALL SUBOPT_0x60
	MOVW R22,R30
	MOV  R26,R6
	CALL SUBOPT_0x30
	MOVW R26,R22
	ST   X,R30
; 0000 03E8                         beg_info[t++]=chislo%10;                               //  Выводим "Единицы" числа
_0x154:
	CALL SUBOPT_0x60
	MOVW R22,R30
	MOV  R26,R6
	CLR  R27
	CALL SUBOPT_0x20
	CALL SUBOPT_0x65
; 0000 03E9                         beg_info[t++]=42;                                      //  Пробел
	LDI  R26,LOW(42)
	STD  Z+0,R26
; 0000 03EA                         temp1=t;
	CALL SUBOPT_0x5D
; 0000 03EB                         while (name_mesec_txt[mesec-1][(t-temp1)] != 255)      //  Выводим месяц
_0x155:
	CALL SUBOPT_0x1A
	CALL SUBOPT_0x66
	CALL SUBOPT_0x5E
	ADD  R30,R22
	ADC  R31,R23
	LPM  R26,Z
	CPI  R26,LOW(0xFF)
	BREQ _0x157
; 0000 03EC                                 {
; 0000 03ED                                 beg_info[t]=name_mesec_txt[mesec-1][t++-temp1];
	CALL SUBOPT_0x63
	CALL SUBOPT_0x1A
	CALL SUBOPT_0x66
	CALL SUBOPT_0x64
	ADD  R30,R22
	ADC  R31,R23
	LPM  R30,Z
	MOVW R26,R24
	ST   X,R30
; 0000 03EE                                 } beg_info[t++] = 42;                          // пробел
	RJMP _0x155
_0x157:
	CALL SUBOPT_0x60
	LDI  R26,LOW(42)
	STD  Z+0,R26
; 0000 03EF                         }
; 0000 03F0                 if (temp2 & 0x04)                                              //  Если "Год" нужно выводить
_0x153:
	LDS  R30,_temp2
	ANDI R30,LOW(0x4)
	BREQ _0x158
; 0000 03F1                         {
; 0000 03F2                         beg_info[t++]=2;                                       // "Тысячи" года (2)
	CALL SUBOPT_0x60
	LDI  R26,LOW(2)
	STD  Z+0,R26
; 0000 03F3                         beg_info[t++]=0;                                       // "Сотни"  года (0)
	CALL SUBOPT_0x60
	LDI  R26,LOW(0)
	STD  Z+0,R26
; 0000 03F4                         beg_info[t++]=(god%100)/10;                            // "Десятки" года
	CALL SUBOPT_0x60
	MOVW R22,R30
	MOV  R26,R8
	CLR  R27
	CALL SUBOPT_0x67
	CALL SUBOPT_0x65
; 0000 03F5                         beg_info[t++]=god%10;                                  // "Единицы" года
	MOVW R22,R30
	MOV  R26,R8
	CLR  R27
	CALL SUBOPT_0x20
	CALL SUBOPT_0x65
; 0000 03F6                         beg_info[t++]=13;                                      // "Г"
	LDI  R26,LOW(13)
	STD  Z+0,R26
; 0000 03F7                         beg_info[t++]=42; beg_info[t++]=42;                    // 2 пробела
	CALL SUBOPT_0x60
	CALL SUBOPT_0x68
	LDI  R26,LOW(42)
	STD  Z+0,R26
; 0000 03F8                         }
; 0000 03F9 
; 0000 03FA                         for (temp1=0;temp1<devices;temp1++)                                         // если датчиков температуры больше 2х
_0x158:
	LDI  R30,LOW(0)
	STS  _temp1,R30
_0x15A:
	LDS  R30,_devices
	LDS  R26,_temp1
	CP   R26,R30
	BRLO PC+3
	JMP _0x15B
; 0000 03FB                         {
; 0000 03FC                             temp5=t;
	LDS  R30,_t
	ST   Y,R30
; 0000 03FD                         if(temp1==0){
	LDS  R30,_temp1
	CPI  R30,0
	BRNE _0x15C
; 0000 03FE                             while (banya_txt[(t-temp5)] != 255)
_0x15D:
	CALL SUBOPT_0x69
	SUBI R30,LOW(-_banya_txt*2)
	SBCI R31,HIGH(-_banya_txt*2)
	LPM  R26,Z
	CPI  R26,LOW(0xFF)
	BREQ _0x15F
; 0000 03FF                             {
; 0000 0400                                      beg_info[t]=banya_txt[t++-temp5];
	CALL SUBOPT_0x6A
	SUBI R30,LOW(-_banya_txt*2)
	SBCI R31,HIGH(-_banya_txt*2)
	LPM  R30,Z
	MOVW R26,R22
	ST   X,R30
; 0000 0401                             }
	RJMP _0x15D
_0x15F:
; 0000 0402                         }
; 0000 0403                         else if(temp1==1){
	RJMP _0x160
_0x15C:
	LDS  R26,_temp1
	CPI  R26,LOW(0x1)
	BRNE _0x161
; 0000 0404                             while (outside_txt[(t-temp5)] != 255)
_0x162:
	CALL SUBOPT_0x69
	SUBI R30,LOW(-_outside_txt*2)
	SBCI R31,HIGH(-_outside_txt*2)
	LPM  R26,Z
	CPI  R26,LOW(0xFF)
	BREQ _0x164
; 0000 0405                             {
; 0000 0406                                      beg_info[t]=outside_txt[t++-temp5];
	CALL SUBOPT_0x6A
	SUBI R30,LOW(-_outside_txt*2)
	SBCI R31,HIGH(-_outside_txt*2)
	LPM  R30,Z
	MOVW R26,R22
	ST   X,R30
; 0000 0407                             }
	RJMP _0x162
_0x164:
; 0000 0408                         }
; 0000 0409                         else if(temp1==2){
	RJMP _0x165
_0x161:
	LDS  R26,_temp1
	CPI  R26,LOW(0x2)
	BRNE _0x166
; 0000 040A                             while (water_txt[(t-temp5)] != 255)
_0x167:
	CALL SUBOPT_0x69
	SUBI R30,LOW(-_water_txt*2)
	SBCI R31,HIGH(-_water_txt*2)
	LPM  R26,Z
	CPI  R26,LOW(0xFF)
	BREQ _0x169
; 0000 040B                             {
; 0000 040C                                      beg_info[t]=water_txt[t++-temp5];
	CALL SUBOPT_0x6A
	SUBI R30,LOW(-_water_txt*2)
	SBCI R31,HIGH(-_water_txt*2)
	LPM  R30,Z
	MOVW R26,R22
	ST   X,R30
; 0000 040D                             }
	RJMP _0x167
_0x169:
; 0000 040E                         }
; 0000 040F                         else if(temp1==3 || temp1==4){
	RJMP _0x16A
_0x166:
	LDS  R26,_temp1
	CPI  R26,LOW(0x3)
	BREQ _0x16C
	CPI  R26,LOW(0x4)
	BRNE _0x16B
_0x16C:
; 0000 0410                             while (underground_txt[(t-temp5)] != 255)
_0x16E:
	CALL SUBOPT_0x69
	SUBI R30,LOW(-_underground_txt*2)
	SBCI R31,HIGH(-_underground_txt*2)
	LPM  R26,Z
	CPI  R26,LOW(0xFF)
	BREQ _0x170
; 0000 0411                             {
; 0000 0412                                      beg_info[t]=underground_txt[t++-temp5];
	CALL SUBOPT_0x6A
	SUBI R30,LOW(-_underground_txt*2)
	SBCI R31,HIGH(-_underground_txt*2)
	LPM  R30,Z
	MOVW R26,R22
	ST   X,R30
; 0000 0413                             }
	RJMP _0x16E
_0x170:
; 0000 0414                             beg_info[t++]=44;
	CALL SUBOPT_0x60
	LDI  R26,LOW(44)
	STD  Z+0,R26
; 0000 0415                             beg_info[t++]=52;
	CALL SUBOPT_0x60
	LDI  R26,LOW(52)
	STD  Z+0,R26
; 0000 0416 
; 0000 0417                             if(temp1==3){
	LDS  R26,_temp1
	CPI  R26,LOW(0x3)
	BRNE _0x171
; 0000 0418                                 beg_info[t++]=1;
	CALL SUBOPT_0x60
	LDI  R26,LOW(1)
	RJMP _0x298
; 0000 0419                             }
; 0000 041A                             else{
_0x171:
; 0000 041B                                 beg_info[t++]=2;
	CALL SUBOPT_0x60
	LDI  R26,LOW(2)
_0x298:
	STD  Z+0,R26
; 0000 041C                             }
; 0000 041D                             beg_info[t++]=42;
	CALL SUBOPT_0x60
	LDI  R26,LOW(42)
	STD  Z+0,R26
; 0000 041E                         }
; 0000 041F                         else if(temp1==5){
	RJMP _0x173
_0x16B:
	LDS  R26,_temp1
	CPI  R26,LOW(0x5)
	BRNE _0x174
; 0000 0420                             while (home_txt[(t-temp5)] != 255)
_0x175:
	CALL SUBOPT_0x69
	SUBI R30,LOW(-_home_txt*2)
	SBCI R31,HIGH(-_home_txt*2)
	LPM  R26,Z
	CPI  R26,LOW(0xFF)
	BREQ _0x177
; 0000 0421                             {
; 0000 0422                                      beg_info[t]=home_txt[t++-temp5];
	CALL SUBOPT_0x6A
	SUBI R30,LOW(-_home_txt*2)
	SBCI R31,HIGH(-_home_txt*2)
	LPM  R30,Z
	MOVW R26,R22
	ST   X,R30
; 0000 0423                             }
	RJMP _0x175
_0x177:
; 0000 0424                         }
; 0000 0425                         beg_info[t++]=56;
_0x174:
_0x173:
_0x16A:
_0x165:
_0x160:
	CALL SUBOPT_0x60
	LDI  R26,LOW(56)
	STD  Z+0,R26
; 0000 0426 
; 0000 0427                         if (temperature[ds_ar[temp1]]!=0)  {
	CALL SUBOPT_0x6B
	SBIW R30,0
	BREQ _0x178
; 0000 0428                              if (temperature[ds_ar[temp1]]<0)
	CALL SUBOPT_0x6B
	TST  R31
	BRPL _0x179
; 0000 0429                                 beg_info[t++]=51;
	CALL SUBOPT_0x60
	LDI  R26,LOW(51)
	RJMP _0x299
; 0000 042A                              else beg_info[t++]=47;           // если темп меньше нуля - пишем знак минус,  если больше - знак плюс
_0x179:
	CALL SUBOPT_0x60
	LDI  R26,LOW(47)
_0x299:
	STD  Z+0,R26
; 0000 042B                         }
; 0000 042C                         if (abs(temperature[ds_ar[temp1]])>99) {beg_info[t++]=(abs(temperature[ds_ar[temp1]])/100);}// Если темп >10,  выводим "десятки" температуры
_0x178:
	CALL SUBOPT_0x6B
	CALL SUBOPT_0x6C
	CPI  R30,LOW(0x64)
	LDI  R26,HIGH(0x64)
	CPC  R31,R26
	BRLT _0x17B
	CALL SUBOPT_0x60
	PUSH R31
	PUSH R30
	CALL SUBOPT_0x6B
	CALL SUBOPT_0x6C
	CALL SUBOPT_0x6D
	POP  R26
	POP  R27
	ST   X,R30
; 0000 042D                         beg_info[t++]=(abs(temperature[ds_ar[temp1]])%100)/10;                               // Выводим "единицы температуры"
_0x17B:
	CALL SUBOPT_0x60
	PUSH R31
	PUSH R30
	CALL SUBOPT_0x6B
	CALL SUBOPT_0x6C
	MOVW R26,R30
	CALL SUBOPT_0x67
	POP  R26
	POP  R27
	ST   X,R30
; 0000 042E                         // если температура  нужна с десятыми - раскомментируйте две строки ниже
; 0000 042F                         beg_info[t++]=43;                                                          // Разделительная точка
	CALL SUBOPT_0x60
	LDI  R26,LOW(43)
	STD  Z+0,R26
; 0000 0430                         beg_info[t++]=abs(temperature[ds_ar[temp1]])%10;                                  // Десятые доли градуса.
	CALL SUBOPT_0x60
	PUSH R31
	PUSH R30
	CALL SUBOPT_0x6B
	CALL SUBOPT_0x6C
	MOVW R26,R30
	CALL SUBOPT_0x20
	POP  R26
	POP  R27
	ST   X,R30
; 0000 0431                         beg_info[t++]=48;                                                             // Знак градуса
	CALL SUBOPT_0x60
	LDI  R26,LOW(48)
	STD  Z+0,R26
; 0000 0432                         beg_info[t++]=42;        //пробел
	CALL SUBOPT_0x60
	LDI  R26,LOW(42)
	STD  Z+0,R26
; 0000 0433                         }
	LDS  R30,_temp1
	SUBI R30,-LOW(1)
	STS  _temp1,R30
	RJMP _0x15A
_0x15B:
; 0000 0434 
; 0000 0435                 //вывод времени восхода
; 0000 0436                 beg_info[t++]=12;beg_info[t++]=24;beg_info[t++]=27;
	CALL SUBOPT_0x60
	LDI  R26,LOW(12)
	STD  Z+0,R26
	CALL SUBOPT_0x60
	LDI  R26,LOW(24)
	STD  Z+0,R26
	CALL SUBOPT_0x60
	LDI  R26,LOW(27)
	STD  Z+0,R26
; 0000 0437                 beg_info[t++]=31;beg_info[t++]=24;beg_info[t++]=14;beg_info[t++]=56;
	CALL SUBOPT_0x60
	LDI  R26,LOW(31)
	STD  Z+0,R26
	CALL SUBOPT_0x60
	LDI  R26,LOW(24)
	STD  Z+0,R26
	CALL SUBOPT_0x60
	LDI  R26,LOW(14)
	STD  Z+0,R26
	CALL SUBOPT_0x60
	LDI  R26,LOW(56)
	STD  Z+0,R26
; 0000 0438 
; 0000 0439                         for(i=1;i<5;i++){
	LDI  R18,LOW(1)
_0x17D:
	CPI  R18,5
	BRSH _0x17E
; 0000 043A                             if(i==1){
	CPI  R18,1
	BRNE _0x17F
; 0000 043B                                 if(sunriseToday/600!=0){ beg_info[t++]=timeToSymbol(sunriseToday,i);}
	LDS  R26,_sunriseToday
	LDS  R27,_sunriseToday+1
	CALL SUBOPT_0x1D
	SBIW R30,0
	BREQ _0x180
	CALL SUBOPT_0x60
	PUSH R31
	PUSH R30
	CALL SUBOPT_0x6E
	POP  R26
	POP  R27
	ST   X,R30
; 0000 043C                             }else{
_0x180:
	RJMP _0x181
_0x17F:
; 0000 043D                                 beg_info[t++]=timeToSymbol(sunriseToday,i);             //    десятки часов
	CALL SUBOPT_0x60
	PUSH R31
	PUSH R30
	CALL SUBOPT_0x6E
	POP  R26
	POP  R27
	ST   X,R30
; 0000 043E                             }
_0x181:
; 0000 043F                              if(i==2){
	CPI  R18,2
	BRNE _0x182
; 0000 0440                                    beg_info[t++]=43;
	CALL SUBOPT_0x60
	LDI  R26,LOW(43)
	STD  Z+0,R26
; 0000 0441                              }
; 0000 0442                         }
_0x182:
	SUBI R18,-1
	RJMP _0x17D
_0x17E:
; 0000 0443                         //    десятки часов
; 0000 0444                  beg_info[t++]=42;
	CALL SUBOPT_0x60
	CALL SUBOPT_0x68
; 0000 0445 
; 0000 0446                 //вывод времени заката
; 0000 0447                 beg_info[t++]=16;beg_info[t++]=10;beg_info[t++]=20;
	LDI  R26,LOW(16)
	STD  Z+0,R26
	CALL SUBOPT_0x60
	LDI  R26,LOW(10)
	STD  Z+0,R26
	CALL SUBOPT_0x60
	LDI  R26,LOW(20)
	STD  Z+0,R26
; 0000 0448                 beg_info[t++]=10;beg_info[t++]=28;beg_info[t++]=56;
	CALL SUBOPT_0x60
	LDI  R26,LOW(10)
	STD  Z+0,R26
	CALL SUBOPT_0x60
	LDI  R26,LOW(28)
	STD  Z+0,R26
	CALL SUBOPT_0x60
	LDI  R26,LOW(56)
	STD  Z+0,R26
; 0000 0449 
; 0000 044A 
; 0000 044B                         for(i=1;i<5;i++){
	LDI  R18,LOW(1)
_0x184:
	CPI  R18,5
	BRSH _0x185
; 0000 044C                             if(i==1){
	CPI  R18,1
	BRNE _0x186
; 0000 044D                                 if(sunsetToday/600!=0){ beg_info[t++]=timeToSymbol(sunsetToday,i);}
	LDS  R26,_sunsetToday
	LDS  R27,_sunsetToday+1
	CALL SUBOPT_0x1D
	SBIW R30,0
	BREQ _0x187
	CALL SUBOPT_0x60
	PUSH R31
	PUSH R30
	CALL SUBOPT_0x6F
	POP  R26
	POP  R27
	ST   X,R30
; 0000 044E                             }else{
_0x187:
	RJMP _0x188
_0x186:
; 0000 044F                                 beg_info[t++]=timeToSymbol(sunsetToday,i);             //    десятки часов
	CALL SUBOPT_0x60
	PUSH R31
	PUSH R30
	CALL SUBOPT_0x6F
	POP  R26
	POP  R27
	ST   X,R30
; 0000 0450                             }
_0x188:
; 0000 0451                              if(i==2){
	CPI  R18,2
	BRNE _0x189
; 0000 0452                                    beg_info[t++]=43;
	CALL SUBOPT_0x60
	LDI  R26,LOW(43)
	STD  Z+0,R26
; 0000 0453                              }
; 0000 0454                         }
_0x189:
	SUBI R18,-1
	RJMP _0x184
_0x185:
; 0000 0455 
; 0000 0456                 beg_info[t++]=42;
	CALL SUBOPT_0x60
	LDI  R26,LOW(42)
	STD  Z+0,R26
; 0000 0457 
; 0000 0458                 //вывод лунных суток
; 0000 0459                 moonDay=1;
	LDI  R21,LOW(1)
; 0000 045A                 for(moonYear=18;moonYear<=god; moonYear++)
	LDI  R20,LOW(18)
_0x18B:
	CP   R8,R20
	BRLO _0x18C
; 0000 045B                 {
; 0000 045C                        moonDay+=11;
	SUBI R21,-LOW(11)
; 0000 045D                        if(moonDay>30){
	CPI  R21,31
	BRLO _0x18D
; 0000 045E                             moonDay-=30;
	CALL SUBOPT_0x70
; 0000 045F                        }
; 0000 0460                 }
_0x18D:
	SUBI R20,-1
	RJMP _0x18B
_0x18C:
; 0000 0461                 moonDay=chislo+mesec+moonDay;
	MOV  R30,R9
	ADD  R30,R6
	ADD  R21,R30
; 0000 0462                 if(moonDay>30){
	CPI  R21,31
	BRLO _0x18E
; 0000 0463                     moonDay-=30;
	CALL SUBOPT_0x70
; 0000 0464                 }
; 0000 0465                 if(moonDay>=30 || moonDay<=0) {moonDay=1;}
_0x18E:
	CPI  R21,30
	BRSH _0x190
	CPI  R21,1
	BRSH _0x18F
_0x190:
	LDI  R21,LOW(1)
; 0000 0466                 if(moonDay>9){
_0x18F:
	CPI  R21,10
	BRLO _0x192
; 0000 0467                     beg_info[t++]=moonDay/10;
	CALL SUBOPT_0x60
	MOVW R22,R30
	MOV  R26,R21
	CALL SUBOPT_0x30
	CALL SUBOPT_0x65
; 0000 0468                     beg_info[t++]=moonDay%10;
	MOVW R22,R30
	MOV  R26,R21
	CLR  R27
	CALL SUBOPT_0x20
	MOVW R26,R22
	ST   X,R30
; 0000 0469                 }
; 0000 046A                 else{
	RJMP _0x193
_0x192:
; 0000 046B                       beg_info[t++]=moonDay;
	CALL SUBOPT_0x60
	ST   Z,R21
; 0000 046C                 }
_0x193:
; 0000 046D 
; 0000 046E                  beg_info[t++]=46; beg_info[t++]=19;
	CALL SUBOPT_0x60
	LDI  R26,LOW(46)
	STD  Z+0,R26
	CALL SUBOPT_0x60
	LDI  R26,LOW(19)
	STD  Z+0,R26
; 0000 046F                 beg_info[t++]=42;
	CALL SUBOPT_0x60
	CALL SUBOPT_0x68
; 0000 0470                 beg_info[t++]=21;beg_info[t++]=29;beg_info[t++]=23;
	LDI  R26,LOW(21)
	STD  Z+0,R26
	CALL SUBOPT_0x60
	LDI  R26,LOW(29)
	STD  Z+0,R26
	CALL SUBOPT_0x60
	CALL SUBOPT_0x71
; 0000 0471                 beg_info[t++]=23;beg_info[t++]=37;beg_info[t++]=19;beg_info[t++]=42;
	CALL SUBOPT_0x71
	LDI  R26,LOW(37)
	STD  Z+0,R26
	CALL SUBOPT_0x60
	LDI  R26,LOW(19)
	STD  Z+0,R26
	CALL SUBOPT_0x60
	CALL SUBOPT_0x68
; 0000 0472                 beg_info[t++]=14;beg_info[t++]=15;beg_info[t++]=23;beg_info[t++]=38;
	LDI  R26,LOW(14)
	STD  Z+0,R26
	CALL SUBOPT_0x60
	LDI  R26,LOW(15)
	STD  Z+0,R26
	CALL SUBOPT_0x60
	CALL SUBOPT_0x71
	LDI  R26,LOW(38)
	STD  Z+0,R26
; 0000 0473                 beg_info[t++]=42;
	CALL SUBOPT_0x60
	CALL SUBOPT_0x68
; 0000 0474                 beg_info[t++]=42;
	CALL SUBOPT_0x68
; 0000 0475 
; 0000 0476 
; 0000 0477                 beg_info[t++]=timeToSymbol(time,1);  //    десятки часов
	PUSH R31
	PUSH R30
	CALL SUBOPT_0x54
	LDI  R30,LOW(1)
	ST   -Y,R30
	CALL _timeToSymbol
	POP  R26
	POP  R27
	ST   X,R30
; 0000 0478                 beg_info[t++]=timeToSymbol(time,2);         //    единицы часов
	CALL SUBOPT_0x60
	PUSH R31
	PUSH R30
	CALL SUBOPT_0x54
	LDI  R30,LOW(2)
	ST   -Y,R30
	CALL _timeToSymbol
	POP  R26
	POP  R27
	ST   X,R30
; 0000 0479                 beg_info[t++]=43;                    //    разделительная точка
	CALL SUBOPT_0x60
	LDI  R26,LOW(43)
	STD  Z+0,R26
; 0000 047A                 beg_info[t++]=timeToSymbol(time,3);          //    десятки минут
	CALL SUBOPT_0x60
	PUSH R31
	PUSH R30
	CALL SUBOPT_0x54
	LDI  R30,LOW(3)
	ST   -Y,R30
	CALL _timeToSymbol
	POP  R26
	POP  R27
	ST   X,R30
; 0000 047B                 beg_info[t++]=timeToSymbol(time,4);               //    единицы минут
	CALL SUBOPT_0x60
	PUSH R31
	PUSH R30
	CALL SUBOPT_0x54
	LDI  R30,LOW(4)
	ST   -Y,R30
	CALL _timeToSymbol
	POP  R26
	POP  R27
	ST   X,R30
; 0000 047C                 beg_info[t]=255;                     //    метка конца "бегущей строки"
	CALL SUBOPT_0x72
; 0000 047D 
; 0000 047E 
; 0000 047F                 if (Interval >= speed){
	BRLO _0x194
; 0000 0480                     Interval=0;
	CALL SUBOPT_0x73
; 0000 0481                     if (beg_stroka_not(beg_info)==255){
	CALL SUBOPT_0x74
	CPI  R30,LOW(0xFF)
	BRNE _0x195
; 0000 0482                         str_pause ();
	CALL SUBOPT_0x75
; 0000 0483                         meny=10;
; 0000 0484                         ochistka();
	CALL _ochistka
; 0000 0485                         data1=time;
	CALL SUBOPT_0x76
; 0000 0486                     }
; 0000 0487                 }//  если строка полностью пробежала
_0x195:
; 0000 0488 
; 0000 0489                 if (BUT_STEP) {meny=30; z=0; z1=0; ochistka();}
_0x194:
	LDI  R30,LOW(2)
	CP   R30,R13
	BRNE _0x196
	CALL SUBOPT_0x58
; 0000 048A                 if (BUT_OK)   {z=0; z1=3; temp=0x0F; ochistka();}
_0x196:
	LDI  R30,LOW(1)
	CP   R30,R13
	BRNE _0x197
	LDI  R30,LOW(0)
	STS  _z,R30
	LDI  R30,LOW(3)
	STS  _z1,R30
	LDI  R30,LOW(15)
	STS  _temp,R30
	CALL _ochistka
; 0000 048B 
; 0000 048C 
; 0000 048D         break;
_0x197:
	RJMP _0x130
; 0000 048E 
; 0000 048F         //****************************Установки будильников***********************************
; 0000 0490         case 30: //  На экране текст - "Будильник"
_0x139:
	CPI  R30,LOW(0x1E)
	LDI  R26,HIGH(0x1E)
	CPC  R31,R26
	BRNE _0x198
; 0000 0491             if (Interval>=speed)  {Interval=0;   beg_stroka(budilnik_txt);}
	CALL SUBOPT_0x77
	BRLO _0x199
	CALL SUBOPT_0x73
	LDI  R30,LOW(_budilnik_txt*2)
	LDI  R31,HIGH(_budilnik_txt*2)
	CALL SUBOPT_0x78
; 0000 0492             if (BUT_STEP) {meny=40;z=0; z1=0;ochistka();}
_0x199:
	LDI  R30,LOW(2)
	CP   R30,R13
	BRNE _0x19A
	LDI  R30,LOW(40)
	CALL SUBOPT_0x79
; 0000 0493             if (BUT_OK)   {ochistka(); bud=0; temp=0; meny=31;}
_0x19A:
	LDI  R30,LOW(1)
	CP   R30,R13
	BRNE _0x19B
	CALL _ochistka
	LDI  R30,LOW(0)
	STS  _bud,R30
	STS  _temp,R30
	LDI  R30,LOW(31)
	MOV  R4,R30
; 0000 0494         break;
_0x19B:
	RJMP _0x130
; 0000 0495         case 31: //  выбираем номер будильника
_0x198:
	CPI  R30,LOW(0x1F)
	LDI  R26,HIGH(0x1F)
	CPC  R31,R26
	BRNE _0x19C
; 0000 0496             if (BUT_STEP) {meny=32;}
	LDI  R30,LOW(2)
	CP   R30,R13
	BRNE _0x19D
	LDI  R30,LOW(32)
	MOV  R4,R30
; 0000 0497             if (BUT_OK  ) {bud++; if (bud==9) bud=0;  }
_0x19D:
	LDI  R30,LOW(1)
	CP   R30,R13
	BRNE _0x19E
	LDS  R30,_bud
	SUBI R30,-LOW(1)
	STS  _bud,R30
	LDS  R26,_bud
	CPI  R26,LOW(0x9)
	BRNE _0x19F
	LDI  R30,LOW(0)
	STS  _bud,R30
_0x19F:
; 0000 0498             ekran_1_figure(11,1); line=1; ekran_1_figure(bud+1,7); line=0; ekran_1_figure(((budilnik_Install[bud] & 0x80) ? (47):(46)),17);
_0x19E:
	CALL SUBOPT_0x7A
	SET
	BLD  R2,7
	CALL SUBOPT_0x7B
	CLT
	BLD  R2,7
	CALL SUBOPT_0x7C
	LD   R30,Z
	ANDI R30,LOW(0x80)
	BREQ _0x1A0
	LDI  R30,LOW(47)
	RJMP _0x1A1
_0x1A0:
	LDI  R30,LOW(46)
_0x1A1:
	CALL SUBOPT_0x7D
; 0000 0499         break;
	RJMP _0x130
; 0000 049A         case 32: //  включаем или отключаем его.  если отключили - переходим в режим "часы"
_0x19C:
	CPI  R30,LOW(0x20)
	LDI  R26,HIGH(0x20)
	CPC  R31,R26
	BREQ PC+3
	JMP _0x1A3
; 0000 049B             if (BUT_STEP)
	LDI  R30,LOW(2)
	CP   R30,R13
	BRNE _0x1A4
; 0000 049C                     {
; 0000 049D                     if (budilnik_Install[bud] & 0x80)    // если текущий будильник включен
	CALL SUBOPT_0x7C
	LD   R30,Z
	ANDI R30,LOW(0x80)
	BREQ _0x1A5
; 0000 049E                         {
; 0000 049F                         budilnik_time[bud]= ystanovki_23_59 (budilnik_time[bud]);     // устанавливаем время сработки будильника
	LDS  R30,_bud
	LDI  R26,LOW(_budilnik_time)
	LDI  R27,HIGH(_budilnik_time)
	CALL SUBOPT_0x42
	PUSH R31
	PUSH R30
	LDS  R30,_bud
	CALL SUBOPT_0x7E
	CALL SUBOPT_0x7F
	POP  R26
	POP  R27
	ST   X+,R30
	ST   X,R31
; 0000 04A0                             if (bud<3){budilnik_Install[bud] = 0xFF; goto m1;}        // если будильник №1-3 то установки "по дням недели" не производим, и переходим сразу к настройке длительности сигнала этого будильника
	LDS  R26,_bud
	CPI  R26,LOW(0x3)
	BRSH _0x1A6
	CALL SUBOPT_0x7C
	LDI  R26,LOW(255)
	STD  Z+0,R26
	RJMP _0x1A7
; 0000 04A1                             else {temp=0;  meny=33;}                                  // если будильник №4-9 то перехъодим к настройке будильника на сработку в определенные дни
_0x1A6:
	LDI  R30,LOW(0)
	STS  _temp,R30
	LDI  R30,LOW(33)
	MOV  R4,R30
; 0000 04A2                         }
; 0000 04A3                     else {str_pause (); meny=10;}   ochistka();  break;               // если текущий будильник отключен - переходим в режим "часы"
	RJMP _0x1A9
_0x1A5:
	CALL SUBOPT_0x75
_0x1A9:
	RJMP _0x29A
; 0000 04A4                     }
; 0000 04A5             if (BUT_OK )  {budilnik_Install[bud] ^= 0x80;}                            //  каждое нажатие включает/отключает конкретный будильник (устанавливает/сбрасывает в 1 бит7)
_0x1A4:
	LDI  R30,LOW(1)
	CP   R30,R13
	BRNE _0x1AA
	CALL SUBOPT_0x7C
	MOVW R0,R30
	LD   R26,Z
	LDI  R30,LOW(128)
	EOR  R30,R26
	MOVW R26,R0
	ST   X,R30
; 0000 04A6             ekran_1_figure(11,1); ekran_1_figure(bud+1,7); line=1; ekran_1_figure(((budilnik_Install[bud] & 0x80) ? (47):(46)),17); line=0;
_0x1AA:
	CALL SUBOPT_0x7A
	CALL SUBOPT_0x7B
	SET
	BLD  R2,7
	CALL SUBOPT_0x7C
	LD   R30,Z
	ANDI R30,LOW(0x80)
	BREQ _0x1AB
	LDI  R30,LOW(47)
	RJMP _0x1AC
_0x1AB:
	LDI  R30,LOW(46)
_0x1AC:
	CALL SUBOPT_0x7D
	CLT
	BLD  R2,7
; 0000 04A7         break;
	RJMP _0x130
; 0000 04A8         case 33:  //  Настраиваем будильник на сработку в определенные дни, и длительность его сигнала.
_0x1A3:
	CPI  R30,LOW(0x21)
	LDI  R26,HIGH(0x21)
	CPC  R31,R26
	BREQ PC+3
	JMP _0x1AE
; 0000 04A9             ekran_1_figure (den_nedeli_letter[temp][0],0);  ekran_1_figure (den_nedeli_letter[temp][1],6);// вывожу названия дней недели. (массив "beg_info" содержит название дня недели)
	CALL SUBOPT_0x80
	LPM  R30,Z
	CALL SUBOPT_0x38
	CALL SUBOPT_0x80
	ADIW R30,1
	LPM  R30,Z
	CALL SUBOPT_0x39
; 0000 04AA             ekran_1_figure (((budilnik_Install[bud] & (1 << temp)) ? 47:46),17);                          // вывожу знак "+" или "-"  обозначающий  вкл./выкл. будильника.
	CALL SUBOPT_0x7C
	LD   R1,Z
	LDS  R30,_temp
	RCALL SUBOPT_0x8
	BREQ _0x1AF
	LDI  R30,LOW(47)
	RJMP _0x1B0
_0x1AF:
	LDI  R30,LOW(46)
_0x1B0:
	CALL SUBOPT_0x7D
; 0000 04AB 
; 0000 04AC             if (BUT_STEP) {temp++; ochistka();                                                            // "перебираю"  дни недели для будильника
	LDI  R30,LOW(2)
	CP   R30,R13
	BRNE _0x1B2
	CALL SUBOPT_0x2B
	CALL _ochistka
; 0000 04AD                           if (temp==7){ m1: meny=10; budilnik_Interval[bud] = ystanovki_2(1,15,8); }      //  если все дни недели установлены,  задаю время звучания сигнала.
	LDS  R26,_temp
	CPI  R26,LOW(0x7)
	BRNE _0x1B3
_0x1A7:
	LDI  R30,LOW(10)
	MOV  R4,R30
	LDS  R30,_bud
	LDI  R31,0
	SUBI R30,LOW(-_budilnik_Interval)
	SBCI R31,HIGH(-_budilnik_Interval)
	PUSH R31
	PUSH R30
	LDI  R30,LOW(1)
	ST   -Y,R30
	LDI  R30,LOW(15)
	ST   -Y,R30
	LDI  R30,LOW(8)
	ST   -Y,R30
	CALL _ystanovki_2
	POP  R26
	POP  R27
	ST   X,R30
; 0000 04AE                           }
_0x1B3:
; 0000 04AF             if (BUT_OK){(budilnik_Install[bud]) ^= (1 << temp);}                                           // включаю/отключаю будильник в конкретный день недели.
_0x1B2:
	LDI  R30,LOW(1)
	CP   R30,R13
	BRNE _0x1B4
	CALL SUBOPT_0x7C
	MOVW R22,R30
	LD   R1,Z
	LDS  R30,_temp
	LDI  R26,LOW(1)
	CALL __LSLB12
	EOR  R30,R1
	MOVW R26,R22
	ST   X,R30
; 0000 04B0         break;
_0x1B4:
	RJMP _0x130
; 0000 04B1         case 40: //*********************Установка времени и даты****************************
_0x1AE:
	CPI  R30,LOW(0x28)
	LDI  R26,HIGH(0x28)
	CPC  R31,R26
	BREQ PC+3
	JMP _0x1B5
; 0000 04B2                 if (Interval>=speed)  {Interval=0; beg_stroka(nastroiki_txt);}
	CALL SUBOPT_0x77
	BRLO _0x1B6
	CALL SUBOPT_0x73
	LDI  R30,LOW(_nastroiki_txt*2)
	LDI  R31,HIGH(_nastroiki_txt*2)
	CALL SUBOPT_0x78
; 0000 04B3                 if (BUT_STEP) {meny=50; z=0; z1=0; ochistka();}
_0x1B6:
	LDI  R30,LOW(2)
	CP   R30,R13
	BRNE _0x1B7
	LDI  R30,LOW(50)
	CALL SUBOPT_0x79
; 0000 04B4                 if (BUT_OK)
_0x1B7:
	LDI  R30,LOW(1)
	CP   R30,R13
	BRNE _0x1B8
; 0000 04B5                         {
; 0000 04B6                         time   =ystanovki_23_59(time);
	CALL SUBOPT_0x54
	CALL _ystanovki_23_59
	STS  _time,R30
	STS  _time+1,R31
; 0000 04B7                         ochistka();
	CALL _ochistka
; 0000 04B8                         ekran_1_figure(33,1);          ekran_1_figure(43,6);
	LDI  R30,LOW(33)
	CALL SUBOPT_0x81
	CALL SUBOPT_0x39
; 0000 04B9                         chislo =ystanovki_2 (chislo,31, 13);
	ST   -Y,R6
	LDI  R30,LOW(31)
	CALL SUBOPT_0x82
	MOV  R6,R30
; 0000 04BA                         ekran_1_figure(22,1);          ekran_1_figure(43,7);
	LDI  R30,LOW(22)
	CALL SUBOPT_0x81
	ST   -Y,R30
	LDI  R30,LOW(7)
	ST   -Y,R30
	CALL _ekran_1_figure
; 0000 04BB                         mesec  =ystanovki_2 (mesec, 12, 13);
	ST   -Y,R9
	LDI  R30,LOW(12)
	CALL SUBOPT_0x82
	MOV  R9,R30
; 0000 04BC                         ekran_1_figure(13,1);          ekran_1_figure(43,5);
	LDI  R30,LOW(13)
	CALL SUBOPT_0x81
	ST   -Y,R30
	LDI  R30,LOW(5)
	ST   -Y,R30
	CALL _ekran_1_figure
; 0000 04BD                         god    =ystanovki_2 (god,   99, 13);
	ST   -Y,R8
	LDI  R30,LOW(99)
	CALL SUBOPT_0x82
	MOV  R8,R30
; 0000 04BE                         button=0;meny=10;ochistka(); temp=0; data1=time; str_pause ();
	CLR  R13
	LDI  R30,LOW(10)
	CALL SUBOPT_0x83
	CALL SUBOPT_0x76
	CALL _str_pause
; 0000 04BF                         }
; 0000 04C0         break;
_0x1B8:
	RJMP _0x130
; 0000 04C1 
; 0000 04C2         case 48: // настройка шрифта
_0x1B5:
	CPI  R30,LOW(0x30)
	LDI  R26,HIGH(0x30)
	CPC  R31,R26
	BRNE _0x1B9
; 0000 04C3             if (Interval>=speed)  {Interval=0; beg_stroka( font_zifr_txt);}
	CALL SUBOPT_0x77
	BRLO _0x1BA
	CALL SUBOPT_0x73
	LDI  R30,LOW(_font_zifr_txt*2)
	LDI  R31,HIGH(_font_zifr_txt*2)
	CALL SUBOPT_0x78
; 0000 04C4             if (BUT_STEP)   {z=0; z1=0; ochistka();temp=12; if(font_epp!=font_)font_epp=font_; meny=10;break; }
_0x1BA:
	LDI  R30,LOW(2)
	CP   R30,R13
	BRNE _0x1BB
	CALL SUBOPT_0x84
	CALL _ochistka
	LDI  R30,LOW(12)
	STS  _temp,R30
	LDS  R30,_font_
	CP   R30,R5
	BREQ _0x1BC
	LDS  R5,_font_
_0x1BC:
	LDI  R30,LOW(10)
	MOV  R4,R30
	RJMP _0x130
; 0000 04C5             if (BUT_OK)  { ochistka();font_++;  if (font_>6) font_=0;
_0x1BB:
	LDI  R30,LOW(1)
	CP   R30,R13
	BRNE _0x1BD
	CALL _ochistka
	LDS  R30,_font_
	SUBI R30,-LOW(1)
	STS  _font_,R30
	LDS  R26,_font_
	CPI  R26,LOW(0x7)
	BRLO _0x1BE
	LDI  R30,LOW(0)
	STS  _font_,R30
; 0000 04C6                            font_cifri ();ekran_1_figure(font_,10); delay_ms(1000);z=0; z1=0;  t=0; temp1=0; ochistka();
_0x1BE:
	CALL _font_cifri
	LDS  R30,_font_
	ST   -Y,R30
	LDI  R30,LOW(10)
	CALL SUBOPT_0x85
	CALL SUBOPT_0x84
	CALL SUBOPT_0x5B
	CALL _ochistka
; 0000 04C7                              } break;
_0x1BD:
	RJMP _0x130
; 0000 04C8         break;
; 0000 04C9 
; 0000 04CA 
; 0000 04CB 
; 0000 04CC         //*******Настройка бег строки. Выбираем какую информацию будем выводить с помощью бег. строки**********
; 0000 04CD         case 50: // на экране текст - "Коррекция"
_0x1B9:
	CPI  R30,LOW(0x32)
	LDI  R26,HIGH(0x32)
	CPC  R31,R26
	BRNE _0x1BF
; 0000 04CE                if (Interval>=speed)  {Interval=0;   beg_stroka(nastr_stroki_txt);}
	CALL SUBOPT_0x77
	BRLO _0x1C0
	CALL SUBOPT_0x73
	LDI  R30,LOW(_nastr_stroki_txt*2)
	LDI  R31,HIGH(_nastr_stroki_txt*2)
	CALL SUBOPT_0x78
; 0000 04CF                if (BUT_STEP) {meny=70; z=0; z1=0; ochistka();}
_0x1C0:
	LDI  R30,LOW(2)
	CP   R30,R13
	BRNE _0x1C1
	LDI  R30,LOW(70)
	CALL SUBOPT_0x79
; 0000 04D0                if (BUT_OK)   {meny=51; ochistka(); temp=0;}
_0x1C1:
	LDI  R30,LOW(1)
	CP   R30,R13
	BRNE _0x1C2
	LDI  R30,LOW(51)
	CALL SUBOPT_0x83
; 0000 04D1         break;
_0x1C2:
	RJMP _0x130
; 0000 04D2         case 51:
_0x1BF:
	CPI  R30,LOW(0x33)
	LDI  R26,HIGH(0x33)
	CPC  R31,R26
	BREQ PC+3
	JMP _0x1C3
; 0000 04D3                 if (BUT_STEP) {temp++; ochistka();}
	LDI  R30,LOW(2)
	CP   R30,R13
	BRNE _0x1C4
	RCALL SUBOPT_0x2B
	CALL _ochistka
; 0000 04D4                 switch (temp)
_0x1C4:
	LDS  R30,_temp
	LDI  R31,0
; 0000 04D5                         {
; 0000 04D6                         case 0:  if (BUT_OK){str ^= (1 << 0);}   ekran_1_figure (((str & 0x01) ? 47:46),19);   txt_ekran(den_txt);            break;
	SBIW R30,0
	BRNE _0x1C8
	LDI  R30,LOW(1)
	CP   R30,R13
	BRNE _0x1C9
	CALL SUBOPT_0x56
	LDI  R26,LOW(1)
	CALL SUBOPT_0x86
_0x1C9:
	CALL SUBOPT_0x56
	ANDI R30,LOW(0x1)
	BREQ _0x1CA
	LDI  R30,LOW(47)
	RJMP _0x1CB
_0x1CA:
	LDI  R30,LOW(46)
_0x1CB:
	RCALL SUBOPT_0x35
	LDI  R30,LOW(_den_txt*2)
	LDI  R31,HIGH(_den_txt*2)
	CALL SUBOPT_0x87
	RJMP _0x1C7
; 0000 04D7                         case 1:  if (BUT_OK){str ^= (1 << 1);}    txt_ekran(data_txt); ekran_1_figure (((str & 0x02) ? 47:46),19);             break;
_0x1C8:
	CPI  R30,LOW(0x1)
	LDI  R26,HIGH(0x1)
	CPC  R31,R26
	BRNE _0x1CD
	LDI  R30,LOW(1)
	CP   R30,R13
	BRNE _0x1CE
	CALL SUBOPT_0x56
	LDI  R26,LOW(2)
	CALL SUBOPT_0x86
_0x1CE:
	LDI  R30,LOW(_data_txt*2)
	LDI  R31,HIGH(_data_txt*2)
	CALL SUBOPT_0x87
	CALL SUBOPT_0x56
	ANDI R30,LOW(0x2)
	BREQ _0x1CF
	LDI  R30,LOW(47)
	RJMP _0x1D0
_0x1CF:
	LDI  R30,LOW(46)
_0x1D0:
	RCALL SUBOPT_0x35
	RJMP _0x1C7
; 0000 04D8                         case 2:  if (BUT_OK){str ^= (1 << 2);}   ekran_1_figure (((str & 0x04) ? 47:46),19);   txt_ekran(god_txt);            break;
_0x1CD:
	CPI  R30,LOW(0x2)
	LDI  R26,HIGH(0x2)
	CPC  R31,R26
	BRNE _0x1D2
	LDI  R30,LOW(1)
	CP   R30,R13
	BRNE _0x1D3
	CALL SUBOPT_0x56
	LDI  R26,LOW(4)
	CALL SUBOPT_0x86
_0x1D3:
	CALL SUBOPT_0x56
	ANDI R30,LOW(0x4)
	BREQ _0x1D4
	LDI  R30,LOW(47)
	RJMP _0x1D5
_0x1D4:
	LDI  R30,LOW(46)
_0x1D5:
	RCALL SUBOPT_0x35
	LDI  R30,LOW(_god_txt*2)
	LDI  R31,HIGH(_god_txt*2)
	CALL SUBOPT_0x87
	RJMP _0x1C7
; 0000 04D9                         case 3:  if (BUT_OK){zv_chs++;       }   ekran_1_figure (((zv_chs) ? 47:46),19);       ekran_1_figure(16,0); ekran_1_figure(12,4); ekran_1_figure(43,8); ekran_1_figure(33,9); ekran_1_figure(27,14); break;
_0x1D2:
	CPI  R30,LOW(0x3)
	LDI  R26,HIGH(0x3)
	CPC  R31,R26
	BRNE _0x1D7
	LDI  R30,LOW(1)
	CP   R30,R13
	BRNE _0x1D8
	LDI  R30,LOW(32)
	EOR  R2,R30
_0x1D8:
	SBRS R2,5
	RJMP _0x1D9
	LDI  R30,LOW(47)
	RJMP _0x1DA
_0x1D9:
	LDI  R30,LOW(46)
_0x1DA:
	RCALL SUBOPT_0x35
	LDI  R30,LOW(16)
	RCALL SUBOPT_0x38
	CALL SUBOPT_0x88
	LDI  R30,LOW(33)
	ST   -Y,R30
	LDI  R30,LOW(9)
	ST   -Y,R30
	CALL _ekran_1_figure
	LDI  R30,LOW(27)
	CALL SUBOPT_0x89
	RJMP _0x1C7
; 0000 04DA                         case 4:  if (BUT_OK){zv_kn++;        }   ekran_1_figure (((zv_kn)  ? 47:46),19);       ekran_1_figure(16,0); ekran_1_figure(12,4); ekran_1_figure(43,8); ekran_1_figure(20,9); ekran_1_figure(23,14); break;
_0x1D7:
	CPI  R30,LOW(0x4)
	LDI  R26,HIGH(0x4)
	CPC  R31,R26
	BRNE _0x1DC
	LDI  R30,LOW(1)
	CP   R30,R13
	BRNE _0x1DD
	LDI  R30,LOW(16)
	EOR  R2,R30
_0x1DD:
	SBRS R2,4
	RJMP _0x1DE
	LDI  R30,LOW(47)
	RJMP _0x1DF
_0x1DE:
	LDI  R30,LOW(46)
_0x1DF:
	RCALL SUBOPT_0x35
	LDI  R30,LOW(16)
	RCALL SUBOPT_0x38
	CALL SUBOPT_0x88
	LDI  R30,LOW(20)
	ST   -Y,R30
	LDI  R30,LOW(9)
	ST   -Y,R30
	CALL _ekran_1_figure
	LDI  R30,LOW(23)
	CALL SUBOPT_0x89
	RJMP _0x1C7
; 0000 04DB                         case 5: if (BUT_OK){ochistka();z=0; z1=0;meny=48;break;}  ; ekran_1_figure(34,0); ekran_1_figure(26,6); ekran_1_figure(18,11); ekran_1_figure(30,16);ekran_1_figure(28,21); break;
_0x1DC:
	CPI  R30,LOW(0x5)
	LDI  R26,HIGH(0x5)
	CPC  R31,R26
	BRNE _0x1E1
	LDI  R30,LOW(1)
	CP   R30,R13
	BRNE _0x1E2
	CALL _ochistka
	CALL SUBOPT_0x84
	LDI  R30,LOW(48)
	MOV  R4,R30
	RJMP _0x1C7
_0x1E2:
	LDI  R30,LOW(34)
	RCALL SUBOPT_0x38
	LDI  R30,LOW(26)
	RCALL SUBOPT_0x39
	LDI  R30,LOW(18)
	ST   -Y,R30
	LDI  R30,LOW(11)
	ST   -Y,R30
	CALL _ekran_1_figure
	LDI  R30,LOW(30)
	ST   -Y,R30
	LDI  R30,LOW(16)
	ST   -Y,R30
	CALL _ekran_1_figure
	LDI  R30,LOW(28)
	ST   -Y,R30
	LDI  R30,LOW(21)
	ST   -Y,R30
	CALL _ekran_1_figure
	RJMP _0x1C7
; 0000 04DC                         case 6:  meny=52; temp=speed; break;
_0x1E1:
	CPI  R30,LOW(0x6)
	LDI  R26,HIGH(0x6)
	CPC  R31,R26
	BRNE _0x1C7
	LDI  R30,LOW(52)
	MOV  R4,R30
	LDS  R30,_speed
	STS  _temp,R30
; 0000 04DD                         }
_0x1C7:
; 0000 04DE         break;
	RJMP _0x130
; 0000 04DF         case 52: // настройка скорости бегущей строки
_0x1C3:
	CPI  R30,LOW(0x34)
	LDI  R26,HIGH(0x34)
	CPC  R31,R26
	BRNE _0x1E4
; 0000 04E0             if (Interval>=temp)  {Interval=0;   beg_stroka_not(beg_info);}
	LDS  R30,_temp
	LDS  R26,_Interval
	LDS  R27,_Interval+1
	LDI  R31,0
	CP   R26,R30
	CPC  R27,R31
	BRLO _0x1E5
	CALL SUBOPT_0x73
	CALL SUBOPT_0x74
; 0000 04E1             if (BUT_OK)  {temp+=3;  if (temp>=60) {temp=9;}}
_0x1E5:
	LDI  R30,LOW(1)
	CP   R30,R13
	BRNE _0x1E6
	LDS  R30,_temp
	SUBI R30,-LOW(3)
	STS  _temp,R30
	LDS  R26,_temp
	CPI  R26,LOW(0x3C)
	BRLO _0x1E7
	LDI  R30,LOW(9)
	STS  _temp,R30
_0x1E7:
; 0000 04E2             if (BUT_STEP)   {speed=temp; meny=54; ochistka();}
_0x1E6:
	LDI  R30,LOW(2)
	CP   R30,R13
	BRNE _0x1E8
	LDS  R30,_temp
	STS  _speed,R30
	LDI  R30,LOW(54)
	MOV  R4,R30
	CALL _ochistka
; 0000 04E3         break;
_0x1E8:
	RJMP _0x130
; 0000 04E4 
; 0000 04E5         case 54: // установка времени включения и выключения пониженной яркости ()
_0x1E4:
	CPI  R30,LOW(0x36)
	LDI  R26,HIGH(0x36)
	CPC  R31,R26
	BRNE _0x1E9
; 0000 04E6             TIMSK&=0x7F;         //  выключаю "автоматическое" изменение яркости.  (нужно для того, чтоб яркость не "пригала" во время настройки)
	IN   R30,0x39
	ANDI R30,0x7F
	OUT  0x39,R30
; 0000 04E7             brigh_down_time=ystanovki_23_59(brigh_down_time); // установка времени включения пониженной яркости
	RCALL SUBOPT_0x16
	CALL SUBOPT_0x7F
	LDI  R26,LOW(_brigh_down_time)
	LDI  R27,HIGH(_brigh_down_time)
	CALL __EEPROMWRW
; 0000 04E8             ochistka();
	CALL _ochistka
; 0000 04E9             brigh_up_time=ystanovki_23_59(brigh_up_time);     // установка времени ВЫключения пониженной яркости
	RCALL SUBOPT_0x17
	CALL SUBOPT_0x7F
	LDI  R26,LOW(_brigh_up_time)
	LDI  R27,HIGH(_brigh_up_time)
	CALL __EEPROMWRW
; 0000 04EA             ochistka();
	CALL _ochistka
; 0000 04EB             meny=55;
	LDI  R30,LOW(55)
	MOV  R4,R30
; 0000 04EC         break;
	RJMP _0x130
; 0000 04ED         case 55: // установка уровня пониженной яркости
_0x1E9:
	CPI  R30,LOW(0x37)
	LDI  R26,HIGH(0x37)
	CPC  R31,R26
	BRNE _0x1EA
; 0000 04EE             ekran_1_figure(41,0);
	LDI  R30,LOW(41)
	RCALL SUBOPT_0x38
; 0000 04EF             ekran_1_figure(26,5);
	LDI  R30,LOW(26)
	ST   -Y,R30
	LDI  R30,LOW(5)
	ST   -Y,R30
	CALL _ekran_1_figure
; 0000 04F0             ekran_1_figure(20,10);
	LDI  R30,LOW(20)
	ST   -Y,R30
	LDI  R30,LOW(10)
	ST   -Y,R30
	CALL _ekran_1_figure
; 0000 04F1             ekran_1_figure(brigh_up,18);
	CALL SUBOPT_0x8A
	ST   -Y,R30
	LDI  R30,LOW(18)
	ST   -Y,R30
	CALL _ekran_1_figure
; 0000 04F2             TIMSK|=0x02;                // включаю регулировку яркости индикаторов(разрешаю прерывание по совпадению Т0)
	IN   R30,0x39
	ORI  R30,2
	OUT  0x39,R30
; 0000 04F3             OCR0=(brigh_up)*23+5;       // яркость экрана в зависимости от значения   brigh_up
	CALL SUBOPT_0x8A
	LDI  R26,LOW(23)
	MULS R30,R26
	MOVW R30,R0
	SUBI R30,-LOW(5)
	OUT  0x3C,R30
; 0000 04F4             if (BUT_OK)  {brigh_up++; if(brigh_up==10) brigh_up=0;} //
	LDI  R30,LOW(1)
	CP   R30,R13
	BRNE _0x1EB
	CALL SUBOPT_0x8A
	SUBI R30,-LOW(1)
	CALL __EEPROMWRB
	SUBI R30,LOW(1)
	CALL SUBOPT_0x8A
	CPI  R30,LOW(0xA)
	BRNE _0x1EC
	LDI  R26,LOW(_brigh_up)
	LDI  R27,HIGH(_brigh_up)
	LDI  R30,LOW(0)
	CALL __EEPROMWRB
_0x1EC:
; 0000 04F5             if (BUT_STEP)   {  meny=57; TIMSK|=0x80; ochistka();}   //
_0x1EB:
	LDI  R30,LOW(2)
	CP   R30,R13
	BRNE _0x1ED
	LDI  R30,LOW(57)
	MOV  R4,R30
	IN   R30,0x39
	ORI  R30,0x80
	OUT  0x39,R30
	CALL _ochistka
; 0000 04F6         break;
_0x1ED:
	RJMP _0x130
; 0000 04F7         case 57: // Настройка периода запуска  бегущей строки
_0x1EA:
	CPI  R30,LOW(0x39)
	LDI  R26,HIGH(0x39)
	CPC  R31,R26
	BRNE _0x1EE
; 0000 04F8         temp=str_period;
	LDI  R26,LOW(_str_period)
	LDI  R27,HIGH(_str_period)
	CALL __EEPROMRDB
	STS  _temp,R30
; 0000 04F9         ekran_1_figure( (temp%60)/10,13);
	LDS  R26,_temp
	RCALL SUBOPT_0x10
	MOVW R26,R30
	LDI  R30,LOW(10)
	LDI  R31,HIGH(10)
	CALL __DIVW21
	RCALL SUBOPT_0x34
; 0000 04FA         ekran_1_figure((temp%60)%10,19);
	LDS  R26,_temp
	RCALL SUBOPT_0x10
	MOVW R26,R30
	RCALL SUBOPT_0x20
	RCALL SUBOPT_0x35
; 0000 04FB         temp=60*(ystanovki_2 (temp/60,3,0) );
	RCALL SUBOPT_0x53
	RCALL SUBOPT_0x1E
	ST   -Y,R30
	LDI  R30,LOW(3)
	RCALL SUBOPT_0x37
	MULS R30,R26
	MOVW R30,R0
	STS  _temp,R30
; 0000 04FC         ekran_1_figure(0,0);          ekran_1_figure(temp/60,6);
	LDI  R30,LOW(0)
	RCALL SUBOPT_0x38
	RCALL SUBOPT_0x53
	RCALL SUBOPT_0x1E
	RCALL SUBOPT_0x39
; 0000 04FD         temp=temp+(ystanovki_2 (str_period%60,59,13));
	RCALL SUBOPT_0xE
	CALL __MODW21
	RCALL SUBOPT_0x3A
	LDS  R26,_temp
	ADD  R30,R26
	STS  _temp,R30
; 0000 04FE         str_period=temp;
	LDI  R26,LOW(_str_period)
	LDI  R27,HIGH(_str_period)
	CALL __EEPROMWRB
; 0000 04FF         str_pause ();  meny=58; z=0;z1=0;
	CALL _str_pause
	LDI  R30,LOW(58)
	MOV  R4,R30
	CALL SUBOPT_0x84
; 0000 0500         break;
	RJMP _0x130
; 0000 0501 
; 0000 0502         case 58:
_0x1EE:
	CPI  R30,LOW(0x3A)
	LDI  R26,HIGH(0x3A)
	CPC  R31,R26
	BRNE _0x1EF
; 0000 0503             if (Interval>=speed)  {Interval=0;   beg_stroka(animation_txt);}
	CALL SUBOPT_0x77
	BRLO _0x1F0
	CALL SUBOPT_0x73
	LDI  R30,LOW(_animation_txt*2)
	LDI  R31,HIGH(_animation_txt*2)
	CALL SUBOPT_0x78
; 0000 0504             if (BUT_OK)  {meny=59;ochistka();}
_0x1F0:
	LDI  R30,LOW(1)
	CP   R30,R13
	BRNE _0x1F1
	LDI  R30,LOW(59)
	MOV  R4,R30
	CALL _ochistka
; 0000 0505             if (BUT_STEP)   {meny=10;}
_0x1F1:
	LDI  R30,LOW(2)
	CP   R30,R13
	BRNE _0x1F2
	LDI  R30,LOW(10)
	MOV  R4,R30
; 0000 0506         break;
_0x1F2:
	RJMP _0x130
; 0000 0507 
; 0000 0508         case 59: //Настройка    анимации
_0x1EF:
	CPI  R30,LOW(0x3B)
	LDI  R26,HIGH(0x3B)
	CPC  R31,R26
	BRNE _0x1F3
; 0000 0509             ekran_cifri(((time-(time/60*60))*60)+sek);
	RCALL SUBOPT_0x59
	RCALL SUBOPT_0x5A
	CALL SUBOPT_0x8B
; 0000 050A             if (BUT_STEP) {str_pause ();  meny=10;}
	BRNE _0x1F4
	CALL SUBOPT_0x75
; 0000 050B             if (BUT_OK)   {if(++animation>3){animation=0;} ochistka();ekran_1_figure(animation,8); delay_ms(1000);ochistka(); }
_0x1F4:
	LDI  R30,LOW(1)
	CP   R30,R13
	BRNE _0x1F5
	LDS  R26,_animation
	SUBI R26,-LOW(1)
	STS  _animation,R26
	CPI  R26,LOW(0x4)
	BRLO _0x1F6
	LDI  R30,LOW(0)
	STS  _animation,R30
_0x1F6:
	CALL _ochistka
	LDS  R30,_animation
	ST   -Y,R30
	LDI  R30,LOW(8)
	CALL SUBOPT_0x85
	CALL _ochistka
; 0000 050C         break;
_0x1F5:
	RJMP _0x130
; 0000 050D 
; 0000 050E         //**************************Установка параметров для бани***************************
; 0000 050F         //На экране  Безумная баня
; 0000 0510         case 70:
_0x1F3:
	CPI  R30,LOW(0x46)
	LDI  R26,HIGH(0x46)
	CPC  R31,R26
	BRNE _0x1F7
; 0000 0511             if (Interval>=speed)  {Interval=0;   beg_stroka(bez_banya_txt);}
	CALL SUBOPT_0x77
	BRLO _0x1F8
	CALL SUBOPT_0x73
	LDI  R30,LOW(_bez_banya_txt*2)
	LDI  R31,HIGH(_bez_banya_txt*2)
	CALL SUBOPT_0x78
; 0000 0512             if (BUT_OK)  {meny=71; z=0; z1=0;  ochistka();}
_0x1F8:
	LDI  R30,LOW(1)
	CP   R30,R13
	BRNE _0x1F9
	LDI  R30,LOW(71)
	CALL SUBOPT_0x79
; 0000 0513             if (BUT_STEP)   {meny=80; z=0; z1=0;   ochistka();}
_0x1F9:
	LDI  R30,LOW(2)
	CP   R30,R13
	BRNE _0x1FA
	LDI  R30,LOW(80)
	CALL SUBOPT_0x79
; 0000 0514         break;
_0x1FA:
	RJMP _0x130
; 0000 0515 
; 0000 0516         //Температура готовности
; 0000 0517         case 71:
_0x1F7:
	CPI  R30,LOW(0x47)
	LDI  R26,HIGH(0x47)
	CPC  R31,R26
	BRNE _0x1FB
; 0000 0518             if (Interval>=speed)  {Interval=0;   beg_stroka(complete_txt);}
	CALL SUBOPT_0x77
	BRLO _0x1FC
	RCALL SUBOPT_0x73
	LDI  R30,LOW(_complete_txt*2)
	LDI  R31,HIGH(_complete_txt*2)
	CALL SUBOPT_0x78
; 0000 0519             if (BUT_OK)  {meny=72;ochistka();}
_0x1FC:
	LDI  R30,LOW(1)
	CP   R30,R13
	BRNE _0x1FD
	LDI  R30,LOW(72)
	MOV  R4,R30
	CALL _ochistka
; 0000 051A             if (BUT_STEP)   {meny=73; z=0; z1=0;   ochistka();}
_0x1FD:
	LDI  R30,LOW(2)
	CP   R30,R13
	BRNE _0x1FE
	LDI  R30,LOW(73)
	CALL SUBOPT_0x79
; 0000 051B         break;
_0x1FE:
	RJMP _0x130
; 0000 051C         case 72:
_0x1FB:
	CPI  R30,LOW(0x48)
	LDI  R26,HIGH(0x48)
	CPC  R31,R26
	BRNE _0x1FF
; 0000 051D 
; 0000 051E             ekran_1_figure((tempComplete/100),0);
	RCALL SUBOPT_0x4D
	CALL SUBOPT_0x8C
; 0000 051F             ekran_1_figure((tempComplete%100)/10,6);
	RCALL SUBOPT_0x4D
	RCALL SUBOPT_0x67
	RCALL SUBOPT_0x39
; 0000 0520             ekran_1_figure(48,13);
	LDI  R30,LOW(48)
	RCALL SUBOPT_0x34
; 0000 0521             ekran_1_figure(49,19);
	LDI  R30,LOW(49)
	RCALL SUBOPT_0x35
; 0000 0522             if (BUT_OK)  {tempComplete+=10; if(tempComplete>990){tempComplete=20;}}
	LDI  R30,LOW(1)
	CP   R30,R13
	BRNE _0x200
	LDS  R30,_tempComplete
	LDS  R31,_tempComplete+1
	ADIW R30,10
	STS  _tempComplete,R30
	STS  _tempComplete+1,R31
	RCALL SUBOPT_0x4D
	CPI  R26,LOW(0x3DF)
	LDI  R30,HIGH(0x3DF)
	CPC  R27,R30
	BRLT _0x201
	LDI  R30,LOW(20)
	LDI  R31,HIGH(20)
	STS  _tempComplete,R30
	STS  _tempComplete+1,R31
_0x201:
; 0000 0523             if (BUT_STEP)   {meny=71;  z=0; z1=0;ochistka();}
_0x200:
	LDI  R30,LOW(2)
	CP   R30,R13
	BRNE _0x202
	LDI  R30,LOW(71)
	RCALL SUBOPT_0x79
; 0000 0524         break;
_0x202:
	RJMP _0x130
; 0000 0525         //Минимальная температура
; 0000 0526         case 73:
_0x1FF:
	CPI  R30,LOW(0x49)
	LDI  R26,HIGH(0x49)
	CPC  R31,R26
	BRNE _0x203
; 0000 0527             if (Interval>=speed)  {Interval=0;   beg_stroka(turning_txt);}
	RCALL SUBOPT_0x77
	BRLO _0x204
	RCALL SUBOPT_0x73
	LDI  R30,LOW(_turning_txt*2)
	LDI  R31,HIGH(_turning_txt*2)
	RCALL SUBOPT_0x78
; 0000 0528             if (BUT_OK)  {meny=74;ochistka();}
_0x204:
	LDI  R30,LOW(1)
	CP   R30,R13
	BRNE _0x205
	LDI  R30,LOW(74)
	MOV  R4,R30
	CALL _ochistka
; 0000 0529             if (BUT_STEP)   {meny=75; z=0; z1=0;   ochistka();}
_0x205:
	LDI  R30,LOW(2)
	CP   R30,R13
	BRNE _0x206
	LDI  R30,LOW(75)
	RCALL SUBOPT_0x79
; 0000 052A         break;
_0x206:
	RJMP _0x130
; 0000 052B 
; 0000 052C         case 74:
_0x203:
	CPI  R30,LOW(0x4A)
	LDI  R26,HIGH(0x4A)
	CPC  R31,R26
	BRNE _0x207
; 0000 052D             ekran_1_figure((tempMin/100),0);
	CALL SUBOPT_0x8D
	CALL SUBOPT_0x8C
; 0000 052E             ekran_1_figure((tempMin%100)/10,6);
	CALL SUBOPT_0x8D
	RCALL SUBOPT_0x67
	RCALL SUBOPT_0x39
; 0000 052F             ekran_1_figure(48,13);
	LDI  R30,LOW(48)
	RCALL SUBOPT_0x34
; 0000 0530             ekran_1_figure(49,19);
	LDI  R30,LOW(49)
	RCALL SUBOPT_0x35
; 0000 0531             if (BUT_OK)  {tempMin+=10;if(tempMin>=tempComplete){tempMin=10;}}
	LDI  R30,LOW(1)
	CP   R30,R13
	BRNE _0x208
	RCALL SUBOPT_0x4C
	ADIW R30,10
	STS  _tempMin,R30
	STS  _tempMin+1,R31
	LDS  R30,_tempComplete
	LDS  R31,_tempComplete+1
	CALL SUBOPT_0x8D
	CP   R26,R30
	CPC  R27,R31
	BRLT _0x209
	LDI  R30,LOW(10)
	LDI  R31,HIGH(10)
	STS  _tempMin,R30
	STS  _tempMin+1,R31
_0x209:
; 0000 0532             if (BUT_STEP)   {meny=73;  z=0; z1=0;ochistka();}
_0x208:
	LDI  R30,LOW(2)
	CP   R30,R13
	BRNE _0x20A
	LDI  R30,LOW(73)
	RCALL SUBOPT_0x79
; 0000 0533         break;
_0x20A:
	RJMP _0x130
; 0000 0534 
; 0000 0535         //+ минуты для прогрева
; 0000 0536         case 75:
_0x207:
	CPI  R30,LOW(0x4B)
	LDI  R26,HIGH(0x4B)
	CPC  R31,R26
	BRNE _0x20B
; 0000 0537             if (Interval>=speed)  {Interval=0;   beg_stroka(delay_time_txt);}
	RCALL SUBOPT_0x77
	BRLO _0x20C
	RCALL SUBOPT_0x73
	LDI  R30,LOW(_delay_time_txt*2)
	LDI  R31,HIGH(_delay_time_txt*2)
	RCALL SUBOPT_0x78
; 0000 0538             if (BUT_OK)  {meny=76;ochistka();}
_0x20C:
	LDI  R30,LOW(1)
	CP   R30,R13
	BRNE _0x20D
	LDI  R30,LOW(76)
	MOV  R4,R30
	CALL _ochistka
; 0000 0539             if (BUT_STEP)   {meny=77; z=0; z1=0;   ochistka();}
_0x20D:
	LDI  R30,LOW(2)
	CP   R30,R13
	BRNE _0x20E
	LDI  R30,LOW(77)
	RCALL SUBOPT_0x79
; 0000 053A         break;
_0x20E:
	RJMP _0x130
; 0000 053B         case 76:
_0x20B:
	CPI  R30,LOW(0x4C)
	LDI  R26,HIGH(0x4C)
	CPC  R31,R26
	BRNE _0x20F
; 0000 053C             ekran_1_figure((delayTime/10),0);
	LDS  R26,_delayTime
	RCALL SUBOPT_0x30
	RCALL SUBOPT_0x38
; 0000 053D             ekran_1_figure((delayTime%10),6);
	LDS  R26,_delayTime
	CLR  R27
	RCALL SUBOPT_0x20
	RCALL SUBOPT_0x39
; 0000 053E             ekran_1_figure(22,13);
	LDI  R30,LOW(22)
	RCALL SUBOPT_0x34
; 0000 053F             ekran_1_figure(43,19);
	LDI  R30,LOW(43)
	RCALL SUBOPT_0x35
; 0000 0540             if (BUT_OK)  { if(++delayTime>59){delayTime=0;} }
	LDI  R30,LOW(1)
	CP   R30,R13
	BRNE _0x210
	LDS  R26,_delayTime
	SUBI R26,-LOW(1)
	STS  _delayTime,R26
	CPI  R26,LOW(0x3C)
	BRLO _0x211
	LDI  R30,LOW(0)
	STS  _delayTime,R30
_0x211:
; 0000 0541             if (BUT_STEP)   {meny=75;  z=0; z1=0; ochistka();}
_0x210:
	LDI  R30,LOW(2)
	CP   R30,R13
	BRNE _0x212
	LDI  R30,LOW(75)
	RCALL SUBOPT_0x79
; 0000 0542         break;
_0x212:
	RJMP _0x130
; 0000 0543 
; 0000 0544         //Звуковые уведомления безумной бани
; 0000 0545         case 77:
_0x20F:
	CPI  R30,LOW(0x4D)
	LDI  R26,HIGH(0x4D)
	CPC  R31,R26
	BRNE _0x213
; 0000 0546             ekran_1_figure(45,0);
	LDI  R30,LOW(45)
	RCALL SUBOPT_0x38
; 0000 0547             ekran_1_figure(57,8);
	LDI  R30,LOW(57)
	ST   -Y,R30
	LDI  R30,LOW(8)
	ST   -Y,R30
	CALL _ekran_1_figure
; 0000 0548             ekran_1_figure(((noticeBanya==0)?46:47),14);
	LDI  R26,0
	SBRC R3,7
	LDI  R26,1
	CPI  R26,LOW(0x0)
	BRNE _0x214
	LDI  R30,LOW(46)
	RJMP _0x215
_0x214:
	LDI  R30,LOW(47)
_0x215:
	RCALL SUBOPT_0x89
; 0000 0549             if (BUT_OK)  {noticeBanya=abs(noticeBanya-1); ochistka();}
	LDI  R30,LOW(1)
	CP   R30,R13
	BRNE _0x217
	LDI  R30,0
	SBRC R3,7
	LDI  R30,1
	LDI  R31,0
	SBIW R30,1
	RCALL SUBOPT_0x6C
	CALL __BSTB1
	BLD  R3,7
	CALL _ochistka
; 0000 054A             if (BUT_STEP)   {meny=70; z=0; z1=0; if(noticeBanya==1){banya_is_complete=0;} ochistka();}
_0x217:
	LDI  R30,LOW(2)
	CP   R30,R13
	BRNE _0x218
	LDI  R30,LOW(70)
	MOV  R4,R30
	RCALL SUBOPT_0x84
	SBRS R3,7
	RJMP _0x219
	CLT
	BLD  R3,4
_0x219:
	CALL _ochistka
; 0000 054B         break;
_0x218:
	RJMP _0x130
; 0000 054C 
; 0000 054D 
; 0000 054E 
; 0000 054F 
; 0000 0550         //**************************Настройка коррекции хода*******************************
; 0000 0551         case 80: // на экране текст - "Коррекция"
_0x213:
	CPI  R30,LOW(0x50)
	LDI  R26,HIGH(0x50)
	CPC  R31,R26
	BRNE _0x21A
; 0000 0552             if (Interval>=speed)  {Interval=0;   beg_stroka(korekt_txt);}
	RCALL SUBOPT_0x77
	BRLO _0x21B
	RCALL SUBOPT_0x73
	LDI  R30,LOW(_korekt_txt*2)
	LDI  R31,HIGH(_korekt_txt*2)
	RCALL SUBOPT_0x78
; 0000 0553             if (BUT_STEP) {str_pause ();  meny=90; z=0; z1=0; ochistka();}
_0x21B:
	LDI  R30,LOW(2)
	CP   R30,R13
	BRNE _0x21C
	CALL _str_pause
	LDI  R30,LOW(90)
	RCALL SUBOPT_0x79
; 0000 0554             if (BUT_OK)   {meny=81; ochistka();}
_0x21C:
	LDI  R30,LOW(1)
	CP   R30,R13
	BRNE _0x21D
	LDI  R30,LOW(81)
	MOV  R4,R30
	CALL _ochistka
; 0000 0555         break;
_0x21D:
	RJMP _0x130
; 0000 0556         case 81: // отображаем секунды.  по нажатию кнопки "ОК" - обнуляем секунды
_0x21A:
	CPI  R30,LOW(0x51)
	LDI  R26,HIGH(0x51)
	CPC  R31,R26
	BRNE _0x21E
; 0000 0557         mig=1;
	SET
	BLD  R2,0
; 0000 0558         ekran_cifri(((time-(time/60*60))*60)+sek);
	RCALL SUBOPT_0x59
	RCALL SUBOPT_0x5A
	RCALL SUBOPT_0x8B
; 0000 0559         if (BUT_STEP) {meny=82; ochistka();}
	BRNE _0x21F
	LDI  R30,LOW(82)
	MOV  R4,R30
	CALL _ochistka
; 0000 055A         if (BUT_OK)   {if (sek>40) {time++; if (time==1440) time=0;}  sek=0; TCNT2=0;}
_0x21F:
	LDI  R30,LOW(1)
	CP   R30,R13
	BRNE _0x220
	LDI  R30,LOW(40)
	CP   R30,R7
	BRSH _0x221
	LDI  R26,LOW(_time)
	LDI  R27,HIGH(_time)
	RCALL SUBOPT_0x9
	RCALL SUBOPT_0xF
	CPI  R26,LOW(0x5A0)
	LDI  R30,HIGH(0x5A0)
	CPC  R27,R30
	BRNE _0x222
	LDI  R30,LOW(0)
	STS  _time,R30
	STS  _time+1,R30
_0x222:
_0x221:
	CLR  R7
	LDI  R30,LOW(0)
	OUT  0x24,R30
; 0000 055B         break;
_0x220:
	RJMP _0x130
; 0000 055C         case 82: // Установка секунд коррекции
_0x21E:
	CPI  R30,LOW(0x52)
	LDI  R26,HIGH(0x52)
	CPC  R31,R26
	BRNE _0x223
; 0000 055D             if (BUT_STEP) {meny=83;}
	LDI  R30,LOW(2)
	CP   R30,R13
	BRNE _0x224
	LDI  R30,LOW(83)
	MOV  R4,R30
; 0000 055E             if (BUT_OK)   {korr_den=((korr_den<0)?(korr_den-=10):(korr_den+=10));if(abs(korr_den)>599){korr_den=korr_den%10;}}
_0x224:
	LDI  R30,LOW(1)
	CP   R30,R13
	BRNE _0x225
	RCALL SUBOPT_0x3
	BRPL _0x226
	RCALL SUBOPT_0x8E
	SBIW R30,10
	RJMP _0x29B
_0x226:
	RCALL SUBOPT_0x8E
	ADIW R30,10
_0x29B:
	LDI  R26,LOW(_korr_den)
	LDI  R27,HIGH(_korr_den)
	CALL __EEPROMWRW
	RCALL SUBOPT_0x8F
	RCALL SUBOPT_0x8E
	RCALL SUBOPT_0x6C
	CPI  R30,LOW(0x258)
	LDI  R26,HIGH(0x258)
	CPC  R31,R26
	BRLT _0x229
	RCALL SUBOPT_0x4
	RCALL SUBOPT_0x20
	RCALL SUBOPT_0x8F
_0x229:
; 0000 055F             ekran_1_figure(((korr_den<0)?46:47),0);
_0x225:
	RCALL SUBOPT_0x3
	BRPL _0x22A
	LDI  R30,LOW(46)
	RJMP _0x22B
_0x22A:
	LDI  R30,LOW(47)
_0x22B:
	RCALL SUBOPT_0x38
; 0000 0560             line=1; ekran_1_figure((abs((korr_den))/100),6); ekran_1_figure(((abs(korr_den)%100)/10),12);
	SET
	BLD  R2,7
	RCALL SUBOPT_0x8E
	RCALL SUBOPT_0x6C
	RCALL SUBOPT_0x6D
	RCALL SUBOPT_0x39
	RCALL SUBOPT_0x8E
	RCALL SUBOPT_0x6C
	MOVW R26,R30
	RCALL SUBOPT_0x67
	RCALL SUBOPT_0x90
; 0000 0561             line=0; ekran_1_figure((abs(korr_den)%10),19);
	CLT
	BLD  R2,7
	RCALL SUBOPT_0x8E
	RCALL SUBOPT_0x6C
	MOVW R26,R30
	RCALL SUBOPT_0x20
	RCALL SUBOPT_0x35
; 0000 0562         break;
	RJMP _0x130
; 0000 0563         case 83: // Установка десятых долей секунд коррекции
_0x223:
	CPI  R30,LOW(0x53)
	LDI  R26,HIGH(0x53)
	CPC  R31,R26
	BRNE _0x22D
; 0000 0564             if (BUT_STEP) { meny=84;}
	LDI  R30,LOW(2)
	CP   R30,R13
	BRNE _0x22E
	LDI  R30,LOW(84)
	MOV  R4,R30
; 0000 0565             if (BUT_OK)   {if(korr_den<0){korr_den--;if(korr_den%10==0)korr_den+=10;}else{korr_den++;if(korr_den%10==0)korr_den-=10;}}
_0x22E:
	LDI  R30,LOW(1)
	CP   R30,R13
	BRNE _0x22F
	RCALL SUBOPT_0x3
	BRPL _0x230
	RCALL SUBOPT_0x8E
	SBIW R30,1
	CALL __EEPROMWRW
	ADIW R30,1
	RCALL SUBOPT_0x4
	RCALL SUBOPT_0x20
	SBIW R30,0
	BRNE _0x231
	RCALL SUBOPT_0x8E
	ADIW R30,10
	RCALL SUBOPT_0x8F
_0x231:
	RJMP _0x232
_0x230:
	RCALL SUBOPT_0x8E
	ADIW R30,1
	CALL __EEPROMWRW
	SBIW R30,1
	RCALL SUBOPT_0x4
	RCALL SUBOPT_0x20
	SBIW R30,0
	BRNE _0x233
	RCALL SUBOPT_0x8E
	SBIW R30,10
	RCALL SUBOPT_0x8F
_0x233:
_0x232:
; 0000 0566             ekran_1_figure(((korr_den<0)?46:47),0);  ekran_1_figure((abs((korr_den))/100),6); ekran_1_figure(((abs(korr_den)%100)/10),12);
_0x22F:
	RCALL SUBOPT_0x3
	BRPL _0x234
	LDI  R30,LOW(46)
	RJMP _0x235
_0x234:
	LDI  R30,LOW(47)
_0x235:
	RCALL SUBOPT_0x38
	RCALL SUBOPT_0x8E
	RCALL SUBOPT_0x6C
	RCALL SUBOPT_0x6D
	RCALL SUBOPT_0x39
	RCALL SUBOPT_0x8E
	RCALL SUBOPT_0x6C
	MOVW R26,R30
	RCALL SUBOPT_0x67
	RCALL SUBOPT_0x90
; 0000 0567             line=1; ekran_1_figure((abs(korr_den)%10),19);  line=0;
	SET
	BLD  R2,7
	RCALL SUBOPT_0x8E
	RCALL SUBOPT_0x6C
	MOVW R26,R30
	RCALL SUBOPT_0x20
	RCALL SUBOPT_0x35
	CLT
	BLD  R2,7
; 0000 0568         break;
	RJMP _0x130
; 0000 0569         case 84: // Установка "знака" коррекции
_0x22D:
	CPI  R30,LOW(0x54)
	LDI  R26,HIGH(0x54)
	CPC  R31,R26
	BRNE _0x237
; 0000 056A             if (BUT_STEP) {str_pause (); meny=10;}
	LDI  R30,LOW(2)
	CP   R30,R13
	BRNE _0x238
	RCALL SUBOPT_0x75
; 0000 056B             if (BUT_OK)   {korr_den = (korr_den * (-1));}
_0x238:
	LDI  R30,LOW(1)
	CP   R30,R13
	BRNE _0x239
	RCALL SUBOPT_0x8E
	LDI  R26,LOW(65535)
	LDI  R27,HIGH(65535)
	CALL __MULW12
	RCALL SUBOPT_0x8F
; 0000 056C             line=1; ekran_1_figure(((korr_den<0)?46:47),0);
_0x239:
	SET
	BLD  R2,7
	RCALL SUBOPT_0x3
	BRPL _0x23A
	LDI  R30,LOW(46)
	RJMP _0x23B
_0x23A:
	LDI  R30,LOW(47)
_0x23B:
	RCALL SUBOPT_0x38
; 0000 056D             line=0; ekran_1_figure((abs((korr_den))/100),6); ekran_1_figure(((abs(korr_den)%100)/10),12); ekran_1_figure((abs(korr_den)%10),19);
	CLT
	BLD  R2,7
	RCALL SUBOPT_0x8E
	RCALL SUBOPT_0x6C
	RCALL SUBOPT_0x6D
	RCALL SUBOPT_0x39
	RCALL SUBOPT_0x8E
	RCALL SUBOPT_0x6C
	MOVW R26,R30
	RCALL SUBOPT_0x67
	RCALL SUBOPT_0x90
	RCALL SUBOPT_0x8E
	RCALL SUBOPT_0x6C
	MOVW R26,R30
	RCALL SUBOPT_0x20
	RCALL SUBOPT_0x35
; 0000 056E         break;
	RJMP _0x130
; 0000 056F 
; 0000 0570 
; 0000 0571 
; 0000 0572 
; 0000 0573 
; 0000 0574 
; 0000 0575 
; 0000 0576 
; 0000 0577         //*************************Подбор датчика*****************************
; 0000 0578         case 90:
_0x237:
	CPI  R30,LOW(0x5A)
	LDI  R26,HIGH(0x5A)
	CPC  R31,R26
	BRNE _0x23D
; 0000 0579             if (Interval>=speed)  {Interval=0;   beg_stroka(sensors_txt);}
	RCALL SUBOPT_0x77
	BRLO _0x23E
	RCALL SUBOPT_0x73
	LDI  R30,LOW(_sensors_txt*2)
	LDI  R31,HIGH(_sensors_txt*2)
	RCALL SUBOPT_0x78
; 0000 057A             if (BUT_STEP) {str_pause ();  meny=10; ochistka();}
_0x23E:
	LDI  R30,LOW(2)
	CP   R30,R13
	BRNE _0x23F
	RCALL SUBOPT_0x75
	CALL _ochistka
; 0000 057B             if (BUT_OK)   {meny=91; z=0; z1=0;  j=0; ochistka();}
_0x23F:
	LDI  R30,LOW(1)
	CP   R30,R13
	BRNE _0x240
	LDI  R30,LOW(91)
	MOV  R4,R30
	RCALL SUBOPT_0x84
	LDI  R19,LOW(0)
	CALL _ochistka
; 0000 057C         break;
_0x240:
	RJMP _0x130
; 0000 057D 
; 0000 057E         //Выбор участка
; 0000 057F         case 91:
_0x23D:
	CPI  R30,LOW(0x5B)
	LDI  R26,HIGH(0x5B)
	CPC  R31,R26
	BREQ PC+3
	JMP _0x241
; 0000 0580                 t=0;
	LDI  R30,LOW(0)
	STS  _t,R30
; 0000 0581                 temp1=t;
	RCALL SUBOPT_0x5D
; 0000 0582                 if(j==0){
	CPI  R19,0
	BRNE _0x242
; 0000 0583                     while (banya_txt[(t-temp1)] != 255)
_0x243:
	RCALL SUBOPT_0x5E
	SUBI R30,LOW(-_banya_txt*2)
	SBCI R31,HIGH(-_banya_txt*2)
	LPM  R26,Z
	CPI  R26,LOW(0xFF)
	BREQ _0x245
; 0000 0584                     {
; 0000 0585                              beg_info[t]=banya_txt[t++-temp1];
	RCALL SUBOPT_0x5F
	SUBI R30,LOW(-_banya_txt*2)
	SBCI R31,HIGH(-_banya_txt*2)
	LPM  R30,Z
	MOVW R26,R22
	ST   X,R30
; 0000 0586                     }
	RJMP _0x243
_0x245:
; 0000 0587                 }
; 0000 0588                 else if(j==1){
	RJMP _0x246
_0x242:
	CPI  R19,1
	BRNE _0x247
; 0000 0589                     while (outside_txt[(t-temp1)] != 255)
_0x248:
	RCALL SUBOPT_0x5E
	SUBI R30,LOW(-_outside_txt*2)
	SBCI R31,HIGH(-_outside_txt*2)
	LPM  R26,Z
	CPI  R26,LOW(0xFF)
	BREQ _0x24A
; 0000 058A                     {
; 0000 058B                              beg_info[t]=outside_txt[t++-temp1];
	RCALL SUBOPT_0x5F
	SUBI R30,LOW(-_outside_txt*2)
	SBCI R31,HIGH(-_outside_txt*2)
	LPM  R30,Z
	MOVW R26,R22
	ST   X,R30
; 0000 058C                     }
	RJMP _0x248
_0x24A:
; 0000 058D                 }
; 0000 058E                 else if(j==2){
	RJMP _0x24B
_0x247:
	CPI  R19,2
	BRNE _0x24C
; 0000 058F                     while (water_txt[(t-temp1)] != 255)
_0x24D:
	RCALL SUBOPT_0x5E
	SUBI R30,LOW(-_water_txt*2)
	SBCI R31,HIGH(-_water_txt*2)
	LPM  R26,Z
	CPI  R26,LOW(0xFF)
	BREQ _0x24F
; 0000 0590                     {
; 0000 0591                              beg_info[t]=water_txt[t++-temp1];
	RCALL SUBOPT_0x5F
	SUBI R30,LOW(-_water_txt*2)
	SBCI R31,HIGH(-_water_txt*2)
	LPM  R30,Z
	MOVW R26,R22
	ST   X,R30
; 0000 0592                     }
	RJMP _0x24D
_0x24F:
; 0000 0593                 }
; 0000 0594                 else if(j==3 || j==4){
	RJMP _0x250
_0x24C:
	CPI  R19,3
	BREQ _0x252
	CPI  R19,4
	BRNE _0x251
_0x252:
; 0000 0595                     while (underground_txt[(t-temp1)] != 255)
_0x254:
	RCALL SUBOPT_0x5E
	SUBI R30,LOW(-_underground_txt*2)
	SBCI R31,HIGH(-_underground_txt*2)
	LPM  R26,Z
	CPI  R26,LOW(0xFF)
	BREQ _0x256
; 0000 0596                     {
; 0000 0597                              beg_info[t]=underground_txt[t++-temp1];
	RCALL SUBOPT_0x5F
	SUBI R30,LOW(-_underground_txt*2)
	SBCI R31,HIGH(-_underground_txt*2)
	LPM  R30,Z
	MOVW R26,R22
	ST   X,R30
; 0000 0598                     }
	RJMP _0x254
_0x256:
; 0000 0599                      beg_info[t++]=44;
	RCALL SUBOPT_0x60
	LDI  R26,LOW(44)
	STD  Z+0,R26
; 0000 059A                      beg_info[t++]=52;
	RCALL SUBOPT_0x60
	LDI  R26,LOW(52)
	STD  Z+0,R26
; 0000 059B 
; 0000 059C                             if(j==3){
	CPI  R19,3
	BRNE _0x257
; 0000 059D                                 beg_info[t++]=1;
	RCALL SUBOPT_0x60
	LDI  R26,LOW(1)
	RJMP _0x29C
; 0000 059E                             }
; 0000 059F                             else{
_0x257:
; 0000 05A0                                 beg_info[t++]=2;
	RCALL SUBOPT_0x60
	LDI  R26,LOW(2)
_0x29C:
	STD  Z+0,R26
; 0000 05A1                             }
; 0000 05A2                             beg_info[t++]=42;
	RCALL SUBOPT_0x60
	LDI  R26,LOW(42)
	STD  Z+0,R26
; 0000 05A3                 }
; 0000 05A4                 else if(j==5){
	RJMP _0x259
_0x251:
	CPI  R19,5
	BRNE _0x25A
; 0000 05A5                     while (home_txt[(t-temp1)] != 255)
_0x25B:
	RCALL SUBOPT_0x5E
	SUBI R30,LOW(-_home_txt*2)
	SBCI R31,HIGH(-_home_txt*2)
	LPM  R26,Z
	CPI  R26,LOW(0xFF)
	BREQ _0x25D
; 0000 05A6                     {
; 0000 05A7                              beg_info[t]=home_txt[t++-temp1];
	RCALL SUBOPT_0x5F
	SUBI R30,LOW(-_home_txt*2)
	SBCI R31,HIGH(-_home_txt*2)
	LPM  R30,Z
	MOVW R26,R22
	ST   X,R30
; 0000 05A8                     }
	RJMP _0x25B
_0x25D:
; 0000 05A9                 }
; 0000 05AA                 beg_info[t]=255;
_0x25A:
_0x259:
_0x250:
_0x24B:
_0x246:
	RCALL SUBOPT_0x72
; 0000 05AB 
; 0000 05AC             if (Interval>=speed)  {Interval=0;   beg_stroka_not(beg_info);}
	BRLO _0x25E
	RCALL SUBOPT_0x73
	RCALL SUBOPT_0x74
; 0000 05AD             if (BUT_OK) {meny=92; ochistka();}
_0x25E:
	LDI  R30,LOW(1)
	CP   R30,R13
	BRNE _0x25F
	LDI  R30,LOW(92)
	MOV  R4,R30
	CALL _ochistka
; 0000 05AE             if (BUT_STEP)   { if(++j>5){j=0; meny=90;}  z=0; z1=0;ochistka();}
_0x25F:
	LDI  R30,LOW(2)
	CP   R30,R13
	BRNE _0x260
	SUBI R19,-LOW(1)
	CPI  R19,6
	BRLO _0x261
	LDI  R19,LOW(0)
	LDI  R30,LOW(90)
	MOV  R4,R30
_0x261:
	RCALL SUBOPT_0x84
	CALL _ochistka
; 0000 05AF         break;
_0x260:
	RJMP _0x130
; 0000 05B0         //Выбор датчика
; 0000 05B1         case 92:
_0x241:
	CPI  R30,LOW(0x5C)
	LDI  R26,HIGH(0x5C)
	CPC  R31,R26
	BRNE _0x130
; 0000 05B2             ekran_1_figure(14,0);
	LDI  R30,LOW(14)
	RCALL SUBOPT_0x38
; 0000 05B3             ekran_1_figure(43,6);
	LDI  R30,LOW(43)
	RCALL SUBOPT_0x39
; 0000 05B4             ekran_1_figure(44,8);
	LDI  R30,LOW(44)
	ST   -Y,R30
	LDI  R30,LOW(8)
	ST   -Y,R30
	CALL _ekran_1_figure
; 0000 05B5             ekran_1_figure(52,14);
	LDI  R30,LOW(52)
	RCALL SUBOPT_0x89
; 0000 05B6             ekran_1_figure(ds_ar[j],19);
	RCALL SUBOPT_0x2
	SUBI R30,LOW(-_ds_ar)
	SBCI R31,HIGH(-_ds_ar)
	LD   R30,Z
	RCALL SUBOPT_0x35
; 0000 05B7             if (BUT_OK) { if(++ds_ar[j]>8){ds_ar[j]=0;}    ochistka(); }
	LDI  R30,LOW(1)
	CP   R30,R13
	BRNE _0x263
	MOV  R26,R19
	LDI  R27,0
	SUBI R26,LOW(-_ds_ar)
	SBCI R27,HIGH(-_ds_ar)
	LD   R30,X
	SUBI R30,-LOW(1)
	ST   X,R30
	CPI  R30,LOW(0x9)
	BRLO _0x264
	RCALL SUBOPT_0x2
	SUBI R30,LOW(-_ds_ar)
	SBCI R31,HIGH(-_ds_ar)
	LDI  R26,LOW(0)
	STD  Z+0,R26
_0x264:
	CALL _ochistka
; 0000 05B8             if (BUT_STEP)   {  meny=91; z=0; z1=0; ochistka();}
_0x263:
	LDI  R30,LOW(2)
	CP   R30,R13
	BRNE _0x265
	LDI  R30,LOW(91)
	MOV  R4,R30
	RCALL SUBOPT_0x84
_0x29A:
	CALL _ochistka
; 0000 05B9         break;
_0x265:
; 0000 05BA         }
_0x130:
; 0000 05BB 
; 0000 05BC     //отсчет времени для включения освещения
; 0000 05BD 	if(timerLight>0 && time<sunriseToday && time>sunsetToday && historyTemp[4]>tempMin )       //закат восход + температура бани превышающая минимум
	LDS  R26,_timerLight
	CPI  R26,LOW(0x1)
	BRLO _0x267
	LDS  R30,_sunriseToday
	LDS  R31,_sunriseToday+1
	RCALL SUBOPT_0x18
	BRGE _0x267
	LDS  R30,_sunsetToday
	LDS  R31,_sunsetToday+1
	RCALL SUBOPT_0x55
	BRGE _0x267
	__GETW2MN _historyTemp,8
	RCALL SUBOPT_0x4C
	CP   R30,R26
	CPC  R31,R27
	BRLT _0x268
_0x267:
	RJMP _0x266
_0x268:
; 0000 05BE 		PORTC.2=1;
	SBI  0x15,2
; 0000 05BF 	else{
	RJMP _0x26B
_0x266:
; 0000 05C0 		endSwitch=0;
	CLT
	BLD  R3,6
; 0000 05C1 		PORTC.2=0;
	CBI  0x15,2
; 0000 05C2 	}
_0x26B:
; 0000 05C3 
; 0000 05C4 
; 0000 05C5 //****************************************************Сюда заходим каждую минуту*******************************************
; 0000 05C6 if (flg_min){
	SBRS R2,1
	RJMP _0x26E
; 0000 05C7     sunrise_update();
	CALL _sunrise_update
; 0000 05C8     flg_min=0;
	CLT
	BLD  R2,1
; 0000 05C9         //_____________________включение будильников
; 0000 05CA         for (bud_temp=0; bud_temp<9; bud_temp++)
	CLR  R10
_0x270:
	LDI  R30,LOW(9)
	CP   R10,R30
	BRSH _0x271
; 0000 05CB         {
; 0000 05CC                 if  (
; 0000 05CD                     ( time==budilnik_time[bud_temp] )                                 //  если наступило время срабатывания будильника
; 0000 05CE                 &&  ( budilnik_Install[bud_temp] & 0x80)                              //  И этот будильник включен (должен срабатывать)
; 0000 05CF                 &&  ( budilnik_Install[bud_temp] & (1 << den_nedeli) )                //  И должен сработать в текущий день недели
; 0000 05D0                 )
	MOV  R30,R10
	RCALL SUBOPT_0x7E
	RCALL SUBOPT_0x55
	BRNE _0x273
	MOV  R30,R10
	RCALL SUBOPT_0x52
	LD   R30,Z
	ANDI R30,LOW(0x80)
	BREQ _0x273
	MOV  R30,R10
	RCALL SUBOPT_0x52
	LD   R1,Z
	MOV  R30,R11
	RCALL SUBOPT_0x8
	BRNE _0x274
_0x273:
	RJMP _0x272
_0x274:
; 0000 05D1                 bud_flg=1;                                                            //  то включить сигнал
	SET
	BLD  R2,2
; 0000 05D2 
; 0000 05D3         //______________________ВЫключение будильников
; 0000 05D4                 if ( time==budilnik_time[bud_temp] +  budilnik_Interval[bud_temp])    //  если будильник "отзвенел" установленное время(от 1 до 15 мин)
_0x272:
	MOV  R30,R10
	RCALL SUBOPT_0x7E
	MOVW R26,R30
	MOV  R30,R10
	LDI  R31,0
	SUBI R30,LOW(-_budilnik_Interval)
	SBCI R31,HIGH(-_budilnik_Interval)
	LD   R30,Z
	RCALL SUBOPT_0x32
	RCALL SUBOPT_0x55
	BRNE _0x275
; 0000 05D5                 {
; 0000 05D6                 bud_flg=0;                                                            //  то выключить сигнал
	CLT
	BLD  R2,2
; 0000 05D7                 if (bud_temp<3)  {budilnik_Install[bud_temp] = 0;}                    //  и если будильник "одноразовый" (№ 1-3), то выключаем его повторную сработку
	LDI  R30,LOW(3)
	CP   R10,R30
	BRSH _0x276
	MOV  R30,R10
	RCALL SUBOPT_0x52
	LDI  R26,LOW(0)
	STD  Z+0,R26
; 0000 05D8                 }
_0x276:
; 0000 05D9         }
_0x275:
	INC  R10
	RJMP _0x270
_0x271:
; 0000 05DA         //______________________ежечасный сигнал
; 0000 05DB         if ( (time%60==0)&&(time > 500)&&(zv_chs) ) {  but_flg=1; tone=5;   TIMSK|=0x10;    but_pause=0;  }    //  Писк каждый час (с 00-00 до 08-00 сигнал не срабатывает)
	RCALL SUBOPT_0xF
	LDI  R30,LOW(60)
	LDI  R31,HIGH(60)
	CALL __MODW21
	SBIW R30,0
	BRNE _0x278
	RCALL SUBOPT_0x91
	BRLT _0x278
	SBRC R2,5
	RJMP _0x279
_0x278:
	RJMP _0x277
_0x279:
	SET
	BLD  R2,3
	LDI  R30,LOW(5)
	RCALL SUBOPT_0x92
	OUT  0x39,R30
	CLR  R12
; 0000 05DC }       ;
_0x277:
_0x26E:
; 0000 05DD // включаем прерывание по совпадению "А" с Т1 (Пищим динамиком. Будильник)
; 0000 05DE if ( ((bud_flg)&&(mig)) ||  (but_flg) )   {
	SBRS R2,2
	RJMP _0x27B
	SBRC R2,0
	RJMP _0x27D
_0x27B:
	SBRS R2,3
	RJMP _0x27A
_0x27D:
; 0000 05DF  tone=3; TIMSK|=0x10;
	LDI  R30,LOW(3)
	RCALL SUBOPT_0x92
	RJMP _0x29D
; 0000 05E0 }
; 0000 05E1 else  {PORTB.5=0; TIMSK&=0xEF;}
_0x27A:
	CBI  0x18,5
	IN   R30,0x39
	ANDI R30,0xEF
_0x29D:
	OUT  0x39,R30
; 0000 05E2 
; 0000 05E3 	//Работа тревоги
; 0000 05E4 	if(timerAlert>0 && mig && time > 500){
	LDS  R26,_timerAlert
	CPI  R26,LOW(0x1)
	BRLO _0x283
	SBRS R2,0
	RJMP _0x283
	RCALL SUBOPT_0x91
	BRGE _0x284
_0x283:
	RJMP _0x282
_0x284:
; 0000 05E5 	 TIMSK|=0x10;
	IN   R30,0x39
	ORI  R30,0x10
	OUT  0x39,R30
; 0000 05E6 	}
; 0000 05E7     //Добавь дрова
; 0000 05E8 	if(timerDrova>0 && mig && time > 500 && noticeBanya){
_0x282:
	LDS  R26,_timerDrova
	CPI  R26,LOW(0x1)
	BRLO _0x286
	SBRS R2,0
	RJMP _0x286
	RCALL SUBOPT_0x91
	BRLT _0x286
	SBRC R3,7
	RJMP _0x287
_0x286:
	RJMP _0x285
_0x287:
; 0000 05E9 	 TIMSK|=0x10;
	IN   R30,0x39
	ORI  R30,0x10
	OUT  0x39,R30
; 0000 05EA 	}
; 0000 05EB     //Баня Готова
; 0000 05EC 	if(completeBeepTime>0 && time > 500 && delayBan==0 && noticeBanya){
_0x285:
	LDS  R26,_completeBeepTime
	CPI  R26,LOW(0x1)
	BRLO _0x289
	RCALL SUBOPT_0x91
	BRLT _0x289
	LDS  R26,_delayBan
	CPI  R26,LOW(0x0)
	BRNE _0x289
	SBRC R3,7
	RJMP _0x28A
_0x289:
	RJMP _0x288
_0x28A:
; 0000 05ED      tone=8;
	LDI  R30,LOW(8)
	RCALL SUBOPT_0x92
; 0000 05EE 	 TIMSK|=0x10;
	OUT  0x39,R30
; 0000 05EF 	}
; 0000 05F0 
; 0000 05F1 //****************************************************************************************************************************
; 0000 05F2 while (POWER == OFF )   // если работаем от батареи, то сидим здесь и не вылазим - усыпляем контроллер
_0x288:
_0x28B:
	SBRC R3,0
	RJMP _0x28D
; 0000 05F3     {
; 0000 05F4     ACSR=0x80;          // выключаю компаратор и внутренний ИОН на время сна (для экономии энергии батарейки)
	LDI  R30,LOW(128)
	OUT  0x8,R30
; 0000 05F5     #asm("sleep")       // спим......
	sleep
; 0000 05F6     ACSR=0x4b;          // включаю компаратор, внутренний ИОН.
	LDI  R30,LOW(75)
	OUT  0x8,R30
; 0000 05F7     }
	RJMP _0x28B
_0x28D:
; 0000 05F8 //****************************************************************************************************************************
; 0000 05F9 };
	JMP  _0x12B
; 0000 05FA }
_0x28E:
	RJMP _0x28E

	.CSEG
_ds18b20_select:
	ST   -Y,R17
	CALL _w1_init
	CPI  R30,0
	BRNE _0x2000003
	LDI  R30,LOW(0)
	RJMP _0x2020002
_0x2000003:
	LDD  R30,Y+1
	LDD  R31,Y+1+1
	SBIW R30,0
	BREQ _0x2000004
	LDI  R30,LOW(85)
	ST   -Y,R30
	CALL _w1_write
	LDI  R17,LOW(0)
_0x2000006:
	LDD  R26,Y+1
	LDD  R27,Y+1+1
	LD   R30,X+
	STD  Y+1,R26
	STD  Y+1+1,R27
	ST   -Y,R30
	CALL _w1_write
	SUBI R17,-LOW(1)
	CPI  R17,8
	BRLO _0x2000006
	RJMP _0x2000008
_0x2000004:
	LDI  R30,LOW(204)
	ST   -Y,R30
	CALL _w1_write
_0x2000008:
	LDI  R30,LOW(1)
	RJMP _0x2020002
_ds18b20_read_spd:
	CALL __SAVELOCR4
	LDD  R30,Y+4
	LDD  R31,Y+4+1
	RCALL SUBOPT_0x93
	CPI  R30,0
	BRNE _0x2000009
	LDI  R30,LOW(0)
	RJMP _0x2020003
_0x2000009:
	LDI  R30,LOW(190)
	ST   -Y,R30
	CALL _w1_write
	LDI  R17,LOW(0)
	__POINTWRM 18,19,___ds18b20_scratch_pad
_0x200000B:
	PUSH R19
	PUSH R18
	__ADDWRN 18,19,1
	CALL _w1_read
	POP  R26
	POP  R27
	ST   X,R30
	SUBI R17,-LOW(1)
	CPI  R17,9
	BRLO _0x200000B
	LDI  R30,LOW(___ds18b20_scratch_pad)
	LDI  R31,HIGH(___ds18b20_scratch_pad)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(9)
	ST   -Y,R30
	CALL _w1_dow_crc8
	CALL __LNEGB1
_0x2020003:
	CALL __LOADLOCR4
	ADIW R28,6
	RET
_ds18b20_convert_temp:
	RCALL SUBOPT_0x94
	__GETB2MN ___ds18b20_scratch_pad,4
	LDI  R27,0
	LDI  R30,LOW(5)
	CALL __ASRW12
	ANDI R30,LOW(0x3)
	MOV  R17,R30
	LDD  R30,Y+1
	LDD  R31,Y+1+1
	RCALL SUBOPT_0x93
	LDI  R26,LOW(0)
	CALL __EQB12
	LDI  R30,LOW(68)
	ST   -Y,R30
	CALL _w1_write
	RJMP _0x2020002
_ds18b20_read_temp:
	RCALL SUBOPT_0x94
	CPI  R30,0
	BRNE _0x200000D
	RCALL SUBOPT_0x95
	RJMP _0x2020002
_0x200000D:
	LDI  R17,LOW(3)
	LDD  R30,Y+1
	LDD  R31,Y+1+1
	RCALL SUBOPT_0x93
	CPI  R30,0
	BRNE _0x200000E
	RCALL SUBOPT_0x95
	RJMP _0x2020002
_0x200000E:
	LDD  R30,Y+1
	LDD  R31,Y+1+1
	ST   -Y,R31
	ST   -Y,R30
	RCALL _ds18b20_read_spd
	CPI  R30,0
	BRNE _0x200000F
	RCALL SUBOPT_0x95
	RJMP _0x2020002
_0x200000F:
	CALL _w1_init
	MOV  R30,R17
	LDI  R26,LOW(_bit_mask_G100*2)
	LDI  R27,HIGH(_bit_mask_G100*2)
	RCALL SUBOPT_0x42
	CALL __GETW1PF
	LDS  R26,___ds18b20_scratch_pad
	LDS  R27,___ds18b20_scratch_pad+1
	AND  R30,R26
	AND  R31,R27
	CALL __CWD1
	CALL __CDF1
	__GETD2N 0x3D800000
	CALL __MULF12
_0x2020002:
	LDD  R17,Y+0
	ADIW R28,3
	RET
_ds18b20_init:
	LDD  R30,Y+3
	LDD  R31,Y+3+1
	RCALL SUBOPT_0x93
	CPI  R30,0
	BRNE _0x2000010
	LDI  R30,LOW(0)
	RJMP _0x2020001
_0x2000010:
	LD   R30,Y
	SWAP R30
	ANDI R30,0xF0
	LSL  R30
	ORI  R30,LOW(0x1F)
	ST   Y,R30
	LDI  R30,LOW(78)
	ST   -Y,R30
	CALL _w1_write
	LDD  R30,Y+1
	ST   -Y,R30
	CALL _w1_write
	LDD  R30,Y+2
	ST   -Y,R30
	CALL _w1_write
	LD   R30,Y
	ST   -Y,R30
	CALL _w1_write
	LDI  R30,LOW(72)
	ST   -Y,R30
	CALL _w1_write
	LDI  R30,LOW(15)
	LDI  R31,HIGH(15)
	ST   -Y,R31
	ST   -Y,R30
	CALL _delay_ms
	CALL _w1_init
_0x2020001:
	ADIW R28,5
	RET

	.DSEG
___ds18b20_scratch_pad:
	.BYTE 0x9
_error_ds18b20:
	.BYTE 0x1
_z:
	.BYTE 0x1
_z1:
	.BYTE 0x1
_bud:
	.BYTE 0x1
_temp:
	.BYTE 0x1
_temp1:
	.BYTE 0x1
_temp2:
	.BYTE 0x1
_t:
	.BYTE 0x1
_flg_korr:
	.BYTE 0x1
_speed:
	.BYTE 0x1
_font_:
	.BYTE 0x1
_delayBan:
	.BYTE 0x1
_delayTime:
	.BYTE 0x1
_str_sec:
	.BYTE 0x1
_ekran:
	.BYTE 0x18
_beg_info:
	.BYTE 0x118
_rom_code:
	.BYTE 0x12
_budilnik_Install:
	.BYTE 0x9
_budilnik_Interval:
	.BYTE 0x9
_lightTime:
	.BYTE 0x1
_completeBeepTime:
	.BYTE 0x1
_timerLight:
	.BYTE 0x1
_alertTime:
	.BYTE 0x1
_timerAlert:
	.BYTE 0x1
_timerDrova:
	.BYTE 0x1
_tone:
	.BYTE 0x1
_timeToComplete:
	.BYTE 0x1
_budilnik_time:
	.BYTE 0x12
_ds_ar:
	.BYTE 0x9
_sensorsReadCount:
	.BYTE 0x1

	.ESEG
_korr_den:
	.DW  0x0
_brigh_up_time:
	.DW  0x168
_brigh_down_time:
	.DW  0x564
_brigh_up:
	.DB  0x9
_str_period:
	.DB  0x3D
_str:
	.DB  0x1B

	.DSEG
_time:
	.BYTE 0x2
_sunriseToday:
	.BYTE 0x2
_sunsetToday:
	.BYTE 0x2
_tempComplete:
	.BYTE 0x2
_temperature:
	.BYTE 0xC
_tempMin:
	.BYTE 0x2
_historyTemp:
	.BYTE 0xA
_averageTemp:
	.BYTE 0x6
_devices:
	.BYTE 0x1
_simvol:
	.BYTE 0x122
_animation:
	.BYTE 0x1
_Interval:
	.BYTE 0x2
_Interval_2:
	.BYTE 0x2
_data1:
	.BYTE 0x2
_str_time:
	.BYTE 0x2
_stroka_S0000004000:
	.BYTE 0x1
_i_S0000004000:
	.BYTE 0x1
_checkButton_S0000004000:
	.BYTE 0x1
_checkEnd1_S0000004000:
	.BYTE 0x1
_pump_pause_S0000004000:
	.BYTE 0x2
_endSwitch1Pause_S0000004000:
	.BYTE 0x2
_Shift_zn_S000000E000:
	.BYTE 0x1
_temp_S0000013000:
	.BYTE 0x1
_temp_S0000014000:
	.BYTE 0x1
_count_S0000014000:
	.BYTE 0x1
_tryCount_S0000014000:
	.BYTE 0x1
_j_S0000014000:
	.BYTE 0x1

	.CSEG
;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x0:
	MOV  R30,R16
	LDI  R31,0
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 18 TIMES, CODE SIZE REDUCTION:31 WORDS
SUBOPT_0x1:
	MOV  R30,R17
	LDI  R31,0
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x2:
	MOV  R30,R19
	LDI  R31,0
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 7 TIMES, CODE SIZE REDUCTION:15 WORDS
SUBOPT_0x3:
	LDI  R26,LOW(_korr_den+1)
	LDI  R27,HIGH(_korr_den+1)
	CALL __EEPROMRDB
	TST  R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 7 TIMES, CODE SIZE REDUCTION:15 WORDS
SUBOPT_0x4:
	LDI  R26,LOW(_korr_den)
	LDI  R27,HIGH(_korr_den)
	CALL __EEPROMRDW
	MOVW R26,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:2 WORDS
SUBOPT_0x5:
	LDI  R30,LOW(10)
	LDI  R31,HIGH(10)
	CALL __MODW21
	LDI  R26,LOW(25)
	MULS R30,R26
	MOVW R30,R0
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:4 WORDS
SUBOPT_0x6:
	LDI  R30,LOW(600)
	LDI  R31,HIGH(600)
	CALL __MODW21
	MOVW R26,R30
	LDI  R30,LOW(10)
	LDI  R31,HIGH(10)
	CALL __DIVW21
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x7:
	LDI  R31,0
	SUBI R30,LOW(-_ekran)
	SBCI R31,HIGH(-_ekran)
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:33 WORDS
SUBOPT_0x8:
	LDI  R26,LOW(1)
	LDI  R27,HIGH(1)
	CALL __LSLW12
	MOV  R26,R1
	LDI  R27,0
	AND  R30,R26
	AND  R31,R27
	SBIW R30,0
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 7 TIMES, CODE SIZE REDUCTION:15 WORDS
SUBOPT_0x9:
	LD   R30,X+
	LD   R31,X+
	ADIW R30,1
	ST   -X,R31
	ST   -X,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0xA:
	LDS  R26,_pump_pause_S0000004000
	LDS  R27,_pump_pause_S0000004000+1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:6 WORDS
SUBOPT_0xB:
	LDI  R30,LOW(0)
	STS  _pump_pause_S0000004000,R30
	STS  _pump_pause_S0000004000+1,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0xC:
	LDS  R26,_endSwitch1Pause_S0000004000
	LDS  R27,_endSwitch1Pause_S0000004000+1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0xD:
	LDI  R30,LOW(0)
	STS  _endSwitch1Pause_S0000004000,R30
	STS  _endSwitch1Pause_S0000004000+1,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:13 WORDS
SUBOPT_0xE:
	LDI  R26,LOW(_str_period)
	LDI  R27,HIGH(_str_period)
	CALL __EEPROMRDB
	LDI  R31,0
	MOVW R26,R30
	LDI  R30,LOW(60)
	LDI  R31,HIGH(60)
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 25 TIMES, CODE SIZE REDUCTION:45 WORDS
SUBOPT_0xF:
	LDS  R26,_time
	LDS  R27,_time+1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x10:
	CLR  R27
	LDI  R30,LOW(60)
	LDI  R31,HIGH(60)
	CALL __MODW21
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x11:
	LDI  R26,LOW(5)
	LDI  R27,HIGH(5)
	CALL __MULW12U
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:8 WORDS
SUBOPT_0x12:
	ST   -Y,R0
	ST   -Y,R1
	ST   -Y,R15
	ST   -Y,R22
	ST   -Y,R23
	ST   -Y,R24
	ST   -Y,R25
	ST   -Y,R26
	ST   -Y,R27
	ST   -Y,R30
	ST   -Y,R31
	IN   R30,SREG
	ST   -Y,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x13:
	LDI  R30,LOW(240)
	ST   -Y,R30
	LDI  R30,LOW(_rom_code)
	LDI  R31,HIGH(_rom_code)
	ST   -Y,R31
	ST   -Y,R30
	CALL _w1_search
	STS  _devices,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:7 WORDS
SUBOPT_0x14:
	LDI  R26,LOW(9)
	MUL  R17,R26
	MOVW R30,R0
	SUBI R30,LOW(-_rom_code)
	SBCI R31,HIGH(-_rom_code)
	ST   -Y,R31
	ST   -Y,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x15:
	LDI  R30,LOW(211)
	ST   -Y,R30
	LDI  R30,LOW(90)
	ST   -Y,R30
	LDI  R30,LOW(2)
	ST   -Y,R30
	RJMP _ds18b20_init

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x16:
	LDI  R26,LOW(_brigh_down_time)
	LDI  R27,HIGH(_brigh_down_time)
	CALL __EEPROMRDW
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x17:
	LDI  R26,LOW(_brigh_up_time)
	LDI  R27,HIGH(_brigh_up_time)
	CALL __EEPROMRDW
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x18:
	RCALL SUBOPT_0xF
	CP   R26,R30
	CPC  R27,R31
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:6 WORDS
SUBOPT_0x19:
	LDI  R26,LOW(_brigh_up)
	LDI  R27,HIGH(_brigh_up)
	CALL __EEPROMRDB
	LDI  R26,LOW(23)
	MULS R30,R26
	MOVW R30,R0
	SUBI R30,-LOW(1)
	OUT  0x3C,R30
	IN   R30,0x39
	ORI  R30,2
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:6 WORDS
SUBOPT_0x1A:
	MOV  R30,R9
	LDI  R31,0
	SBIW R30,1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 17 TIMES, CODE SIZE REDUCTION:61 WORDS
SUBOPT_0x1B:
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:17 WORDS
SUBOPT_0x1C:
	CALL __LSLW2
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETD1P
	MOVW R26,R30
	MOVW R24,R22
	MOV  R30,R6
	LDI  R31,0
	CALL __CWD1
	CALL __CDF1
	CALL __MULF12
	CALL __CFD1
	CLR  R22
	CLR  R23
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x1D:
	LDI  R30,LOW(600)
	LDI  R31,HIGH(600)
	CALL __DIVW21
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 6 TIMES, CODE SIZE REDUCTION:7 WORDS
SUBOPT_0x1E:
	LDI  R30,LOW(60)
	LDI  R31,HIGH(60)
	CALL __DIVW21
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 8 TIMES, CODE SIZE REDUCTION:32 WORDS
SUBOPT_0x1F:
	CALL __MODW21
	MOVW R26,R30
	LDI  R30,LOW(10)
	LDI  R31,HIGH(10)
	CALL __DIVW21
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 14 TIMES, CODE SIZE REDUCTION:23 WORDS
SUBOPT_0x20:
	LDI  R30,LOW(10)
	LDI  R31,HIGH(10)
	CALL __MODW21
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x21:
	LDS  R30,_data1
	LDS  R31,_data1+1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x22:
	STS  _data1,R30
	STS  _data1+1,R31
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 8 TIMES, CODE SIZE REDUCTION:32 WORDS
SUBOPT_0x23:
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	ST   -Y,R31
	ST   -Y,R30
	ST   -Y,R17
	JMP  _timeToSymbol

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:2 WORDS
SUBOPT_0x24:
	RCALL SUBOPT_0x21
	ST   -Y,R31
	ST   -Y,R30
	ST   -Y,R17
	JMP  _timeToSymbol

;OPTIMIZER ADDED SUBROUTINE, CALLED 11 TIMES, CODE SIZE REDUCTION:27 WORDS
SUBOPT_0x25:
	LDS  R0,_temp
	CLR  R1
	RJMP SUBOPT_0x1

;OPTIMIZER ADDED SUBROUTINE, CALLED 11 TIMES, CODE SIZE REDUCTION:97 WORDS
SUBOPT_0x26:
	MOVW R26,R28
	ADIW R26,1
	ADD  R26,R30
	ADC  R27,R31
	LD   R30,X
	LDI  R31,0
	ADD  R30,R0
	ADC  R31,R1
	SUBI R30,LOW(-_ekran)
	SBCI R31,HIGH(-_ekran)
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 8 TIMES, CODE SIZE REDUCTION:74 WORDS
SUBOPT_0x27:
	LDI  R26,LOW(5)
	MUL  R30,R26
	MOVW R30,R0
	SUBI R30,LOW(-_simvol)
	SBCI R31,HIGH(-_simvol)
	MOVW R26,R30
	LDS  R30,_temp
	LDI  R31,0
	ADD  R26,R30
	ADC  R27,R31
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 31 TIMES, CODE SIZE REDUCTION:57 WORDS
SUBOPT_0x28:
	CALL __SWAPW12
	SUB  R30,R26
	SBC  R31,R27
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:12 WORDS
SUBOPT_0x29:
	MOVW R22,R30
	LD   R1,Z
	LDS  R30,_Shift_zn_S000000E000
	LDI  R26,LOW(1)
	CALL __LSLB12
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x2A:
	COM  R30
	AND  R30,R1
	MOVW R26,R22
	ST   X,R30
	RJMP SUBOPT_0x23

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:6 WORDS
SUBOPT_0x2B:
	LDS  R30,_temp
	SUBI R30,-LOW(1)
	STS  _temp,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x2C:
	LDD  R30,Y+2
	LDI  R26,LOW(5)
	MUL  R30,R26
	MOVW R30,R0
	SUBI R30,LOW(-_simvol)
	SBCI R31,HIGH(-_simvol)
	MOVW R26,R30
	CLR  R30
	ADD  R26,R17
	ADC  R27,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:7 WORDS
SUBOPT_0x2D:
	MOV  R26,R17
	CLR  R27
	LDD  R30,Y+1
	LDI  R31,0
	ADD  R30,R26
	ADC  R31,R27
	SUBI R30,LOW(-_ekran)
	SBCI R31,HIGH(-_ekran)
	__PUTW1R 23,24
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:7 WORDS
SUBOPT_0x2E:
	LD   R22,X
	LDI  R30,0
	SBRC R2,0
	LDI  R30,1
	LDI  R26,LOW(128)
	MULS R30,R26
	MOVW R30,R0
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x2F:
	ADD  R30,R22
	__GETW2R 23,24
	ST   X,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:12 WORDS
SUBOPT_0x30:
	LDI  R27,0
	LDI  R30,LOW(10)
	LDI  R31,HIGH(10)
	CALL __DIVW21
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x31:
	SUBI R30,LOW(-_simvol)
	SBCI R31,HIGH(-_simvol)
	MOVW R26,R30
	CLR  R30
	ADD  R26,R17
	ADC  R27,R30
	RJMP SUBOPT_0x2E

;OPTIMIZER ADDED SUBROUTINE, CALLED 11 TIMES, CODE SIZE REDUCTION:27 WORDS
SUBOPT_0x32:
	LDI  R31,0
	ADD  R30,R26
	ADC  R31,R27
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x33:
	LD   R26,Y
	LDD  R27,Y+1
	LDI  R30,LOW(60)
	LDI  R31,HIGH(60)
	CALL __MODW21U
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:9 WORDS
SUBOPT_0x34:
	ST   -Y,R30
	LDI  R30,LOW(13)
	ST   -Y,R30
	JMP  _ekran_1_figure

;OPTIMIZER ADDED SUBROUTINE, CALLED 14 TIMES, CODE SIZE REDUCTION:36 WORDS
SUBOPT_0x35:
	ST   -Y,R30
	LDI  R30,LOW(19)
	ST   -Y,R30
	JMP  _ekran_1_figure

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x36:
	LD   R26,Y
	LDD  R27,Y+1
	LDI  R30,LOW(60)
	LDI  R31,HIGH(60)
	CALL __DIVW21U
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x37:
	ST   -Y,R30
	LDI  R30,LOW(0)
	ST   -Y,R30
	CALL _ystanovki_2
	LDI  R26,LOW(60)
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 15 TIMES, CODE SIZE REDUCTION:39 WORDS
SUBOPT_0x38:
	ST   -Y,R30
	LDI  R30,LOW(0)
	ST   -Y,R30
	JMP  _ekran_1_figure

;OPTIMIZER ADDED SUBROUTINE, CALLED 12 TIMES, CODE SIZE REDUCTION:30 WORDS
SUBOPT_0x39:
	ST   -Y,R30
	LDI  R30,LOW(6)
	ST   -Y,R30
	JMP  _ekran_1_figure

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:2 WORDS
SUBOPT_0x3A:
	ST   -Y,R30
	LDI  R30,LOW(59)
	ST   -Y,R30
	LDI  R30,LOW(13)
	ST   -Y,R30
	JMP  _ystanovki_2

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:2 WORDS
SUBOPT_0x3B:
	LDI  R31,0
	__ADDW1MN _ekran,1
	LD   R30,Z
	ST   X,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x3C:
	LDS  R30,_z1
	LD   R26,Y
	LDD  R27,Y+1
	RJMP SUBOPT_0x32

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:9 WORDS
SUBOPT_0x3D:
	LPM  R30,Z
	LDI  R26,LOW(5)
	MUL  R30,R26
	MOVW R30,R0
	SUBI R30,LOW(-_simvol)
	SBCI R31,HIGH(-_simvol)
	MOVW R26,R30
	LDS  R30,_z
	LDI  R31,0
	ADD  R26,R30
	ADC  R27,R31
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:6 WORDS
SUBOPT_0x3E:
	LDI  R30,LOW(0)
	__PUTB1MN _ekran,23
	STS  _z,R30
	LDS  R30,_z1
	SUBI R30,-LOW(1)
	STS  _z1,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x3F:
	LD   R30,X
	__PUTB1MN _ekran,23
	LDS  R30,_z
	SUBI R30,-LOW(1)
	STS  _z,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x40:
	MOV  R30,R17
	LDI  R26,LOW(_temperature)
	LDI  R27,HIGH(_temperature)
	LDI  R31,0
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 8 TIMES, CODE SIZE REDUCTION:11 WORDS
SUBOPT_0x41:
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 7 TIMES, CODE SIZE REDUCTION:15 WORDS
SUBOPT_0x42:
	LDI  R31,0
	RJMP SUBOPT_0x41

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x43:
	LDS  R30,_j_S0000014000
	LDI  R26,LOW(_historyTemp)
	LDI  R27,HIGH(_historyTemp)
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:2 WORDS
SUBOPT_0x44:
	LDS  R26,_j_S0000014000
	CLR  R27
	LSL  R26
	ROL  R27
	__ADDW2MN _historyTemp,2
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:6 WORDS
SUBOPT_0x45:
	LDS  R30,_j_S0000014000
	SUBI R30,-LOW(1)
	STS  _j_S0000014000,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x46:
	LDI  R30,LOW(0)
	__CLRD1S 1
	STS  _j_S0000014000,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 14 TIMES, CODE SIZE REDUCTION:36 WORDS
SUBOPT_0x47:
	LDI  R31,0
	RJMP SUBOPT_0x1B

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x48:
	__GETD2S 1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x49:
	CALL __CWD1
	CALL __CDF1
	CALL __ADDF12
	__PUTD1S 1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x4A:
	LDS  R30,_ds_ar
	LDI  R26,LOW(_temperature)
	LDI  R27,HIGH(_temperature)
	RJMP SUBOPT_0x47

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:2 WORDS
SUBOPT_0x4B:
	MOVW R26,R30
	LDS  R30,_tempComplete
	LDS  R31,_tempComplete+1
	CP   R26,R30
	CPC  R27,R31
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x4C:
	LDS  R30,_tempMin
	LDS  R31,_tempMin+1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x4D:
	LDS  R26,_tempComplete
	LDS  R27,_tempComplete+1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:11 WORDS
SUBOPT_0x4E:
	LDS  R30,_z1
	LDD  R26,Y+9
	LDD  R27,Y+9+1
	LDI  R31,0
	ADD  R26,R30
	ADC  R27,R31
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:9 WORDS
SUBOPT_0x4F:
	LD   R30,X
	LDI  R26,LOW(5)
	MUL  R30,R26
	MOVW R30,R0
	SUBI R30,LOW(-_simvol)
	SBCI R31,HIGH(-_simvol)
	MOVW R26,R30
	LDS  R30,_z
	LDI  R31,0
	ADD  R26,R30
	ADC  R27,R31
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x50:
	MOV  R30,R16
	LDD  R26,Y+4
	LDD  R27,Y+4+1
	RJMP SUBOPT_0x32

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x51:
	LPM  R30,Z
	LDI  R26,LOW(5)
	MUL  R30,R26
	MOVW R30,R0
	SUBI R30,LOW(-_simvol)
	SBCI R31,HIGH(-_simvol)
	MOVW R26,R30
	CLR  R30
	ADD  R26,R19
	ADC  R27,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 11 TIMES, CODE SIZE REDUCTION:27 WORDS
SUBOPT_0x52:
	LDI  R31,0
	SUBI R30,LOW(-_budilnik_Install)
	SBCI R31,HIGH(-_budilnik_Install)
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x53:
	LDS  R26,_temp
	LDI  R27,0
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 6 TIMES, CODE SIZE REDUCTION:17 WORDS
SUBOPT_0x54:
	LDS  R30,_time
	LDS  R31,_time+1
	ST   -Y,R31
	ST   -Y,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x55:
	RCALL SUBOPT_0xF
	CP   R30,R26
	CPC  R31,R27
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 8 TIMES, CODE SIZE REDUCTION:11 WORDS
SUBOPT_0x56:
	LDI  R26,LOW(_str)
	LDI  R27,HIGH(_str)
	CALL __EEPROMRDB
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x57:
	LDI  R30,LOW(11)
	MOV  R4,R30
	LDI  R30,LOW(0)
	STS  _z,R30
	STS  _z1,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x58:
	LDI  R30,LOW(30)
	MOV  R4,R30
	LDI  R30,LOW(0)
	STS  _z,R30
	STS  _z1,R30
	JMP  _ochistka

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x59:
	RCALL SUBOPT_0xF
	RJMP SUBOPT_0x1E

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:25 WORDS
SUBOPT_0x5A:
	LDI  R26,LOW(60)
	LDI  R27,HIGH(60)
	CALL __MULW12
	RCALL SUBOPT_0xF
	SUB  R26,R30
	SBC  R27,R31
	LDI  R30,LOW(60)
	LDI  R31,HIGH(60)
	CALL __MULW12
	MOVW R26,R30
	MOV  R30,R7
	RJMP SUBOPT_0x32

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x5B:
	LDI  R30,LOW(0)
	STS  _t,R30
	STS  _temp1,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:41 WORDS
SUBOPT_0x5C:
	LDS  R30,_t
	SUBI R30,-LOW(1)
	STS  _t,R30
	SUBI R30,LOW(1)
	LDI  R31,0
	SUBI R30,LOW(-_beg_info)
	SBCI R31,HIGH(-_beg_info)
	LDI  R26,LOW(45)
	STD  Z+0,R26
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 6 TIMES, CODE SIZE REDUCTION:7 WORDS
SUBOPT_0x5D:
	LDS  R30,_t
	STS  _temp1,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 10 TIMES, CODE SIZE REDUCTION:69 WORDS
SUBOPT_0x5E:
	LDS  R26,_t
	CLR  R27
	LDS  R30,_temp1
	LDI  R31,0
	RJMP SUBOPT_0x28

;OPTIMIZER ADDED SUBROUTINE, CALLED 8 TIMES, CODE SIZE REDUCTION:158 WORDS
SUBOPT_0x5F:
	LDS  R30,_t
	LDI  R31,0
	SUBI R30,LOW(-_beg_info)
	SBCI R31,HIGH(-_beg_info)
	MOVW R22,R30
	LDS  R30,_t
	SUBI R30,-LOW(1)
	STS  _t,R30
	SUBI R30,LOW(1)
	LDI  R31,0
	MOVW R26,R30
	LDS  R30,_temp1
	LDI  R31,0
	RJMP SUBOPT_0x28

;OPTIMIZER ADDED SUBROUTINE, CALLED 81 TIMES, CODE SIZE REDUCTION:717 WORDS
SUBOPT_0x60:
	LDS  R30,_t
	SUBI R30,-LOW(1)
	STS  _t,R30
	SUBI R30,LOW(1)
	LDI  R31,0
	SUBI R30,LOW(-_beg_info)
	SBCI R31,HIGH(-_beg_info)
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:2 WORDS
SUBOPT_0x61:
	LDS  R30,_timeToComplete
	LDI  R31,0
	RJMP SUBOPT_0xF

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:2 WORDS
SUBOPT_0x62:
	MOV  R30,R11
	LDI  R26,LOW(12)
	MUL  R30,R26
	MOVW R30,R0
	SUBI R30,LOW(-_den_nedeli_txt*2)
	SBCI R31,HIGH(-_den_nedeli_txt*2)
	MOVW R22,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x63:
	LDS  R30,_t
	LDI  R31,0
	SUBI R30,LOW(-_beg_info)
	SBCI R31,HIGH(-_beg_info)
	MOVW R24,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:12 WORDS
SUBOPT_0x64:
	LDS  R30,_t
	SUBI R30,-LOW(1)
	STS  _t,R30
	SUBI R30,LOW(1)
	LDI  R31,0
	MOVW R26,R30
	LDS  R30,_temp1
	LDI  R31,0
	RJMP SUBOPT_0x28

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x65:
	MOVW R26,R22
	ST   X,R30
	RJMP SUBOPT_0x60

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:2 WORDS
SUBOPT_0x66:
	LDI  R26,LOW(9)
	LDI  R27,HIGH(9)
	CALL __MULW12U
	SUBI R30,LOW(-_name_mesec_txt*2)
	SBCI R31,HIGH(-_name_mesec_txt*2)
	MOVW R22,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 7 TIMES, CODE SIZE REDUCTION:9 WORDS
SUBOPT_0x67:
	LDI  R30,LOW(100)
	LDI  R31,HIGH(100)
	RJMP SUBOPT_0x1F

;OPTIMIZER ADDED SUBROUTINE, CALLED 6 TIMES, CODE SIZE REDUCTION:7 WORDS
SUBOPT_0x68:
	LDI  R26,LOW(42)
	STD  Z+0,R26
	RJMP SUBOPT_0x60

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:25 WORDS
SUBOPT_0x69:
	LDS  R26,_t
	CLR  R27
	LD   R30,Y
	LDI  R31,0
	RJMP SUBOPT_0x28

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:85 WORDS
SUBOPT_0x6A:
	LDS  R30,_t
	LDI  R31,0
	SUBI R30,LOW(-_beg_info)
	SBCI R31,HIGH(-_beg_info)
	MOVW R22,R30
	LDS  R30,_t
	SUBI R30,-LOW(1)
	STS  _t,R30
	SUBI R30,LOW(1)
	LDI  R31,0
	MOVW R26,R30
	LD   R30,Y
	LDI  R31,0
	RJMP SUBOPT_0x28

;OPTIMIZER ADDED SUBROUTINE, CALLED 6 TIMES, CODE SIZE REDUCTION:47 WORDS
SUBOPT_0x6B:
	LDS  R30,_temp1
	LDI  R31,0
	SUBI R30,LOW(-_ds_ar)
	SBCI R31,HIGH(-_ds_ar)
	LD   R30,Z
	LDI  R26,LOW(_temperature)
	LDI  R27,HIGH(_temperature)
	RJMP SUBOPT_0x47

;OPTIMIZER ADDED SUBROUTINE, CALLED 15 TIMES, CODE SIZE REDUCTION:25 WORDS
SUBOPT_0x6C:
	ST   -Y,R31
	ST   -Y,R30
	JMP  _abs

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:6 WORDS
SUBOPT_0x6D:
	MOVW R26,R30
	LDI  R30,LOW(100)
	LDI  R31,HIGH(100)
	CALL __DIVW21
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:4 WORDS
SUBOPT_0x6E:
	LDS  R30,_sunriseToday
	LDS  R31,_sunriseToday+1
	ST   -Y,R31
	ST   -Y,R30
	ST   -Y,R18
	JMP  _timeToSymbol

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:4 WORDS
SUBOPT_0x6F:
	LDS  R30,_sunsetToday
	LDS  R31,_sunsetToday+1
	ST   -Y,R31
	ST   -Y,R30
	ST   -Y,R18
	JMP  _timeToSymbol

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x70:
	MOV  R30,R21
	LDI  R31,0
	SBIW R30,30
	MOV  R21,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x71:
	LDI  R26,LOW(23)
	STD  Z+0,R26
	RJMP SUBOPT_0x60

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:15 WORDS
SUBOPT_0x72:
	LDS  R30,_t
	LDI  R31,0
	SUBI R30,LOW(-_beg_info)
	SBCI R31,HIGH(-_beg_info)
	LDI  R26,LOW(255)
	STD  Z+0,R26
	LDS  R30,_speed
	LDS  R26,_Interval
	LDS  R27,_Interval+1
	LDI  R31,0
	CP   R26,R30
	CPC  R27,R31
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 14 TIMES, CODE SIZE REDUCTION:36 WORDS
SUBOPT_0x73:
	LDI  R30,LOW(0)
	STS  _Interval,R30
	STS  _Interval+1,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x74:
	LDI  R30,LOW(_beg_info)
	LDI  R31,HIGH(_beg_info)
	ST   -Y,R31
	ST   -Y,R30
	JMP  _beg_stroka_not

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x75:
	CALL _str_pause
	LDI  R30,LOW(10)
	MOV  R4,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x76:
	LDS  R30,_time
	LDS  R31,_time+1
	RJMP SUBOPT_0x22

;OPTIMIZER ADDED SUBROUTINE, CALLED 11 TIMES, CODE SIZE REDUCTION:87 WORDS
SUBOPT_0x77:
	LDS  R30,_speed
	LDS  R26,_Interval
	LDS  R27,_Interval+1
	LDI  R31,0
	CP   R26,R30
	CPC  R27,R31
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 11 TIMES, CODE SIZE REDUCTION:17 WORDS
SUBOPT_0x78:
	ST   -Y,R31
	ST   -Y,R30
	JMP  _beg_stroka

;OPTIMIZER ADDED SUBROUTINE, CALLED 12 TIMES, CODE SIZE REDUCTION:74 WORDS
SUBOPT_0x79:
	MOV  R4,R30
	LDI  R30,LOW(0)
	STS  _z,R30
	STS  _z1,R30
	JMP  _ochistka

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x7A:
	LDI  R30,LOW(11)
	ST   -Y,R30
	LDI  R30,LOW(1)
	ST   -Y,R30
	JMP  _ekran_1_figure

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x7B:
	LDS  R30,_bud
	SUBI R30,-LOW(1)
	ST   -Y,R30
	LDI  R30,LOW(7)
	ST   -Y,R30
	JMP  _ekran_1_figure

;OPTIMIZER ADDED SUBROUTINE, CALLED 7 TIMES, CODE SIZE REDUCTION:9 WORDS
SUBOPT_0x7C:
	LDS  R30,_bud
	RJMP SUBOPT_0x52

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x7D:
	ST   -Y,R30
	LDI  R30,LOW(17)
	ST   -Y,R30
	JMP  _ekran_1_figure

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x7E:
	LDI  R26,LOW(_budilnik_time)
	LDI  R27,HIGH(_budilnik_time)
	RJMP SUBOPT_0x47

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x7F:
	ST   -Y,R31
	ST   -Y,R30
	JMP  _ystanovki_23_59

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x80:
	LDS  R30,_temp
	LDI  R26,LOW(_den_nedeli_letter*2)
	LDI  R27,HIGH(_den_nedeli_letter*2)
	RJMP SUBOPT_0x42

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x81:
	ST   -Y,R30
	LDI  R30,LOW(1)
	ST   -Y,R30
	CALL _ekran_1_figure
	LDI  R30,LOW(43)
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x82:
	ST   -Y,R30
	LDI  R30,LOW(13)
	ST   -Y,R30
	JMP  _ystanovki_2

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x83:
	MOV  R4,R30
	CALL _ochistka
	LDI  R30,LOW(0)
	STS  _temp,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 8 TIMES, CODE SIZE REDUCTION:25 WORDS
SUBOPT_0x84:
	LDI  R30,LOW(0)
	STS  _z,R30
	STS  _z1,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:4 WORDS
SUBOPT_0x85:
	ST   -Y,R30
	CALL _ekran_1_figure
	LDI  R30,LOW(1000)
	LDI  R31,HIGH(1000)
	ST   -Y,R31
	ST   -Y,R30
	JMP  _delay_ms

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x86:
	EOR  R30,R26
	LDI  R26,LOW(_str)
	LDI  R27,HIGH(_str)
	CALL __EEPROMWRB
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x87:
	ST   -Y,R31
	ST   -Y,R30
	JMP  _txt_ekran

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:7 WORDS
SUBOPT_0x88:
	LDI  R30,LOW(12)
	ST   -Y,R30
	LDI  R30,LOW(4)
	ST   -Y,R30
	CALL _ekran_1_figure
	LDI  R30,LOW(43)
	ST   -Y,R30
	LDI  R30,LOW(8)
	ST   -Y,R30
	JMP  _ekran_1_figure

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:6 WORDS
SUBOPT_0x89:
	ST   -Y,R30
	LDI  R30,LOW(14)
	ST   -Y,R30
	JMP  _ekran_1_figure

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x8A:
	LDI  R26,LOW(_brigh_up)
	LDI  R27,HIGH(_brigh_up)
	CALL __EEPROMRDB
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x8B:
	ST   -Y,R31
	ST   -Y,R30
	CALL _ekran_cifri
	LDI  R30,LOW(2)
	CP   R30,R13
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x8C:
	LDI  R30,LOW(100)
	LDI  R31,HIGH(100)
	CALL __DIVW21
	RJMP SUBOPT_0x38

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x8D:
	LDS  R26,_tempMin
	LDS  R27,_tempMin+1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 17 TIMES, CODE SIZE REDUCTION:29 WORDS
SUBOPT_0x8E:
	LDI  R26,LOW(_korr_den)
	LDI  R27,HIGH(_korr_den)
	CALL __EEPROMRDW
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x8F:
	LDI  R26,LOW(_korr_den)
	LDI  R27,HIGH(_korr_den)
	CALL __EEPROMWRW
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x90:
	ST   -Y,R30
	LDI  R30,LOW(12)
	ST   -Y,R30
	JMP  _ekran_1_figure

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:6 WORDS
SUBOPT_0x91:
	RCALL SUBOPT_0xF
	CPI  R26,LOW(0x1F5)
	LDI  R30,HIGH(0x1F5)
	CPC  R27,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x92:
	STS  _tone,R30
	IN   R30,0x39
	ORI  R30,0x10
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x93:
	ST   -Y,R31
	ST   -Y,R30
	RJMP _ds18b20_select

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:2 WORDS
SUBOPT_0x94:
	ST   -Y,R17
	LDD  R30,Y+1
	LDD  R31,Y+1+1
	ST   -Y,R31
	ST   -Y,R30
	RJMP _ds18b20_read_spd

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x95:
	__GETD1N 0xC61C3C00
	RET


	.CSEG
_delay_ms:
	ld   r30,y+
	ld   r31,y+
	adiw r30,0
	breq __delay_ms1
__delay_ms0:
	__DELAY_USW 0x7D0
	wdr
	sbiw r30,1
	brne __delay_ms0
__delay_ms1:
	ret

_w1_init:
	clr  r30
	cbi  __w1_port,__w1_bit
	sbi  __w1_port-1,__w1_bit
	__DELAY_USW 0x3C0
	cbi  __w1_port-1,__w1_bit
	__DELAY_USB 0x25
	sbis __w1_port-2,__w1_bit
	ret
	__DELAY_USB 0xCB
	sbis __w1_port-2,__w1_bit
	ldi  r30,1
	__DELAY_USW 0x30C
	ret

__w1_read_bit:
	sbi  __w1_port-1,__w1_bit
	__DELAY_USB 0x5
	cbi  __w1_port-1,__w1_bit
	__DELAY_USB 0x1D
	clc
	sbic __w1_port-2,__w1_bit
	sec
	ror  r30
	__DELAY_USB 0xD5
	ret

__w1_write_bit:
	clt
	sbi  __w1_port-1,__w1_bit
	__DELAY_USB 0x5
	sbrc r23,0
	cbi  __w1_port-1,__w1_bit
	__DELAY_USB 0x23
	sbic __w1_port-2,__w1_bit
	rjmp __w1_write_bit0
	sbrs r23,0
	rjmp __w1_write_bit1
	ret
__w1_write_bit0:
	sbrs r23,0
	ret
__w1_write_bit1:
	__DELAY_USB 0xC8
	cbi  __w1_port-1,__w1_bit
	__DELAY_USB 0xD
	set
	ret

_w1_read:
	ldi  r22,8
	__w1_read0:
	rcall __w1_read_bit
	dec  r22
	brne __w1_read0
	ret

_w1_write:
	ldi  r22,8
	ld   r23,y+
	clr  r30
__w1_write0:
	rcall __w1_write_bit
	brtc __w1_write1
	ror  r23
	dec  r22
	brne __w1_write0
	inc  r30
__w1_write1:
	ret

_w1_search:
	push r20
	push r21
	clr  r1
	clr  r20
	ld   r26,y
	ldd  r27,y+1
__w1_search0:
	mov  r0,r1
	clr  r1
	rcall _w1_init
	tst  r30
	breq __w1_search7
	ldd  r30,y+2
	st   -y,r30
	rcall _w1_write
	ldi  r21,1
__w1_search1:
	cp   r21,r0
	brsh __w1_search6
	rcall __w1_read_bit
	sbrc r30,7
	rjmp __w1_search2
	rcall __w1_read_bit
	sbrc r30,7
	rjmp __w1_search3
	rcall __sel_bit
	and  r24,r25
	brne __w1_search3
	mov  r1,r21
	rjmp __w1_search3
__w1_search2:
	rcall __w1_read_bit
__w1_search3:
	rcall __sel_bit
	and  r24,r25
	ldi  r23,0
	breq __w1_search5
__w1_search4:
	ldi  r23,1
__w1_search5:
	rcall __w1_write_bit
	rjmp __w1_search13
__w1_search6:
	rcall __w1_read_bit
	sbrs r30,7
	rjmp __w1_search9
	rcall __w1_read_bit
	sbrs r30,7
	rjmp __w1_search8
__w1_search7:
	mov  r30,r20
	pop  r21
	pop  r20
	adiw r28,3
	ret
__w1_search8:
	set
	rcall __set_bit
	rjmp __w1_search4
__w1_search9:
	rcall __w1_read_bit
	sbrs r30,7
	rjmp __w1_search10
	rjmp __w1_search11
__w1_search10:
	cp   r21,r0
	breq __w1_search12
	mov  r1,r21
__w1_search11:
	clt
	rcall __set_bit
	clr  r23
	rcall __w1_write_bit
	rjmp __w1_search13
__w1_search12:
	set
	rcall __set_bit
	ldi  r23,1
	rcall __w1_write_bit
__w1_search13:
	inc  r21
	cpi  r21,65
	brlt __w1_search1
	rcall __w1_read_bit
	rol  r30
	rol  r30
	andi r30,1
	adiw r26,8
	st   x,r30
	sbiw r26,8
	inc  r20
	tst  r1
	breq __w1_search7
	ldi  r21,9
__w1_search14:
	ld   r30,x
	adiw r26,9
	st   x,r30
	sbiw r26,8
	dec  r21
	brne __w1_search14
	rjmp __w1_search0

__sel_bit:
	mov  r30,r21
	dec  r30
	mov  r22,r30
	lsr  r30
	lsr  r30
	lsr  r30
	clr  r31
	add  r30,r26
	adc  r31,r27
	ld   r24,z
	ldi  r25,1
	andi r22,7
__sel_bit0:
	breq __sel_bit1
	lsl  r25
	dec  r22
	rjmp __sel_bit0
__sel_bit1:
	ret

__set_bit:
	rcall __sel_bit
	brts __set_bit2
	com  r25
	and  r24,r25
	rjmp __set_bit3
__set_bit2:
	or   r24,r25
__set_bit3:
	st   z,r24
	ret

_w1_dow_crc8:
	clr  r30
	ld   r24,y
	tst  r24
	breq __w1_dow_crc83
	ldi  r22,0x18
	ldd  r26,y+1
	ldd  r27,y+2
__w1_dow_crc80:
	ldi  r25,8
	ld   r31,x+
__w1_dow_crc81:
	mov  r23,r31
	eor  r23,r30
	ror  r23
	brcc __w1_dow_crc82
	eor  r30,r22
__w1_dow_crc82:
	ror  r30
	lsr  r31
	dec  r25
	brne __w1_dow_crc81
	dec  r24
	brne __w1_dow_crc80
__w1_dow_crc83:
	adiw r28,3
	ret

__ROUND_REPACK:
	TST  R21
	BRPL __REPACK
	CPI  R21,0x80
	BRNE __ROUND_REPACK0
	SBRS R30,0
	RJMP __REPACK
__ROUND_REPACK0:
	ADIW R30,1
	ADC  R22,R25
	ADC  R23,R25
	BRVS __REPACK1

__REPACK:
	LDI  R21,0x80
	EOR  R21,R23
	BRNE __REPACK0
	PUSH R21
	RJMP __ZERORES
__REPACK0:
	CPI  R21,0xFF
	BREQ __REPACK1
	LSL  R22
	LSL  R0
	ROR  R21
	ROR  R22
	MOV  R23,R21
	RET
__REPACK1:
	PUSH R21
	TST  R0
	BRMI __REPACK2
	RJMP __MAXRES
__REPACK2:
	RJMP __MINRES

__UNPACK:
	LDI  R21,0x80
	MOV  R1,R25
	AND  R1,R21
	LSL  R24
	ROL  R25
	EOR  R25,R21
	LSL  R21
	ROR  R24

__UNPACK1:
	LDI  R21,0x80
	MOV  R0,R23
	AND  R0,R21
	LSL  R22
	ROL  R23
	EOR  R23,R21
	LSL  R21
	ROR  R22
	RET

__CFD1U:
	SET
	RJMP __CFD1U0
__CFD1:
	CLT
__CFD1U0:
	PUSH R21
	RCALL __UNPACK1
	CPI  R23,0x80
	BRLO __CFD10
	CPI  R23,0xFF
	BRCC __CFD10
	RJMP __ZERORES
__CFD10:
	LDI  R21,22
	SUB  R21,R23
	BRPL __CFD11
	NEG  R21
	CPI  R21,8
	BRTC __CFD19
	CPI  R21,9
__CFD19:
	BRLO __CFD17
	SER  R30
	SER  R31
	SER  R22
	LDI  R23,0x7F
	BLD  R23,7
	RJMP __CFD15
__CFD17:
	CLR  R23
	TST  R21
	BREQ __CFD15
__CFD18:
	LSL  R30
	ROL  R31
	ROL  R22
	ROL  R23
	DEC  R21
	BRNE __CFD18
	RJMP __CFD15
__CFD11:
	CLR  R23
__CFD12:
	CPI  R21,8
	BRLO __CFD13
	MOV  R30,R31
	MOV  R31,R22
	MOV  R22,R23
	SUBI R21,8
	RJMP __CFD12
__CFD13:
	TST  R21
	BREQ __CFD15
__CFD14:
	LSR  R23
	ROR  R22
	ROR  R31
	ROR  R30
	DEC  R21
	BRNE __CFD14
__CFD15:
	TST  R0
	BRPL __CFD16
	RCALL __ANEGD1
__CFD16:
	POP  R21
	RET

__CDF1U:
	SET
	RJMP __CDF1U0
__CDF1:
	CLT
__CDF1U0:
	SBIW R30,0
	SBCI R22,0
	SBCI R23,0
	BREQ __CDF10
	CLR  R0
	BRTS __CDF11
	TST  R23
	BRPL __CDF11
	COM  R0
	RCALL __ANEGD1
__CDF11:
	MOV  R1,R23
	LDI  R23,30
	TST  R1
__CDF12:
	BRMI __CDF13
	DEC  R23
	LSL  R30
	ROL  R31
	ROL  R22
	ROL  R1
	RJMP __CDF12
__CDF13:
	MOV  R30,R31
	MOV  R31,R22
	MOV  R22,R1
	PUSH R21
	RCALL __REPACK
	POP  R21
__CDF10:
	RET

__SWAPACC:
	PUSH R20
	MOVW R20,R30
	MOVW R30,R26
	MOVW R26,R20
	MOVW R20,R22
	MOVW R22,R24
	MOVW R24,R20
	MOV  R20,R0
	MOV  R0,R1
	MOV  R1,R20
	POP  R20
	RET

__UADD12:
	ADD  R30,R26
	ADC  R31,R27
	ADC  R22,R24
	RET

__NEGMAN1:
	COM  R30
	COM  R31
	COM  R22
	SUBI R30,-1
	SBCI R31,-1
	SBCI R22,-1
	RET

__ADDF12:
	PUSH R21
	RCALL __UNPACK
	CPI  R25,0x80
	BREQ __ADDF129

__ADDF120:
	CPI  R23,0x80
	BREQ __ADDF128
__ADDF121:
	MOV  R21,R23
	SUB  R21,R25
	BRVS __ADDF1211
	BRPL __ADDF122
	RCALL __SWAPACC
	RJMP __ADDF121
__ADDF122:
	CPI  R21,24
	BRLO __ADDF123
	CLR  R26
	CLR  R27
	CLR  R24
__ADDF123:
	CPI  R21,8
	BRLO __ADDF124
	MOV  R26,R27
	MOV  R27,R24
	CLR  R24
	SUBI R21,8
	RJMP __ADDF123
__ADDF124:
	TST  R21
	BREQ __ADDF126
__ADDF125:
	LSR  R24
	ROR  R27
	ROR  R26
	DEC  R21
	BRNE __ADDF125
__ADDF126:
	MOV  R21,R0
	EOR  R21,R1
	BRMI __ADDF127
	RCALL __UADD12
	BRCC __ADDF129
	ROR  R22
	ROR  R31
	ROR  R30
	INC  R23
	BRVC __ADDF129
	RJMP __MAXRES
__ADDF128:
	RCALL __SWAPACC
__ADDF129:
	RCALL __REPACK
	POP  R21
	RET
__ADDF1211:
	BRCC __ADDF128
	RJMP __ADDF129
__ADDF127:
	SUB  R30,R26
	SBC  R31,R27
	SBC  R22,R24
	BREQ __ZERORES
	BRCC __ADDF1210
	COM  R0
	RCALL __NEGMAN1
__ADDF1210:
	TST  R22
	BRMI __ADDF129
	LSL  R30
	ROL  R31
	ROL  R22
	DEC  R23
	BRVC __ADDF1210

__ZERORES:
	CLR  R30
	CLR  R31
	CLR  R22
	CLR  R23
	POP  R21
	RET

__MINRES:
	SER  R30
	SER  R31
	LDI  R22,0x7F
	SER  R23
	POP  R21
	RET

__MAXRES:
	SER  R30
	SER  R31
	LDI  R22,0x7F
	LDI  R23,0x7F
	POP  R21
	RET

__MULF12:
	PUSH R21
	RCALL __UNPACK
	CPI  R23,0x80
	BREQ __ZERORES
	CPI  R25,0x80
	BREQ __ZERORES
	EOR  R0,R1
	SEC
	ADC  R23,R25
	BRVC __MULF124
	BRLT __ZERORES
__MULF125:
	TST  R0
	BRMI __MINRES
	RJMP __MAXRES
__MULF124:
	PUSH R0
	PUSH R17
	PUSH R18
	PUSH R19
	PUSH R20
	CLR  R17
	CLR  R18
	CLR  R25
	MUL  R22,R24
	MOVW R20,R0
	MUL  R24,R31
	MOV  R19,R0
	ADD  R20,R1
	ADC  R21,R25
	MUL  R22,R27
	ADD  R19,R0
	ADC  R20,R1
	ADC  R21,R25
	MUL  R24,R30
	RCALL __MULF126
	MUL  R27,R31
	RCALL __MULF126
	MUL  R22,R26
	RCALL __MULF126
	MUL  R27,R30
	RCALL __MULF127
	MUL  R26,R31
	RCALL __MULF127
	MUL  R26,R30
	ADD  R17,R1
	ADC  R18,R25
	ADC  R19,R25
	ADC  R20,R25
	ADC  R21,R25
	MOV  R30,R19
	MOV  R31,R20
	MOV  R22,R21
	MOV  R21,R18
	POP  R20
	POP  R19
	POP  R18
	POP  R17
	POP  R0
	TST  R22
	BRMI __MULF122
	LSL  R21
	ROL  R30
	ROL  R31
	ROL  R22
	RJMP __MULF123
__MULF122:
	INC  R23
	BRVS __MULF125
__MULF123:
	RCALL __ROUND_REPACK
	POP  R21
	RET

__MULF127:
	ADD  R17,R0
	ADC  R18,R1
	ADC  R19,R25
	RJMP __MULF128
__MULF126:
	ADD  R18,R0
	ADC  R19,R1
__MULF128:
	ADC  R20,R25
	ADC  R21,R25
	RET

__DIVF21:
	PUSH R21
	RCALL __UNPACK
	CPI  R23,0x80
	BRNE __DIVF210
	TST  R1
__DIVF211:
	BRPL __DIVF219
	RJMP __MINRES
__DIVF219:
	RJMP __MAXRES
__DIVF210:
	CPI  R25,0x80
	BRNE __DIVF218
__DIVF217:
	RJMP __ZERORES
__DIVF218:
	EOR  R0,R1
	SEC
	SBC  R25,R23
	BRVC __DIVF216
	BRLT __DIVF217
	TST  R0
	RJMP __DIVF211
__DIVF216:
	MOV  R23,R25
	PUSH R17
	PUSH R18
	PUSH R19
	PUSH R20
	CLR  R1
	CLR  R17
	CLR  R18
	CLR  R19
	CLR  R20
	CLR  R21
	LDI  R25,32
__DIVF212:
	CP   R26,R30
	CPC  R27,R31
	CPC  R24,R22
	CPC  R20,R17
	BRLO __DIVF213
	SUB  R26,R30
	SBC  R27,R31
	SBC  R24,R22
	SBC  R20,R17
	SEC
	RJMP __DIVF214
__DIVF213:
	CLC
__DIVF214:
	ROL  R21
	ROL  R18
	ROL  R19
	ROL  R1
	ROL  R26
	ROL  R27
	ROL  R24
	ROL  R20
	DEC  R25
	BRNE __DIVF212
	MOVW R30,R18
	MOV  R22,R1
	POP  R20
	POP  R19
	POP  R18
	POP  R17
	TST  R22
	BRMI __DIVF215
	LSL  R21
	ROL  R30
	ROL  R31
	ROL  R22
	DEC  R23
	BRVS __DIVF217
__DIVF215:
	RCALL __ROUND_REPACK
	POP  R21
	RET

__CMPF12:
	TST  R25
	BRMI __CMPF120
	TST  R23
	BRMI __CMPF121
	CP   R25,R23
	BRLO __CMPF122
	BRNE __CMPF121
	CP   R26,R30
	CPC  R27,R31
	CPC  R24,R22
	BRLO __CMPF122
	BREQ __CMPF123
__CMPF121:
	CLZ
	CLC
	RET
__CMPF122:
	CLZ
	SEC
	RET
__CMPF123:
	SEZ
	CLC
	RET
__CMPF120:
	TST  R23
	BRPL __CMPF122
	CP   R25,R23
	BRLO __CMPF121
	BRNE __CMPF122
	CP   R30,R26
	CPC  R31,R27
	CPC  R22,R24
	BRLO __CMPF122
	BREQ __CMPF123
	RJMP __CMPF121

__ANEGW1:
	NEG  R31
	NEG  R30
	SBCI R31,0
	RET

__ANEGD1:
	COM  R31
	COM  R22
	COM  R23
	NEG  R30
	SBCI R31,-1
	SBCI R22,-1
	SBCI R23,-1
	RET

__LSLB12:
	TST  R30
	MOV  R0,R30
	MOV  R30,R26
	BREQ __LSLB12R
__LSLB12L:
	LSL  R30
	DEC  R0
	BRNE __LSLB12L
__LSLB12R:
	RET

__LSLW12:
	TST  R30
	MOV  R0,R30
	MOVW R30,R26
	BREQ __LSLW12R
__LSLW12L:
	LSL  R30
	ROL  R31
	DEC  R0
	BRNE __LSLW12L
__LSLW12R:
	RET

__ASRW12:
	TST  R30
	MOV  R0,R30
	MOVW R30,R26
	BREQ __ASRW12R
__ASRW12L:
	ASR  R31
	ROR  R30
	DEC  R0
	BRNE __ASRW12L
__ASRW12R:
	RET

__LSLW2:
	LSL  R30
	ROL  R31
	LSL  R30
	ROL  R31
	RET

__ASRW2:
	ASR  R31
	ROR  R30
	ASR  R31
	ROR  R30
	RET

__CWD1:
	MOV  R22,R31
	ADD  R22,R22
	SBC  R22,R22
	MOV  R23,R22
	RET

__CWD2:
	MOV  R24,R27
	ADD  R24,R24
	SBC  R24,R24
	MOV  R25,R24
	RET

__EQB12:
	CP   R30,R26
	LDI  R30,1
	BREQ __EQB12T
	CLR  R30
__EQB12T:
	RET

__LNEGB1:
	TST  R30
	LDI  R30,1
	BREQ __LNEGB1F
	CLR  R30
__LNEGB1F:
	RET

__MULW12U:
	MUL  R31,R26
	MOV  R31,R0
	MUL  R30,R27
	ADD  R31,R0
	MUL  R30,R26
	MOV  R30,R0
	ADD  R31,R1
	RET

__MULW12:
	RCALL __CHKSIGNW
	RCALL __MULW12U
	BRTC __MULW121
	RCALL __ANEGW1
__MULW121:
	RET

__DIVW21U:
	CLR  R0
	CLR  R1
	LDI  R25,16
__DIVW21U1:
	LSL  R26
	ROL  R27
	ROL  R0
	ROL  R1
	SUB  R0,R30
	SBC  R1,R31
	BRCC __DIVW21U2
	ADD  R0,R30
	ADC  R1,R31
	RJMP __DIVW21U3
__DIVW21U2:
	SBR  R26,1
__DIVW21U3:
	DEC  R25
	BRNE __DIVW21U1
	MOVW R30,R26
	MOVW R26,R0
	RET

__DIVW21:
	RCALL __CHKSIGNW
	RCALL __DIVW21U
	BRTC __DIVW211
	RCALL __ANEGW1
__DIVW211:
	RET

__MODW21U:
	RCALL __DIVW21U
	MOVW R30,R26
	RET

__MODW21:
	CLT
	SBRS R27,7
	RJMP __MODW211
	COM  R26
	COM  R27
	ADIW R26,1
	SET
__MODW211:
	SBRC R31,7
	RCALL __ANEGW1
	RCALL __DIVW21U
	MOVW R30,R26
	BRTC __MODW212
	RCALL __ANEGW1
__MODW212:
	RET

__CHKSIGNW:
	CLT
	SBRS R31,7
	RJMP __CHKSW1
	RCALL __ANEGW1
	SET
__CHKSW1:
	SBRS R27,7
	RJMP __CHKSW2
	COM  R26
	COM  R27
	ADIW R26,1
	BLD  R0,0
	INC  R0
	BST  R0,0
__CHKSW2:
	RET

__GETW1P:
	LD   R30,X+
	LD   R31,X
	SBIW R26,1
	RET

__GETD1P:
	LD   R30,X+
	LD   R31,X+
	LD   R22,X+
	LD   R23,X
	SBIW R26,3
	RET

__GETW1PF:
	LPM  R0,Z+
	LPM  R31,Z
	MOV  R30,R0
	RET

__CDF2U:
	SET
	RJMP __CDF2U0
__CDF2:
	CLT
__CDF2U0:
	RCALL __SWAPD12
	RCALL __CDF1U0

__SWAPD12:
	MOV  R1,R24
	MOV  R24,R22
	MOV  R22,R1
	MOV  R1,R25
	MOV  R25,R23
	MOV  R23,R1

__SWAPW12:
	MOV  R1,R27
	MOV  R27,R31
	MOV  R31,R1

__SWAPB12:
	MOV  R1,R26
	MOV  R26,R30
	MOV  R30,R1
	RET

__EEPROMRDW:
	ADIW R26,1
	RCALL __EEPROMRDB
	MOV  R31,R30
	SBIW R26,1

__EEPROMRDB:
	SBIC EECR,EEWE
	RJMP __EEPROMRDB
	PUSH R31
	IN   R31,SREG
	CLI
	OUT  EEARL,R26
	OUT  EEARH,R27
	SBI  EECR,EERE
	IN   R30,EEDR
	OUT  SREG,R31
	POP  R31
	RET

__EEPROMWRW:
	RCALL __EEPROMWRB
	ADIW R26,1
	PUSH R30
	MOV  R30,R31
	RCALL __EEPROMWRB
	POP  R30
	SBIW R26,1
	RET

__EEPROMWRB:
	SBIS EECR,EEWE
	RJMP __EEPROMWRB1
	WDR
	RJMP __EEPROMWRB
__EEPROMWRB1:
	IN   R25,SREG
	CLI
	OUT  EEARL,R26
	OUT  EEARH,R27
	SBI  EECR,EERE
	IN   R24,EEDR
	CP   R30,R24
	BREQ __EEPROMWRB0
	OUT  EEDR,R30
	SBI  EECR,EEMWE
	SBI  EECR,EEWE
__EEPROMWRB0:
	OUT  SREG,R25
	RET

__CPW02:
	CLR  R0
	CP   R0,R26
	CPC  R0,R27
	RET

__CPD02:
	CLR  R0
	CP   R0,R26
	CPC  R0,R27
	CPC  R0,R24
	CPC  R0,R25
	RET

__BSTB1:
	CLT
	TST  R30
	BREQ PC+2
	SET
	RET

__SAVELOCR4:
	ST   -Y,R19
__SAVELOCR3:
	ST   -Y,R18
__SAVELOCR2:
	ST   -Y,R17
	ST   -Y,R16
	RET

__LOADLOCR4:
	LDD  R19,Y+3
__LOADLOCR3:
	LDD  R18,Y+2
__LOADLOCR2:
	LDD  R17,Y+1
	LD   R16,Y
	RET

__INITLOCB:
__INITLOCW:
	ADD  R26,R28
	ADC  R27,R29
__INITLOC0:
	LPM  R0,Z+
	ST   X+,R0
	DEC  R24
	BRNE __INITLOC0
	RET

;END OF CODE MARKER
__END_OF_CODE:
