function read_kstar_intersect, shotno, bin=bin, path=path

s = load_mse_demod_settings( shotno )
default, path, '.mse.intersect'
mdsopen, s.tree, s.reg_shot
       
;intersect = {'R': R_int, $
;             'Phi': phi_int, $
;             'X': int[*,*,0], $
;             'Y': int[*,*,1],$
;             'Z': int[*,*,2], $
;             'v': fltarr(view.nchi, view.ntheta),$
;             'i', view.unit, $
;             'j', junit, $
;             'k', kunit )


   mdssetdefault, path
    
    r = mdsvalue('radius')
    sz=size(r) & nr=sz[1] & nz=sz[2]

   if keyword_Set(bin) then begin
   
   intersect= {$
    r:  rebinb(mdsvalue('radius'),bin), $
    phi:rebinb(mdsvalue('phi'),bin), $
    x:  rebinb(mdsvalue('xint'),bin), $
    y:  rebinb(mdsvalue('yint'),bin), $
    z:  rebinb(mdsvalue('zint'),bin), $
    v:  rebinb(mdsvalue('v'),[bin,bin,1]), $
    i:  rebinb(mdsvalue('i'),[bin,bin,1]), $
    j:  rebinb(mdsvalue('j'),[bin,bin,1]), $
    k:  rebinb(mdsvalue('k'),[bin,bin,1]), $
    gamma: rebinb(mdsvalue('gamma'),bin), $
    psi:  rebinb(mdsvalue('psi'),bin), $
    theta:  rebinb(mdsvalue('theta'),bin), $
    alpha:  rebinb(mdsvalue('alpha'),bin), $
    omega:  rebinb(mdsvalue('omega'),bin), $
    help:  mdsvalue('help'), $
    nr: nr/bin, $
    nz: nz/bin, $
    nr_orig: nr, $
    nz_orig: nz, $
    bin: bin $
    }

   end else begin
   
   intersect= {$
    r:       mdsvalue('radius'), $
    phi: mdsvalue('phi'), $
    x:  mdsvalue('xint'), $
    y:         mdsvalue('yint'), $
    z:    mdsvalue('zint'), $
    v:    mdsvalue('v'), $
    i:    mdsvalue('i'), $
    j:    mdsvalue('j'), $
    k:    mdsvalue('k'), $
    gamma:    mdsvalue('gamma'), $
    psi:    mdsvalue('psi'), $
    theta:    mdsvalue('theta'), $
    alpha:    mdsvalue('alpha'), $
    omega:    mdsvalue('omega'), $
    help:    mdsvalue('help'), $
    nr: nr, $
    nz: nz, $
    bin: 1 $
    }
       
   end
mdsclose, s.tree,  s.reg_shot
 
return, intersect

end

