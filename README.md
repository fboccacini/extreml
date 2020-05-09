# Extreml
### Ruby XML manipulation gem

A powerful ruby gem to easily manipulate XML documents, that gives acces to the elements through dynamic methods.

This library contains another two classes, XmlHeader and TypeElement, which expose dynamic methods named after respectively their properties and nested tags.

The document method in of Extreml returns aTypeElement object with a method named after the root tag which returns the first level of nesting represented as TypeElement objects.

Any subsequent object has methods that reflect its structure, that return recursively an object that has the nested elements as methods.

If there are more than one element with the same tag, that method will return an array containing all subsequent objects.

All basic methods of TypeElement have aliases, in order to prevent method overriding in case the document contains tags with similar names, which are called with two leading underscores (es. __types).


Usage:
------

### Basic methods:



**Extreml:**

header: returns the representation of the xml header as a XmlHeader object.

document: returns the representation of the entire document as a TypeElement object.

tree: prints the entire structure of the document for debugging purposes.



**TypeElement:**

name: returns the name of the element (= tag name).

namespace: returns the namespace of the tag.

attributes: returns an hash with the property names as key and the values as value.

types: returns an array containing the names of the dynamic methods referring to the nested elements.

to_s: returns the content (overrides
tree: prints the structure referred part of the document for debugging purposes.

All these methods have aliases (eg. __name, __namespace, etc.)



**File examples:**
funny_people.xml

    <?xml version="1.0" encoding="UTF-8"?>
    <ns0:funnyPeople>
      <ns1:businessCard>
        <name>
          <firstName>Guybrush</firstName>
          <lastName>Threepwood</lastName>
        </name>
        <jobs:occupation name="pirate" description="Terror of threeheaded monkeys"/>
        <address>
          <island>Scabb Island</island>
          <city>Pirate's city</city>
          <street>Voodoo Blvd.</street>
          <number>3</number>
        </address>
      </ns1:businessCard>
      <ns1:businessCard>
        <name>
          <firstName>Senbei</firstName>
          <lastName>Norimaki</lastName>
        </name>
        <jobs:occupation name="inventor" description="A great genius"/>
        <address>
          <city>Penguin Village</city>
          <street>Tanuki doro</street>
          <number>1</number>
        </address>
      </ns1:businessCard>
      <types>
        <type name="main character"/>
        <type name="villain"/>
        <otherTypes/>
      </types>
    </ns0:funnyPeople>
    
movies.xml

    <movies>
      <movie>
        <title>The terminator</title>
        <year>1984</year>
      </movie>
      <movie>
        <title>The matrix</title>
        <year>1999</year>
      </movie>
    </movies>

## Code example:

    xml = Extreml.new './funny_people.xml'

    xml.header.version                                           # => "1.0"
    xml.header.encoding                                          # => "UTF-8"

    xml.document.funnyPeople.businessCard[0].name.firstName.to_s # => "Guybrush"
    xml.document.funnyPeople.businessCard[0].__name              # => "businessCard"

    xml.document.funnyPeople.types                               # => #<TypeElement:0x0000557373082fc8>
    xml.document.funnyPeople.__types                             # => [:businessCard, :types]

    
    xml = Extreml.new './movies.xml'

    xml.header                                                   # => nil

    xml.document.movies.movie[0].title                           # => "The terminator"
    xml.document.movies.types                                    # => [:movie]
    
    
