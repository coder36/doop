# encoding: utf-8

require 'doop'
require 'yaml'
require 'date'

class DemoController < ApplicationController

  delegate :index, :answer, to: :@doop_controller
  before_filter :setup_doop

  def harness
    return if request.get?
    @doop_controller.inject_yaml params["yaml"]
    index
  end
  
  def setup_doop
    @doop_controller = Doop::DoopController.new self do |doop|

      yaml do

        <<-EOS
          page: {
            before_you_begin: {
              _page: "before_you_begin",
              _nav_name: "Before you begin",
            },
            preamble: {
              _page: "preamble",
              _nav_name: "Preamble",

              income_more_than_50000: {
                _question: "Does you or your partner have an individual income of more than £50,000 a year ?"
              },
              do_you_still_want_to_apply: {
                _question: "Do you still want to apply for child benefit?"
              }
            },
            about_you: {
              _page: "about_you",
              _nav_name: "About You",

              your_name: {
                _question: "What is your name?",
                _answer: {}
              },
              known_by_other_name: {
                _question: "Have you ever been known by another surname ?"
              },
              previous_name: {
                _question: "What name were you previously known by ?"
              },
              dob: {
                _question: "Your date of birth"
              },
              your_address: {
                _question: "Your address",
                _answer: {}
              },
              lived_at_address_for_more_than_12_months: {
                _question: "Have you lived at this address for more than 12 months ?"
              },
              last_address: {
                _question: "What was your last address ?",
                _answer: {}
              },
              your_phone_numbers: {
                _question: "What numbers can we contact you on ?",
                _answer: {}
              },
              have_nino: {
                _question: "Do you have a national insurance number ?"
              },
              nino: {
                _question: "What is your national insurance number ?"
              }

            },
            children: {
              _page: "children",
              _nav_name: "Children",
              how_many_birth_certs: {
                _question: "How many birth certificates are you sending us?"
              },
              #{child_yaml}
            },
            declaration: {
              _page: "declaration",
              _nav_name: "Declaration",
            }

          }
        EOS

      end

      def child_yaml 
        <<-EOS
              child__1: {
                name: {
                  _question: "Child's name",
                  _answer: {}
                },
                gender: {
                  _question: "Is this child male or female ?"
                },
                dob: {
                  _question: "Child's date of birth"
                },
                own_child: {
                  _question: "Is this child your own child ?"
                }
             }
          EOS
      end


      # PREAMBLE callbacks

      on_answer "/page/preamble/income_more_than_50000"  do |question,path, params, answer|
        answer_with( question, { "_summary" => answer } )
        enable( "/page/preamble/do_you_still_want_to_apply", answer == 'Yes' )
      end

      on_answer "/page/preamble/do_you_still_want_to_apply"  do |question,path, params, answer|
        answer_with( question, { "_summary" => "Yes" } )
      end



      # ABOUT YOU callbacks

      on_answer "/page/about_you/your_name"  do |question,path, params, answer|
        res = validate( answer, ["title", "firstname", "surname"] )
        next res if !res.empty?

        name = "#{answer['title']} #{answer['firstname']} #{answer['middlenames']} #{answer['surname']}".squish
        formatted_name = name.split( " ").map{ |n| n.capitalize }.join( " ")
        answer_with( question, { "_summary" => formatted_name } )
      end

      on_answer "/page/about_you/known_by_other_name"  do |question,path, params, answer|
        answer_with( question, { "_summary" => answer } )
        enable( "/page/about_you/previous_name", answer == 'Yes' )
      end

      on_answer "/page/about_you/previous_name"  do |question,path, params, answer|
        res = validate( answer )
        next res if !res.empty?
        answer_with( question, { "_summary" => answer } )
      end

      on_answer "/page/about_you/dob"  do |question,path, params, answer|
        d = format_date answer
        next { :answer_error => "Date of birth must be formated as dd/mm/yyyy" } if d.nil?
        answer_with( question, { "_summary" => d } )
      end

      on_answer "/page/about_you/your_address"  do |question,path, params, answer|
        res = validate( answer, ["address1", "address2", "address3", "postcode"] )
        next res if !res.empty?

        a = "#{answer['address1']}, #{answer['postcode']}"
        answer_with( question, { "_summary" => a } )
      end

      on_answer "/page/about_you/lived_at_address_for_more_than_12_months" do |question, path, params, answer|
        answer_with( question, { "_summary" => answer } )
        enable( "/page/about_you/last_address", answer == 'No' )
      end

      on_answer "/page/about_you/last_address"  do |question,path, params, answer|
        res = validate( answer, ["address1", "address2", "address3", "postcode"] )
        next res if !res.empty?

        a = "#{answer['address1']}, #{answer['postcode']}"
        answer_with( question, { "_summary" => a } )
      end

      on_answer "/page/about_you/your_phone_numbers"  do |question,path, params, answer|
        res = validate( answer, ["daytime", "evening"] )
        next res if !res.empty?
        answer_with( question, { "_summary" => "Provided" } )
      end

      on_answer "/page/about_you/have_nino" do |question, path, params, answer|
        answer_with( question, { "_summary" => answer } )
        enable( "/page/about_you/nino", answer == 'Yes' )
      end

      on_answer "/page/about_you/nino" do |question, path, params, answer|
        res = validate( answer )
        next res if !res.empty?
        answer_with( question, { "_summary" => answer } )
      end

      on_answer "/page/children/how_many_birth_certs"  do |question,path, params, answer|
        res = validate( answer )
        next res if !res.empty?
        next { :answer_error => "Must be a number" } if !is_number answer


        answer_with( question, { "_summary" => answer } )
      end

      on_answer "/page/children/child__(\\d+)/name"  do |question,path, params, answer|
        res = validate( answer, ["firstname", "surname"] )
        next res if !res.empty?

        name = "#{answer['firstname']} #{answer['middlenames']} #{answer['surname']}".squish
        formatted_name = name.split( " ").map{ |n| n.capitalize }.join( " ")
        answer_with( question, { "_summary" => formatted_name } )
      end

      on_answer "/page/children/child__(\\d+)/gender"  do |question,path, params, answer|
        answer_with( question, { "_summary" => answer } )
      end

      on_answer "/page/children/child__(\\d+)/dob"  do |question,path, params, answer|
        d = format_date answer
        next { :answer_error => "Date of birth must be formated as dd/mm/yyyy" } if d.nil?
        answer_with( question, { "_summary" => d } )
      end

      on_answer "/page/children/child__(\\d+)/own_child"  do |question,path, params, answer|
        answer_with( question, { "_summary" => answer } )
      end

      on_answer "/page/children/child__(\\d+)"  do |question,path, params, answer|
        if params.include?("remove_child")
          remove path
          renumber "/page/children"
          next
        end
        name = doop["#{path}/name/_answer"]
        answer_with( question, { "_summary" => doop["#{path}/name/_summary"] } )
      end

      on_answer "/page/children" do |question, path, params, answer|
        if params.include?("add_child")
          add( "/page/children/child__99", YAML.load( child_yaml )["child__1"] )
          renumber( "/page/children" )
          next
        end
        answer_with( question, { "_summary" => "Provided" } )
      end

      on_answer "/page/declaration" do |question, path, params, answer |
        { :redirect => "https://github.com/coder36/doop" }
      end

    end
  end

  def format_date d
    begin
      return nil if d.length != 10
      Date.strptime( d, "%d/%m/%Y" ).strftime( "%-d %B %Y" )
    rescue
      nil
    end
  end

  def validate answer,fields=nil
    res = {}

    if fields == nil
        res["answer_error".to_sym] = "Can not be empty" if answer.squish.empty?
        return res
    end

    fields.each do |f|
      res["#{f}_error".to_sym] = "Can not be empty" if answer[f].squish.empty?
    end
    res
  end

  def is_number num
    num =~ /\A[-+]?[0-9]*\.?[0-9]+\Z/
  end

end
