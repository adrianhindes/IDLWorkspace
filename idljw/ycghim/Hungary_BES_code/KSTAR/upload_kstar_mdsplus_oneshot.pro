pro upload_kstar_mdsplus_oneshot, shot
  filename=dir_f_name('mds','uploaded_shots.sav')
  if file_test(filename) then begin
    restore, filename 
  endif else begin
    upload_database={shot:long(0), rel_cal:fix(0), spat_cal:fix(0), $
                     detector_temp:fix(0), detector_voltage:fix(0), $
                     description:'If shotnumber is present, the shot is uploaded to MDSPLus with additional data indicated by a 1 value at the corresponding name in the database.'}
    upload_database=replicate(upload_database,1)
    save, upload_database, filename=filename
  endelse
  
  ind=where(shot eq upload_database.shot)
  if ind[0] eq -1 then begin
    upload_database=[upload_database,upload_database[0]]
    ind=n_elements(upload_database)-1
    upload_database[ind].shot=shot
    upload_data=1
  endif else begin
    print, 'Shot has already been uploaded. RAW data will not be uploaded!'
    upload_data=0
  endelse
  
  default, datapath, '/media/DATA/APDCAM'
  bit_res=12.                   ;Resolution of the measurements
  offset=[0,0.001]              ;Offset for the measurement

                                ;The actual data can be read from
                                ;\BES_0416:FOO which equals:
                                ;\BES_0416:RAW * \BES_0416:FBITS

  mdsconnect,'172.17.100.202:8000',status=stat,/quiet
  mdsopen, 'BES', shot

  if shot lt 10000 then begin
     row=4
     column=8
  endif else begin
     row=4
     column=16
  endelse
  a=systime(/seconds)
  spat_cal=getcal_kstar_spat(shot)
  for i=1,row do begin
     for j=1,column do begin
        main_node="\BES_"+string(i,format='(i02)')+string(j,format='(i02)')
        bes_channel='BES-'+strtrim(i,2)+'-'+strtrim(j,2)
        
        if upload_data then begin
          ;DATA:RAW
          subnode=':RAW'
          get_rawsignal, shot, bes_channel, t, d ,/nocalib, /no_offset, /binary
          datacount=n_elements(d)
          daqstime=-2
  ;        if shot lt and shot gt then daqstime=0
  ;        if shot lt and shot gt then daqstime=-2
  ;        if shot lt and shot gt then daqstime=0
          perrate=t[1]-t[0]
                                  ;Offset subtraction
          n1=long(offset[0]/perrate)
          n2=long(offset[1]/perrate)
          d=d-mean(d[n1:n2])
  
          mdsput,main_node+subnode,'BUILD_SIGNAL(MAKE_WITH_UNITS($,"V"),,MAKE_DIM(MAKE_WINDOW(0,$,$),MAKE_SLOPE(MAKE_WITH_UNITS($,"s"))))', d, datacount, daqstime, perrate
          subnode=':FBITS'
          mdsput,main_node+subnode,string((2./(2.^(bit_res))))
        endif
        ;BEAM TYPE:SOURCE [BOOLEAN]
        subnode=':SOURCE'
        if shot lt 10000 and shot gt 9110 then begin
           load_config_parameter, shot, 'Optics', 'APDCAMFilter', output_struct=filter,  errormess=err
           if err eq '' then begin
              type=filter.value
              if type eq 'Deuterium' then source=0 else source=1
           endif
        endif
        if shot lt 9110 then begin
           source=0
        endif
        if shot gt 10000 then begin
           load_config_parameter, shot, 'Optics', 'APDCAMfiltertype', output_struct=filter,  errormess=err
           if err eq '' then begin
              type=filter.value
              if type eq 'Deuterium' then source=0 else source=1
           endif
        endif
        mdsput,main_node+subnode,i2str(source)
        
        ;RELATIVE CALIBRATION:CAL [NULL] ;TO BE IMPLEMENTED
        subnode=':CAL'
        mdsput,main_node+subnode,i2str(1.0)
        upload_database[ind].rel_cal=0
        if max(spat_cal) ne -1 then begin
          subnode=':RPOS'
          ;RADIAL POSITION:RPOS [MM]
          mdsput,main_node+subnode,i2str(round(spat_cord[row-1,column-1,0]))
          
          ;VERICAL POSITION:VPOS [MM]
          subnode=':VPOS'
          mdsput,main_node+subnode,i2str(-1)
          upload_database[ind].spat_cal=1
        endif else begin
          ;RADIAL POSITION:RPOS [MM] ;TO BE IMPLEMENTED
          subnode=':RPOS'
          
          mdsput,main_node+subnode,i2str(-1)
  
          ;VERICAL POSITION:VPOS [MM] ;TO BE IMPLEMENTED
          subnode=':VPOS'
          mdsput,main_node+subnode,i2str(-1)
          upload_database[ind].spat_cal=0

        endelse

        ;RADIAL STEPPERMOTOR POSITION:RMIR [STEP]
        subnode=':RMIR'
        if shot gt 10000 then begin
           load_config_parameter, shot, 'Optics', 'RadialMirrorPosition', output_struct=res,  errormess=err
           if err eq '' then begin
              radmirpos=res.value
           endif
        endif
        mdsput,main_node+subnode,radmirpos
        
        ;VERTICAL STEPPERMOTOR POSITION:VMIR [STEP]
        subnode=':VMIR'
        if shot gt 10000 then begin
           load_config_parameter, shot, 'Optics', 'VerticalMirrorposition', output_struct=res,  errormess=err
           if err eq '' then begin
              vertmirpos=res.value
           endif
        endif
        mdsput,main_node+subnode,i2str(vertmirpos)

        ;DETECTOR VOLTAGES:DVOL1,:DVOL2 [V]
        subnode1=':DVOL1'
        subnode2=':DVOL2'
        if shot lt 11000 then begin ;This value is not recorded in the config file
           voltage=415.
           upload_database[ind].detector_voltage=0
        endif else begin
           
        endelse
        mdsput,main_node+subnode1,i2str(voltage)
        mdsput,main_node+subnode2,i2str(voltage)
        
        ;DETECTOR TEMPERATURES:DTEM1,DTEM2 [C]
        subnode1=':DTEM1'
        subnode2=':DTEM2'
        if shot lt 11000 then begin ;This value is not recorded in the config file
           dtemp1=-1.
           dtemp2=-1.
           upload_database[ind].detector_temp=0
        endif else begin
        endelse
        mdsput,main_node+subnode1,i2str(dtemp1)
        mdsput,main_node+subnode2,i2str(dtemp2)

        ;FILTER TEMPERATURE:FTEM [C]
        subnode=':FTEM'
        if shot gt 10520 then begin ;Lithium and deuterium temperatures were reversed until this shot
           if source eq 0 then begin
              load_config_parameter, shot, 'Optics', 'APDDeuteriumfiltertemperature', output_struct=res,  errormess=err
              if err eq '' then begin
                 filt_temp=res.value
              endif
           endif else begin
              load_config_parameter, shot, 'Optics', 'APDLithiumfiltertemperature', output_struct=res,  errormess=err
              if err eq '' then begin
                 filt_temp=res.value
              endif
           endelse
        endif
        
        if shot lt 10520 and shot gt 10335 then begin ; They were interchanged between these shots
           if source eq 0 then begin
              load_config_parameter, shot, 'Optics', 'APDLithiumfiltertemperature', output_struct=res,  errormess=err
              if err eq '' then begin
                 filt_temp=res.value
              endif
           endif else begin
              load_config_parameter, shot, 'Optics', 'APDDeuteriumfiltertemperature', output_struct=res,  errormess=err
              if err eq '' then begin
                 filt_temp=res.value
              endif
           endelse
        endif
        
        if shot lt 10335 and shot gt 10109 then begin ;Due to software error no Deuterium filter temperature is in the config file
           if source eq 0 then begin
              load_config_parameter, shot, 'Optics', 'APDLithiumfiltertemperature', output_struct=res,  errormess=err
              if err eq '' then begin
                 filt_temp=res.value
              endif
           endif else begin
              filt_temp=-1
           endelse
        endif
        
        if shot lt 10000 then begin
           filt_temp=-1
        endif
        mdsput,main_node+subnode,i2str(filt_temp)
     endfor
  endfor
  
  mdstcl,'close'
  mdsdisconnect
  print, string(systime(/seconds)-a)+'s was to upload the shot!'

end
