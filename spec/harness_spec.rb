require 'spec_helper'


describe "HMRC Self Assessment form" do

  let(:form) {
   <<-EOS
      root: {
        
        your_personal_details: {
          _question: "Your Personal Deatils",
          date_of_birth: { _question: "Your date of birth - it helps get your tax right (DD MM YY)"},
          phone_number: { _question: "Your phone number"},
          name_and_address: {
            first_name: { _question: "Your firstnames"},
            surname: { _question: "Your surname"},
            address_1: { _question: "Address Line 1"},
            address_2: { _question: "Address Line 2"},
            address_3: { _question: "Address Line 3"},
            postcode: { _question: "Postcode"}
          },
          nino: { _question: "Your National Insurance Number"  }

        }

      }

      EOS
  }

  it "parses" do
    harness = Doop::Harness.new( form )
  end



end


