function gettstorepath

common cbshot, shotc,dbc, isconnected

if !version.os eq 'Win32' then begin
   if getenv('COMPUTERNAME') eq 'A-FIDURZ77TUN7K' then begin
      home='e:\dstore\demod\'
   endif
   if getenv('COMPUTERNAME') eq 'JINIL-PC' then begin
      home='c:\dstore\demod\'
   endif
   if getenv('COMPUTERNAME') eq 'PRL33' then begin
      home='d:\dstore\'
   endif
   if getenv('COMPUTERNAME') eq '2D-MSE2' then begin
      home='y:\dstore\demod\'
   endif
   if getenv('COMPUTERNAME') eq 'PRL98' then begin
      home='C:\dstore\demod\'
   endif

endif else begin
   home=getenv('HOME')
   if n_elements(dbc) ne 0 then if dbc eq 'kstar' then home='/home/cam112'
   home=home+'/tmp'             ;     if getenv('HOST') eq 'scucomp2.anu.edu.au' then
   if getenv('HOST') eq 'scucomp1.anu.edu.au' then home='/scratch/cam112'
   spawn,'hostname',host
   if host eq 'ikstar.nfri.re.kr' then home='/home/users/cmichael/tmp'

   home=home+'/demod/'
endelse

return,home
end
