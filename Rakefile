require 'rake'
require 'rake/testtask'
require 'rcov/rcovtask'

task :default => :test

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/basic.rb']
  t.verbose = true
end

Rcov::RcovTask.new do |t|
  t.test_files = FileList['test/basic.rb']
  t.verbose = true
end
