### VampireAds, text to screen SMS application

Source code for the admin part of VampireAds.com. 

Does text to screen and a more complex semi-anonymized chat (what we call "proxy chat" - see the diagram, below). See VampireAds.com for examples.

##### Workflow

![workflow diagram](http://dl.dropbox.com/u/225019/rm-app-screenshots/VampireAds/VampireAds%201.1.png)

_All of the carrier-specific notes are deprecated (tariffs, T-Mobile double opt-in… all of this is now much more easily accomplished over long codes)._


##### Notes

* It's a Rails 2.1.2 app (!).

###### It may take some doing to get this up and running. The general idea:

1. Get sources

2. Update config/deploy.rb:

	- change :repository to point to the remote repository with code (accessible from the deployment server (DS) )
	- change :domain to the DS IP or name
	- change :user and :runner to the DS user name
	- change :deploy_to to the full path for the deployment

2.1 Install capistrano gem

	$ gem install capistrano

3. Check the dependencies on the server by running locally:
	
	$ cap deploy:check

4. Make the directory structure:

	$ cap deploy:setup

5. Log into the server and create “shared/config/database.yml” with database config (see config/database.yml)

6. Deploy the app and start fixing errors:

	$ cap deploy:cold

Now the fun part: installing missing gems. This project is from pre-Bundler era, so there’s no gem manifest. You'll have to wire the app to the web server and test it in-browser. The errors will mention a missing gem. Then, go into the server console, install it, rinse, repeat.