# frozen_string_literal: true

require_relative "lib/moleculer/version"

Gem::Specification.new do |spec|
  spec.name = "moleculer"
  spec.version = Moleculer::VERSION
  spec.authors = ["fugufish"]
  spec.email = ["fugu@hey.com"]

  spec.summary       = "This is a Ruby implementation of the Moleculer framework."
  spec.description   = "This is a Ruby implementation of the Moleculer framework."
  spec.homepage      = "https://github.com/moleculer-ruby/moleculer"
  spec.license       = "MIT"

  spec.required_ruby_version = ">= 3.3.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/moleculer-ruby/moleculer"
  spec.metadata["changelog_uri"] = "https://github.com/moleculer-ruby/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "dry-initializer", "~> 3.1.1"
  spec.add_dependency "dry-types", "1.7.2"
  spec.add_dependency "timers", "~> 4.3.5"
  spec.add_dependency "console", "~> 1.25.2"

  # For more information and examples abkkkout making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata["rubygems_mfa_required"] = "true"
end
