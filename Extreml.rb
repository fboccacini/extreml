require 'pp'
require 'net/http'
require 'byebug'

class XmlHeader
end

class Namespace
end

class Type

  def initialize document

    @name = document[:name]
    @namespace = document[:namespace]
    @attributes = document[:attributes]
    @content = document[:content]
    unless @content.nil?
      @content.each do |v|
        add_type v[:name], v
      end
    end

  end

  def name
    @name
  end

  def attributes
    @attributes
  end

  def namespace
    @namespace
  end

  def method_names
    return self.methods - Object.methods
  end

  def __types
    return self.method_names - [:add_type, :namespace, :attributes, :__types, :tree, :method_names]
  end

  def add_type name, content

    if self.__types.any? name.to_sym
      array = self.send name.to_sym
      define_singleton_method name.to_sym do
        return [array].flatten + [(content.class == Hash ? (Type.new content) : content)]
      end
    else
      define_singleton_method name.to_sym do
        if content.class == Hash
          return Type.new content
        else
          return content
        end
      end
    end


  end

  def tree level = 0

    puts "#{'   ' * level}|#{'__'}#{self.namespace}:#{self.name} #{self.__types.inspect} #{self.attributes}"
    level += 1
    # pp @content
    # gets
    self.__types.each do |m|
      next_type = self.send(m)
      [next_type].flatten.each do |nt|
        nt.tree level unless next_type.nil?
      end
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
    define_singleton_method :document do
      return Type.new({name: 'document', content: @document})
    end

    # unpack(doc[1]).each do |pack|
    #
    #   @document = Type.new namespace: pack.namespace, attributes: pack.attributes, name: pack.name
    #   @document.add_type pack, method_name: 'definitions'
    # end
      # xsd_address = @wsdl_definitions[]
      # Net::HTTP.start("somedomain.net") do |http|
      #   resp = http.get("/flv/sample/sample.flv")
      #   open("sample.flv", "wb") do |file|
      #       file.write(resp.body)
      #   end
      # end
  end

  def tree
    self.document.tree
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

          pack = Hash[
            :name => parts[:name],
            :namespace => parts[:namespace],
            :attributes => attributes
          ]
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
      return [unpack(tags[:prerest].strip), pack, unpack(tags[:rest].strip)].reject{ |p| p == ""}

    end
  rescue Exception => e
    puts e.message
    puts e.backtrace.join("\n")
  end

    # pack = nil
    # string = string.gsub(/\<\!--[^>]*--\>/,'').strip
    # begin
    #   string = string.strip
    #   tags = string.match /(?<prerest>.*?)?\<(?:(?<namespace>\w*):)?(?<name>[^\/]\w*)(?:[\t]*(?<attributes>[^>]*)?)\>(?<content>.*?)[\t\n\r\f]*\<\/\k<namespace>?:?\k<name>\>(?<rest>.*)/m
    #
    #   if tags.nil?
    #     parts = string.match /(?<prerest>.*?)?\<(?:(?<namespace>\w*):)?(?<name>[^\/]\w*)(?:[\t]*(?<attributes>[^>]*)?)[\t\n\r\f]*\/\>(?<rest>.*)/m
    #
    #     if parts.nil?
    #       return string
    #     else
    #       attributes = Array.new
    #       a = parts[:attributes].scan /[\t\n\r\f ]*(?:(?<namespace>[^:\n\r\f\t]*):)?(?<property>[^=\n\r\f\t ]*)[\t ]*=[\t ]*"(?<value>[^"]*)"[\t\n\r\f]*/m
    #       a.each do |p|
    #         attributes << {
    #           :namespace => p[0],
    #           :property => p[1],
    #           :value => p[2]
    #         }
    #       end
    #
    #       pack = Hash[
    #         :name => parts[:name],
    #         :namespace => parts[:namespace],
    #         :attributes => attributes
    #       ]
    #
    #       if defined? self.parts[:name]
    #
    #       else
    #
    #
    #       end
    #
    #       type = Type.new ({
    #         :name => parts[:name],
    #         :namespace => parts[:namespace],
    #         :attributes => attributes
    #       })
    #       # pack = Hash[
    #       #   :name => parts[:name],
    #         # :namespace => parts[:namespace],
    #         # :attributes => attributes
    #       #
    #       # ]
    #       # pp pack
    #       # puts pack.inspect
    #       # puts defined? self.parts[:name]
    #       # puts self.parts[:name].methods
    #       # self.call(parts[:name])
    #       return [unpack(parts[:prerest].strip), type, unpack(parts[:rest].strip)].reject{ |p| p == ""}
    #     end
    #   else
    #
    #     if tags[:attributes].strip! == ""
    #       attributes = nil
    #     else
    #       attributes = Array.new
    #       a = tags[:attributes].scan /[\t\n\r\f ]*(?:(?<namespace>[^:\n\r\f\t]*):)?(?<property>[^=\n\r\f\t ]*)[\t ]*=[\t ]*"(?<value>[^"]*)"[\t\n\r\f]*/m
    #       a.each do |p|
    #         attributes << {
    #           :namespace => p[0],
    #           :property => p[1],
    #           :value => p[2]
    #         }
    #       end
    #     end
    #     type = Type.new ({
    #       :name => tags[:name],
    #       :namespace => tags[:namespace],
    #       :attributes => attributes
    #     })
    #     pp tags[:content].strip
    #     box = unpack(tags[:content].strip)
    #     pp box
    #     box.flatten.each do |t|
    #       puts "#{type.name} -> #{t.name}"
    #       type.add_type t
    #     end
    #     gets
    #     # pack.each do |p|
    #     #   next if p.nil?
    #     #   # p.each do |pp|
    #     #     if p.class == Type
    #     #       pack.add_type p
    #     #     else
    #     #       pp p
    #     #       pack.add_type p, method_name: tags[:name]
    #     #     end
    #     #   # end
    #     # end
    #     # if pack.nil?
    #     #   pack = Hash[
    #     #     :name => tags[:name].strip,
    #     #     :namespace => tags[:namespace].nil? ? nil : tags[:namespace].strip,
    #     #     :attributes => attributes,
    #     #     :content => Array.new
    #     #   ]
    #     # end
    #     #
    #     # pack[:content] += [unpack(tags[:content].strip)].flatten
    #   end
    #
    #
    #   # return pack
    #   return [unpack(tags[:prerest].strip), type, unpack(tags[:rest].strip)].reject{ |p| p == ""}

  #   end
  # rescue Exception => e
  #   puts e.message
  #   puts e.backtrace.join("\n")
  # end

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
# puts test.xml.class
# puts test.xml.version
pp test.document.definitions.tree
# pp test.document.definitions.method_names
# pp test.document.definitions.message.part.method_names
# test.document.definitions.portType.tree
# puts test.version
