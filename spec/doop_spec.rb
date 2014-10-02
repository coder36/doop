require "spec_helper"

describe "doop" do

  let(:question) {
    Question.new( 
      <<-EOS
  
      root: {
        age: {answer: 25},
        address: { 
          address_line_1: { answer: "21 The Grove" },
          address_line_2: { answer: "Telford" },
          address_line_3: {}
        },

        pets: {
          pet__8: { answer: "Claude" },
          pet__3: { answer: "Lucy" }
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
    expect(question["/root/age/answer"] ).to eq(25)
    expect(question["/root/age"] ).to eq({"answer"=>25})
    expect(question["/root/address/address_line_1/answer"] ).to eq("21 The Grove")
    expect(question["/root/address/address_line_3/answer"] ).to eq(nil)
  end

  it "allows questions to be answered" do
    question["/root/address/address_line_3/answer"] = "Shropshire" 
    expect(question["/root/address/address_line_3/answer"] ).to eq("Shropshire")

    yaml = <<-EOS

      address_line_1: { answer: "AAA" }
      address_line_2: { answer: "BBB" }

    EOS

    question["/root/address"] = YAML.load(yaml)
    expect(question["/root/address/address_line_1/answer"] ).to eq("AAA")

  end

  it "allows questions to be added" do
    question.add( "/root/address/address_line_4" )
    question["/root/address/address_line_4/answer"] = "XXX"
    expect(question["/root/address/address_line_4/answer"] ).to eq("XXX")
  end

  it "allows questions to be removed" do
    question.remove( "/root/address/address_line_1" )
    expect(question["/root/address/address_line_1"] ).to eq(nil)
  end

  it "allows questions to be moved" do
    question.move( "/root/address/address_line_1", "/root/address/address_line_6" )
    expect(question["/root/address/address_line_1"] ).to eq(nil)
    expect(question["/root/address/address_line_6/answer"] ).to eq("21 The Grove")
  end

  it "allows question to be renumbered in sequence" do
    question.renumber( "/root/pets" )
    expect(question["/root/pets/pet__1/answer"] ).to eq("Lucy")
    expect(question["/root/pets/pet__2/answer"] ).to eq("Claude")
  end




end
