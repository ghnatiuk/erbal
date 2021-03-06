require 'rake/gempackagetask'
require 'yaml'

WIN_SUFFIX = ENV['WIN_SUFFIX'] || 'i386-mswin32'
ERBAL_VERSION = '0.0.2'

task :clean => :clobber_package

spec = Gem::Specification.new do |s|
  s.name                  = 'erbal'
  s.version               = ERBAL_VERSION
  s.platform              = WIN ? Gem::Platform::CURRENT : Gem::Platform::RUBY
  s.summary               = 
  s.description           = "Very small, very fast Ragel/C based ERB parser"
  s.author                = "Ian Leitch"
  s.email                 = 'ian.leitch@systino.net'
  s.homepage              = 'http://github.com/ileitch/erbal'
  s.has_rdoc              = false

  s.files                 = %w(COPYING CHANGELOG README.rdoc Rakefile) +
                            Dir.glob("{lib,spec,tasks,benchmark}/**/*") + 
                            Dir.glob("ext/**/*.{h,c,rb,rl}")
  
  if WIN
    s.files              += ["lib/erbal.#{Config::CONFIG['DLEXT']}"]
  else
    s.extensions          = FileList["ext/**/extconf.rb"].to_a
  end
  
  s.require_path          = "lib"
end

Rake::GemPackageTask.new(spec) do |p|
  p.gem_spec = spec
end

namespace :gem do
  desc "Update the gemspec for GitHub's gem server"
  task :github do
    File.open("erbal.gemspec", 'w') { |f| f << YAML.dump(spec) }
  end  
end

task :install => [:clean, :clobber, :ragel, :compile, :package] do
  sh "#{SUDO} #{gem} install pkg/#{spec.full_name}.gem"
end

task :uninstall => :clean do
  sh "#{SUDO} #{gem} uninstall -v #{ERBAL_VERSION} -x erbal"
end

def gem
  RUBY_1_9 ? 'gem19' : 'gem'
end