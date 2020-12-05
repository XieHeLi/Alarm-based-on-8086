ASSUME CS:CODE,DS:DATA

DATA SEGMENT
          HELLO DB 'The current time is:',0AH,'$'
          REMINDER DB 'Do you need to set up your alarm?',0AH,'Input y or n',0AH,'$'
          ENTER DB 0AH,'$'
		  SPACE DB 0DH,'$'
          SETH DB 'Input hour:',0AH,'$'
          SETM DB 'Input minute:',0AH,'$'
          TIME DB 24H,61H                ;分别为小时和分钟
          BUF DB 5 DUP(?)               ;缓冲区
DATA ENDS

CODE SEGMENT
     START:                               CALL ASK   
                                          
                                          MOV AX,DATA
                                          MOV DS,AX
                                          MOV DX,OFFSET HELLO
                                          MOV AH,09H
                                          INT 21H

             TIME_CHANGE:                 CALL INIT_REG     ;初始化
                                          
                                          CALL SHOW_CLOCK        ;循环更新时间
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
                                         MOV DX,OFFSET REMINDER         ;提示询问用户是否需要设置闹钟
                                         MOV AH,09H
                                         INT 21H
                                         MOV AH,01H               ;开始输入 
                                         INT 21H
                                         CMP AL,79H
                                         JNE RETURN                 ;不需要则退出
                                         CALL KONGGE                 ;空格
                                         LEA SI,BUF                   ;输入的值放入缓冲区
                                         ;设置小时
                                         MOV DX,OFFSET SETH             ;请用户输入小时
                                         MOV AH,09H
                                         INT 21H 
                                         MOV AH,01H               ;将要执行输入功能
                                         MOV CX,2                    ;输入两个字符
                       LOPA:          INT 21H                       ;读入字符
                                         MOV DS:[SI],AL                ;回写到缓冲区                                      
                                         INC SI                         ;指针往下指
                               LOOP LOPA   
                                         CALL HUICHE             ;回车
                                         ;设置分钟
                                         MOV DX,OFFSET SETM             ;请用户输入分钟
                                         MOV AH,09H
                                         INT 21H 
                                         MOV AH,01H               ;将要执行输入功能
                                         MOV CX,2                    ;输入两个字符
                       BBB:          INT 21H                       ;读入字符
                                         MOV DS:[SI],AL                ;回写到缓冲区                                      
                                         INC SI                         ;指针往下指
                               LOOP BBB
							             CALL HUICHE
                                         LEA SI,BUF                   ;回来检测刚刚输入的数据是否合法
                 
                                         MOV AL,DS:[SI]           ;AL放十位，AH放个位
                                         INC SI
                                         MOV AH,DS:[SI]           ;检查小时                                                                    
                                         SUB AL,30H
                                         SUB AH,30H                ;都转换为BCD码
                                         CMP AL,03H               ;十位是否大于3？
                                         JA CLE                         ;是，请重新设置
                                         CMP AL,02H               ;十位是否等于2？
                                         JNZ CCC                      ;若不是，则分钟不需要再判断
                                         CMP AH,03H               ;否则，判断个位是否大于3？
                                         JA CLE                        ;是，请重新设置 
                  
                        CCC:          SHL AL,1                    ;十位左移4
                                         SHL AL,1
                                         SHL AL,1
                                         SHL AL,1
                                         OR AL,AH                    ;AL存放小时
                                         PUSH SI
                                         MOV SI,OFFSET TIME     
                                         MOV DS:[SI],AL          ;存入小时
                                         POP SI
                                         INC SI  
                                         MOV AL,DS:[SI]
                                         INC SI
                                         MOV AH,DS:[SI]           ;检查分钟                                                                    
                                         SUB AL,30H
                                         SUB AH,30H                ;都转换为BCD码
                                         CMP AL,05H               ;十位大于5吗？
                                         JA CLE                         ;若是请重新设置
                                         SHL AL,1                    ;十位左移4
                                         SHL AL,1
                                         SHL AL,1
                                         SHL AL,1
                                         OR AL,AH                    ;AL存放分钟
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
	    MOV DX,OFFSET ENTER             ;回车
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
	    MOV DX,OFFSET SPACE             ;回车
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
                                          MOV SI,OFFSET TIME      ;取存入闹钟时间的偏移量
                                          MOV CX,2                        ;计数两次
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

                                          MOV AL,04H                ;确定要装入的是时
                                          OUT 70H,AL
                                          IN AL,71H
                                          MOV AH,DS:[SI]               ;将闹钟的小时数读入AH
                                          CMP AH,AL                      ;与取出来的时间比较
                                          JNE ONE                          ;若不等，则计数器不做操作
                                          DEC CX                            ;若相等，则计数器减1
                      ONE:            MOV AH,AL                      ;取出的一字节BCD码拷贝一份到AH
                                          SHR AH,1
                                          SHR AH,1
                                          SHR AH,1
                                          SHR AH,1                         ;将AH连续右移四次，AH中装入了十位数字
                                          AND AL,00001111B         ;使得AL中装入的是个位数字
                                          ADD AH,30H                    ;转换成ASI码值
                                          ADD AL,30H
                                          MOV ES:[DI],AH
                                          MOV ES:[DI+2],AL
                                          INC SI                              ;指向闹钟的分
                                          ADD DI,6
                                          
                                          MOV AL,02H                ;确定要取的是分
                                          OUT 70H,AL
                                          IN AL,71H
                                          MOV AH,DS:[SI]               ;将闹钟的分钟位读入AH
                                          CMP AH,AL                      ;与取出来的时间比较
                                          JNE TWO                          ;若不等，则计数器不做操作
                                          DEC CX                            ;若相等，则计数器减1
                      TWO:           MOV AH,AL                      ;取出的一字节BCD码拷贝一份到AH
                                          SHR AH,1
                                          SHR AH,1
                                          SHR AH,1
                                          SHR AH,1                         ;将AH连续右移四次，AH中装入了十位数字
                                          AND AL,00001111B         ;使得AL中装入的是个位数字
                                          ADD AH,30H                    ;转换成ASI码值
                                          ADD AL,30H
                                          MOV ES:[DI],AH
                                          MOV ES:[DI+2],AL
                                          ADD DI,6
                                        
                                          MOV AL,0H                ;确定要取的是秒
                                          OUT 70H,AL
                                          IN AL,71H
                                          MOV AH,AL                      ;取出的一字节BCD码拷贝一份到AH
                                          SHR AH,1
                                          SHR AH,1
                                          SHR AH,1
                                          SHR AH,1                         ;将AH连续右移四次，AH中装入了十位数字
                                          AND AL,00001111B         ;使得AL中装入的是个位数字
                                          ADD AH,30H                    ;转换成ASI码值
                                          ADD AL,30H
                                          MOV ES:[DI],AH
                                          MOV ES:[DI+2],AL
                                          
                                          MOV AX,CX
                                          CMP AX,0                        
                                          JNZ THREE                 ;计数器不等于0则退出程序                     
                                          CALL HORN               ;否则启动扬声器
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
                                         MOV AL,086H            ;开始初始化计数器 086H
                                         OUT 43H,AL               ;写命令字
                                         MOV AX,1983            ;计数初值
                                         OUT 42H,AL                ;写计数值低位
                                         MOV AL,AH               
                                         OUT 42H,AL                ;写计数值高位

                                         CALL SPEAKON           ;开启扬声器
                                         CALL PAUSE
                                         CALL SPEAKOFF          ;关闭扬声器

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
		         DEC DX                ;循环次数减一
		         JNZ FOUR               ;循环次数不为0跳转到FOUR
		         POP DX
		         POP CX
		         RET
      PAUSE ENDP

      SPEAKON PROC                    ;开启扬声器子程序
                            PUSH AX
                            IN AL,61H             ;读8255 B口状态
                            OR AL,03H            ;将 PB1 PB0置为11，其他保持不变，使得扬声器打开
                            OUT 61H,AL          ;写到B口
                            POP AX
                            RET
        SPEAKON ENDP 

        SPEAKOFF PROC                  ;关闭扬声器子程序
                             PUSH AX
                             IN AL,61H
                             AND AL,0FCH     ;将PB1 PB0置为00，关闭扬声器，其它位保持不变
                             OUT 61H,AL        ;写回B口
                             POP AX
                             RET
         SPEAKOFF ENDP     
                                        
CODE ENDS
END START
