# Doop

A question framework for govuk sites, inspired by the great work that GDS have done to standardize the cross government internet presence.


Demo


## Background
A bit of background first.  Whilst working with the Student Loans company and GDS we discovered that the best way to get a student to fill a form in was to progressively
ask questions, one after the other rather than as one big form.  User experience testing showed this was a far less intimidating experience, and they would more likely
stick at it.  Furthermore, based on pevious answers, we  can choose which questions to ask.  This makes each questionaire effectively tailored to the individual student.

Other things we learned, was that students hate answering lots of questions, only to find at the end they are not eligible.  So the order of questions is very important,
and thats why some of the early questions when applying for a student loan may seem a bit obscure, but they are designed to weed out those who are inelligble as soon as possible. 

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
* Build on rails 4


# Installation


Add this line to your application's Gemfile:

```ruby
gem 'doop'
```

And then execute:

    $ bundle


# Usage

# Generator

Make sure that the gemfile contains gem 'doop'.   Then run

    $ rails generate doopgds demo
    $ rails s

Navigate to http://localhost:3000 and you will see the demo questionaire.  

For the demo, the serialized questionaire is stored as a form parameter.  This is a nice approach as a general strategy since its completely stateless and as a result scalable.  


# Notes

## Perfoamnce

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



## TODO

* Refactor -  make the code, simpler and read better
* Doop-Rspec - it would be nice to have a DSL to drive answering questions.  This could be extended to capybara.


## Contributing

1. Fork it ( https://github.com/[my-github-username]/doop/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
