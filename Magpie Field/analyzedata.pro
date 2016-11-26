pro analyzeData

;Calculate perpendicular and parallel diffusion
;from MAGPIE experiments given parameters
;and probe data

;guesstimates for B at z 1,2,3,4 (z=1 at source, z=3 pinch)
Bz = [0.01,0.015,0.1,0.001]

temp=[7,4,6,3] ;electrons
n=[1E19,2.3E19,2.5E19,0] ;n_i approx = n_e assuming quasineutral

gradN = 0.5E19

ionTemp = 0.1

fluxResults = ptarr 

for i = 0, 3 do begin
  fluxResults = perpParallelDiffusion(b = Bz[i], te = temp[i], ti = ionTemp, $
    n_i=n[i], del_ni = gradN, spec = species)
endfor

z=[1,2,3,4]

plot,z,fluxResults
end

