# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'postal_search_jp/version'

Gem::Specification.new do |spec|
  spec.name          = 'postal_search_jp'
  spec.version       = PostalSearchJp::VERSION
  spec.platform      = 'java'
  spec.authors       = ['tearoom6']
  spec.email         = ['tearoom6.biz@gmail.com']

  spec.summary       = %q{Search addresses in Japan by postal code, and vice versa.}
  spec.description   = %q{Search addresses in Japan by postal code, and vice versa, by using AWS Athena. This gem can only work by using JRuby.}
  spec.homepage      = 'https://github.com/tearoom6/postal_search_jp'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    #spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1'
  spec.add_development_dependency 'jbundler', '~> 0.9'
  spec.add_development_dependency 'rake', '~> 10'
  spec.add_development_dependency 'rspec', '~> 3'
  spec.add_development_dependency 'aws-sdk', '~> 2'
  spec.add_development_dependency 'rubyzip', '~> 1'
end
