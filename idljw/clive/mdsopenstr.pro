pro mdsvaluestr, str,node,open=open,close=close

common cbmdsvaluestr, tmp

if keyword_set(open) then begin
   mpath=str.tree+'_path'
   tmp=getenv(mpath)
   if str.path ne tmp then $
      setenv,mpath+'='+str.path
   mdsopen,str.tree,sh
endif

pre='\'+str.tree+'::top'
v=mdsvalue2(pre+node,/quiet)


            flc1=mdsvalue2(pre+'.DAQ.DATA:FLC_1',/quiet)
            flc0.t+=str.t0
            flc1.t+=str.t0
            mdsclose

if keyword_set(close) then begin
   mdsclose
   if str.path ne tmp then $
      setenv,mpath+'='+tmp
endif

end
