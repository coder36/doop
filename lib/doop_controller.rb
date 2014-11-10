require 'yaml'
require 'rails'

module Doop

  class DoopController

    delegate :set_yaml, :unanswer_path, :add, :renumber, :on_answer, :answer_with, :enable, :remove, to: :@doop

    attr_reader :doop

    def initialize application_controller, &block
      @controller = application_controller
      @block = block
    end

    def index
      render_page in_doop { |doop| doop.ask_next }
    end

    def answer
      back_val = @controller.params["back_a_page"]
      nav_path = @controller.params["nav_path"]
      change_answer_path = @controller.params["change_answer_path"]
      return back if back_val != nil 
      return change_page nav_path if nav_path != nil
      return change change_answer_path if change_answer_path != nil

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
        pages = all_pages 
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

      redirect_url = res[:redirect]

      if ! redirect_url.nil?
        @controller.respond_to do |format|
          format.js { @controller.render :js => "window.location.href='#{redirect_url}'" }
          format.html { redirect_to redirect_url }
        end
        return
      end

      res[:page] = get_page
      res[:page_path] = get_page_path
      res[:page_title] = @doop[res[:page_path]]["_nav_name"]
      res[:all_pages] = get_all_pages
      @controller.render "index", :locals => { :res => res, :doop => @doop }
    end

    def load
      @doop = Doop.new()
      @self_before_instance_eval = eval "self", @block.binding
      instance_exec @doop, &@block
      @doop.yaml = load_yaml
      @doop.init
      @doop
    end

    def in_doop
      load
      res = yield(@doop)
      save_yaml @doop.dump
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

    def get_page
      path = @doop.currently_asked
      @doop[current_page( path )]["_page"]
    end

    def get_page_path
      path = @doop.currently_asked
      current_page( path )
    end

    def load_yaml
      data = params["doop_data"] 
      return ActiveSupport::MessageEncryptor.new(Rails.application.secrets.secret_key_base).decrypt_and_verify(data) if !data.nil?
      @yaml_block.call
    end

    def save_yaml yaml
      @controller.request["doop_data"] = ActiveSupport::MessageEncryptor.new(Rails.application.secrets.secret_key_base).encrypt_and_sign(yaml)
    end

    def yaml &block
      @yaml_block = block
    end

    def current_page path 
      a = path.split("/").reject {|s| s.empty? }[1] 
      "/page/#{a}"
    end

    def get_all_pages 
      l = []
      doop.each_question_with_regex_filter "^\/page/\\w+$" do |question,path|
        l << path if doop[path]["_enabled"]
      end
      l
    end
  end
end
