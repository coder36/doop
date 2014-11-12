require 'rails_helper'
require 'pry'


feature "Child Benefit online form" do

  scenario "Complete Child Benefit form", :js => true do
    before_you_begin
    preamble
    about_you
    children
    declaration

    page_navigation
  end

  def before_you_begin
    visit '/demo/index'
    wait_for_page( "before_you_begin" )
    click_button "Start"
  end

  def preamble
    wait_for_page( "preamble" )

    # check income_more_than_50000 alternate flows
    answer_question( "income_more_than_50000")  do
      click_button "No,"
      expect( tooltip ).to be_visible
    end
    expect( question "do_you_still_want_to_apply" ).to be_disabled

    change_question( "income_more_than_50000") do
      expect( change_answer_tooltip ).to be_visible
      click_button "Yes," 
    end

    expect( question "do_you_still_want_to_apply" ).to be_enabled

    answer_question( "do_you_still_want_to_apply")  { click_button "Yes," }

    answer_question( "proof_of_id" ) { click_button "Continue" }
    click_button "Continue" 
  end


  def about_you
    wait_for_page( "about_you" )
    answer_question( "your_name") do
      b_fill_in( "title" => "Mr", "surname" => "Middleton", "firstname" => "Mark", "middlenames" => "Alan")
      click_button "Continue" 
      expect( rollup_text ).to eq( "Mr Mark Alan Middleton" )
    end
    answer_question( "known_by_other_name" ) { click_button "No," }
    expect( question "previous_name" ).to be_disabled
    change_question( "known_by_other_name" ) { click_button "Yes," }
    expect( question "previous_name" ).to be_enabled

    answer_question( "previous_name" ) { b_fill_in( "answer" => "Bob Smith"); click_button "Continue" }

    answer_question( "dob" ) do
      b_fill_in( "answer" => "25/02/1977")
      click_button "Continue"
      expect( rollup_text ).to eq( "25 February 1977" )
    end

    answer_question( "your_address" ) do
      b_fill_in( "address1" => "1 Runswick Avenue", "address2" => "Woolston", "address3" => "Leeds", "postcode" => "LE31 4WP" )
      click_button "Continue"
      expect( rollup_text ).to eq( "1 Runswick Avenue, LE31 4WP" )
    end

    answer_question( "lived_at_address_for_more_than_12_months" ) { click_button "Yes," }
    expect( question "last_address" ).to be_disabled
    change_question( "lived_at_address_for_more_than_12_months" ) { click_button "No," }
    expect( question "last_address" ).to be_enabled

    answer_question( "last_address" ) do
      b_fill_in( "address1" => "5 Runswick Avenue", "address2" => "Woolston", "address3" => "Leeds", "postcode" => "LE31 4WP" )
      click_button "Continue"
      expect( rollup_text ).to eq( "5 Runswick Avenue, LE31 4WP" )
    end

    answer_question( "your_phone_numbers" ) do
      b_fill_in( "daytime" => "01235 6789117", "evening" => "01235 678117" )
      click_button "Continue"
      expect( rollup_text ).to eq( "Provided" )
    end

    answer_question( "have_nino" ) { click_button "No," }
    expect( question "nino" ).to be_disabled

    change_question( "have_nino" ) { click_button "Yes," }
    expect( question "nino" ).to be_enabled

    answer_question( "nino" ) do
      b_fill_in( "answer" => "00123456A" )
      click_button "Continue"
      expect( rollup_text ).to eq( "00123456A" )
    end

    click_button "Continue"
  end

  def children
    wait_for_page( "children" )

    # child__1
    answer_question( "name" ) do 
      b_fill_in( "firstname" => "Padraig", "middlenames" => "Alan", "surname" => "Middleton" ); click_button "Continue" 
      expect( rollup_text ).to eq ( "Padraig Alan Middleton" )
    end
    answer_question( "gender" ) { click_button "Male" }
    answer_question( "dob" ) { b_fill_in( "answer" => "30/09/2006" ); click_button "Continue" }
    answer_question( "own_child" ) { click_button "Yes," }
    answer_question( "birth_certificate" ) { click_button "Continue" }
    answer_question( "child__1" ) { click_button "Continue" }

    # child__2
    click_button "Add another child"
    answer_question( "name" ) do 
      b_fill_in( "firstname" => "Annie", "middlenames" => "", "surname" => "Middleton" ); click_button "Continue" 
      expect( rollup_text ).to eq ( "Annie Middleton" )
    end
    answer_question( "gender" ) { click_button "Female" }
    answer_question( "dob" ) { b_fill_in( "answer" => "24/02/2008" ); click_button "Continue" }
    answer_question( "own_child" ) { click_button "Yes," }
    answer_question( "birth_certificate" ) { click_button "Continue" }
    answer_question( "child__2" ) { click_button "Continue" }

    # remove child__2
    change_question( "child__2" ) {
      click_button "Remove child"
    }

    expect( question "child__2" ).to be_disabled
    click_button "Continue"

  end

  def declaration
    wait_for_page( "declaration" )
  end

  def page_navigation
    wait_for_page( "declaration" )
    change_page( "about_you" )
    back_a_page
    wait_for_page( "preamble" )
    back_a_page
    wait_for_page( "before_you_begin" )
    click_button "Start"
    wait_for_page( "preamble" )
    click_button "Continue"
    wait_for_page( "about_you" )
    click_button "Continue"
    wait_for_page( "children" )
    click_button "Continue"
    wait_for_page( "declaration" )
  end

end
