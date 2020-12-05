ASSUME CS:CODE,DS:DATA

DATA SEGMENT
          HELLO DB 'The current time is:',0AH,'$'
          REMINDER DB 'Do you need to set up your alarm?',0AH,'Input y or n',0AH,'$'
          ENTER DB 0AH,'$'
		  SPACE DB 0DH,'$'
          SETH DB 'Input hour:',0AH,'$'
          SETM DB 'Input minute:',0AH,'$'
          TIME DB 24H,61H                ;�ֱ�ΪСʱ�ͷ���
          BUF DB 5 DUP(?)               ;������
DATA ENDS

CODE SEGMENT
     START:                               CALL ASK   
                                          
                                          MOV AX,DATA
                                          MOV DS,AX
                                          MOV DX,OFFSET HELLO
                                          MOV AH,09H
                                          INT 21H

             TIME_CHANGE:                 CALL INIT_REG     ;��ʼ��
                                          
                                          CALL SHOW_CLOCK        ;ѭ������ʱ��
                                          JMP TIME_CHANGE
                                          MOV AX,4C00H
                                          INT 21H
ASK PROC
                                  PUSH AX
								  PUSH DS
								  PUSH SI
								  PUSH CX
								  PUSH DX
                                         MOV AX,DATA
                                         MOV DS,AX
             CLE:                 CALL CLEAR
                                         MOV DX,OFFSET REMINDER         ;��ʾѯ���û��Ƿ���Ҫ��������
                                         MOV AH,09H
                                         INT 21H
                                         MOV AH,01H               ;��ʼ���� 
                                         INT 21H
                                         CMP AL,79H
                                         JNE RETURN                 ;����Ҫ���˳�
                                         CALL KONGGE                 ;�ո�
                                         LEA SI,BUF                   ;�����ֵ���뻺����
                                         ;����Сʱ
                                         MOV DX,OFFSET SETH             ;���û�����Сʱ
                                         MOV AH,09H
                                         INT 21H 
                                         MOV AH,01H               ;��Ҫִ�����빦��
                                         MOV CX,2                    ;���������ַ�
                       LOPA:          INT 21H                       ;�����ַ�
                                         MOV DS:[SI],AL                ;��д��������                                      
                                         INC SI                         ;ָ������ָ
                               LOOP LOPA   
                                         CALL HUICHE             ;�س�
                                         ;���÷���
                                         MOV DX,OFFSET SETM             ;���û��������
                                         MOV AH,09H
                                         INT 21H 
                                         MOV AH,01H               ;��Ҫִ�����빦��
                                         MOV CX,2                    ;���������ַ�
                       BBB:          INT 21H                       ;�����ַ�
                                         MOV DS:[SI],AL                ;��д��������                                      
                                         INC SI                         ;ָ������ָ
                               LOOP BBB
							             CALL HUICHE
                                         LEA SI,BUF                   ;�������ո�����������Ƿ�Ϸ�
                 
                                         MOV AL,DS:[SI]           ;AL��ʮλ��AH�Ÿ�λ
                                         INC SI
                                         MOV AH,DS:[SI]           ;���Сʱ                                                                    
                                         SUB AL,30H
                                         SUB AH,30H                ;��ת��ΪBCD��
                                         CMP AL,03H               ;ʮλ�Ƿ����3��
                                         JA CLE                         ;�ǣ�����������
                                         CMP AL,02H               ;ʮλ�Ƿ����2��
                                         JNZ CCC                      ;�����ǣ�����Ӳ���Ҫ���ж�
                                         CMP AH,03H               ;�����жϸ�λ�Ƿ����3��
                                         JA CLE                        ;�ǣ����������� 
                  
                        CCC:          SHL AL,1                    ;ʮλ����4
                                         SHL AL,1
                                         SHL AL,1
                                         SHL AL,1
                                         OR AL,AH                    ;AL���Сʱ
                                         PUSH SI
                                         MOV SI,OFFSET TIME     
                                         MOV DS:[SI],AL          ;����Сʱ
                                         POP SI
                                         INC SI  
                                         MOV AL,DS:[SI]
                                         INC SI
                                         MOV AH,DS:[SI]           ;������                                                                    
                                         SUB AL,30H
                                         SUB AH,30H                ;��ת��ΪBCD��
                                         CMP AL,05H               ;ʮλ����5��
                                         JA CLE                         ;��������������
                                         SHL AL,1                    ;ʮλ����4
                                         SHL AL,1
                                         SHL AL,1
                                         SHL AL,1
                                         OR AL,AH                    ;AL��ŷ���
                                         MOV SI,OFFSET TIME
                                         INC SI
                                         MOV DS:[SI],AL 
             RETURN:              CALL HUICHE      
			                      POP DX
								  POP CX
								  POP SI
								  POP DS
								  POP AX                
                                         RET                                         
