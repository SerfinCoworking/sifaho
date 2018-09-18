[logo]: https://gitlab.com/eugesma/SifahoHSMA/blob/master/app/assets/images/LogoSIFAHO.png
# SIFAHO
###### Sistema Farmacéutico Hospitalario 

A pharmaceutical stock application for hospitals.
***
## Installation guide tested in Ubuntu 16.04LTS:

1. ###### Install RVM and JavaScript Runtime:
```
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB

cd /tmp

curl -sSL https://get.rvm.io -o rvm.sh

cat /tmp/rvm.sh | bash -s stable --rails

source /home/sammy/.rvm/scripts/rvm
```

```

```
Full guide [here](https://www.digitalocean.com/community/tutorials/how-to-install-ruby-on-rails-with-rvm-on-ubuntu-16-04)

2. ###### Install ruby and create gemset:
```
rvm install ruby-2.4.2

rvm gemset create sifaho

rvm ruby-2.4.2@sifaho
```
3. #### Install PostgreSQL  
3. #### Clone the repo and install dependencies 

Place in SifahoHSMA directory and run:

```
rvm use ruby-2.4.2@sifaho

/bin/bash --login

rvm use 2.4.2

bundle install
```

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
