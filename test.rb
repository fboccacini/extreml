require 'extreml'
require 'extreml/type_element'

ric = './SdIRiceviFile_v1.0.wsdl'
xsd = './RicezioneTypes_v1.0.xsd'
xml = './IT02663950984_7FSk5.xml'
tst = 'test.wsdl'
tt = 'testt.xml'
test = Extreml.new(ric)

xml = Extreml.new './testt.xml'

puts xml.header.inspect                                                   # => nil

puts xml.document.movies.movie[0].title               # => "The terminator"
puts xml.document.movies.types.inspect
