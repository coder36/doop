class DoopgovukGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)
  argument :name, :type => :string, :default => "demo"


  def generate_layout
    copy_file "app/assets/stylesheets/demo.css.scss", "app/assets/stylesheets/#{name}.css.scss"
    copy_file "app/assets/javascripts/demo.js.coffee", "app/assets/javascripts/#{name}.js.coffee"
    template "app/controllers/demo_controller.rb", "app/controllers/#{name}_controller.rb"
    copy_file "app/views/layouts/application.html.erb",  "app/views/layouts/application.html.erb"
    directory "app/views/doop"
    directory "app/views/demo", "app/views/#{name}"
    gsub_file "app/controllers/#{name}_controller.rb", /DemoController/, "#{name.capitalize}Controller"


    route "root '#{name}#index'"
    route "get '#{name}/index'"
    route "post '#{name}/answer'"

    gem 'govuk_frontend_toolkit'
    gem 'govuk_template'

    Bundler.with_clean_env do
      run "bundle install"
    end

  end
end
