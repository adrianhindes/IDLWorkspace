function bspline_bkpts, x, nord=nord, bkpt=bkpt, bkspace=bkspace,  $
                        nbkpts=nbkpts, everyn=everyn, silent=silent, $
                        bkspread=bkspread, placed=placed

      nx = n_elements(x)

      if (NOT keyword_set(bkpt)) then begin
 
         range = (max(x) - min(x))
         startx = min(x)
         if (keyword_set(placed)) then begin
            w = where(placed ge startx and placed le startx+range, cnt)
            nbkpts = cnt
            if (nbkpts LT 2) then begin
               nbkpts = 2
               tempbkspace = double(range/(float(nbkpts-1)))
               bkpt = (findgen(nbkpts))*tempbkspace + startx
            endif else $
               bkpt = placed[w]
         endif else if (keyword_set(bkspace)) then begin
            nbkpts = long(range/float(bkspace)) + 1
            if (nbkpts LT 2) then nbkpts = 2
            tempbkspace = double(range/(float(nbkpts-1)))
            bkpt = (findgen(nbkpts))*tempbkspace + startx
         endif else if keyword_set(nbkpts) then begin
            nbkpts = long(nbkpts)
            if (nbkpts LT 2) then nbkpts = 2
            tempbkspace = double(range/(float(nbkpts-1)))
            bkpt = (findgen(nbkpts))*tempbkspace + startx
         endif else if keyword_set(everyn) then begin
            nbkpts = (nx / everyn) > 1
            if (nbkpts EQ 1) then xspot = [0] $
             else xspot = lindgen(nbkpts)*(nx / (nbkpts-1))
            bkpt = x[xspot]
         endif else message, 'No information for bkpts'
      endif

      bkpt = float(bkpt)

      if (min(x) LT min(bkpt,spot)) then begin
         if (NOT keyword_set(silent)) then $
          print, 'Lowest breakpoint does not cover lowest x value: changing'
         bkpt[spot] = min(x)
      endif

      if (max(x) GT max(bkpt,spot)) then begin
         if (NOT keyword_set(silent)) then $
          print, 'highest breakpoint does not cover highest x value, changing'
         bkpt[spot] = max(x)
      endif

      nshortbkpt = n_elements(bkpt)
      fullbkpt = bkpt

      if (NOT keyword_set(bkspread)) then bkspread = 1.0
      if (nshortbkpt EQ 1) then bkspace = bkspread $
       else bkspace = (bkpt[1] - bkpt[0]) * bkspread

      for i=1, nord-1 do $
       fullbkpt = [bkpt[0]-bkspace*i, fullbkpt, $
        bkpt[nshortbkpt - 1] + bkspace*i]
 
   return, fullbkpt
end 