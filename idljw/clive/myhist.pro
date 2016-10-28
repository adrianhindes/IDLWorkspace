pro myhist,imgc,h,hx,nbins=nbins
h=histogram(imgc,omin=omin,omax=omax,nbins=nbins)
hx1=linspace(omin,omax,nbins+1)
hx=(hx1(1:nbins)+hx1(0:nbins-1))/2.
end
