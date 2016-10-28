pro pathadd, pth,noexp=noexp

p0=strsplit(!path,':')
if keyword_set(noexp) then char='' else char='+'
expan=expand_path(char+pth,/array)
nexp=n_elements(expan)
for i=0,nexp-1 do begin
    fnd=where(p0 eq expan(i)) ;;pathfind(expan(i))
;    if fnd(0) ne '' then begin
    if fnd(0) ne -1 then begin
        print,'path '+expan(i)+' already there, not adding'
        continue
    endif
    !path=expan(i)+':'+!path
    print,'added ',expan(i)
endfor


;fnd=pathfind(pth)
;if fnd(0) ne '' then begin
;    print,'path '+pth+' already there, not adding'
;    return
;endif
;!path=expand_path('+'+pth)+':'+!path

end

