function mdsvaluestr, str,node,open=open,close=close,flat=flat,nozero=nozero,nodata=nodata,dostop=dostop
if keyword_set(dostop) then stop
common cbmdsvaluestr, tmp
common cbshot, shotc,dbc, isconnected

if n_elements(isconnected) ne 0 then if isconnected eq 1 then mdsdisconnect

if keyword_set(open) then begin
   mpath=str.tree+'_path'
   tmp=getenv(mpath)
   if str.path ne tmp then $
      setenv,mpath+'='+str.path
   mdsopen,str.tree,str.sh

endif

pre='\'+str.tree+'::top'
if n_elements(node) ne 0 then if strmid(node,0,1) eq '\' then pre=''
quiet=1
if not keyword_set(nodata) then if keyword_set(flat) then v=mdsvalue(strupcase(pre+node),quiet=quiet) else  v=mdsvalue2(strupcase(pre+node),quiet=quiet,nozero=nozero)
;stop
if keyword_set(close) then begin
   mdsclose
   mpath=str.tree+'_path'
   
   if str.path ne tmp then $
      setenv,mpath+'='+tmp
endif
if n_elements(v) eq 0 then v=0
return,v

end
