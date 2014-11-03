require 'rails_helper'
require 'pry'


feature "Doop questionnaire" do

  scenario "Quick run through", :js => true do
    load_completed_form
  end

  scenario "Changing an answer, causes change_answer_tool_tip_text to appear", :js => true do
    load_completed_form
    change_page( "Apply Online" )
    change_question( "Have you enrolled for this service before") do 
      expect(change_answer_tooltip_text).to match /additional questions may be asked/
    end
  end

  scenario "Answering a question results in a tooltip appearing", :js => true do
    load_completed_form
    change_page( "Apply Online" )
    change_question( "Turn debug on") do 
      click_button "No" 
      expect(tooltip_text).to match /Are you sure/
    end
  end

  scenario "Answering a question results in a new question being asked", :js => true do
    load_completed_form
    change_page( "Apply Online" )
    change_question( "Have you enrolled for this service before")  { click_button "Yes" }
    expect( question "What year did you last apply" ).to be_enabled
    change_question( "Have you enrolled for this service before")  { click_button "No" }
    expect( question "What year did you last apply" ).to be_disabled
  end

  def load_completed_form
    
    if $completed_form_yaml != nil
      visit '/demo/harness'
      fill_in( "doop_data", :with => $completed_form_yaml )
      click_button "Render"
      return
    end

    visit '/demo/index'
    wait_for_page( "Apply Online" )
    answer_question( "Turn debug on") { click_button "Yes" }
    answer_question( "Have you enrolled for this service before")  { click_button "Yes" }
    answer_question( "What year did you last apply")  { select( '2012', :from => 'b_answer' ); click_button "Continue"  }
    answer_question( "Why are you applying")  { fill_in( 'b_answer', :with => "My circumstances have changed" ); click_button "Continue"}
    click_button "Continue and Save"

    wait_for_page( "Your Details" )
    answer_question( "What is your name") do 
      b_fill_in( "firstname" => "mark", "surname" => "middleton" )
      click_button "Continue" 
      expect(rollup_text).to be == "Mark Middleton" 
    end
    address = { "address1" => "1 Runswick Avenue", "address2" => "Telford", "address3" => "Shropshire", "postcode" => "T56 HDJ" }
    answer_question( "Address 1") { b_fill_in( address); click_button "Continue" }
    click_button "Continue"
    click_button "Continue and Save"

    wait_for_page( "Summary" )
    answer_question( "Terms and conditions") { click_button "I have read" }
    $completed_form_yaml = page.find_by_id( "doop_data", :visible => false).value
  end

end
