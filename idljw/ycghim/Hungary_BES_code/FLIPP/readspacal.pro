FUNCTION readspacal,channel=channel,device=device,zlbo=zlbo

;****** Function to determine the position of a given channel in 
;****** lbo-coord. (zlbo) or to get the channel that is next to a given
;****** position along the beam (zlbo)
;****** channel: PM-channel 1-11 or Camera-Pixel 1-128
;****** device: 'pm' or 'cam'
;****** zlbo: position in LBO-coord. (along the beam) with 0 at the inner side
;****** of the outer wall and zlbo rising inwards to the plasma center
;****** only one of the arguments 'channel' and 'zlbo' may be set,
;****** the other one is the output. ******zlbo is in mm!!!!******
;****** The ouput is stored in the variable 'output'. If an error occured,
;****** output is set to -1

output=-2


;****** PMs *************************************************
;****** array with index=channel-1, value=zlbo(channel) in mm
pm_zlbo=140.+[5.5,11.75,19.5,26.25,33.,40.5,47.5,55.0,63.0,72.0,78.0]

;****** array with first column: pixel number (=channel)
;****** second column: Position in zlbo coord.
cam_zlbo=[[21,74.75],[48,55.],[90,25.5],[100,19.25]]
cam_zlbo[1,*]=cam_zlbo[1,*]+145.

IF (defined(channel) EQ 0) AND (defined(zlbo) EQ 0) THEN BEGIN
  print,'ERROR: One of the parameters "channel" and "lbo" is needed!!!'
  output=-1
ENDIF

IF (defined(channel) EQ 1) AND (defined(zlbo) EQ 1) THEN BEGIN
  print,'ERROR: Only one of the keywords "channel" and "zlbo" is allowed!!!'
  output=-1
ENDIF

IF (defined(device) EQ 0) THEN BEGIN
    print,'ERROR: A valid device should be selected.'
    print,'  Possible devices are the strings "pm" and "cam".'
    output=-1
ENDIF ELSE BEGIN

  CASE device OF
  'pm': BEGIN
          IF (defined(channel) EQ 1) THEN BEGIN
            aa=where ([1,2,3,4,5,6,7,8,9,10,11] EQ channel,count)
            IF count EQ 0 THEN BEGIN
              print,'Error, no valid channel has been chosen!!!'
              output=-1
            ENDIF ELSE BEGIN
            output=pm_zlbo[channel-1]
            ENDELSE
          ENDIF ELSE BEGIN
            IF (defined(zlbo) EQ 1) THEN BEGIN
              dist=min(abs(pm_zlbo-zlbo),min_index)
              print,'The next PM-channel to z_LBO = ',zlbo,' mm'
              print,'  is channel number ',min_index+1,'.'
              print,'  The distance is ',dist,' mm.'
              output=min_index+1
            ENDIF
          ENDELSE
        END

  'cam':BEGIN
          IF (defined(channel) EQ 1) THEN BEGIN
            coeff=poly_fit(cam_zlbo[0,*],cam_zlbo[1,*],2)
            zlbo=coeff[0]+coeff[1]*channel+coeff[2]*channel^2  
          output=zlbo
          ENDIF ELSE BEGIN
            IF (defined(zlbo)EQ 1) THEN BEGIN
              coeff=poly_fit(cam_zlbo[1,*],cam_zlbo[0,*],2)
              channel=coeff[0]+coeff[1]*zlbo+coeff[2]*zlbo^2
              output=channel
            ENDIF
          ENDELSE
        END

  ELSE:BEGIN
         print,'ERROR: A valid device should be selected.'
         print,'  Possible devices are the strings "pm" and "cam".'
         output=-1
       END

  ENDCASE
ENDELSE
return,output
END ;readspacal