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

# Exposes the xml header properties as methods
class Extreml::XmlHeader

  # Initialize
  #
  # @param header [Hash|String] the header.
  # @return [XmlHeader] the object.
  def initialize header

    h = header.scan /([\w\?\<]*)=["|']([^'"]*)["|']/
    if h.empty?
      @attributes = nil
    else
      @attributes = Array.new
      h.each do |param|
        @attributes << param[0].to_sym
        define_singleton_method param[0].to_sym do
          return param[1]
        end
      end
    end
  end

  def to_xml
    if @attributes.nil?
      header = ''
    else
      header = '<?xml'
      @attributes.each do |a|
        header += " #{a.to_s}=\"#{self.send(a)}\""
      end
      header += '?>'
    end

    return header
  end
end
