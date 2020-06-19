require 'extreml'
require 'byebug'

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

      it "should create an object from a file, add a type, and return its content, and also return the same hashes of  the previous methods" do

        Dir.each_child('./test_files').each do |f|
          file = './test_files/' + f
          xml_file = File.read file

          xml_file = xml_file.gsub(/<!--.*-->/,'').gsub(/[\t\n\r\f ]/,'')
          xml = Extreml.new file
          types = xml.document.__types
          results = Hash.new
          types.each do |t|
            results[t] = xml.document.send(t).to_hash
          end

          xml.document.add_new_type "stest", "tester"

          expect(xml.document.stest.content).to eq "tester"
          types.each do |t|
            expect(xml.document.send(t).to_hash).to eq results[t]
          end
        end

      end

      it "should create an empty object, add a type, and return the content" do

        xml = Extreml.new
        xml.document.add_new_type "stest", "tester"

        expect(xml.document.stest.content).to eq "tester"

      end
   end
end
