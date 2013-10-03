require 'rake/testtask'

namespace 'test' do
  unit_tests = FileList['test/**/*_test.rb']
  desc "Run unit tests"
  Rake::TestTask.new('units') do |t|
    t.libs << 'test'
    t.test_files = unit_tests
    t.verbose = true
    t.warning = true
  end
end

desc "Run tests"
task :default => :test

task :test do
  Rake::Task['test:units'].invoke
end
