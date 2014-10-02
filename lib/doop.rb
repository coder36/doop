require "doop/version"

require "yaml"

module Doop


  class Question



    def initialize yaml
      @hash = YAML.load( yaml )
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
        name = elem[/[^__]*/]
        move( "#{path}/#{elem}", "#{path}/#{name}__#{i}" )
        i+=1
      end

    end

  end
end
