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
    'addons' => {
      'code_climate' => {
        'repo_token' => 'c326cca5984d0e32d2c6b5d9b985756ee9312f63fc6a9480fc9cfa55c454d68a'
      }
    },
  )

  ::File.open('.travis.yml', 'w+') do |file|
    file.write(travis)
  end
end
