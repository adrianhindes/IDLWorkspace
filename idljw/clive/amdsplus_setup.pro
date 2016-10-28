function mdsplus_setup,server=server, debug=debug

  forward_function mdsisclient

  ;; test for definition of D3D_PATH ... if defined then native
  ;; access, otherwise, client/server.  
  ;; &&& NOTE THAT THIS IS SPECIFIC to DIII-D!!!! &&&
  
  test = getenv('d3d_path')  ;&& KLUDGE - drive from application!

  if ((test eq '') or (n_elements(server) gt 0)) then begin

    if (keyword_set(debug)) then message,/info,'not using native mode'

    ;; client/server mode.  Is client connected to server?

    if (mdsIsClient()) then begin

      if (keyword_set(debug)) then message,/info,'already connected to a server'

      status = 3

    endif else begin

      if (keyword_set(debug)) then message,/info,'not connected to server'

      if (n_elements(server) eq 0) then server='ATLAS.GAT.COM'
      if (strcompress(server,/remove_all) ne '') then begin 

        if (keyword_set(debug)) then message,/info,'connecting to '+server

        mdsconnect,server,/quiet,status=status
      endif else status = 5 ; Server not blank

    endelse 

  endif else status = 1 ; MDSplus native access ok

  return,status

end
