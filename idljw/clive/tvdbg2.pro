cd ,'tree_view_2012'
print,'See notes in tree_view_port.txt'

.r fixups
if getenv("MDS_DATA_PATHS") eq '' then begin&setenv,"MDS_DATA_PATHS=KSTAR"&print,'set mdsdatapaths to kstar'&end;setenv,"MDS_DATA_PATHS=pulsed_arc,h1data,main,pulsed_arc,ech,daq,oriel_260i"
;if getenv("TREE_VIEW_EXTRA") ne '' then begin
;.r tree_view_extra.pro
;endif
if getenv("MDSIP_SERVER") ne '' then begin&mdsconnect, getenv("MDSIP_SERVER"), port=8005&print,'connected to ',getenv('MDSIP_SERVER'),'port 8005'&end else begin
;   mdsopen,'h1data',0,status=local_data
;   if (local_data and 1) eq 0 then mdsconnect,'localhost'

tree_view
