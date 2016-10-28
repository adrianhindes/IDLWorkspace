pro test_case
command=''
read, command, prompt='enter and IDL display command:'
cmdlist=['plot','surface','tv']
index=where(strlowcase(command)eq cmdlist)
case index[0]of
0:plot, sin(findgen(100)*0.25)
1:surface, dist(32)
2:begin
      erase
       image=dist(400)
        tvscl, image
        end
else: print, 'valid display command are:', cmdlist
endcase

end