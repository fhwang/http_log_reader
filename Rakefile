require 'rake'
require 'rubygems'
gem 'rspec'
require 'spec/rake/spectask'

desc "Run all specs"
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_files = FileList['specs/*.rb']
end

task :default => :spec
