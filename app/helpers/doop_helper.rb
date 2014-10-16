module DoopHelper

  def info_box &block
    render "doop/info_box", :content => block
  end

  def question_visible? path
    doop = request[:doop]
    doop.each_visible_question do |root,p|
      return true if p == path
    end
    false
  end

  def question_form doop, res, &block
    request[:doop] = doop
    s = render( "doop/question_form", :content => block, :res => res, :doop => doop )
    s
  end

  def question path, opts = {:title => nil, :indent => false}, &block
    doop = request[:doop]
    root = doop[path]
    s = ""
    if question_visible? path
      s = render( "doop/question", :content => block, :root => root, :path => path, :answer => root["_answer"], :title => opts[:title], :indent => opts[:indent] )
    end
    s
  end

  def when_answered path, &block
    doop = request[:doop]
    block.call if doop.all_nested_answered(path)
  end

  def error res, id
    render( "doop/error", :msg => res[id] ) if res[id] != nil
  end

  def list path_regex, &block
    doop = request[:doop]
    l = {}
    doop.each_question do |root,path|
      m = path.match( "^#{path_regex}$")
      l[m[1]] = path if m != nil
    end

    l.keys.sort.each { |k| block.call( l[k], k.to_i ) }
  end

end
