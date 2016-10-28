pro gettime, sh, date
mdsopen,'h1data',sh
default, node, '\h1data::top.operations:h18212sl:input_07'
;node='\H1DATA::TOP.ELECTR_DENS::TOP.NE_HET:NE_CENTRE'
node='\H1DATA::TOP.ELECTR_DENS.CAMAC:A14_21:INPUT_1'
node='\H1DATA::TOP.OPERATIONS:I_MAIN'
 node='\H1DATA::TOP.RF:P_RF_NET'
node='\H1DATA::TOP.RF:A14_4:INPUT_1'
datesecs=mdsvalue('getnci("\'+node+'","TIME_INSERTED")',quiet=quiet,stat=dstat)
;y
 date=mdsvalue('date_time($)',datesecs)

;print,date

end

pro loop

sh1=88891
sh0=81746
openw,lun,'/home/cmichael/idl/clive/settings/probexls/shotdate.txt',/get_lun
for i=sh1,sh0,-1 do begin
gettime,i,date & printf,lun,i,' ',date & print,i,' ',date

endfor
close,lun
free_lun,lun
end

