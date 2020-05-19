require 'extreml'

describe Extreml do
   context "When testing the Extreml class" do

      it "should return the an XML similar to the original, comments and spaces taken out" do

        Dir.each_child('./test_files').each do |f|
          file = './test_files/' + f
          xml_file = File.read file
          xml_file = xml_file.gsub(/<!--.*-->/,'').gsub(/[\t\n\r\f ]/,'')
          xml = Extreml.new file
          xml_cmp = xml.to_xml.gsub(/[\t\n\r\f ]/,'')
          expect(xml_cmp).to eq xml_file
        end

      end

   end
end
