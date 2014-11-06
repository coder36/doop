
    RSpec::Matchers.define :be_asked do 
      match do |q_title|
        page.find_by_id( "#{q_title}-open" )
      end

      failure_message do |q_title|
        "Expected question with id #{q_title} to be asked"
      end

    end

    RSpec::Matchers.define :be_enabled do 
      match do |q_title|
        page.find_by_id( q_title )
      end
    end

    RSpec::Matchers.define :be_disabled do 
      match do |q_title|
        expect(page).to have_no_selector( "##{q_title}" )
      end
    end

    RSpec::Matchers.define :be_visible do 
      match do |id|
        page.find_by_id( id )
      end
    end

    def question text
      text
    end

    def change_question q_title, &block
      @q_title = q_title
      page.find_by_id( "#{q_title}-change" ).click
      expect( question q_title ).to be_asked
      yield block
    end

    def answer_question q_title, &block
      @q_title = q_title
      expect( question q_title ).to be_asked
      yield block
      page.find_by_id( "#{q_title}-closed" )
    end

    def rollup_text
      page.find_by_id( "#{@q_title}-change" ).text
    end

    def change_answer_tooltip_for q_id
      "#{q_id}-change-answer-tooltip"
    end

    def tooltip
      "#{@q_title}-tooltip"
    end

    def change_answer_tooltip
      "#{@q_title}-change-answer-tooltip"
    end

    def wait_for_page p_title
      page.find_by_id( "#{p_title}-page" )
    end

    def page_title
      page.find_by_id( "page_title").text
    end

    def b_fill_in options = {}
      options.keys.each do |key|
        page.fill_in( "b_#{key}", :with => options[key] )
      end
    end

    def change_page page_name
      page.find_by_id( "#{page_name}-nav" ).click
      wait_for_page page_name
    end
