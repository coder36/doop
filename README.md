# Doop

A question framework for govuk sites, inspired by the great work [GDS](https://gds.blog.gov.uk) have done to standardize the cross government internet presence.  Try out the demos:

## Demos

When opening the demos, I suggest right clicking on the link and opening in a new tab.  (Inside the demo, the behaviour of the back button is modified to go back a 'doop' page)

### [Demo 1](http://blooming-wave-8670.herokuapp.com/demo/index)
[Demo 1](http://blooming-wave-8670.herokuapp.com/demo/index) is an extensive demo covering most of the features supported by doop.

### [Demo 2](http://blooming-wave-8670.herokuapp.com/sasdemo/index)
[Demo 2](http://blooming-wave-8670.herokuapp.com/sasdemo/index) is based on [this](https://www.gov.uk/check-if-you-need-a-tax-return/y) existing online form to check whether you should complete a self assessment or not.  It took about a day to develop:    [SasdemoController.rb](https://github.com/coder36/doop/blob/master/demo/app/controllers/sasdemo_controller.rb), [_quick_check.html.erb](https://github.com/coder36/doop/blob/master/demo/app/views/sasdemo/_quick_check.html.erb)


The demos are hosted on heroku so there may be an initial pause while heroku fires up the dynamo.

## Screenshots

<a href="http://blooming-wave-8670.herokuapp.com/demo/index"><img src="https://raw.githubusercontent.com/coder36/doop/master/notes/screenshots/doop_1.png"/></a>

<a href="http://blooming-wave-8670.herokuapp.com/sasdemo/index"><img src="https://raw.githubusercontent.com/coder36/doop/master/notes/screenshots/doop_2.png"/></a>

# Quick start

Assuming ruby 1.9.3, rails and nodejs is installed:

    $ sudo apt-get install qt4-dev-tools libqt4-dev libqt4-core libqt4-gui xvfb libpq-dev nodejs

    These are needed to support the headless capybara test suite.

    $ rails new govsite
    $ cd govsite
    $ echo "gem 'doop'" >> Gemfile
    $ bundle
    $ rails generate doopgovuk demo
    $ rails s

Navigate to http://localhost:3000/demo/index


## Background
Whilst working with the Student Loans company and [GDS](https://gds.blog.gov.uk) we discovered that the best way to get a student to fill a form in was to progressively ask questions, one after the other rather than as one big form.  User experience testing showed this was a far less intimidating experience, and they would more likely stick at it.  Furthermore, based on pevious answers, we  can choose which questions to ask.  This makes each questionaire effectively tailored to the individual student.

Other things we learned, was that students hate answering lots of questions, only to find at the end they are not eligible.  So the order of questions is very important, and thats why some of the early questions when applying for a student loan may seem a bit obscure, but they are designed to weed out those who are inelligble as soon as possible. 

If you compare the Student loans site and the [DVLA](https://www.taxdisc.service.gov.uk) site, which are both govuk questionaires you will see that they have been implemented in very different ways, and as a result look fairly different, but essentially do the same thing.  In fact I found that within the same company, you had multiple approaches, and completely different technology stacks to achieve the same thing.  I spent months writing Daone of these sites, 

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
* File upload capability
* Stateless
* Fast
* Ajax call backs
* Built on rails 4


# Usage

## Generator (Tested on ruby 1.9.3)

Make sure that the gemfile contains gem 'doop'.   Then run

    $ rails generate doopgovuk demo
    $ rspec
    $ rails s

Navigate to http://localhost:3000/demo/index and you will see the demo questionaire.  
    
See the [demo rails controller](https://github.com/coder36/doop/blob/master/demo/app/controllers/demo_controller.rb) to get a feel for the DSL.  Also take a look at the [.erb](https://github.com/coder36/doop/blob/master/demo/app/views/demo/_preamble.html.erb) file which defines the web page layout and test.

## Yaml

Doop is initiated with a Yaml data structure:

    page: {
      preamble: {
       _page: "preamble",
       _nav_name: "Preamble",
       income_more_than_50000: {
       _question: "Do you have an income of more than £50,000 a year ?"
      },
      do_you_still_want_to_apply: {
        _question: "Do you still want to apply for child benefit?"
      },
      proof_of_id: {
        _question: "We need proof of your identity",
        _answer: {}
      }
    },

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
        income_more_than_50000: {
          _answered: false,
          _answer: "",
          _summary: "",
          _enabled: true,
          _question: "Do you have an income of more than £50,000 a year ?"
        },
        ...
  

Meta data always starts with an _.  Doop uses the meta data to keep track of whats been answerd, what's currently being asked, and what questions are enabled.



## Question order

The questions will be asked in the order in which they appear in yaml.  So for above, the order of questions will be:

1.  page/preamble/income_more_than_50000
2.  page/preamble/do_you_still_want_to_apply
3.  page/preamble
4.  page

The most nested question is asked first, then the next and so ending on the least nested question.  


As the questions are answered, callbacks will invoked.


## Callbacks

Call backs are used to manipulate the yaml structure, to set _metadata etc.  In the example below, when /page/preamble/do_you_still_want_to_apply is answered, the summary will be set to the answer.

```ruby
on_answer "/page/preamble/do_you_still_want_to_apply"  do |question,path, params, answer|
  answer_with( question, { "_summary" => answer } )
end

```

On_answer call backs can be used to change the question flow.  The code below will enable or disable the year_last_applied question depending on whether the answer was Yes or No:

```ruby
on_answer "/page/preamble/income_more_than_50000"  do |question,path, params, answer|
  answer_with( question, { "_summary" => answer } )
  enable( "/page/preamble/do_you_still_want_to_apply", answer == "Yes" )
end
```

## DSL for defining content

Doop defines a DSL for writing the .erb to display the questions:

    <%=question_form doop, res do %>
      <%=question "/page/preamble" do |root, answer| %>
      
        <%=question "/page/preamble/income_more_than_50000" do |root,answer| %>
          <button name="b_answer" value="Yes">Yes</button><br/>
          <button name="b_answer" value="No"></button>
        <% end %>
        
        <%=question "/page/preamble/do_you_still_want_to_apply" do |root,answer| %>
          <button name="b_answer" value="Yes">Yes, I still want to apply for child benefit</button
        <% end %>
        
        <% when_answered "/page/preamble" do %>
          <button>Continue and Save</button>
        <% end %>
        
      <% end %>
    <% end %>

# Notes

## Javascript

Doop feels fast, because ajax is used to handle button presses.  Only the question pannel section is ever redrawn, and thats
once the server side processing has completed.  Things to note:

* The navigation links at the top, result in a hidden button being pressed
* The browser back button, results in a hidden button being pressed.   

### Back button

Doop hijacks the the browser back button.  Pressing it will open the previous pages questions. This is done
with the following [coffeescript](https://github.com/coder36/doop/blob/master/lib/generators/doopgovuk/templates/app/assets/javascripts/demo.js.coffee) code:

    $( () ->
      history.pushState("back", null, null);
      if typeof history.pushState == "function"
        history.pushState("back", null, null);
        window.onpopstate = (evt) ->
          history.pushState('back', null, null);
          $( "#back_a_page" ).val( "pressed" )
          $( "#back_a_page" ).click()
    )

### No javascript support ?

Doop will work fine with java script disabled.  It still feels fast.  Take note of the following:

* The entire page will be re-rendered when ever a button is pressed.
* A `back` navigation button will appear at the bottom.  Normally javascript within [app/views/doop/_question_form.html.erb](https://github.com/coder36/doop/blob/master/lib/generators/doopgovuk/templates/app/views/doop/_question_form.html.erb) would set this to `$("#back_a_page").css( "display", "none" )`
* The top navigation links will not work, but the website is perfectly usable and still feels fast. 



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


# Testing

The generated doopgovuk project, will give you a set of rspec tests, which use capybara, to click buttons, set
fields etc through a scenario.  These scenarios will form the acceptance tests.  These should be included
as part of a CI pipeline, on the road to production.  

## Headless web driver

When using TDD, you need to get into a tight feedback loop.  Your tests need to be quick and this means compromises.  
The compromise doop makes, is to use the `:webkit` headless driver.  This is blisteringly fast, but the downside
is that you can't see what its doing.  The webkit headless driver relies on a framebuffer, so to get it working,
 you'll need to install some libraries:

    sudo apt-get install qt4-dev-tools libqt4-dev libqt4-core libqt4-gui xvfb libpq-dev nodejs

The driver is defined in [spec/rails_helper.rb](https://github.com/coder36/doop/blob/master/lib/generators/doopgovuk/templates/spec/rails_helper.rb)


## DSL

Doop provides an [inituitive DSL](https://github.com/coder36/doop/blob/master/lib/generators/doopgovuk/templates/spec/features/demo_spec.rb) for writing acceptance tests.  Try to limit the number of scenarios, to keep the test run as quick as possible.  Perhaps have an end to end scenario which covers every  question and every flow, then have another one which covers the way that 95% people would answer.  The test should work with `:js=>false`, but again, the vast majority of people will be using javascript.  

    feature "Child Benefit online form" do
      scenario "Complete Child Benefit form", :js => true do
        before_you_begin
        preamble
      end
      
      def before_you_begin
        visit '/demo/index'
        wait_for_page( "before_you_begin" )
        click_button "Start"
      end
      def preamble
        wait_for_page( "preamble" )
        
        answer_question( "income_more_than_50000")  do
          click_button "No,"
          expect( tooltip ).to be_visible
        end
        
        expect( question "do_you_still_want_to_apply" ).to be_disabled
        
        change_question( "income_more_than_50000") do
          expect( change_answer_tooltip ).to be_visible
          click_button "Yes," 
        end
      end
    end


## Testing Gotchas

* The :webkit driver seems to hang when using google analytics, so for development and test, google analytics are
disabled.



# Performance

For the demo, the serialized questionaire is stored as a form parameter.  This is a nice approach as a general strategy since its completely stateless and as a result scalable.  
Its also very fast.  

I've worked with a lot of java farmeworks (I'm thinking JSF!) and in comparison I can assure you that the demo application is fast.  Doop fully supports jruby, so you may get some optimization going down that route.  As mentioned earlier its completely stateless, so you can scale by simply firing up more servers. 

I tested it with passenger and nginx and it was lightening fast.  Without any optimisation each request was taking about 20ms.

# Jruby

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
* Language localisation
* Rspec tests only work on ruby 1.9.3
* Update doop to use (hashie)[https://github.com/intridea/hashie]


## Contributing

1. Fork it ( https://github.com/coder36/doop/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
