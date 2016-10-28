;---------------------------------------------------
pro mdsplus_subtree_put, path, s,  status = status, quiet = quiet
;+
; overwrite a subtree with specified structure
;-

   mdssetdefault, path, /quiet, status = status
   mdsplus_error,  status,  error = errmsg, quiet = quiet
   if not status then return

tn = tag_names(s)
for i = 0, n_elements(tn)-1 do begin
   tag = tn[i]
   node =  ':'+tn[i]
   node = tree_dir(filt = node)
   if node[0] ne '' then begin
      mdsput, node, '$', s.(i),  status = status,  quiet = quiet
      if status then begin
         if not keyword_set(quiet) then $
          print, strtrim(s.(i), 2)+' ==> '+node
      end else mdsplus_error, status, quiet = quiet,  error = errmsg
   end
end

end

