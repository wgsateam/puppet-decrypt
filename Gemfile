source 'https://rubygems.org'

gem "puppet-crypt", :git => "https://github.com/wgsateam/puppet-decrypt"

# Specify your gem's dependencies in puppet-crypt.gemspec
gemspec

# Not in the gemspec because we're testing multiple versions with appraisal.
gem 'puppet'

# Things we don't want on Travis
group :debugging do
  # just for pushing documentation, requires ruby 1.9+
  gem 'relish'
  gem 'pry'
  gem 'pry-nav'
end

