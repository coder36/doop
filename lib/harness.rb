require 'colorize'
require 'pry'
module Doop
  class Harness
    def initialize doop
      @doop = doop
      @res = {}
      @questions = []
    end

    
    def start
      while true
        draw_screen
        inp = input
        if inp != nil
          @res = @doop.answer( { "answer"=>inp, "summary"=>inp.upcase } )
        end
      end
    end

    def input 
      inp = STDIN.gets.chomp
      exit(0) if inp == "quit"

      m = inp.match( /change (\d)+/ )
      if m != nil
        #binding.pry
        @doop.change( @questions[m[1].to_i - 1 ] )
        return nil
      end

      inp
    end

    def draw_screen
      clear_screen

      current_question = @doop.currently_asked

      if @res["error"] != nil
        puts "Error: #{@res['error']}".red

      end
      @questions = []
      index = 1

      #@doop.each_question do |root,path|
      @doop.each_visible_question do |root,path|
        @questions << path
        question = root[ "_question"]
        answer = root["_answer"] ==  nil ? "" : root["_answer"]
        summary = root["_summary"] == nil ? "" : root["_summary"]
        open = root["_open"]
        answered = root["_answered"]

        n = nest(path.count("/"), index)
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
        index += 1

      end

      puts "\n\n----\n"
      puts "#{@doop[current_question]["_question"]}"


    end

    def nest depth, index
      sprintf( "%2d", index) + "  " * depth

    end

    def index

    end




    def clear_screen
      print "\e[2J\e[f"
    end

  end


end
