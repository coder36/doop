# Doop Demo
An example doop-rails project which is used as the template for the doopgovuk generator.


## Development

   git clone git@github.com:coder36/doop.git
   cd doop
   git submodule init
   cd ..
   git clone git@github.com:coder36/doop_demo.git
   cd doop_demo
   bundle install
   rails s


## Publishing to Heroku

    touch heroku
    bundle install
    git add .
    git commit -m"Heroku build"
    heroku login     (provide email and password)
    git push heroku


# Testing

I've used cucmber extensively in the past, but found that inveitably the customer would never actually read the gherkin, so immediatly the rational
for using gherkins would be invalid.  One of the issues that I found with gherkins was the lure towards writing hundreds of different flows, but
all that would happen is that the testing feedback loop increased to hours!  Also cucmber matchers feel very artificial and can lead you down a
rabbit hole!


I would suggest to use (capybara)[https://github.com/jnicklas/capybara] with rspec, along with a headless browser.  Rspec gives much more control to the developer, so that accurate and concise testing can be done, without the overhead of creating cucumber matchers.


## Headless web driver

    sudo apt-get install qt4-dev-tools libqt4-dev libqt4-core libqt4-gui xvfb


## Chromedriver

Download the (chromedriver)[http://chromedriver.storage.googleapis.com/index.html].  

    chromdriver --white-listed-ips 192.168.33.11

This allows the chromedriver to be used remotely from 192.168.33.11.  This type of setup is ideal for a CI pipeline.  

