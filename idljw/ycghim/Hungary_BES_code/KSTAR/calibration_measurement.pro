pro adjust_stepmotor, motor, position
                                ;Motor: 1:Vertical 2: radial, 3: apd rotation
  spawn,'adj_stepmotor '+strtrim(motor,2)+' '+strtrim(position,2)
  while 1 do begin
     spawn, 'read_stepmotor',pos
     act_pos=long(strmid(pos[motor-1],6,5))
     if long(act_pos) eq long(position) then begin
        case (motor) of
           1: str='Vertical mirror'
           2: str='Radial mirror'
           3: str='APD rotation'
        endcase
        print,str+' position set to '+i2str(position)+ '.'
        break
     endif   
     wait,2
  endwhile
end

pro calibration_measurement
  n_rad=18.
  n_vert=10.
  n_rot=2.
  
  max_rad=90000.
  max_vert=150000.

  rad_step=max_rad/n_rad
  vert_step=max_vert/n_vert

  rad_pos=indgen(n_rad)*rad_step
  vert_pos=indgen(n_vert)*vert_step
  apd_rot=[500,19000]
  image=dblarr(1312,1082)

  data={radial_position:long(0), vertical_position:long(0), apd_rotation:long(0), image:lonarr(1312,1082)}
  data=replicate(data,n_vert,n_rad,n_rot)

  spawn, 'read_IO', io
  io=long(io[1:8])
  spawn, 'write_IO 7 1'
  spawn, 'write_IO 3 0'
  spawn, 'write_IO 4 0'
  spawn, 'write_IO 5 0'
  spawn, 'write_IO 6 0'

  adjust_stepmotor, 1, 0
  adjust_stepmotor, 2, 0
  adjust_stepmotor, 3, 0
  wait, 1
  
    shot=0


           
  default,data_path,'/home/bes/Data/calibration/'
  clock_divider = 10000.
  frametime_ms_calib=200
  meas_time_calib=0.4
  exptime_calib=100
  cccam_path='/home/bes/measurement_control/CMOS_control'
  frametime_calib = long(float(frametime_ms_calib)*10000/clock_divider) ; in clock units
  
           camera_chopper=1
  for k=0,1 do begin
     adjust_stepmotor, 3, apd_rot[k]
     for i=0,n_elements(vert_pos)-1 do begin
        adjust_stepmotor, 1, vert_pos[i]
        for j=0,n_elements(rad_pos)-1 do begin
           adjust_stepmotor, 2, rad_pos[j]
           print, 'Vertical position: '+ strtrim(vert_pos[i],2)
           print, 'Radial position: '+ strtrim(rad_pos[j],2)
           print, 'APDCAM position: '+ strtrim(apd_rot[k],2)

           start_cmos,shot,error_start=error,cam_error=camerr,$
                      exptime=exptime_calib,frametime=frametime_calib,meas_time=meas_time_calib,datapath=data_path,$
                      trigger=0,chopper_start_time=0,chopper_period_time=0,$
                      camera_chopper=1,series=s,chopper_start_clock=0,$
                      chopper_period_clock=0, meas_error=meas_error,$
                      error_camera=error_camera,pipes=pipes,clock_divider=clock_divider,$
                      cccam_path=cccam_path
           wait, 2
           camserv_status,pipes,1,status=stat,frame_n=frame_n,error=error,camera_error=camera_error
           if defined(stat) then begin
              if not (stat eq "Meas OK") then camserv_halt,pipes
           endif
           meas_error = 0
           if camera_error eq '' then begin
              finish_cmos,shot,error_finish=error,cam_error=camerr,$
                          exptime=exptime_calib,frametime=frametime_calib,meas_time=meas_time_calib,datapath=data_path,$
                          trigger=0,chopper_start_time=0,chopper_period_time=0,$
                          camera_chopper=1,series=series, chopper_start_clock=0,$
                          chopper_period_clock=0, meas_error=meas_error,$
                          error_camera=error_camera,pipes=pipes,clock_divider=clock_divider,$
                          frame_n=frame_n, /calibration, /nosave, meas_data=meas
           endif
           
           
           data[i,j,k].vertical_position=vert_pos[i]
           data[i,j,k].radial_position=rad_pos[j]
           data[i,j,k].apd_rotation=apd_rot[k]
           data[i,j,k].image=reform(meas[1,*,*])
           save, data,vert_pos,rad_pos,apd_rot, filename=data_path+'temp.calibration.sav'
        endfor
        adjust_stepmotor, 1, 0
     endfor
  endfor
  save, data,vert_pos,rad_pos,apd_rot, filename=datapath+'final.calibration.sav'

for i=0,7 do spawn, 'write_IO '+i2str(i) + ' '+i2str(io[i])
end
