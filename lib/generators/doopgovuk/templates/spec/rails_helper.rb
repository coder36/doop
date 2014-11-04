# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require 'spec_helper'
require File.expand_path("../../config/environment", __FILE__)
require 'capybara'
require 'capybara/rails'
require 'capybara/rspec'
require 'capybara-webkit'
require 'headless'
require 'capybara-screenshot/rspec'


Capybara.javascript_driver = :webkit

# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|

  config.before(:suite) do
    @headless = Headless.new
    @headless.start
  end

  config.after(:suite) do
    @headless.destroy
  end

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  #config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  #config.use_transactional_fixtures = true

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  #config.infer_spec_type_from_file_location!
end

RSpec::Matchers.define :be_asked do 
  match do |q_title|
    page.has_css?( '.question-open h2', :text => q_title )
  end

  failure_message do |q_title|
    actual = page.all( '.question-open h2', ).last.text
    "Expected question to be asked: #{q_title}, but was asked #{actual}"
  end

end

RSpec::Matchers.define :be_enabled do 
  match do |q_title|
    page.has_css?( '.question_title', :text => q_title )
  end
end

RSpec::Matchers.define :be_disabled do 
  match do |q_title|
    page.has_no_css?( '.question_title', :text => q_title )
  end
end

def question text
  text
end

def change_question q_title, &block
  @q_title = q_title
  page.find( '.question-closed div.title', :text => q_title ).find(:xpath, "..").find( 'div.answer a' ).click
  expect( question q_title ).to be_asked
  yield block
end

def answer_question q_title, &block
  @q_title = q_title
  expect( question q_title ).to be_asked
  yield block
  page.find( '.question-closed div.title', :text => q_title )
end

def rollup_text
  page.find( '.question-closed div.title', :text => @q_title ).find(:xpath, '..').find( 'div.answer').text
end

def tooltip_text
  page.find( '.tooltip' ).text
end

def change_answer_tooltip_text
  page.find( '.change_answer_tooltip' ).text
end

def wait_for_page p_title
  page.find_by_id( "page_title", :text=>p_title)
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
  page.find_link( page_name ).click
  wait_for_page page_name
end
