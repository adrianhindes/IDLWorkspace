pro gettstamp, d,sec,c,yr,mon,day,hr,min,sec0
;input:
;d = first 14 pixels of image (uint)

;output:
;sec = seconds of that image within that day
;c = image counter in sequence
; ,y,mon,day - year,month,day
;sec0 = seconds within that minute and withouth resolving microseconds


da = d and 15
db0 = d and (128+64+32+16)
db=db0/16
dc=10*db + da
dc=long(dc)
;print,d
;print,da
;print,db
;print,dc


j=0
c0=dc(j++)
c1=dc(j++)
c2=dc(j++)
c3=dc(j++);lsb
c=c3+c2*100+c1*10000+c0*1000000

yr0=dc(j++)
yr1=dc(j++);lsb
yr=100*yr0 + yr1
mon=dc(j++)
day=dc(j++)
hr=dc(j++)*1d0
min=dc(j++)*1d0
sec0=dc(j++)*1d0
tenms=dc(j++)*1d0
hundredmicros=dc(j++)*1d0
micros=dc(j++)*1d0
sec=hr*3600  + min*60 + sec0 + tenms * 0.01d0 + hundredmicros * 100d-6 + micros * 1d-6

end

pro testtstamp
sh=8049;8062
s=dblarr(10)
for i=0,9 do begin
d=read_tiff('/data/kstar/MSE_DATA/'+string(sh,format='(I0)')+'.tif',image_index=i) &gettstamp, d(0:13),stmp & s(i)=stmp
endfor
s2=s-s(0)
print,s2


end


;; pixel 1 pixel 2 pixel 3 pixel 4 pixel 5 pixel 6 pixel 7
;; image
;; counter
;; (MSB)
;; (00  99)
;; image
;; counter
;; (00  99)
;; image
;; counter
;; (00  99)
;; image
;; counter
;; (LSB)
;; (00  99)
;; year
;; (MSB)
;; (20)
;; year
;; (LSB)
;; (03  99)
;; month
;; (01  12)
;; pixel 8 pixel 9 pixel 10 pixel 11 pixel 12 pixel 13 pixel 14
;; day
;; (01 ... 31)
;; h
;; (00  23)
;; min
;; (00  59)
;; s
;; (00  59)
;; µs * 10000
;; (00  99)
;; µs * 100
;; (00  99)
;; µs
;; (00  90)
