require 'yaml'

ruby_versions = %w[2.4.5 2.5.3 2.6.1]
dry_equalizer_versions = %w[0.1.0 0.2.1]

dry_equalizer_versions.each do |version|
  appraise "dry-equalizer-#{version}" do
    gem 'dry-equalizer', version
  end
end

Dir.glob('gemfiles/*.gemfile').tap do |gemfiles|
  travis = ::YAML.dump(
    'cache' => {
      'bundler' => true,
    },
    'language' => 'ruby',
    'rvm' => ruby_versions,
    'before_script' => [
      'bundle install',
    ],
    'script' => [
      'bundle exec rspec',
      'bundle exec rubocop --fail-level C',
    ],
    'gemfile' => gemfiles,
  )

  ::File.open('.travis.yml', 'w+') do |file|
    file.write(travis)
  end
end
