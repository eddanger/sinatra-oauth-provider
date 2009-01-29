Sinatra Rack Middleware OAuth Provider
===

An experiment in creating a Sinatra OAuth Provider as Rack Middleware, a simple OAuth Consumer and API wrapper to tie it all together.

The Rack Middleware takes a simple hash of OAuth protected paths (represented by regular expressions) and associated request methods.

# To run the provider:
	ruby provider.rb
Go to http://localhost:4567/

# To run the consumer:
	ruby consumer.rb -p 5678
Go to http://localhost:5678/
	
# Requirements and Installation

**Sinatra: http://sinatra.github.com/**

	sudo gem install sinatra

**Datamapper: http://datamapper.org/**

	sudo gem install datamapper
	sudo gem install do_sqlite3

**OAuth for Ruby: http://github.com/pelle/oauth**

	sudo gem install oauth

**OAuth Provider for Ruby: http://github.com/halorgium/oauth_provider**

Since there is no gem yet you will need to do the following:
	cd lib
	git clone git://github.com/halorgium/oauth_provider.git

Thanks to pelle, halorgium (for the auth_provider), and singpolyma (for the simple Sinatra example)! And to the Vancouver "Ruby in the Rain" event for opening my eyes to Sinatra. You guys rock!

Enjoy!