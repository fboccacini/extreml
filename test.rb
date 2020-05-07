require 'extreml'
require 'extreml/type_element'

ric = './SdIRiceviFile_v1.0.wsdl'
xsd = './RicezioneTypes_v1.0.xsd'
xml = './IT02663950984_7FSk5.xml'
tst = 'test.wsdl'
tt = 'testt.xml'
test = Extreml.new(ric)

xml = Extreml.new './testt.xml'

# puts xml.header.version # => "1.0"
# puts xml.header.encoding # => "UTF-8"

puts xml.document.funnyPeople.businessCard[0].name.firstName.inspect # => Guybrush
# puts xml.document.funnyPeople.businessCard[0].__name # => "businessCard"
#
# puts xml.document.funnyPeople.types.inspect # =>
# puts xml.document.funnyPeople.__types.inspect # =>
