pro fill_calib_database,user=user,w_cal_file=w_cal_file
  ;*//////////////////////////////////////////////////////////
  ;*                  fill_calib_database
  ;*//////////////////////////////////////////////////////////
  ;*This procedure fills up the calibration database with the EDICAM
  ;*data from different shots give by the user. User friendly interface
  ;*is applied for the algorythm. 
  ;*
  ;*INPUT:
  ;*      user: the user name in string
  ;*      w_cal_file: make tne calibration with apd_calib
  ;//////////////////////////////////////////////////////////
  default,user,'lampee'
  default,w_cal_file,1
  fname=dir_f_name('cal','calib_database.sav')
  if user eq 'lampee' then cd, 'D:\KFKI\Measurements\KSTAR\Measurement'
  if not (file_test(fname)) then begin
      dbtrial={shot:long(0),fourcord:intarr(4,2),direction:long(0)}
      database=replicate(dbtrial,1)
      database[0].shot=6076
      database[0].fourcord[0,*]=[500,541] ;top
      database[0].fourcord[1,*]=[924,585] ;bottom
      database[0].fourcord[2,*]=[347,738] ;left
      database[0].fourcord[3,*]=[739,726] ;right
      database[0].direction=0
      save, database, filename=fname
  endif
  restore, fname
  save,database,filename=fname+'.bak'
  bl=''
  fourcord=intarr(4,2)
  shot1=long(0)
  shot2=long(0)
  print, 'Please write in the first and last shot number where the edicam image'
  print, 'is valid. Please read the four necessary coordinates according to'
  print, "Yong Un's riport."
  print, 'Shot interval (0), or different shots (1)?'
  read, ' ', si
  if si eq 0 then begin
    print, 'From (#shot): '
    while (bl ne 'n') do begin
      read,'From (#shot): ',shot1
      read,'To (#shot): ',shot2 ;if only one shot, remains the same
      n=n_elements(database)
      m=shot2-shot1+1
      dbtemp=replicate(database[0],n+m)
      dbtemp[0:n-1]=database
print, 'Read data from an older shot? (0:No,1:Yes)'
      a=0
      read,'',a
      while (a ne 0 and a ne 1) do read, 'Wrong input! Read data from an older shot? (0:No,1:Yes)',a
      if a eq 0 then begin
        read,'Top corner x [pix]: ',a
        fourcord[0,0]=a
        read,'Top corner y [pix]: ',a
        fourcord[0,1]=a
        read,'Bottom corner x [pix]: ',a
        fourcord[1,0]=a
        read,'Bottom corner y [pix]: ',a
        fourcord[1,1]=a
        read,'Left corner x [pix]: ',a
        fourcord[2,0]=a
        read,'Left corner y [pix]: ',a
        fourcord[2,1]=a
        read,'Right corner x [pix]: ',a
        fourcord[3,0]=a
        read,'Right corner y [pix]: ',a
        fourcord[3,1]=a
        read,'Direction 0:edge,1:core.mid,2:core.low ',direction
      endif else begin
        read,'Older shot number: ',oshot
        ind=where(database.shot eq oshot)
        fourcord=database[ind].fourcord
        direction=database[ind].direction
      endelse
      for i=0,m-1 do begin
        dbtemp[n+i].shot=shot1+i
        dbtemp[n+i].fourcord=fourcord
        dbtemp[n+i].direction=direction
      endfor
      database=dbtemp
      read,'Another? (y/n) ',bl
      while (bl ne 'y' and bl ne 'n') do begin
        read,'Wrong input, please write y or n. Another? (y/n) ',bl
        print, bl
      endwhile
    endwhile
  endif else begin
    print, 'Please write the shot numbers in, when finished, please type -1'
    while (bl ne 'n') do begin
      shot=intarr(1)
      i=0
      while (shot1 ne -1) do begin
        print, 'Shot '+strtrim(i,2)+':'
        read,'',a
        if (a eq -1) then begin
          temp=shot
          shot=intarr(i)
          shot=temp[0:i-1]
          break
        endif
        shot[i]=a
        temp=shot
        i=i+1
        shot=intarr(i+1)
        shot[0:i-1]=temp[*]
      endwhile
      print, shot
      stop
      n=n_elements(database)
      m=n_elements(shot)
      dbtemp=replicate(database[0],n+m)
      dbtemp[0:n-1]=database
      print, 'Read data from an older shot? (0:No,1:Yes)'
      a=0
      read,'',a
      while (a ne 0 and a ne 1) do read, 'Wrong input! Read data from an older shot? (0:No,1:Yes)',a
      if a eq 0 then begin
        read,'Top corner x [pix]: ',a
        fourcord[0,0]=a
        read,'Top corner y [pix]: ',a
        fourcord[0,1]=a
        read,'Bottom corner x [pix]: ',a
        fourcord[1,0]=a
        read,'Bottom corner y [pix]: ',a
        fourcord[1,1]=a
        read,'Left corner x [pix]: ',a
        fourcord[2,0]=a
        read,'Left corner y [pix]: ',a
        fourcord[2,1]=a
        read,'Right corner x [pix]: ',a
        fourcord[3,0]=a
        read,'Right corner y [pix]: ',a
        fourcord[3,1]=a
        read,'Direction 0:edge,1:core.mid,2:core.low ',direction
      endif else begin
        read,'Older shot number: ',oshot
        ind=where(database.shot eq oshot)
        fourcord=database[ind].fourcord
        direction=database[ind].direction
      endelse
      for i=0,m-1 do begin
        dbtemp[n+i].shot=shot[i]
        dbtemp[n+i].fourcord=fourcord
        dbtemp[n+i].direction=direction
      endfor
      database=dbtemp
      read,'Another set of shots? (y/n) ',bl
      while (bl ne 'y' and bl ne 'n') do begin
        read,'Wrong input, please write y or n. Another? (y/n) ',bl
        print, bl
      endwhile
    endwhile
  endelse
  save, database, filename=fname
  print, 'Database saved. Done!'
  if keyword_set(w_cal_file) then begin
    print, 'Doing the calibration!'
    for i=0,n_elements(database)-1 do begin
      calibrate_kstar_spatial, database[i].shot
    endfor
    print, 'Done!'
  endif

end
