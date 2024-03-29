# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = 'elastic_record'
  s.version = '5.6.2'
  s.summary = 'An Elasticsearch querying ORM'
  s.description = 'Find your records with Elasticsearch'

  s.required_ruby_version     = '>= 2.7'
  s.required_rubygems_version = ">= 3.0"

  s.license           = 'MIT'
  s.authors           = ['Infogroup', 'Matthew Higgins']
  s.email             = 'developer@matthewhiggins.com'
  s.homepage          = 'http://github.com/data-axle/elastic_record'

  s.extra_rdoc_files = ['README.md']
  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- {test}/*`.split("\n")

  s.add_dependency 'arelastic', '>= 3.4.1'
  s.add_dependency 'activemodel'
  s.add_dependency 'activesupport'
end
