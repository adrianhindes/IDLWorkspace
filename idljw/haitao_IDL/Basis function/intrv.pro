function intrv, x, fullbkpt, nbkptord 
    
      nx = n_elements(x)
      nbkpt= n_elements(fullbkpt)
      n = (nbkpt - nbkptord)

      indx = lonarr(nx)

      ileft = nbkptord - 1L
      for i=0L, nx-1 do begin
        while (x[i] GT fullbkpt[ileft+1] AND ileft LT n-1 ) do $
            ileft = ileft + 1L
        indx[i] = ileft
      endfor
      indxold = indx


     ; here's another sneaky attempt, which takes way too long for
     ; superflat...

     ; fullist = [fullbkpt, x]
     ; hmm = sort(fullist)
     ; back = lonarr(n_elements(hmm))
     ; back[hmm] = lindgen(n_elements(hmm))
     ; for i=0,n-1 do indx[back[i]-i:nx-1] = i  

      
     return, indx
end 