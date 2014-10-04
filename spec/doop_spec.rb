require "spec_helper"

describe "doop" do

  describe "question management" do

    let(:question) {
      Question.new( 
        <<-EOS
    
        root: {
          age: {_answer: 25, _answered: true},
          address: { 
            address_line_1: { _answer: "21 The Grove" },
            address_line_2: { _answer: "Telford" },
            address_line_3: {}
          },

          pets: {
            pet__8: { _answer: "Claude" },
            pet__3: { _answer: "Lucy" }
          }

        }

        EOS
      )
    }

    it "is initialized with a YAML data structure" do
    end

    it "can be serilized" do
      dump = question.dump
      expect(dump).to include( "root" )
      expect(dump).to eq( Question.new(dump).dump )
    end

    it "allows questions to be accessed like a file system" do
      expect(question["/root/age/_answer"] ).to eq(25)
      expect(question["/root/age"] ).not_to be_nil
      expect(question["/root/address/address_line_1/_answer"] ).to eq("21 The Grove")
      expect(question["/root/address/address_line_3/_answer"] ).to eq(:empty)
    end

    it "allows questions to be answered" do
      question["/root/address/address_line_3/_answer"] = "Shropshire" 
      expect(question["/root/address/address_line_3/_answer"] ).to eq("Shropshire")

      yaml = <<-EOS

        address_line_1: { _answer: "AAA" }
        address_line_2: { _answer: "BBB" }

      EOS

      question["/root/address"] = YAML.load(yaml)
      expect(question["/root/address/address_line_1/_answer"] ).to eq("AAA")

    end

    it "allows questions to be added" do
      question.add( "/root/address/address_line_4" )
      question["/root/address/address_line_4/_answer"] = "XXX"
      expect(question["/root/address/address_line_4/_answer"] ).to eq("XXX")
    end

    it "allows questions to be removed" do
      question.remove( "/root/address/address_line_1" )
      expect(question["/root/address/address_line_1"] ).to eq(nil)
    end

    it "allows questions to be moved" do
      question.move( "/root/address/address_line_1", "/root/address/address_line_6" )
      expect(question["/root/address/address_line_1"] ).to eq(nil)
      expect(question["/root/address/address_line_6/_answer"] ).to eq("21 The Grove")
    end

    it "allows question to be renumbered in sequence" do
      question.renumber( "/root/pets" )
      expect(question["/root/pets/pet__1/_answer"] ).to eq("Lucy")
      expect(question["/root/pets/pet__2/_answer"] ).to eq("Claude")
    end

    it "automatically adds meta data. Meta data starts with _" do

      expect(question["/root/pets/_answered"] ).not_to be_nil
      expect(question["/root/pets/_open"] ).not_to be_nil
      expect(question["/root/pets/_enabled"] ).not_to be_nil
      expect(question["/root/pets/_answer"] ).not_to be_nil

    end

  end


  describe "navigation and answering" do


    let(:question) {
      Question.new( 
        <<-EOS
    
        root: {
          age: { _question: "How old are you?"},
          address: { 
            _question: "What is your address",
            address_line__1: { _question: "Address Line 1"},
            address_line__2: { _question: "Address Line 2"},
            address_line__3: { _question: "Address Line 3"}
          }
        }

        EOS
      )
    }

    it "gets the next unaswered question" do
      expect(question.currently_asked).to eq( "/root/age" )
    end

    it "allows question to be answered in order" do
      expect(question.currently_asked).to eq( "/root/age" )
      question.answer( { "answer" => 36 } )
      expect(question["/root/age/_answer"]).to eq( 36 )
      expect(question.currently_asked).to eq( "/root/address/address_line__1" )
      question.answer( { "answer" => "address1" } )
      expect(question.currently_asked).to eq( "/root/address/address_line__2" )
      question.answer( {"answer" => "address2" } )
      expect(question.currently_asked).to eq( "/root/address/address_line__3" )
      question.answer( {"answer" => "address3" } )
      expect(question.currently_asked).to eq( "/root/address" )
      question.answer( { "answer" => "#{question['/root/address/address_line__1']},  #{question['/root/address/address_line__2']},  #{question['/root/address/address_line__3']}" } )
      expect(question.currently_asked).to eq( "/root" )
      question.answer( { "answer" => "done" } )
      expect(question.currently_asked).to be_nil
    end

    it "allows questions to be disabled" do
      question.disable("/root/address")
      expect(question.currently_asked).to eq( "/root/age" )
      question.answer( {"answer" => 36 } )
      expect(question.currently_asked).to eq( "/root" )
    end

    it "allows earlier questions to be changed" do
      expect(question.currently_asked).to eq( "/root/age" )
      question.answer( {"answer" => 36} )
      expect(question["/root/age/_answer"]).to eq( 36 )
      expect(question.currently_asked).to eq( "/root/address/address_line__1" )
      question.answer( {"answer" => "address1" } )
      expect(question.currently_asked).to eq( "/root/address/address_line__2" )
      question.answer( {"answer" => "address2"} )
      expect(question.currently_asked).to eq( "/root/address/address_line__3" )

      question.change( "/root/age" )
      expect(question.currently_asked).to eq( "/root/age" )
      question.answer({ "answer" => 35} )
      expect(question.currently_asked).to eq( "/root/address/address_line__3" )
    end

  end

  describe "callbacks" do

    let(:question) {
      Question.new( 
        <<-EOS
    
        root: {
          address: { 
            _question: "What is your address",
            address_line__1: { _question: "Address Line 1"},
            address_line__2: { _question: "Address Line 2"},
            address_line__3: { _question: "Address Line 3"}
          }
        }

        EOS
      )

    }

    it "allows a callback when a question is answered.  This allows flows to be changed based on the answer" do

      question.on_answer "/root/address/address_line__1" do |root, path, context|
        question.enable( "/root/address/address_line__2", context[:button] == :ok )
        root["_answer"] = "answered!"
        root["_summary"] = "my summary"
        root["_answered"] = true

      end

      expect(question.currently_asked).to eq( "/root/address/address_line__1" )
      question.answer( {:button => :skip} )
      expect(question.currently_asked).to eq( "/root/address/address_line__3" )
      question.change( "/root/address/address_line__1" )
      expect(question.currently_asked).to eq( "/root/address/address_line__1" )
      question.answer( {:button => :ok} )
      expect(question.currently_asked).to eq( "/root/address/address_line__2" )
    end

    it "allows callbacks based on a regex expression" do
      question.on_answer "/root/address/address_line__(.*)" do |root, path, context|
        root["_answer"] = "answered!"
        root["_answered"] = true
      end
      expect(question.currently_asked).to eq( "/root/address/address_line__1" )
      question.answer( {} )
      expect(question["/root/address/address_line__1/_answer"]).to eq( "answered!" )
      question.answer( {} )
      expect(question["/root/address/address_line__2/_answer"]).to eq( "answered!" )
    end

  end

end

