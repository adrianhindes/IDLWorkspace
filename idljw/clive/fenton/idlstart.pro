; main startup program
common maincom, termmode1,psfile1,start_t1, oldfont1, colour, epsf
common shotplotcom, termmode,psfile,start_t, oldfont, master_page, eps_flag

start_t=systime(1) 
eps_flag=0b
master_page=''  ; if non-blank, then execute this string on ps

if (trnlog('DECW$DISPLAY', terminalname) ne 1) then $
  termmode='TEK' else termmode='X'
if strpos(username(0),'112') gt 0 then $	; grp disk for plasma
;	psfile = 'grp_prl2:[jnh112]idl.ps' $
	psfile = 'grp_prl:[jnh112.idl]idl.ps' $
;	psfile = 'grp_prl:['+username(0)+']idl.ps' $
else psfile='sys$scratch:idl.ps'
colour=0  &  epsf=0
print, 'Using ', psfile, ' for ps output'
;print, ' Seems like your terminal understands '+termmode+' protocol'
set_plot,termmode

start_11=start_t
termmode1=termmode
psfile1=psfile
;oldfont1=oldfont


if !version.os eq 'vms' then begin  ;use ultrix xlsfonts to show selections
	widget_control, default_font='-adobe-helvetica-bold-r-normal--12*'
end

end

