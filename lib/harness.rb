require 'colorize'
module Doop
  class Harness
    def initialize doop
      @doop = doop
      @res = {}
    end

    
    def start
      while true
        draw_screen
        inp = input
        @res = @doop.answer( { "answer"=>inp, "summary"=>inp.upcase } )
      end
    end

    def input 
      inp = STDIN.gets.chomp
      exit(0) if inp == "QUIT"
      inp
    end

    def draw_screen
      clear_screen

      current_question = @doop.currently_asked

      if @res["error"] != nil
        puts "Error: #{@res['error']}".red

      end

      @doop.each_question do |root,path|
        question = root[ "_question"]
        answer = root["_answer"] ==  nil ? "" : root["_answer"]
        summary = root["_summary"] == nil ? "" : root["_summary"]
        open = root["_open"]
        answered = root["_answered"]

        n = nest(path.count("/"))
        s = ""

        if open
          if path == current_question
            puts n + "==> " + question.colorize(:white).underline
          else
            puts n + question.colorize(:blue)
          end
        elsif answered == true
          puts n + question.colorize(:blue).on_light_blue + " --> " + summary.colorize(:green)
        end

      end

      puts "\n\n----\n"
      puts "#{@doop[current_question]["_question"]}"


    end

    def nest depth
      "  " * depth

    end


    def clear_screen
      print "\e[2J\e[f"
    end

  end


end
