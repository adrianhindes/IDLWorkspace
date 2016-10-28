
function getcal_kstar_spat, shot, area=area, detcorn=detcorn,$
         transpose=transpose, xyz=xyz, errormess=error, prompt=prompt

  ;***************************************************************
  ;*                read_kstar_spatial_calib                     *
  ;***************************************************************
  ;Read the calibration database from the database file and      *
  ;return the area or the spatial coordinates for each detector  *
  ;The detector names are BES-n-m the return value is a matrix   *
  ;with [8,4,x] dimension. The notation is the following:        *
  ;[0,0] -> BES-1-1; [0,3] -> BES-4-1                            *
  ;[7,0] -> BES-1-8; [7,3] -> BES-4-8                            *
  ;***************************************************************
  ;INPUT:                                                        *
  ;       shot: shot number                                      *
  ;       /area: the function returns the detected area(OPTIONAL)*
  ;       /detcorn: the function returns the detector corners    *
  ;                (OPTIONAL) [8,4,4,*] variables in cylindrical *
  ;       trans: [8,4,*] variables are returned instead of       *
  ;              [4,8,*] variables                               *
  ;RETURN:                                                       *
  ;       the function returns the detector position (R,Z,phi)   *
  ;       or the area (square mm)                                *
  ;       (depending on /area keyword set) for each detector     *
  ;       pixel                                                  *
  ;***************************************************************


error = ''

default,cal_path,local_default('cal_path',/silent)
default,prompt,0
if (cal_path eq '') then begin
  res = routine_info('getcal_kstar_spat',/source,/func)
  cal_path = strmid(res[0].path,0,strlen(res[0].path)-strlen(res[0].name)-5)
  cal_path = dir_f_name(cal_path,'cal')
endif

restore, dir_f_name(cal_path, 'calib_database.sav')

ind=where(database.shot eq shot)

  if ind[0] eq -1 then begin
    if keyword_set(prompt) then begin
      print, 'Shot '+strtrim(shot,2)+' is not in the spatial calibration database!'
      bl=''
      print, 'De you want to put it into the database?(Y/N)',bl
      read, '',bl
      if bl eq 'y' then begin
        fill_calib_database
        restore, fname
        ind=where(database.shot eq shot)
        if ind[0] eq -1 then begin
          print, 'Error during input in fill_calib_database, please revise your inputs. Now returning...'
          return, -1
        endif
      endif else begin
        error=1
        return, -1
      endelse
    endif else begin
      error=1
      return, -1
    endelse
  endif

  position=database[ind].position
  area_m=database[ind].area
  corner=database[ind].det_corner_pos
  if keyword_set(xyz) then begin
    for i=0,7 do begin
      for j=0,3 do begin
        position[i,j,*]=xyztocyl(position[i,j,*], /inv)
        for k=0,3 do begin
          corner[i,j,k,*]=xyztocyl(corner[i,j,k,*], /inv)
        endfor
      endfor
    endfor    
  endif
  
  if not (keyword_set(transpose)) then begin
    position = transpose(position,[1,0,2])
    area_m = transpose(area_m)
    corner = transpose(corner,[1,0,2,3])
  endif
  if (keyword_set(area) and keyword_set(detcorn)) then begin
    print, 'Only one of /area or /corner should be set. Returning...'
    return, -1
  endif
  if (keyword_set(area)) then return, area_m
  if (keyword_set(detcorn)) then return, corner
  if ((shot lt 7277) and (shot gt 7000)) then begin
    temppos=position

    temppos[0,0,*]=position[3,7,*]
    temppos[0,1,*]=position[3,3,*]
    temppos[0,2,*]=position[2,7,*]
    temppos[0,3,*]=position[2,3,*]
    temppos[0,4,*]=position[1,7,*]
    temppos[0,5,*]=position[1,3,*]
    temppos[0,6,*]=position[0,7,*]
    temppos[0,7,*]=position[0,3,*]
    
    temppos[1,0,*]=position[3,6,*]
    temppos[1,1,*]=position[3,2,*]
    temppos[1,2,*]=position[2,6,*]
    temppos[1,3,*]=position[2,2,*]
    temppos[1,4,*]=position[1,6,*]
    temppos[1,5,*]=position[1,2,*]
    temppos[1,6,*]=position[0,6,*]
    temppos[1,7,*]=position[0,2,*]
    
    temppos[2,0,*]=position[3,5,*]
    temppos[2,1,*]=position[3,1,*]
    temppos[2,2,*]=position[2,5,*]
    temppos[2,3,*]=position[2,1,*]
    temppos[2,4,*]=position[1,5,*]
    temppos[2,5,*]=position[1,1,*]
    temppos[2,6,*]=position[0,5,*]
    temppos[2,7,*]=position[0,1,*]
        
    temppos[3,0,*]=position[3,4,*]
    temppos[3,1,*]=position[3,0,*]
    temppos[3,2,*]=position[2,4,*]
    temppos[3,3,*]=position[2,0,*]
    temppos[3,4,*]=position[1,4,*]
    temppos[3,5,*]=position[1,0,*]
    temppos[3,6,*]=position[0,4,*]
    temppos[3,7,*]=position[0,0,*]
    
    position=temppos
  endif
  return, position
end