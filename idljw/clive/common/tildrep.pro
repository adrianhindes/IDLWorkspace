function tildrep, str
pos=strpos(str,'~')
if pos eq -1 then return,str

rv=getenv('HOME')+strmid(str,pos+1,999)
return,rv
end

