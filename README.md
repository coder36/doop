# Doop

A question framework for govuk sites, inspired by the great work GDS have done to standardize the cross government internet presence.

## [Doopgovuk demo](http://blooming-wave-8670.herokuapp.com)

Try out a demo... it's hosted on heroku so there may be a initial pause while heroku fires up the demo:



# Quick start

Assuming ruby, rails and nodejs is installed:

    $ sudo apt-get install qt4-dev-tools libqt4-dev libqt4-core libqt4-gui xvfb

    These are needed to support the headless capybara test suite.

    $ rails new govsite
    $ cd govsite
    $ echo "gem 'doop'" >> Gemfile
    $ bundle
    $ rails generate doopgovuk demo
    $ rails s

Navigate to http://localhost:3000/demo/index

This is still in development, so if you want the latest, then add `gem 'doop', git: 'git://github.com/coder36/doop.git'` to your Gemfile.


## Background
Whilst working with the Student Loans company and GDS we discovered that the best way to get a student to fill a form in was to progressively ask questions, one after the other rather than as one big form.  User experience testing showed this was a far less intimidating experience, and they would more likely stick at it.  Furthermore, based on pevious answers, we  can choose which questions to ask.  This makes each questionaire effectively tailored to the individual student.

Other things we learned, was that students hate answering lots of questions, only to find at the end they are not eligible.  So the order of questions is very important, and thats why some of the early questions when applying for a student loan may seem a bit obscure, but they are designed to weed out those who are inelligble as soon as possible. 

If you compare the Student loans site and the DVLA site, which are both govuk questionaires you will see that they have been implemented in very different ways, and as a result look fairly different, but essentially do the same thing.  In fact I found that within the same company, you had multiple approaches, and completely different technology stacks to achieve the same thing.  I spent months writing Daone of these sites, 

Designing something from scratch is expensive and time consuming.  This is where GDS have added real value.  They have provided a set of ruby gems to trivialise the production of
govuk sites.  One thing they are lacking however is a gem to trivialize the creation of complex questionaires.  And this is why government organisations are seemingly reinventing
the wheel multiple times over.  This is the niche which Doop fills.

If your govuk site requires any kind of questionaire, doop is the answer.  


## Features

* DSL
* Rails generator to quickly get you started
* Ability to Change answer
* Summarize answers
* Broswer backbutton integration
* Stateless
* Fast
* Ajax call backs
* Built on rails 4


# Usage

## Generator

Make sure that the gemfile contains gem 'doop'.   Then run

    $ rails generate doopgovuk demo
    $ rspec
    $ rails s

Navigate to http://localhost:3000/demo/index and you will see the demo questionaire.  
    
