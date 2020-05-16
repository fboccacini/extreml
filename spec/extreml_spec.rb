require 'extreml'

describe Extreml do
   context "When testing the Extreml class" do

      it "should return the element content when we call a method with the same name" do

        # More testing is needed, work in progress
         xml = Extreml.new './test_files/movies.xml'
         content = xml.document.movies.movie[0].title.to_s
         expect(content).to eq "The terminator"

      end

   end
end
