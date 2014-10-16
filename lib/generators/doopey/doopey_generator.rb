class DoopeyGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)
  argument :name, :type => :string, :default => "demo"


  def generate_layout
    copy_file "app/assets/stylesheets/demo.css.scss", "app/assets/stylesheets/#{name}.css.scss"
    template "app/controllers/demo_controller.rb", "app/controllers/#{name}_controller.rb"
    copy_file "app/views/demo/index.html.erb",  "app/views/#{name}/index.html.erb"
    copy_file "app/views/demo/index.js.erb",  "app/views/#{name}/index.js.erb"
    copy_file "app/views/demo/_preamble.html.erb",  "app/views/#{name}/_preamble.html.erb"
    copy_file "app/views/demo/_summary.html.erb",  "app/views/#{name}/_summary.html.erb"
    copy_file "app/views/demo/_your_details.html.erb",  "app/views/#{name}/_your_details.html.erb"
    copy_file "app/views/layouts/application.html.erb",  "app/views/layouts/application.html.erb"

    route "root '#{name}#index'"
    route "get '#{name}/index'"
    route "post '#{name}/answer'"

    gem 'doop',path: "../doop"
    gem 'govuk_frontend_toolkit'
    gem 'govuk_template'

    Bundler.with_clean_env do
      run "bundle install"
    end

  end
end
