require "doop/version"

require "yaml"
require 'harness'

module Doop


  class Doop


    def initialize yaml
      @hash = YAML.load( yaml )
      setup_handlers
      add_meta_data
      ask_next
    end

    def setup_handlers
      @on_answer_handlers = {}
      @on_answer_handlers["default"] = method(:default_on_answer)

      @on_all_nested_answer_handlers = {}
      @on_all_nested_answer_handlers["default"] = method(:default_on_all_nested_answer)
    end

    def default_on_all_nested_answer( root, path, context )
      # do nothing
    end

    def default_on_answer( root, path, context )
      self[path + "/_answer"] = context["answer"]
      self[path + "/_summary"] = context["summary"]
      self[path + "/_answered"] = true
      self[path + "/_open"] = false
      {}
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

    def each_path_elem(path)
      p = ""
      path.split("/").select{|r| !r.empty?}.each do |n|
        p += "/" + n
        yield( p )
      end
    end

    def each_path_elem_reverse(path)
      a = []
      each_path_elem(path) {|n| a << n }
      a.reverse.each { |n| yield(n) }
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
        #root["_on_answer_handler"] = "default" if !root.has_key?("_on_answer_handler")
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

      each_path_elem( q )  { |n| self[n]["_open"] = true } 

    end

    def currently_asked
      # get the most nested open answer
      p = ""
      each_question do |root, path|
        p = path if path.start_with?(p) && root["_open"] == true
        #return path if root["_open"] == true
      end
      p.empty? ? nil : p
    end

    def question
      currently_asked
    end

    def answer context
      path = currently_asked
      res = get_handler(@on_answer_handlers, path, "_on_answer_handler").call( self[path], path, context )

      ask_next
      path = currently_asked
      return if path == nil
      each_path_elem_reverse(path) do |p|
        if all_nested_answered( p ) == true
          get_handler( @on_all_nested_answer_handlers, p, "_on_all_nested_answered" ).call( self[p], p, context )
          ask_next
        end
      end
      res
    end

    def get_handler handlers, path, handler_elem
      handler = self[path][handler_elem]
      if handler != nil
        block = handlers[handler]
      else
        keys = handlers.keys.select { |k| path.match( "^#{k}$" ) != nil }
        block = keys.empty? ? handlers["default"] : handlers[keys[0]]
      end
      block
    end

    def all_nested_answered path
      return true if path==nil
      each_question( self[path], path ) do |root,path| 
        return false if root["_answered"] == false
      end
      true
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
      each_path_elem_reverse(currently_asked) do |p|
        self[p + "/_open"] = false
      end

      # open all parent questions
      each_path_elem_reverse(path) do |p|
        self[p + "/_open"] = true
      end
    end

    def on_answer(path, &block)
      @on_answer_handlers[path] = block
    end

    def on_all_nested_answer(path, &block)
      @on_all_nested_answer_handlers[path] = block
    end


  end

  class Path
    def initialize doop, path
      @path = path
      @doop = path
      @root = @doop[@path]
    end

    def answer a
      @root["_answer"] = a
      @root["_answered"] = true
    end

  end

end
