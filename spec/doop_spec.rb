require "spec_helper"

describe "Doop" do

  describe "answering in sequence" do

    let(:question) {
      q = Doop::Doop.new 
      q.yaml=
        <<-EOS
    
        pages: {
          about_you: { 
            dob: { _question: "What is your dob" }
          },
          about_your_partner: { 
            dob: { _question: "What is your dob" }
          }
        }

        EOS
      q.init
      q.ask_next
      q
    }

    it "can handle questions with similar names" do
      expect(question.currently_asked).to eq( "/pages/about_you/dob" )
      question.answer( { "answer" => "aa"} )
      expect(question.currently_asked).to eq( "/pages/about_you" )
      question.answer( { "answer" => "bb"} )
      expect(question.currently_asked).to eq( "/pages/about_your_partner/dob" )
      question.answer( { "answer" => "cc"} )
      expect(question.currently_asked).to eq( "/pages/about_your_partner" )
      question.answer( { "answer" => "dd"} )
      expect(question.currently_asked).to eq( "/pages" )
      question.answer( { "answer" => "ee"} )

      expect( question["/pages/about_you/dob/_answer"] ).to eq("aa")
      expect( question["/pages/about_you/_answer"] ).to eq("bb")
      expect( question["/pages/about_your_partner/dob/_answer"] ).to eq("cc")
      expect( question["/pages/about_your_partner/_answer"] ).to eq("dd")
      expect( question["/pages/_answer"] ).to eq("ee")

      question.change( "/pages/about_you/dob" )
      question.answer( { "answer" => "ff"} )
      expect(question.currently_asked).to eq( "/pages/about_you" )
    end

  end

  describe "automatic binding" do

    let(:question) {
      q = Doop::Doop.new
      q.yaml = ( 
        <<-EOS
    
        root: {
          age: {},
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
      q.init
      q.ask_next
      q
    }


    it "attempts to bind anything starting with b_ to the answer" do
      expect(question.currently_asked).to eq( "/root/age" )
      question.answer( { "b_age"=>10 } )
      expect( question["/root/age/_answer"]["age"] ).to eq(10)

    end

  end

  describe "structure management" do

    let(:question) {
      q = Doop::Doop.new
      q.yaml = 
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
      q.init
      q.ask_next
      q
    }

    it "is initialized with a YAML data structure" do
    end

    it "can be serialized" do
      dump = question.dump
      expect(dump).to include( "root" )
      expect(dump).to eq( Doop::Doop.new(dump).dump )
    end

    it "allows questions to be accessed like a file system" do
      expect(question["/root/age/_answer"] ).to eq(25)
      expect(question["/root/age"] ).not_to be_nil
      expect(question["/root/address/address_line_1/_answer"] ).to eq("21 The Grove")
      expect(question["/root/address/address_line_3/_answer"] ).to eq(nil)
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
      expect(question["/root/pets/_answer"] ).to be_nil

    end

  end


  describe "navigation and answering" do


    let(:question) {
      q = Doop::Doop.new 
      q.yaml=
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
      q.init
      q.ask_next
      q
    }

    it "remembers that last question to be answered" do
      expect(question.currently_asked).to eq( "/root/age" )
      question.answer( { "answer" => 36 } )
      expect(question.last_answered).to eq( "/root/age" )
      expect(question.currently_asked).to eq( "/root/address/address_line__1" )
      question.answer( { "answer" => "address1" } )
      expect(question.last_answered).to eq( "/root/address/address_line__1" )

    end

    it "gets the next unaswered question" do
      expect(question.currently_asked).to eq( "/root/age" )
    end


    it "allows question to be answered in order" do
      expect(question.currently_asked).to eq( "/root/age" )
      question.answer( { "answer" => 36 } )
      expect(question["/root/age/_answer"]).to eq( 36 )
      expect(question["/root/address/_open"]).to eq( true )
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
      question.change( "/root/address/address_line__1" )
      dump = question.dump
      expect( question.dump ).to eq( Doop::Doop.new(dump).dump )


      expect(question.currently_asked).to eq( "/root/address/address_line__1" )
      question.answer( {"answer" => "address1"} )
      expect(question.currently_asked).to eq( "/root/address/address_line__3" )

      question.change( "/root/age" )
      expect(question.currently_asked).to eq( "/root/age" )
      question.answer({ "answer" => 35} )
      expect(question.currently_asked).to eq( "/root/address/address_line__3" )
    end

    it "tells you if a question is being changed rather than just answered for the first time" do
      expect(question.currently_asked).to eq( "/root/age" )
      expect( question.is_being_changed("/root/age") ).to eq(false)
      question.answer( {"answer" => 36} )
      question.change( "/root/age" )
      expect( question.is_being_changed("/root/age") ).to eq(true)

    end

    it "provides a mechanism to see if all questions are answered under a given path" do

      expect(question.currently_asked).to eq( "/root/age" )
      question.answer( {"answer" => 36} )
      expect(question["/root/age/_answer"]).to eq( 36 )
      expect(question.currently_asked).to eq( "/root/address/address_line__1" )
      question.answer( {"answer" => "address1" } )
      expect(question.currently_asked).to eq( "/root/address/address_line__2" )
      question.answer( {"answer" => "address2"} )
      expect(question.currently_asked).to eq( "/root/address/address_line__3" )
      question.answer({ "answer" => "address3"} )
      expect(question.all_answered("/root/address")).to eq(true)
      expect(question.all_answered("/root")).to eq(false)
      question.answer({ "answer" => "provided"} )
      expect(question.all_answered("/root")).to eq(true)
      question.answer({ "answer" => "provided"} )
      expect(question.all_answered("/")).to eq(true)
    end

  end

  describe "on question answered callbacks" do

    let(:question) {
      q = Doop::Doop.new 
      q.yaml=
        <<-EOS
    
        root: {
          address: { 
            _question: "What is your address",
            address_line__1: { _question: "Address Line 1"},
            address_line__2: { _question: "Address Line 2"},
            address_line__3: { _question: "Address Line 3"}
          },
          age: {
            _question: "How old are you?",
            _on_answer_handler: "how_old_are_you"
          }

        }

        EOS
      q.init
      q.ask_next
      q

    }

    it "allows a callback when a question is answered.  This allows flows to be changed based on the answer" do

      question.on_answer "/root/address/address_line__1" do |root, path, context, answer|
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

    it "allows named handlers to be used" do
      question.on_answer "how_old_are_you" do |root,path,context,answer|
        root["_answered"] = true
      end
      question.answer( {} )
      question.answer( {} )
      expect(question.currently_asked).to eq( "/root/address/address_line__3" )
      question.answer( {"b_answer" => "test"} )
      expect( question[ "/root/address/address_line__3/_answer" ] ).to eq( "test" )
      question.answer( {} )
      expect(question.currently_asked).to eq( "/root/age" )
      question.answer( {"b_age" => 30 } )
      expect(question["/root/age/_answer/age"]).to eq( 30 )
    end

  end

  describe "on child question answered callbacks" do

    let(:nested_question) {
      q = Doop::Doop.new 

      q.yaml=
        <<-EOS
        root: {
          a: {
            b: {
              c1: {},
              c2: {}
            }
          }
        }
        EOS
      q.init
      q.ask_next
      q

    }

    let(:question) {
      q = Doop::Doop.new 
      q.yaml =
        <<-EOS
    
        root: {
          address: { 
            _question: "What is your address",
            address_line__1: { _question: "Address Line 1"},
            address_line__2: { _question: "Address Line 2"},
            address_line__3: { _question: "Address Line 3"}
          },
          age: {
            _question: "How old are you?",
            _on_answer_handler: "how_old_are_you"
          }

        }

        EOS
      q.init
      q.ask_next
      q

    }

    it "allows a callback when all nested questions have been answered" do
      question.on_all_nested_answer "/root/address" do |root,path,context|
        root["_answer"] = "answered!"
        root["_answered"] = true
      end

      expect(question.currently_asked).to eq( "/root/address/address_line__1" )
      question.answer( {} )
      expect(question.currently_asked).to eq( "/root/address/address_line__2" )
      question.answer( {} )
      expect(question.currently_asked).to eq( "/root/address/address_line__3" )
      question.answer( {} )
      # /root/address should be answered by the callback
      expect(question.currently_asked).to eq( "/root/age" )
    end

    it "recursively descends the question tree, making call backs" do
      nested_question.on_all_nested_answer "/root/a/b" do |root,path,context|
        root["_answer"] = "answered!"
        root["_answered"] = true
      end
      nested_question.on_all_nested_answer "/root/a" do |root,path,context|
        root["_answer"] = "answered!"
        root["_answered"] = true
      end

      expect(nested_question.currently_asked).to eq( "/root/a/b/c1" )
      nested_question.answer( {} )
      expect(nested_question.currently_asked).to eq( "/root/a/b/c2" )
      nested_question.answer( {} )
      expect(nested_question.currently_asked).to eq( "/root" )
    end

  end

  describe "on the fly structure manipulation" do

    let(:question) {
      q = Doop::Doop.new 
      q.yaml = 
        <<-EOS
    
        root: {
          address: { 
            _question: "What is your address",
            address_line__1: { _question: "Address Line 1"},
            address_line__2: { _question: "Address Line 2"},
            address_line__3: { _question: "Address Line 3"}
          },
          age: {
            _question: "How old are you?",
            _on_answer_handler: "how_old_are_you"
          }

        }

        EOS
      q.init
      q.ask_next
      q

    }

    it "allows questions to be removed and added in flight" do

      expect(question.currently_asked).to eq( "/root/address/address_line__1" )
      question.answer( {"answer"=>"address1"} )
      question.answer( {"answer"=>"address2"} )
      question.answer( {"answer"=>"address3"} )
      expect(question.currently_asked).to eq( "/root/address" )

      expect( question["/root/address/address_line__1/_answer"] ).to eq( "address1" ) 

      question.remove( "/root/address/address_line__1" )
      question.renumber( "/root/address" )
      question.ask_next
      expect( question["/root/address/address_line__1/_answer"] ).to eq( "address2" ) 

      question.add( "/root/address/address_line__3" )
      question.ask_next
      expect(question.currently_asked).to eq( "/root/address/address_line__3" )

    end
  end

end

