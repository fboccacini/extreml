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


class Extreml

  def initialize xml_file = nil, warnings: true, xml_header: nil

    # Warnings flag
    @warnings = warnings
    @header = XmlHeader.new xml_header

    if xml_file.nil?
      @document = Array.new
    else
      if !File.file? xml_file
        raise "Error: file #{xml_file} not found."
      else

        # Read file
        xml = File.read xml_file

        @body = Hash.new

        # Get xml header informations
        header = xml[/^\<\?xml (.*)\?\>/]

        if header.nil?
          puts "Warning: #{xml_file}: xml header missing." if @warnings
          define_singleton_method :header do
            return nil
          end
        else
          h = header.scan /([\w\?\<]*)=["|']([^'"]*)["|']/

          @xml_header = XmlHeader.new header

          define_singleton_method :header do
            return @xml_header
          end
        end

      end

      # Read document
      doc = xml.match /(?:\<\?xml .*?(?: ?\?\>))?[\t\n\r\f ]*(.*)/m
      @document = unpack doc[1]

    end

  end

  # Returns the document in an Hash form
  def to_hash
    return self.document.to_hash
  end

  def to_json
    return self.document.to_json
  end

  # Retrurns the document in XML format
  def to_xml
    if @xml_header.nil?
      xml = ''
    else
      xml = @xml_header.to_xml + "\n"
    end
    self.document.__types.each do |t|
      xml += self.document.send(t).to_xml
    end
    return xml
  end

  # Expose the entire document
  def document
    return TypeElement.new({name: 'document', content: @document}, main_element: self)
  end

  # update content from a subsequent element
  def update_content key, content

    # @document = content.to_hash
    # upd = false
    # @document.each do |e|

    #   if e[:name] == key
    #     upd = true
    #     content.each do |k,v|
    #       e[k] = v
    #     end
    #     break
    #   end
    # end
    #
    # unless upd
    #   @document << content
    # end
    # if @document[key].nil?
    #   @document[key] = content
    # else
    #   unless @document[key].class = Array
    #     @document[key] = [@document[key]]
    #   end
    #   @document[key] << content.to_hash
    # end

  end

  # Print the entire document tree. For debug purposes
  def tree attributes: false
    self.document.__tree attributes: attributes
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
        a = parts[:attributes].scan /[\t\n\r\f ]*(?:(?<namespace>[^\:\=\n\r\f\t ]*):)?(?<property>[^\:\=\n\r\f\t ]*)[\t ]*=[\t ]*"(?<value>[^"]*)"[\t\n\r\f]*/m

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
        a = tags[:attributes].scan /[\t\n\r\f ]*(?:(?<namespace>[^\:\=\n\r\f\t ]*):)?(?<property>[^\:\=\n\r\f\t ]*)[\t ]*=[\t ]*"(?<value>[^"]*)"[\t\n\r\f]*/m
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


require 'extreml/type_element'
require 'extreml/xml_header'
