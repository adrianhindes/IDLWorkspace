function ask,txt

;***********************************************
; ASK.PRO
;  This procedure prints the text and asks a yes/no
; question. Returns 0 if no is given, otherwise 1.
;***********************************************

default,txt,''

rep:
print
print,txt+' (y/n)?'
ans='a'
read,ans
if ((ans ne 'y') and (ans ne 'Y') and (ans ne 'n') and (ans ne 'N')) $
     then begin
  print,'????? Answer y or n !!!!'
  goto,rep
endif
if ((ans eq 'n') or (ans eq 'N')) then return,0
return,1
end
