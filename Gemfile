source 'https://rubygems.org'
gemspec
gem "rake"
group :test do
  gem 'rspec'
end

if RUBY_ENGINE != "jruby"
  group :development do
    gem 'yard'
    gem 'redcarpet'
  end
end
