require File.join(%W[#{File.dirname(__FILE__)} lib sinatra api version])

Gem::Specification.new do |s|
  s.name        = 'sinatra-api-helpers'
  s.summary     = 'Handy helpers for writing RESTful APIs in Sinatra.'
  s.version     = Sinatra::API::VERSION
  s.date        = Time.now.strftime('%Y-%m-%d')
  s.authors     = [ 'Ahmad Amireh' ]
  s.email       = 'ahmad@algollabs.com'
  s.homepage    = 'https://github.com/amireh/sinatra-api-helpers'
  s.files       = Dir.glob("{lib,spec}/**/*.rb") +
                  [ 'LICENSE', 'README.md', '.rspec', '.yardopts', __FILE__ ]
  s.has_rdoc    = 'yard'
  s.license     = 'MIT'

  s.required_ruby_version = '>= 1.9.3'

  s.add_dependency 'json'
  s.add_dependency 'sinatra'
  s.add_dependency 'activesupport'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rack-test'
  s.add_development_dependency 'yard', '>= 0.8.0'
end
