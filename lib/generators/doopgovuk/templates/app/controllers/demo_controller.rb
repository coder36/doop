
require 'doop'
require 'yaml'

class DemoController < ApplicationController

  delegate :index, :answer, to: :@doop_controller
  before_filter :setup_doop

  def setup_doop
    @doop_controller = Doop::DoopController.new self do |doop|

      load_yaml do
        data = params["doop_data"] 
        if data != nil
          if Rails.env.development? || Rails.env.test?
            next data
          else
            next ActiveSupport::MessageEncryptor.new(Rails.application.secrets.secret_key_base).decrypt_and_verify data if !Rails.env.development?
          end
        end

        <<-EOS
          page: {
            preamble: {
              _page: "preamble",
              _nav_name: "Apply Online",

              debug_on: {
                _question: "Turn debug on ?",
                _answer: "No"
              },
              enrolled_before: {
                _question: "Have you enrolled for this service before ?"
              },
              year_last_applied: {
                _question: "What year did you last apply?"
              },
              reason_for_applying: {
                _question: "Why are you applying?"
              }
            },
            your_details: {
              _page: "your_details",
              _nav_name: "Your Details",

              your_name: {
                _question: "What is your name?",
                _answer: {},
              },
              address_history: {
                _question: "What is your address ?",
                address__1: { _answer: {} }
              }

            },
            summary: {
              _page: "summary",
              _nav_name: "Summary",

              terms_and_conditions: {
                _question: "Terms and conditions"
              }
            }

          }
        EOS

      end

      save_yaml do |yaml|
        if Rails.env.development? || Rails.env.test?
          request["doop_data"] = yaml
        else
          crypt = ActiveSupport::MessageEncryptor.new(Rails.application.secrets.secret_key_base)
          data = crypt.encrypt_and_sign(yaml)
          request["doop_data"] = data
        end
      end

      debug_on do 
        doop["/page/preamble/debug_on/_answer"] == "Yes"
      end

      # On answer call backs

      on_answer "/page/preamble/debug_on"  do |question,path, params, answer|
        answer_with( question, { "_summary" => answer } )
      end

      on_answer "/page/preamble/enrolled_before"  do |question,path, params, answer|
        answer_with( question, { "_summary" => answer } )
        enable( "/page/preamble/year_last_applied", answer == "Yes" )
      end

      on_answer "/page/preamble/year_last_applied" do |question,path,params,answer|
        answer_with( question, { "_summary" => answer } )
      end

      on_answer "/page/preamble/reason_for_applying" do |question,path,params,answer|
        if answer.empty? 
          next { :reason_for_applying_error => "This can not be blank" }
        end

        answer_with( question, { "_summary" => "Provided" } )
      end

      on_answer( "/page/preamble" ) do |question, path, params, answer|
        answer_with( question, { "_summary" => "Provided" } )
      end

      on_answer( "/page/your_details/your_name" ) do |question, path, params, answer|
        firstname = answer["firstname"].capitalize
        surname = answer["surname"].capitalize
        answer_with( question, { "_summary" => "#{firstname} #{surname}" } )
      end

      on_answer( "/page/your_details/address_history/address__(\\d+)" ) do |question, path, params, answer|

        if params.include?("remove_address")
          remove path
          next
        end

        address1 = answer["address1"]
        address2 = answer["address2"]
        address3 = answer["address3"]
        postcode = answer["postcode"]
        summary = [address1, address2, address3, postcode].select{ |n| !n.empty? }.join( ", ")
        answer_with( question, { "_summary" => summary } )

      end

      on_answer( "/page/your_details/address_history" ) do |question, path, params, answer|
        if params.include?("add_address")
          address = YAML.load("{ _answer: {}}")
          add( "/page/your_details/address_history/address__99", address )
          renumber( "/page/your_details/address_history" )
          next
        end

        answer_with( question, { "_summary" => "Provided" } )
      end

      on_answer( "/page/your_details" ) do |question, path, params, answer|
        answer_with( question, { "_summary" => "Provided" } )
      end

      on_answer( "/page/your_details" ) do |question, path, params, answer|
        answer_with( question, { "_summary" => "Provided" } )
      end

      on_answer( "/page/summary/terms_and_conditions" ) do |question, path, params, answer|
        answer_with( question, { "_summary" => "Accepted" } )
      end

    end
  end


end

