@xml_to_struct2__define

xmlObj = OBJ_NEW('xml_to_struct2')
xmlFile = FILEPATH('planets.xml', SUBDIRECTORY = ['examples', 'data'])
;xmlfile='sample.xml'
xmlfile='~/footer_1.xml'
xmlObj->ParseFile, xmlFile
planets = xmlObj->GetArray()
OBJ_DESTROY, xmlObj

end
;help,/str,dum.speformat.datahistories.datahistory.origin.experiment.devices.cameras.camera.experiment.onlinecorrections.orientationcorrection.flipvertically
