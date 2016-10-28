;__________________________________________________________________________________
function read_kstar_efit, shotno

mdsopen,'kstar',shotno

mdssetdefault, '.efit01'

efit =   {bcentr:  mdsvalue('BCENTR'), $
          rmaxis:  mdsvalue('RMAXIS'), $
          zmaxis:  mdsvalue('ZMAXIS'), $
          ssimag:  mdsvalue('SSIMAG'), $
          ssibry:  mdsvalue('SSIBRY'), $
          aminor:  mdsvalue('AMINOR'), $
          r:  mdsvalue('R'),$
          z:  mdsvalue('Z'),$
          time:  mdsvalue('TIME'),$
          kappa:  mdsvalue('KAPPA'), $
          tritop:  mdsvalue('TRITOP'), $
          tribot:  mdsvalue('TRIBOT'), $
          psin:  mdsvalue('PSIN'),$
          bdry:  mdsvalue('BDRY'), $
          rhovn:  mdsvalue('RHOVN'), $
          psirz:  mdsvalue('PSIRZ'),$
          mw:  mdsvalue('MW'),$
          mh:  mdsvalue('MH'),$
          rzero:  mdsvalue('RZERO'),$
          fpol:  mdsvalue('FPOL')$
       }
mdsclose

return, efit
end

