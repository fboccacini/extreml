# MIT License
#
# Copyright (c) 2020 Fabio Boccacini - fboccacini@gmail.com
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require 'pp'

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
