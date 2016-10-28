pro fix_timing_2014,shot,ext_trigger=ext_trigger,trigger=trigger,errormess=e

; Corrects the timing information in the 2014 BES measurement config file

default,e,''
default,ext_trigger,-2.
default,trigger,0

s=create_struct('name','ExternalTriggerTime','Type','float','value',ext_trigger,'unit','s','comment','Trigger time relative to the plasma start')
modify_shot_config,shot,section='ADCSettings',Element=s,error=e,/overwrite
if (e ne '') then return

s=create_struct('name','Trigger','Type','float','value',trigger,'unit','s','comment','Trigger: <0: manual,otherwise external with this delay')
modify_shot_config,shot,section='ADCSettings',Element=s,error=e,/overwrite
if (e ne '') then return

end


