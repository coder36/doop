require "doop/version"

require "yaml"

module Doop


  class Question



    def initialize yaml
      @hash = YAML.load( yaml )
      setup_handlers
      add_meta_data
      ask_next
    end

    def setup_handlers
      @on_answer_handlers = {}
      @on_answer_handlers["default"] = method(:default_on_answer)
    end

    def default_on_answer( root, path, context )
      self[path + "/_answer"] = context["answer"]
      self[path + "/_summary"] = context["summary"]
      self[path + "/_answered"] = true
      self[path + "/_open"] = false
    end

    def dump
      @hash.to_yaml
    end

    def [](path)
      path_elements(path).inject(@hash) { |a,n| a[n] }
    end

    def []=(path,val)
      l = path_elements(path)
      missing = []

      # create missing nodes
      while self[construct_path(l)] == nil
        missing << l.pop
      end

      missing.reverse.each do |elem|
        self[construct_path(l)][elem] = ""
        l << elem
      end

      # set node to value
      elem = l.pop
      self[construct_path(l)][elem] = val

    end

    def construct_path(elements)
       elements.join("/")
    end

    def path_elements(path)
      path.split("/").select {|n| !n.empty? }
    end

    def add(path)
      self[path] = {}
    end

    def remove(path)
      e = path_elements(path)
      k = e.pop
      self[construct_path(e)].delete(k)
    end

    def move( from, to )
      q = self[from]
      remove(from)
      add(to)
      self[to] = q
    end

    def renumber( path )
      q = self[path]
      i = 1
      q.keys.sort_by{|s| s.scan(/\d+/).map{|s| s.to_i}}.each do |elem|
        next if elem.start_with?("_")
        name = elem[/[^__]*/]
        move( "#{path}/#{elem}", "#{path}/#{name}__#{i}" )
        i+=1
      end
    end

    def each_question(root=@hash, path="", &block) 
      root.keys.each do |key|
        next if key.start_with?("_")
        new_path = path + "/" + key
        new_root = root[key]
        block.call( new_root, new_path )
        each_question( new_root, new_path, &block )
      end
    end

    def add_meta_data
      each_question do |root, path|
        root["_open"] = false if !root.has_key?("_open")
        root["_enabled"] = true if !root.has_key?("_enabled")
        root["_answered"] = false if !root.has_key?("_answered")
        root["_answer"] = :empty if !root.has_key?("_answer")
        root["_on_answer_handler"] = "default" if !root.has_key?("_on_answer_handler")
      end
    end

    def ask_next

      q = ""
      disabled_path = nil

      each_question do |root, path|
        self[path]["_open"] = false
        next if disabled_path != nil && path.start_with?(disabled_path)
        if self[path+"/_enabled"] == false
          disabled_path = path
          next
        end

        q = path if path.start_with?(q) && root["_answered"] == false
      end

      self[q]["_open"] = true if !q.empty?
    end

    def currently_asked
      each_question do |root, path|
        return path if root["_open"] == true
      end
      nil
    end

    def answer context
      path = currently_asked
      keys = @on_answer_handlers.keys.select { |k| path.match( "^#{k}$" ) != nil }
      block = keys.empty? ? @on_answer_handlers["default"] : @on_answer_handlers[keys[0]]
      block.call( self[path], path, context )
      ask_next
    end

    def disable path
      self[path + "/_enabled"] = false
      ask_next
    end

    def enable path, enable = true
      self[path + "/_enabled"] = enable
      ask_next
    end

    def change path
      self[currently_asked + "/_open"] = false
      self[path + "/_open"] = true
    end

    def on_answer(path, &block)
      @on_answer_handlers[path] = block
    end



  end
end
