pro plot_bes_ecei_corr_2d, shot, timerange=timerange, ps=ps, frange=frange

default, shot, 6123
default, timerange, [1.3,1.7]
default, frange, [30,200]*1e3
default, savefile, 'show_all_kstar_ecei_power.sav'

restore,dir_f_name('tmp',savefile)

nblock = n_elements(block)
nrow = (size(chname_arr))[3]
ncol = (size(chname_arr))[2]*nblock
   if (nblock eq 1) then begin
      iblock = where(strupcase(block_saved) eq strupcase(block[0]))
    endif  else begin
      iblock = icolumn/(ncol/2)
      iblock = where(strupcase(block_saved) eq strupcase(block[iblock]))
    endelse
    row = irow
    if (nblock ne 1) then column = icolumn mod (ncol/2) else column = icolumn
    
maxcorr=dblarr(nblock,nrow,ncol)
  for iblock=0,nblock-1 do begin
    for irow=0,nrow-1 do begin
      for icolumn=0,ncol-1 do begin
        maxcorr[iblock,icolumn,irow]=max(reform(p_matrix[iblock,icolumn,irow,*]))
      endfor
    endfor
    position=[[0.05,0.05,0.5,0.5],$
              [0.5,0.05,0.95,0.5]]
    contour,maxcorr[iblock,irow,icolumn],position=position[*,iblock]
  endfor
  stop
  

end