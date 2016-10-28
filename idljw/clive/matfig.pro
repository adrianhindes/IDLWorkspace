for sh=9163,9166 do begin
mkfig,'h:\mat_'+string(sh,format='(I0)')+'.eps',xsize=18,size=15,font_size=9
loadallnew,sh,maxt=7,tr=[0,6],/nostop
endfig,/jp
endfor
end

