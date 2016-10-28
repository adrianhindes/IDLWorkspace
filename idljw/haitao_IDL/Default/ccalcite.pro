
;pro ccalcite,n_e=n_e,n_o=n_o,lambda=lambda,dnedl=dnedl,dnodl=dnodl
;default,lambda,656e-9

function ccalcite, lambda, n_e=n_e, n_o=n_o, dnedl=dnedl, dnodl=dnodl, dmudl=dmudl, sell2=sell2


l = lambda*1d-3

n_o = Sqrt( 1.73358749 + 0.96464345*l^2/(l^2-1.94325203e-2) + 1.82831454*l^2/(l^2-120.) )
n_e = Sqrt( 1.35859695 + 0.82427830*l^2/(l^2-1.06689543e-2) + 0.14429128*l^2/(l^2-120.) )

dnodl = (-270.0173789117974*l + 13.02581108105369*Power(l,3) - $
     219.4164902534244*Power(l,5))/$
   (Power(2.3319024360000005 - 120.0194325203*Power(l,2) + $
       Power(l,4),2)*Sqrt((4.042556890950126 - $
         323.8569295335045*Power(l,2) + 4.526545479999999*Power(l,4)$
         )/(2.3319024360000005 - 120.0194325203*Power(l,2) + $
         Power(l,4))))

dnedl= (-126.63827109186887*l + 2.4800699004936178*Power(l,3) - $
     17.323747787513184*Power(l,5))/$
   (Power(1.280274516 - 120.0106689543*Power(l,2) + Power(l,4),2)*$
     Sqrt((1.7393770526003263 - 261.9610642458439*Power(l,2) + $
         2.32716653*Power(l,4))/$
       (1.280274516 - 120.0106689543*Power(l,2) + Power(l,4))))


dnodl*=1e6
dnedl*=1e6


dmudl = dnedl - dnodl
return, dmudl 
stop
end
