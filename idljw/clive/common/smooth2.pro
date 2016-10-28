function smooth2, arrayd, n1, n2,  edge_truncate = edge_truncate
array=arrayd
forward_function smooth2
sz = size(array)
if sz(0) eq 2 then begin

   if n_params() eq 1 then return, array
   if n_params() eq 2 then begin
      if n1 le 2 then return, array
      return, reform(smooth(reform(array, n_elements(array)), n1,$
	edge_truncate = edge_truncate), sz(1), sz(2))
   end
   if n1 le 2 then begin
      if n2 le 2 then return, array
      for j = 0L, sz(1)-1L do $
       array(j, *) = temporary(smooth(array(j, *), n2, $
                                      edge_truncate = edge_truncate))
      return,  array
   end else begin
      for i = 0L, sz(2)-1L do $
       array(*, i) = temporary(smooth(array(*, i), n1, $
                                      edge_truncate = edge_truncate))
      return,  smooth2(array, 1, n2, edge_truncate = edge_truncate)
   end
   

end else return,  array

end
