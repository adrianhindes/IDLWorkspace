function funcreadflcwp,id
if id eq '' then return,{id:'',type:'none'}
if strmid(id,0,3) eq 'pol' then begin
    return,{id:'pol',type:'pol'}
endif else if strmid(id,0,3) eq 'flc' then readflc,id,str else readwp,id,str
return,str
end


