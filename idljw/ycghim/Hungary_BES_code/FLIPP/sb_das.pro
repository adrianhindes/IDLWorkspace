; Martin Hron, March 2000, function for reading data from all channels of sb devices
; without using japedas function (= withhout opening 16x the spawn process)
;
; data are supposed to be previously decompressed from database to \RSI\TEMP\
; -> the result is in an array fltarr(17,n_elements(channel)) that is named "data"
; prvky ve sloupcich 1 .. 16 odpovidaji datum z kanalu 1 .. 16
; prvky data(0,0) = pocet kanalu    ;  data(0,1) = pocet vzorku / kanal     ; data(0,2) = vzorkovani [mus]
;
; -------------------------------------------------------------------------
; ACKNOWLEDGEMENT:
; for reading of the data from .dat files is used a core of the
; Vladimir Weinzettl's procedure DAStoWAF.pro
; -------------------------------------------------------------------------

function sbDAS,sb
  openr, sb_unit, getenv('DAS_TEMP')+sb+'.dat',/get_lun
  datafile = indgen(8192)*0
  data = indgen(1) & j=0
  readu, sb_unit, data & datafile(0)=data
  readu, sb_unit, data & datafile(1)=data
  readu, sb_unit, data & datafile(2)=data
  for j=3,datafile(0)*datafile(1)+2 do begin
    readu, sb_unit, data
    datafile(j)=data
  endfor
  close,sb_unit   &   free_lun,sb_unit

  channels = datafile(0)
  print,"No. of channels in ",sb,channels
  samples = datafile(1)
  print,"No. of samples in ",sb,samples
  rate = datafile(2)
  print,"sampling rate of ",sb,rate

  data = fltarr(17,samples)
  data(0,0) = datafile(0)          ; No of sb channels
  data(0,1) = datafile(1)          ; No of sb samples
  data(0,2) = datafile(2)          ; sb sampl. rate

  for channelindex=1,16 do begin
    point=samples*(channelindex-1)+3
    data(channelindex,*)=datafile(point:point+samples-1)
  endfor

  return,data
end