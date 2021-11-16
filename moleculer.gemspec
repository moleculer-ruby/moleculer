# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "moleculer/version"

Gem::Specification.new do |spec|
  spec.name          = "moleculer"
  spec.version       = Moleculer::VERSION
  spec.authors       = ["fugufish"]
  spec.email         = ["therealfugu@gmail.com"]

  spec.required_ruby_version = ">= 3.0"

  spec.summary       = "This is a Ruby implementation of the Moleculer framework."
  spec.description   = "This is a Ruby implementation of the Moleculer framework."
  spec.homepage      = "https://github.com/moleculer-ruby/moleculer"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the
  # 'allowed_push_host` to allow pushing to a single host or delete this section to
  # allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"

    spec.metadata["homepage_uri"] = spec.homepage
    # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
    # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "concurrent-ruby",      "~> 1.1"
  spec.add_dependency "concurrent-ruby-edge", "~> 0.6"
  spec.add_dependency "concurrent-ruby-ext",  "~> 1.1"
  spec.add_dependency "semantic_logger",      "~> 4.8"

  spec.add_development_dependency "rake",      "~> 13.0"
  spec.add_development_dependency "redis",     "~> 4.5"
  spec.add_development_dependency "rspec",     "~> 3.10"
  spec.add_development_dependency "rubocop",   "~> 1.22"
  spec.add_development_dependency "simplecov", "~> 0.21"
  spec.add_development_dependency "yard",      "~> 0.9"
end