ASK ENDP

HUICHE PROC
      PUSH AX
	  PUSH DX
	  PUSH DS
	    MOV AX,DATA
		MOV DS,AX
	    MOV DX,OFFSET ENTER             ;�س�
        MOV AH,09H
        INT 21H
      POP DS 
	  POP DX
	  POP AX
	  RET
HUICHE ENDP

KONGGE PROC
      PUSH AX
	  PUSH DX
	  PUSH DS
	    MOV AX,DATA
		MOV DS,AX
	    MOV DX,OFFSET SPACE             ;�س�
        MOV AH,09H
        INT 21H
      POP DS 
	  POP DX
	  POP AX
	  RET
KONGGE ENDP

     INIT_REG PROC            
                                          MOV AX,0B800H
                                          MOV ES,AX
                                          MOV AX,CS
                                          MOV DS,AX
                                          MOV DI,160*12+70
                                          MOV AX,DATA
                                          MOV DS,AX
                                          MOV SI,OFFSET TIME      ;ȡ��������ʱ���ƫ����
                                          MOV CX,2                        ;��������
                                          RET
    INIT_REG ENDP

          CLEAR PROC                    
                                          MOV AX,0003H
                                          INT 10H
                                          PUSH BX
                                          PUSH CX
                                          PUSH ES
                                          MOV BX,0B800H
                                          MOV ES,BX
                                          MOV CX,2000
                CLEARP:             MOV BYTE PTR ES:[BX],' '
                                          ADD BX,2
                                          LOOP CLEARP
                                          POP ES
                                          POP CX
                                          POP BX
                                          RET
           CLEAR ENDP

     SHOW_CLOCK PROC
                                          PUSH DX
                                          PUSH ES
                                          PUSH DI
                                          PUSH SI
                                          PUSH DS
                                          PUSH CX

                                          MOV AL,04H                ;ȷ��Ҫװ�����ʱ
                                          OUT 70H,AL
                                          IN AL,71H
                                          MOV AH,DS:[SI]               ;�����ӵ�Сʱ������AH
                                          CMP AH,AL                      ;��ȡ������ʱ��Ƚ�
                                          JNE ONE                          ;�����ȣ����������������
                                          DEC CX                            ;����ȣ����������1
                      ONE:            MOV AH,AL                      ;ȡ����һ�ֽ�BCD�뿽��һ�ݵ�AH
                                          SHR AH,1
                                          SHR AH,1
                                          SHR AH,1
                                          SHR AH,1                         ;��AH���������ĴΣ�AH��װ����ʮλ����
                                          AND AL,00001111B         ;ʹ��AL��װ����Ǹ�λ����
                                          ADD AH,30H                    ;ת����ASI��ֵ
                                          ADD AL,30H
                                          MOV ES:[DI],AH
                                          MOV ES:[DI+2],AL
                                          INC SI                              ;ָ�����ӵķ�
                                          ADD DI,6
                                          
                                          MOV AL,02H                ;ȷ��Ҫȡ���Ƿ�
                                          OUT 70H,AL
                                          IN AL,71H
                                          MOV AH,DS:[SI]               ;�����ӵķ���λ����AH
                                          CMP AH,AL                      ;��ȡ������ʱ��Ƚ�
                                          JNE TWO                          ;�����ȣ����������������
                                          DEC CX                            ;����ȣ����������1
                      TWO:           MOV AH,AL                      ;ȡ����һ�ֽ�BCD�뿽��һ�ݵ�AH
                                          SHR AH,1
                                          SHR AH,1
                                          SHR AH,1
                                          SHR AH,1                         ;��AH���������ĴΣ�AH��װ����ʮλ����
                                          AND AL,00001111B         ;ʹ��AL��װ����Ǹ�λ����
                                          ADD AH,30H                    ;ת����ASI��ֵ
                                          ADD AL,30H
                                          MOV ES:[DI],AH
                                          MOV ES:[DI+2],AL
                                          ADD DI,6
                                        
                                          MOV AL,0H                ;ȷ��Ҫȡ������
                                          OUT 70H,AL
                                          IN AL,71H
                                          MOV AH,AL                      ;ȡ����һ�ֽ�BCD�뿽��һ�ݵ�AH
                                          SHR AH,1
                                          SHR AH,1
                                          SHR AH,1
                                          SHR AH,1                         ;��AH���������ĴΣ�AH��װ����ʮλ����
                                          AND AL,00001111B         ;ʹ��AL��װ����Ǹ�λ����
                                          ADD AH,30H                    ;ת����ASI��ֵ
                                          ADD AL,30H
                                          MOV ES:[DI],AH
                                          MOV ES:[DI+2],AL
                                          
                                          MOV AX,CX
                                          CMP AX,0                        
                                          JNZ THREE                 ;������������0���˳�����                     
                                          CALL HORN               ;��������������
                THREE:               POP CX
                                          POP DS
                                          POP SI
                                          POP DI
                                          POP ES
                                          POP DX
                                          RET
     SHOW_CLOCK ENDP

     HORN PROC
                                         PUSH AX
                                         PUSH CX
                                         MOV AL,086H            ;��ʼ��ʼ�������� 086H
                                         OUT 43H,AL               ;д������
                                         MOV AX,1983            ;������ֵ
                                         OUT 42H,AL                ;д����ֵ��λ
                                         MOV AL,AH               
                                         OUT 42H,AL                ;д����ֵ��λ

                                         CALL SPEAKON           ;����������
                                         CALL PAUSE
                                         CALL SPEAKOFF          ;�ر�������

                                         POP CX
                                         POP AX
                                         RET
      HORN ENDP
        
      PAUSE PROC
		         PUSH CX
                                         PUSH DX
		         MOV DX,5
                            FOUR:   MOV CX,0FFFFH

		LOP:  
		         LOOP LOP
		         DEC DX                ;ѭ��������һ
		         JNZ FOUR               ;ѭ��������Ϊ0��ת��FOUR
		         POP DX
		         POP CX
		         RET
      PAUSE ENDP

      SPEAKON PROC                    ;�����������ӳ���
                            PUSH AX
                            IN AL,61H             ;��8255 B��״̬
                            OR AL,03H            ;�� PB1 PB0��Ϊ11���������ֲ��䣬ʹ����������
                            OUT 61H,AL          ;д��B��
                            POP AX
                            RET
        SPEAKON ENDP 

        SPEAKOFF PROC                  ;�ر��������ӳ���
                             PUSH AX
                             IN AL,61H
                             AND AL,0FCH     ;��PB1 PB0��Ϊ00���ر�������������λ���ֲ���
                             OUT 61H,AL        ;д��B��
                             POP AX
                             RET
         SPEAKOFF ENDP     
                                        
CODE ENDS
END START
