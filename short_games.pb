
Debug "read"
in=ReadFile(#PB_Any,"games.json")

NewList text.s()

While Not Eof(in)
  line.s=ReadString(in)
  
  If Right(line,4)=": "+#DQUOTE$+#DQUOTE$ Or Right(line,4)=": []" Or Right(line,3)=": 0"
    If Right(text(),1)=","
      text()=Left(text(),Len(text())-1)
    EndIf
  ElseIf Right(line,5)<>": "+#DQUOTE$+#DQUOTE$+"," And Right(line,5)<>": []," And Right(line,4)<>": 0,"
    AddElement(text.s())
;     Repeat
;       a=Len(line)
;       line=ReplaceString(line," :",":")
;     Until a=Len(line)
;     line=ReplaceString(line,#DQUOTE$+": ",#DQUOTE$+":")    
;     line=trim(line)    
    text()=line
  EndIf
Wend
CloseFile(in)


Debug "write compact"
out=CreateFile(#PB_Any,"media\games.json")
ForEach text()
  WriteStringN(out,text())
Next
CloseFile(out)
; IDE Options = PureBasic 6.11 LTS (Windows - x64)
; CursorPosition = 30
; EnableXP