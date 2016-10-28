
pro tdms_get_image,data=data,ifr=ifr,path=path,file=file,nx=nx,ny=ny,nfr=nfr,bug=bug,copy_tdms=copy_tdms
print,'enter getimage routine'
common cbtdmsgi, filepathstore, prop_values, METADATA
;- Define file location
;default,path,'/data/kstar/'
default,path,'F:\CXRS_2013_DATA\'
;default,file,'Images.tdms'
default,file,'CXRS_2013_9092_Record.TDMS'
default,ifr,13

filepath=path+file
filepath=file_search(filepath,/fold_case)
if n_elements(filepathstore) ne 0 then if filepath eq filepathstore then begin
   print,'skipping tdms_reader'
   goto,aa1
endif


;- Extract data structure
print,'before tdms reader' & t0=systime(1)
TDMS_reader,filepath,LEADIN,METADATA,PROP_NAMES,PROP_VALUES,DEBUG=0
print,'after tdms read, time elapsed=',systime(1)-t0
;help,LEADIN,METADATA,PROP_NAMES,PROP_VALUES



;- EXAMPLES

;- 1. Identify the groups name and print the Segments name
getgroups=0
;;__ to get groups
if getgroups eq 1 then begin
   N_METADATA = N_ELEMENTS(METADATA)
   group = bytarr(N_METADATA)
                                ;- print,string(47b) > /
   for k=0l,N_METADATA-1 do group(k) = total(byte(METADATA(k).OBJECT_PATH_STRING) eq 47b) eq 1
   group_index=where(group eq 1)
;print_list,
   groups=METADATA(group_index).OBJECT_PATH_STRING
endif


;- 2. Extract Channel properties and Data
;- channel 1 = Time Serie
;- Define the desired Group+channel
;group='TM_SCIENCE_TIR_DATA'
;channel='time_generation:1'  ;- Use the full channel name! inclusive :1

filepathstore=filepath
aa1:
if not keyword_set(bug) then begin
   nx=prop_values.(0).(1)
   ny=prop_values.(0).(2)
   nfr=prop_values.(0).(3)
endif

if ifr lt 0 then return


group='Image_'+string(ifr,format='(I0)')
channel='Pixels'
;- Search in which segment the desired Group+Channel are present
 channel_path='/'+string(39b)+group+string(39b)+'/'+string(39b)+channel+string(39b)
 channel_in_seg=(where(STREGEX(METADATA.OBJECT_PATH_STRING,channel_path) eq 0))

;stop
;- extract channel properties  OPTIONAL
;channel_props=tdms_channel_props_builder(METADATA,PROP_NAMES,PROP_VALUES,channel_in_seg)
;print,channel_path
;print,channel_props(0,*)+' = '+channel_props(1,*),format='(A)'

;stop
;- extract channel data

print,'before tdms channel datareader'
data  = tdms_channel_data_reader(filepath,METADATA,channel_in_seg,copy_tdms=copy_tdms)
print,'after tdms channel datareader'

data=reform(data,nx,ny)
; help,prop_names.(0)
;; ** Structure <d84bb8>, 5 tags, length=80, data length=80, refs=2:
;;    PROPERTY_NAMES________0
;;                    STRING    'name'
;;    PROPERTY_NAMES______________________1
;;                    STRING    'X resolution'
;;    PROPERTY_NAMES______________________2
;;                    STRING    'Y resolution'
;;    PROPERTY_NAMES______________________3
;;                    STRING    'Number of frames'
;;    PROPERTY_NAMES______________________4
;;                    STRING    'Image type'
;help,prop_values.(0)

; imgplot,reform(data,nx,ny),/cb


end



