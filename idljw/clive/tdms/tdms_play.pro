pro print_list, x
print, x
end


default,path,'/data/kstar/'
default,file,'Images.tdms'
default,ifr,13

filepath=path+file

;- Extract data structure
TDMS_reader,filepath,LEADIN,METADATA,PROP_NAMES,PROP_VALUES,DEBUG=0

help,LEADIN,METADATA,PROP_NAMES,PROP_VALUES

nx=prop_values.(0).(1)
ny=prop_values.(0).(2)
nfr=prop_values.(0).(3)


;- EXAMPLES

;- 1. Identify the groups name and print the Segments name
getgroups=1
;;__ to get groups
if getgroups eq 1 then begin
   N_METADATA = N_ELEMENTS(METADATA)
   group = bytarr(N_METADATA)
                                ;- print,string(47b) > /
   for k=0l,N_METADATA-1 do group(k) = total(byte(METADATA(k).OBJECT_PATH_STRING) eq 47b) eq 1
   group_index=where(group eq 1)

   groups=METADATA(group_index).OBJECT_PATH_STRING
   print_list,groups
endif


;- 2. Extract Channel properties and Data
;- channel 1 = Time Serie
;- Define the desired Group+channel
;group='TM_SCIENCE_TIR_DATA'
;channel='time_generation:1'  ;- Use the full channel name! inclusive :1

group='Image_'+string(ifr,format='(I0)')
;channel='Timestamps'
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
data  = tdms_channel_data_reader(filepath,METADATA,channel_in_seg)

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



