require 'rails_helper'
require 'pry'


feature "Check if you need to fill in a Self Assessment tax return" do

  scenario "Quick Check form", :js => true do
    quick_check
    test_matrix
  end

  def quick_check
    visit '/sasdemo/index'
    wait_for_page( "quick_check" )

    answer_question( "work_status" ) do
      choose "Employed ("
      click_button "Next Step" 
      expect( rollup_text ).to eq( "Employed" )
    end

    answer_question( "claiming_expenses" ) do
      choose "No"
      click_button "Next Step" 
    end

    answer_question( "income_over_100000" ) do
      choose "No"
      click_button "Next Step" 
    end

    answer_question( "child_benefit" ) do
      choose "No"
      click_button "Next Step" 
    end

    answer_question( "income_from_uk_property" ) do
      choose "No"
      click_button "Next Step" 
    end

    answer_question( "income_to_report" ) do
      choose "No"
      click_button "Next Step" 
    end

    answer_question( "capital_gains_tax" ) do
      choose "No"
      click_button "Next Step" 
    end

    answer_question( "other" ) do
      choose "None"
      click_button "Next Step" 
    end

    def test_matrix
      # should re-write as a gherkin
      test( { "work_status" => "Director of a company", :sa_required_box =>:visible } )
      test( { "work_status" => "Employed (", "claiming_expenses" => "Yes", :sa_required_box =>:visible } )
    end

    def test hash
      change_question( "work_status" ) {}
      hash.each do |id, val|

        if id.is_a? String
          answer_question( id ) do
            choose val
            click_button "Next Step" 
          end
        else
          find_by_id( id.to_s ) if val == :visible
        end

      end

    end

  end
end

