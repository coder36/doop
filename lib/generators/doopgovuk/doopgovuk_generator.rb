class DoopgovukGenerator < Rails::Generators::Base
  source_root File.expand_path('../../../../demo', __FILE__)
  argument :name, :type => :string, :default => "demo"


  def generate_layout
    copy_file "app/assets/stylesheets/demo.css.scss", "app/assets/stylesheets/#{name}.css.scss"
    copy_file "app/assets/stylesheets/demo/application.css", "app/assets/stylesheets/#{name}/application.css"
    copy_file "app/assets/javascripts/demo.js.coffee", "app/assets/javascripts/#{name}.js.coffee"
    copy_file "app/assets/javascripts/demo/application.js", "app/assets/javascripts/#{name}/application.js"
    copy_file "app/assets/javascripts/demo/analytics.js.erb", "app/assets/javascripts/#{name}/analytics.js.erb"
    template "app/controllers/demo_controller.rb", "app/controllers/#{name}_controller.rb"
    copy_file "app/views/layouts/application.html.erb",  "app/views/layouts/application.html.erb"
    directory "public/uploads"
    copy_file "public/uploads/.keep",  "public/uploads/.keep"
    directory "app/views/doop"
    directory "app/views/demo", "app/views/#{name}"
    gsub_file "app/controllers/#{name}_controller.rb", /DemoController/, "#{name.capitalize}Controller"

    copy_file "spec/rails_helper.rb"
    copy_file "spec/spec_helper.rb"
    copy_file "spec/features/demo_spec.rb", "spec/features/#{name}_spec.rb"
    gsub_file "spec/features/#{name}_spec.rb", /\/demo\/harness/, "/#{name}/harness"
    gsub_file "spec/features/#{name}_spec.rb", /\/demo\/index/, "/#{name}/index"

    route "get '#{name}/index'"
    route "post '#{name}/index'"
    route "post '#{name}/answer'"
    route "get '#{name}/harness'"
    route "post '#{name}/harness'"

    gem "govuk_frontend_toolkit", "~> 1.6"
    gem "govuk_template", "~> 0.9"
    gem "jquery-ui-rails", "~> 5.0"
    gem "blueimp-gallery", "~> 2.11.0"
    gem "jquery-fileupload-rails", "~> 0.4"


    gem_group :production do
      gem 'rails_12factor', "~> 0.0"
      gem 'pg', "~> 0.17"
    end

    gem_group :development do
      gem 'rspec-rails', "~> 3.1"
      gem 'guard-rspec', "~> 4.3"
      gem 'capybara', "~> 2.4"
      gem 'pry', "~> 0.10"
      gem 'pry-nav', "~> 0.2"
      gem 'capybara-webkit', "~> 1.3"
      gem 'headless', "~> 1.0"
      gem 'capybara-screenshot', "~> 1.0"
    end

    Bundler.with_clean_env do
      run "bundle install"
    end

  end
end
