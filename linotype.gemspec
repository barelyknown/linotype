# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'linotype/version'

Gem::Specification.new do |gem|
  gem.name          = "linotype"
  gem.version       = Linotype::VERSION
  gem.authors       = ["Sean Devine"]
  gem.email         = ["barelyknown@icloud.com"]
  gem.description   = <<-eos
  linotype implements that game mechanic of Letterpress for iOS by atebits software. The program was written to support the automation of letterpress gameplay and to power command line or web-based versions of the game. It was inspired by a tweet by Andy Baio about cheating in letterpress. The game uses the words file that comes with Mac OS X, but any word file can be used.
  eos
  gem.summary       = %q{The game mechanic of Letterpress for iOS, written in ruby.}
  gem.homepage      = "https://github.com/barelyknown/linotype"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
