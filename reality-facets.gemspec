# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name               = %q{reality-facets}
  s.version            = '1.11.0'
  s.platform           = Gem::Platform::RUBY

  s.authors            = ['Peter Donald']
  s.email              = %q{peter@realityforge.org}

  s.homepage           = %q{https://github.com/realityforge/reality-facets}
  s.summary            = %q{A basic toolkit for binding facets or extensions to model objects.}
  s.description        = %q{A basic toolkit for binding facets or extensions to model objects.}

  s.files              = `git ls-files`.split("\n")
  s.test_files         = `git ls-files -- {spec}/*`.split("\n")
  s.executables        = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths      = %w(lib)

  s.rdoc_options       = %w(--line-numbers --inline-source --title reality-facets)

  s.add_dependency 'reality-core', '>= 1.8.0'
  s.add_dependency 'reality-naming', '>= 1.9.0'
  s.add_dependency 'reality-orderedhash', '>= 1.0.0'

  s.add_development_dependency(%q<minitest>, ['= 5.9.1'])
  s.add_development_dependency(%q<test-unit>, ['= 3.1.5'])
end
