;-------------------------------------------------------------
function mdsplus_subtree,  path,  usage=usage, quiet = quiet, recurse = recurse
;+
; Given a path in the tree, this routine reads all of the 
; text and numeric subnodes
; creates a structure with the same name tags and fills it with the
; node information.  
; It will normally ignore child nodes, but can act recursively 
; to produce structures of structures if RECURSE keyword is set
;
;-
   default, usage, ['text','numeric']
   if n_params() ne 1 then stop, 'Please supply default path'
   mdssetdefault, path, /quiet, status = status
   mdsplus_error,  status,  error = errmsg, quiet = quiet
   if not status then  return, {error: errmsg}

  for i=0, n_elements(usage)-1 do begin
     new_nodes = tree_dir(/minpath,usage=usage(i))
     if new_nodes[0] ne '' then $
      if n_elements(_nodes) eq 0 then _nodes = new_nodes else $
      _nodes = [_nodes,new_nodes]
  end

   mdssetdefault, path, quiet = quiet
   for i = 0, n_elements(_nodes)-1 do begin 
      frag = strsplit(_nodes[i],'.:',/extract)
      if n_elements(frag) gt 1 then begin
	if keyword_Set(recurse) then begin
;	  next_subtree = mdsplus_subtree(path+...) 
;          if n_elements(subtree_struct) eq 0 then $
;           subtree_struct = else $
;           subtree_struct =
	end
      end else begin      
	val =  mdsvalue(_nodes(i), status = status, /quiet)
        if status then begin
          if n_elements(subtree_struct) eq 0 then $
           subtree_struct = create_struct(_nodes(i), val) else $
           subtree_struct = create_struct(subtree_struct,  _nodes(i), val)
        end else mdsplus_error, status, quiet = quiet,  error = errmsg
     end
   end

   if n_elements(subtree_struct) eq 0 then return, {error: errmsg}
   return,  subtree_struct

end

