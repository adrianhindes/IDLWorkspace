;---------------------------------------------------
function camac_unit, node, quiet = quiet,  status = status,  valid = valid
;+
;
; Returns the camac module associated with a given signal node name
; Assumes the database is open
;
;-

   units = ''
   valid = 0
   for i = 0,  n_elements(node)-1 do begin
      nd = node[i]
      cmc = mdsvalue('decompile(`getnci('+nd+',"RECORD"))',$
                     status=status, /quiet)
      if not status then begin
         if not keyword_Set(quiet) then print, 'Node name:', nd
         mdsplus_error, status, quiet = quiet,  error = errmsg
      end else begin
         if cmc ne '<no-node>' then begin
            cmcunit = mdsvalue('getnci($,"fullpath")', cmc)
            if units[0] eq '' then begin
               units = cmcunit 
               valid = i
            end else begin
               units = [units, cmcunit]
               valid = [valid, i]
            end
         end
      end
   end

return, units
  
end
