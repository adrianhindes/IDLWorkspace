@read_spe
pth='~/greg/7_24_2013/hydrogenLampHBeta/';data/'
fil=file_search(pth,'*.spe',count=cnt)
;print,fil


for i=0,cnt-1 do begin
read_spe,fil(i),l,t,d,str=str


;stop
print,fil(i)
print,median(l),max(l)-min(l),n_elements(t),n_elements(t) gt 1 ? t(1)-t(0) : 0
print,size(d,/dim)
plot,totaldim(d,[0,0,1])
print,'___'
stop
endfor


end
