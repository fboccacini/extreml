require './Extreml.rb'

ric = './SdIRiceviFile_v1.0.wsdl'
xsd = './RicezioneTypes_v1.0.xsd'
xml = './IT02663950984_7FSk5.xml'
tst = 'test.wsdl'
test = Extreml.new(ric)

pp test.document
pp test.document.tree attributes: true
pp test.document.definitions.message[1].part.to_s
