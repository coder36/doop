# encoding: utf-8

require 'doop'
require 'yaml'
require 'date'

class SasdemoController < ApplicationController

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
            quick_check: {
              _page: "quick_check",
              _nav_name: "Check if you need to fill in a Self Assessment tax return",
              _sa_required: false,
              _display_nav: false,
              work_status: {
                _question: "What's your work status?"
              },
              have_you_started_trading: {
                _question: "Have you started trading"
              },
              claiming_expenses: {
                _question: "Are you claiming expenses from employment of more that £2,500 per tax year ?"
              },
              income_over_100000: {
                _question: "Is your income over £100,000 per tax year"
              },
              child_benefit: {
                _question: "If you or your partner's income is over £50,000, do either of you get Child Benefit ?"
              },
              income_from_uk_property: {
                _question: "Do you have income from UK property or land?"
              },
              income_to_report: {
                _question: "Do you have any other income you need to report ?"
              },
              capital_gains_tax: {
                _question: "Do you expect to pay Capital Gains tax ?"
              },
              other: {
                _question: "Do any of the following apply to you ?"
              }
            }
          }
        EOS

      end

      def answer_and_validate question, path, answer
        doop["/page/quick_check/_sa_required"] = false
        return { :no_answer => "Please select an option" } if answer == nil
        answer_with( question, { "_summary" => answer } )
        enable_all_questions_after path, :setting_answered => false
        nil
      end

      def sa_required path
        disable_all_questions_after path
        doop["/page/quick_check/_sa_required"] = true
      end

      # QUICK_CHECK callbacks
     

      on_answer "/page/quick_check/work_status"  do |question,path, params, answer|
        res = answer_and_validate( question, path, answer )
        next res if res != nil
        enable_question "/page/quick_check/have_you_started_trading", :if => answer == "Self-employed"
        enable_question "/page/quick_check/claiming_expenses", :if => answer == "Employed"

        sa_required(path) if answer == "Director of a company"

      end

      on_answer "/page/quick_check/claiming_expenses"  do |question,path, params, answer|
        res = answer_and_validate( question, path, answer )
        next res if res != nil
        sa_required(path) if answer == "Yes"
      end

      on_answer "/page/quick_check/have_you_started_trading"  do |question,path, params, answer|
        res = answer_and_validate( question, path, answer )
        next res if res != nil
      end

      on_answer "/page/quick_check/income_over_100000"  do |question,path, params, answer|
        res = answer_and_validate( question, path, answer )
        next res if res != nil
        sa_required(path) if answer == "Yes"
      end

      on_answer "/page/quick_check/child_benefit"  do |question,path, params, answer|
        res = answer_and_validate( question, path, answer )
        next res if res != nil
        sa_required(path) if answer == "Yes, and my income is higher then my partner's"
      end

      on_answer "/page/quick_check/income_from_uk_property"  do |question,path, params, answer|
        res = answer_and_validate( question, path, answer )
        next res if res != nil
        sa_required(path) if answer != "No"
      end

      on_answer "/page/quick_check/income_to_report"  do |question,path, params, answer|
        res = answer_and_validate( question, path, answer )
        next res if res != nil
        sa_required(path) if answer == "Yes"
      end

      on_answer "/page/quick_check/capital_gains_tax"  do |question,path, params, answer|
        res = answer_and_validate( question, path, answer )
        next res if res != nil
        sa_required(path) if answer == "Yes"
      end

      on_answer "/page/quick_check/other"  do |question,path, params, answer|
        res = answer_and_validate( question, path, answer )
        next res if res != nil
        if answer == "None of these"
          doop["/page/quick_check/_sa_required"] = false
        else
          sa_required(path)
        end
      end

    end


  end

end
