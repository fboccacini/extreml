require 'pp'
require 'net/http'

class XmlHeader
end

class Namespace
end

class Type

  def initialize namespace: nil, attributes: []
    @namespace = namespace
    @atributes = attributes
    @types = Array.new
  end

  def add_type name, type

    @types << type

    define_singleton_method name.to_sym do
      eval "return @types[#{@types.length - 1}]"
    end

  end
end

class Extreml

  def initialize xml_file, warnings: true

    @warnings = warnings

    if xml_file.nil?
      raise 'Error: please specify an xml file. Nil was given.'
    elsif !File.file? xml_file
      raise "Error: file #{xml_file} not found."
    else
      xml = File.read xml_file

      @header = nil
      @body = Hash.new

      header = xml[/^\<\?xml (.*)\?\>/]

      if header.nil?
        puts "Warning: #{xml_file}: xml header missing." if @warnings
        define_singleton_method :xml do
          return nil
        end
      else
        h = header.scan /([\w\?\<]*)=["|']([^'"]*)["|']/

        @xml = XmlHeader.new
        h.each do |param|
          @xml.instance_eval do
            define_singleton_method param[0].to_sym do
              return param[1]
            end
          end
        end

        define_singleton_method :xml do
          return @xml
        end
      end
    end

    # Read document
    doc = xml.match /(?:\<\?xml .*?(?: ?\?\>))?[\t\n\r\f ]*(.*)/m
    @document = unpack doc[1]

      # xsd_address = @wsdl_definitions[]
      # Net::HTTP.start("somedomain.net") do |http|
      #   resp = http.get("/flv/sample/sample.flv")
      #   open("sample.flv", "wb") do |file|
      #       file.write(resp.body)
      #   end
      # end
  end

  def document
    return @document
  end

  private

  def unpack string

    pack = nil
    string = string.gsub(/\<\!--[^>]*--\>/,'').strip
    begin
      string = string.strip
      tags = string.match /(?<prerest>.*?)?\<(?:(?<namespace>\w*):)?(?<name>[^\/]\w*)(?:[\t]*(?<attributes>[^>]*)?)\>(?<content>.*?)[\t\n\r\f]*\<\/\k<namespace>?:?\k<name>\>(?<rest>.*)/m

      if tags.nil?
        parts = string.match /(?<prerest>.*?)?\<(?:(?<namespace>\w*):)?(?<name>[^\/]\w*)(?:[\t]*(?<attributes>[^>]*)?)[\t\n\r\f]*\/\>(?<rest>.*)/m

        if parts.nil?
          return string
        else
          attributes = Array.new
          a = parts[:attributes].scan /[\t\n\r\f ]*(?:(?<namespace>[^:\n\r\f\t]*):)?(?<property>[^=\n\r\f\t ]*)[\t ]*=[\t ]*"(?<value>[^"]*)"[\t\n\r\f]*/m
          a.each do |p|

            attributes << {
              :namespace => p[0],
              :property => p[1],
              :value => p[2]
            }
          end
          # puts "#{parts[:name]} - #{defined?(parts[:name].to_s)}"
          # puts "#{parts[:name]} - #{defined?("blabla")}"
          # name = parts[:name][0].upcase + parts[:name][1..-1]
          # puts name
          # unless defined?(name) == 'constant' && name.class == Class
          #   classname = Object.const_set(name, Class.new do
          #
          #
          #   end)
          #
          #   # class << parts[:name]; Type do
          #   #
          #   # end
          # end
          # puts "#{defined?(name)} && #{name.class == Class}"
          if defined? self.parts[:name]

          else
            pack = Type.new ({
              :namespace => parts[:namespace],
              :attributes => attributes
            })

            pack.add_type tags[:name], nil
            return pack
          end
          # pack = Hash[
          #   :name => parts[:name],
            # :namespace => parts[:namespace],
            # :attributes => attributes
          #
          # ]
          # pp pack
          # puts pack.inspect
          # puts defined? self.parts[:name]
          # puts self.parts[:name].methods
          # self.call(parts[:name])
          return [unpack(parts[:prerest].strip), pack, unpack(parts[:rest].strip)].reject{ |p| p == ""}
        end
      else

        if tags[:attributes].strip! == ""
          attributes = nil
        else
          attributes = Array.new
          a = tags[:attributes].scan /[\t\n\r\f ]*(?:(?<namespace>[^:\n\r\f\t]*):)?(?<property>[^=\n\r\f\t ]*)[\t ]*=[\t ]*"(?<value>[^"]*)"[\t\n\r\f]*/m
          a.each do |p|
            attributes << {
              :namespace => p[0],
              :property => p[1],
              :value => p[2]
            }
          end
        end
        if pack.nil?
          pack = Hash[
            :name => tags[:name].strip,
            :namespace => tags[:namespace].nil? ? nil : tags[:namespace].strip,
            :attributes => attributes,
            :content => Array.new
          ]
        end
        pack[:content] += [unpack(tags[:content].strip)].flatten
      end
      pack = Type.new ({
        :namespace => parts[:namespace],
        :attributes => attributes
      })

      pack.add_type tags[:name], unpack(tags[:content].strip)
      return pack
      # return [unpack(tags[:prerest].strip), pack, unpack(tags[:rest].strip)].reject{ |p| p == ""}

    end
  rescue Exception => e
    puts e.message
    puts e.backtrace.join("\n")
  end

end

ric = './SdIRiceviFile_v1.0.wsdl'
xsd = './RicezioneTypes_v1.0.xsd'
xml = './IT02663950984_7FSk5.xml'
tst = 'test.wsdl'
test = Extreml.new(ric)

# test.definitions[0][:content].each do |t|
#     t.each do |l|
#       pp l
#       gets
#     end
#
#
# end
puts test.xml.class
puts test.xml.version
puts NewClass.test
puts Otherclass.method1
# puts test.version
