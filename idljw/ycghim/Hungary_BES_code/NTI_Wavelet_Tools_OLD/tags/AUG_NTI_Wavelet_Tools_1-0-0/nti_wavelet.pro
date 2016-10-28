;==========================================================================================

;NTI_WAVELET.PRO

;==========================================================================================
;-- NTI_WAVELET.PRO is a part of MTR environment
;-- This program runs, when NTI_WAVELET is called from the main menu of MTR
;-- All variable, which MTR read is stored in state variable
;==========================================================================================

pro nti_wavelet, state, event

;Create mtr_state variable, because I don't want to return any changes to Marc
mtr_state=state

;Preapre data:
  mtr_prepare_data, mtr_state


;Creating data_block for NTI WAVELET TOOLS (included all nescessarry information for modenumber calculations)
;------------------------------------------------------------------------------------------------------------
;Expeiment Name:
  expname=mtr_state.ExpName
;Shotnumber:
  shotnumber=mtr_state.shotnum
;Selected channels:
if (mtr_state.diagname eq 'gen') then begin
  handle_value,mtr_state.signame_handle,signame
  handle_value,mtr_state.indices_handle,indices
  diagname = strarr(n_elements(indices))
  diagname[*] = mtr_state.realdiagname
print, diagname
    channels=diagname[where(indices)]+"-"+signame[where(indices)]
print, channels
endif else begin	;(mtr_state.diagname eq 'gen')
  handle_value,mtr_state.signame_handle,signame
  handle_value,mtr_state.diagname_handle,diagname
  handle_value,mtr_state.indices_handle,indices
    channels=diagname[where(indices)]+"-"+signame[where(indices)]
endelse		;(mtr_state.diagname eq 'gen')

;Data vector:
  handle_value,mtr_state.data_handle,data
    data=data[*,where(indices)]
;Time vector:
  handle_value,mtr_state.time_handle,time
;Theta
  handle_value,mtr_state.theta_handle,theta
;Phi
  handle_value,mtr_state.phi_handle,phi

;Calculate geometrical values:
;HERE WILL BE A FUNCTION
theta_type = "Geometrical"

;Creating the datablock structure: (This is the expected structure from NTI_WAVELET_GUI.PRO)
mtr_output = { $
;Signal features:
	expname : expname, $
	shotnumber : shotnumber, $
	channels : channels, $
	theta_type : theta_type, $
	data_history : "Loaded_with_MTR", $
;Data of signals:
	data : data, $
	time : time, $
	theta : theta, $
	phi : phi $
}

nti_wavelet_gui, input_structure=mtr_output, event=event

end