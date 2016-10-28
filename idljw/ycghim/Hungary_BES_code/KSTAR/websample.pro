pro websample 
  ourl = OBJ_NEW('IDLnetURL') 
  content1 = ourl->get(url='http://www.netpincer.hu/joy', /string_array); 
  print, 'Contents of netpincer.hu:' 
  print 
  print, content1 
  print 
  content2 = ourl->get(url='http://www.google.com/search?q=IdlnetURL', /string_array) 
  print, 'Contents of searching google for idlneturl:' 
  print 
  print, content2 
  OBJ_DESTROY, ourl 
end 