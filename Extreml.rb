require 'pp'
require 'net/http'
require 'byebug'

class XmlHeader
end

class Namespace
end

class TypeElement

  def initialize document

    # document model:
    #
    # {
    #   name: 'string',
    #   namespace: 'string'|nil,
    #   attributes: [attributes_array]|nil,
    #   content: [mixed_array]|nil
    # }
    #
    # attributes model:
    #
    # {
    #   property: 'string',
    #   namespace: 'string'|nil,
    #   value: 'string'
    # }
    #
    # Initialize properties
    @name = document[:name]
    @namespace = document[:namespace]
    @attributes = document[:attributes]
    @content = document[:content]

    # Add a type for every element in content
    unless @content.nil?
      @content.each do |v|
        if v.class == Hash
          __add_type v[:name], v
        end
      end
    end

  end

  # Getters
  def name
    @name
  end
  alias __name name

  def attributes
    @attributes
  end
  alias __attributes attributes

  def namespace
    @namespace
  end
  alias __namespace namespace

  def content
    if @content.nil? || @content.length >  1
      return @content
    else
      return @content[0]
    end
  end
  alias __content content

  def types
    return self.methods - TypeElement.instance_methods
  end
  alias __types types

  # Add a type method, that returns an array if there are more elements with the same tag,
  # a Type object if it's just one, or the content if it's the last level
  def add_type name, content

    # If method exists, override it and return an array including all previous elements
    # Else create a method that returns a new object of the content
    if self.__types.any? name.to_sym
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
  alias __add_type add_type

  # Override to_s to use in strings (useful for the last nesting level)
  def to_s
    return self.__content
  end
  alias __to_s to_s

  # This method is for debug purposes only, it prints a tree of the document
  def tree level: 0, attributes: false

    pre = level > 0 ? "#{'    ' * level}|#{'-->'}" : ""
    puts "#{pre}#{self.__namespace}:#{self.__name} #{self.__types.inspect}" + (attributes ? " #{self.__attributes}" : "")
    level += 1
    self.__types.each do |m|
      next_type = self.send(m)
      [next_type].flatten.each do |nt|
        (nt.__tree level: level, attributes: attributes) unless next_type.nil?
      end
    end
  end
  alias __tree tree

end

class Extreml

  def initialize xml_file, warnings: true

    # Warnings flag
    @warnings = warnings

    if xml_file.nil?
      raise 'Error: please specify an xml file. Nil was given.'
    elsif !File.file? xml_file
      raise "Error: file #{xml_file} not found."
    else

      # Read file
      xml = File.read xml_file

      @header = nil
      @body = Hash.new

      # Get xml header informations
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

  end

  # Expose the entire document
  def document
    return TypeElement.new({name: 'document', content: @document})
  end

  # Print the entire document tree. For debug purposes
  def tree attributes: false
    self.document.__tree attributes
  end

  private

  def unpack string

    # Remove comments
    string = string.gsub(/\<\!--[^>]*--\>/,'').strip

    # Match a tag pair at a time, recurse for nested content
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
