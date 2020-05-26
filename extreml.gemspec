Gem::Specification.new do |s|
  s.name        = 'extreml'
  s.version     = '2.0.0'
  s.summary     = "A gem to easily mamipulate XML documents."
  s.description = "This gem allows to read an XML/Json file or string and access its elements using methods named after the tags.
    Also there are methods to return the object as an Hash or XML/Json string.
    See https://github.com/fboccacini/extreml for reference and usage."
  s.authors     = ["Fabio Boccacini"]
  s.email       = 'fboccacini@gmail.com'
  s.files       = ["lib/extreml.rb","lib/extreml/type_element.rb","lib/extreml/xml_header.rb"]
  s.homepage    = 'https://github.com/fboccacini/extreml'
  s.license     = 'MIT'
end
