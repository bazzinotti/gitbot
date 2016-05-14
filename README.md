# Ayumi
My lovely IRC bot

# Getting Started

This doc is largely geared towards UNIX-based systems such as Linux or Mac.

## Dependencies

### Ruby

Ruby is the dominant language of Ayumi. Use your OS package manager or http://github.com/postmodern/ruby-install

#### bundle

This is a ruby gem, (library). I use it to manage all the gems that Ayumi uses,
so that you can quickly instill the same versions of the gems I use, on your machine.

`gem install -N bundle`

__Note__: `-N` ensures documentation is not installed for that gem. If you want the doc, remove `-N`

Can you invoke `bundle`? Try `bundle --version` to check.

If it does not work, try adding the Ruby Gems bin folder to your `PATH` environment variable,
- if you installed bundle as a "local user" gem, you could add `export PATH="~/.gem/ruby/bin/:$PATH"` to `~/.bashrc` 
- for a system gem, RTFM

For more control over your gem installation, and awareness, check out `gem help install`

### Redis

This is a database that Ayumi is using. You should have it installed and running before invoking ayumi.

You can see if you can install Redis through your OS package manager, or install from source through http://redis.io/

You may run your redis server on a unix socket or on a network socket. Configure the yml file as appropriate.

**Note**: The presence of a unix socket filename will override any network socket configuration if both are present in config.yml

## Prepping Ayumi

from the project directory, type `bundle install`. This downloads all the ruby gems Ayumi uses at appropriate versions.

## Config File

Ayumi's config file is pretty cool, and self-documented. Check out `config.yml.example`

Ayumi will by default look for `config.yml` in the directory of the shell that invoked her or 
can be explicitly specified by supplying the filename as a parameter. eg. `ruby bin/ayumi myconfig.yml`

## Running Ayumi

`ruby bin/ayumi` or `ruby bin/ayumi myconfig.yml`

Currently, all options are specified via the config.yml file.
