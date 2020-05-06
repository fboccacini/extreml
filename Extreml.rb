require 'pp'
require 'net/http'
require 'byebug'

class XmlHeader
end

class Namespace
end

class TypeElement

  def initialize document

    @name = document[:name]
    @namespace = document[:namespace]
    @attributes = document[:attributes]
    @content = document[:content]
    unless @content.nil?
      @content.each do |v|
        if v.class == Hash
          __add_type_element v[:name], v
        end
      end
    end

  end

  def __name
    @name
  end

  def __attributes
    @attributes
  end

  def __namespace
    @namespace
  end

  def __content
    if @content.nil? || @content.length >  1
      return @content
    else
      return @content[0]
    end
  end

  def __method_names
    return self.methods - Object.methods
  end

  def __type_elements
    return self.__method_names - TypeElement.instance_methods
  end

  def __add_type_element name, content
    if content[:conent].class == String
      pp content
      puts content.class
      puts self.__type_elements.any? name.to_sym
      gets
    end
    if self.__type_elements.any? name.to_sym
      array = self.send name.to_sym
      define_singleton_method name.to_sym do
        return [array].flatten + [(content.class == Hash ? (TypeElement.new content) : content)]
      end
    else
      define_singleton_method name.to_sym do
        if content.class == Hash
          return TypeElement.new content
        else
          return content
        end
      end
    end
  end

  def to_s
    return self.__content
  end

  def __tree level = 0, attributes: false

    pre = level > 0 ? "#{'    ' * level}|#{'-->'}" : ""
    puts "#{pre}#{self.__namespace}:#{self.__name} #{self.__type_elements.inspect}" + (attributes ? " #{self.__attributes}" : "")
    level += 1
    self.__type_elements.each do |m|
      next_type_element = self.send(m)
      [next_type_element].flatten.each do |nt|
        nt.__tree level unless next_type_element.nil?
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
      return TypeElement.new({name: 'document', content: @document})
    end

  end

  def tree
    self.document.__tree
  end

  def document
    return @document
  end

  private

  def unpack string

    pack = nil
    string = string.gsub(/\<\!--[^>]*--\>/,'').strip

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

end