See the [demo rails controller](https://github.com/coder36/doop/blob/master/lib/generators/doopgovuk/templates/app/controllers/demo_controller.rb) to get a feel for the DSL.

## Yaml

Doop is initiated with a Yaml data structure:

    page: {
      preamble: {
        _page: "preamble",
        _nav_name: "Apply Online",
        enrolled_before: {
          _question: "Have you enrolled for this service before ?"
        },
        year_last_applied: {
          _question: "What year did you last apply?"
        }
      }
    }

Once initialized doop will add meta data to the structure.  Each question will get meta data.  So the above yaml will end up looking like:

    page: {
      _answered: false,
      _answer: "",
      _summary: "",
      _enabled: true,
      _open: false,
      preamble: {
        _answered: false,
        _answer: "",
        _summary: "",
        _enabled: true,
        _page: "preamble",
        _nav_name: "Apply Online",
        enrolled_before: {
          _answered: false,
          _answer: "",
          _summary: "",
          _enabled: true,
          _question: "Have you enrolled for this service before ?"
        },
        year_last_applied: {
          _answered: false,
          _answer: "",
          _summary: "",
          _enabled: true,
          _question: "What year did you last apply?"
        }
      }
    }

Meta data always starts with an _.  Doop uses the meta data to keep track of whats been answerd, what's currently being asked, and what questions are enabled.



## Question order

The questions will be asked in the order in which they appear in yaml.  So for above, the order of questions will be:

1.  page/preamble/enrolled_before
2.  page/preamble/year_last_applied
3.  page/preamble
4.  page

The most nested question is asked first, then the next and so ending on the least nested question.  


As the questions are answered, callbacks will invoked.


## Callbacks

Call backs are used to manipulate the yaml structure, to set _metadata etc.  In the example below, when /page/preamble/enrolled_before is answered, the summary will be set to the answer.

```ruby
on_answer "/page/preamble/enrolled_before"  do |question,path, params, answer|
  answer_with( question, { "_summary" => answer } )
end

```

On_answer call backs can be used to change the question flow.  The code below will enable or disable the year_last_applied question depending on whether the answer was Yes or No:

```ruby
on_answer "/page/preamble/enrolled_before"  do |question,path, params, answer|
  answer_with( question, { "_summary" => answer } )
  enable( "/page/preamble/year_last_applied", answer == "Yes" )
end
```


# Notes

## Analytics 

Analytics is provided by [google anaytics](http://www.google.com/analytics/).  When you use the generator, a file named `app/assets/javascript/demo/anayltics.js.erb` will be created.  This contains the javascript code to integrate with google analytics.  Out of the box, the following  events will be recorded:


| Event                           | Category    | Action    | Label
|:--------------------------------|:------------|:----------|:-------- 
|Backbutton clicked               | button      | click     | back-button
|Navigation link clicked          | page        | changed   | page_id 
|Question answered                | question    | answered  | question_id
|Question re-opened               | question    | reopened  | question_id

To get this working for your project, you will need to update [anayltics.js.erb](https://github.com/coder36/doop/blob/master/lib/generators/doopgovuk/templates/app/assets/javascripts/demo/analytics.js.erb) with your google Universal Analytics id.  

Typically, jquery is used to dynamically bind the the 'GA send' code to the forms buttons. eg.

     $("[id$=-change]").click( function() {
       id = $(this).attr('id')
       ga( 'send', 'event', 'question', 'reopened', id.replace( '-change', '' ) )
     })



## Performance

For the demo, the serialized questionaire is stored as a form parameter.  This is a nice approach as a general strategy since its completely stateless and as a result scalable.  
Its also very fast.  

I've worked with a lot of java farmeworks (I'm thinking JSF!) and in comparison I can assure you that the demo application is fast.  Doop fully supports jruby, so you may get some 
optimisation going down that route.  As mentioned earlier its completely stateless, so you can scale by simply firing up more servers. 

I tested it with passenger and nginx and it was lightening fast.  Without any optimisation each request was taking about 20ms.

## Jruby

The yaml serialization uses encryption, so you will need to tell java to allow unlimted strength cryptography.  Create a file config/initializers/unlimited_strength_cryptography

```ruby
    platform :jruby do
      require 'java'
      security_class = java.lang.Class.for_name('javax.crypto.JceSecurity')
      restricted_field = security_class.get_declared_field('isRestricted')
      restricted_field.accessible = true
      restricted_field.set nil, false
    end
```

Don't forget to deal with database drivers.  In your Gemfile, you will need to use JDBC drivers:

```ruby
    platform :jruby do
      gem 'activerecord-jdbcsqlite3-adapter'
    end

    platform :ruby do
      gem 'sqlite3'
    end
```

## Creating and publishing doop gem

    git submodule init    <-- to load doop_demo
    gem build doop.gemspec
    gem push doop-<version>.gem



## TODO

* Refactor -  make the code, simpler and read better
* Doop-Rspec - it would be nice to have a DSL to drive answering questions.  This could be extended to capybara.
* Responsive - on the whole the govuk frontend is responsive, fonts resize etc.  But there is still some work to be done.


## Contributing

1. Fork it ( https://github.com/coder36/doop/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
