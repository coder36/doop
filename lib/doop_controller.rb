require 'yaml'
require 'rails'

module Doop

  class DoopController

    delegate :set_yaml, :unanswer_path, :add, :renumber, :on_answer, :answer_with, :enable, :remove, to: :@doop

    attr_reader :doop

    def initialize application_controller, &block
      @controller = application_controller
      @block = block
      @debug_on_block = nil
      @current_page_block = method( :default_current_page )
      @all_pages_block = method( :default_all_pages )
    end

    def index
      render_page in_doop { |doop| doop.ask_next }
    end

    def answer
      back_val = @controller.params["back_a_page"]
      nav_path = @controller.params["nav_path"]
      change_answer_path = @controller.params["change_answer_path"]
      return back if back_val != nil && !back_val.empty?
      return change_page nav_path if nav_path != nil && !nav_path.empty?
      return change change_answer_path if change_answer_path != nil && !change_answer_path.empty?

      render_page in_doop { |doop| doop.answer( @controller.params ) }
    end

    def back
      in_doop do |doop|
        page = get_page_path
        pages = get_all_pages
        i = pages.index(page)
        if i!=0
          path = pages[i-1]
          doop.change( path )
          pages[pages.index(path), pages.length].each do |n|
            doop[n]["_answered"] = false
          end

          doop.ask_next
        end
      end
      render_page
    end

    def change path
      res = in_doop do
        |doop| doop.change( path ) 
      end
      render_page res
    end

    def change_page path
      in_doop do |doop|
        #path = @controller.params["path"]
        doop.change( path )

        # unanswer all pages after path
        pages = @all_pages_block.call 
        pages[pages.index(path), pages.length].each do |n|
          doop[n]["_answered"] = false
        end

        doop.ask_next
      end
      render_page
    end

    def parent_of path
      p = path.split("/")
      p.pop
      p.join("/")
    end

    def render_page res = {}
      res[:page] = get_page
      res[:page_path] = get_page_path
      res[:page_title] = @doop[res[:page_path]]["_nav_name"]
      res[:all_pages] = get_all_pages
      res[:debug_on] = @debug_on_block != nil ? @debug_on_block.call : false
      @controller.render "index", :locals => { :res => res, :doop => @doop }
    end

    def load
      @doop = Doop.new()
      @self_before_instance_eval = eval "self", @block.binding
      instance_exec @doop, &@block
      @doop.yaml = @load_yaml_block.call
      @doop.init
      @doop
    end

    def in_doop
      load
      res = yield(@doop)
      @save_yaml_block.call @doop.dump
      return res if res.kind_of? Hash
      {}
    end

    def evaluate(block)
      @self_before_instance_eval = eval "self", block.binding
      instance_eval &block
    end

    def method_missing(method, *args, &block)
      @self_before_instance_eval.send method, *args, &block
    end

    def current_page &block
      @current_page_block = block
    end

    def all_pages &block
      @all_pages_block = block
    end

    def get_page
      path = @doop.currently_asked
      @doop[@current_page_block.call( path )]["_page"]
    end

    def get_page_path
      path = @doop.currently_asked
      @current_page_block.call( path )
    end

    def get_all_pages
      @all_pages_block.call
    end

    def debug_on &block
      @debug_on_block = block
    end

    def load_yaml &block
      @load_yaml_block = block
    end

    def save_yaml &block
      @save_yaml_block = block
    end

    def default_current_page path 
      a = path.split("/").reject {|s| s.empty? }[1] 
      "/page/#{a}"
    end

    def default_all_pages 
      l = []
      doop.each_question_with_regex_filter "^\/page/\\w+$" do |question,path|
        l << path if doop[path]["_enabled"]
      end
      l
    end
  end
end
