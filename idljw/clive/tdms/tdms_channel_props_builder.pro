function tdms_channel_props_builder,METADATA,PROP_NAMES,PROP_VALUES,channel_in_seg

channel_properties = ['DUMMYSTRINGASATEST','DUMMYSTRINGASATEST']

n_channel_in_seg = N_ELEMENTS(channel_in_seg)

for ll=long64(0),n_channel_in_seg-1 do begin ;-START for on different segments
;if (METADATA(channel_in_seg(ll)).N_PROPERTIES ne 0) then begin ;- START protect against no props

tmp_prop_names=PROP_NAMES.(METADATA(channel_in_seg(ll)).SEGMENT_ID).(METADATA(channel_in_seg(ll)).CHANNEL_ID)
tmp_prop_values=PROP_VALUES.(METADATA(channel_in_seg(ll)).SEGMENT_ID).(METADATA(channel_in_seg(ll)).CHANNEL_ID)

 ;- START protect against no props = 1 prop and it's fake!
if NOT((N_TAGS(tmp_prop_names) eq 1 ) AND (strmatch(tmp_prop_names.(0),'FAKE_NOT_SET') eq 1)) then begin

  for kk=long64(0),METADATA(channel_in_seg(ll)).N_PROPERTIES-1 do begin ;-START for on all the PROPERTIES
        tmp_NAMES=tmp_prop_names.(kk) 
        tmp_VALUE=tmp_prop_values.(kk)
        tmp_NAMES_match=strmatch(channel_properties(0,*),tmp_NAMES)
        n_tmp_NAMES_match=total(tmp_NAMES_match)
        case (n_tmp_NAMES_match) of
          0: channel_properties = [[channel_properties],[tmp_NAMES,tmp_VALUE]] ;- the current proerties doesn't exist: add
          1: channel_properties(1,where(tmp_NAMES_match)) = tmp_VALUE ;- the current proerties exist: update prop value
          else: 
        endcase
  endfor ;-END for on different segments
  
endif ;- END protect against no props

endfor ;-END for on all the PROPERTIES
  
channel_properties = channel_properties[*,1:*] ;- erase empty values at top

return,channel_properties

end