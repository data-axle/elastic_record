require 'rake'
require 'rake/testtask'

desc 'Default: run unit tests.'
task default: :test

desc 'Test.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/elastic_record/**/*_test.rb'
  t.verbose = true
end