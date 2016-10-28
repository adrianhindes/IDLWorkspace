@demodc
shotno=802
tree='MSE'
;if n_elements(u) eq 0 then
 u = get_kstar_mse_images(shotno, camera=camera, time=time, tree=tree)

end
