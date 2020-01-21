[![Gem Version](https://badge.fury.io/rb/guard-kibit.svg)](http://badge.fury.io/rb/guard-kibit)

# guard-kibit

**guard-kibit** allows you to automatically check Clojure code style with [Kibit](https://github.com/jonase/kibit) when files are modified.

## Installation

Please make sure to have [Guard](https://github.com/guard/guard) installed before continue.

Add `guard-kibit` to your `Gemfile`:

```ruby
group :development do
  gem 'guard-kibit'
end
```

and then execute:

```sh
$ bundle install
```

or install it yourself as:

```sh
$ gem install guard-kibit
```

Add the default Guard::Kibit definition to your `Guardfile` by running:

```sh
$ guard init kibit
```

## Usage

Please read the [Guard usage documentation](https://github.com/guard/guard#readme).

## Options

You can pass some options in `Guardfile` like the following example:

```ruby
guard :kibit, all_on_start: false do
  # ...
end
```


### Available Options

```ruby
all_on_start: true     # Check all files at Guard startup.
                       #   default: true
notification: :failed  # Display Growl notification after each run.
                       #   true    - Always notify
                       #   false   - Never notify
                       #   :failed - Notify only when failed
                       #   default: :failed
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

Copyright (c) 2020 Eric Musgrove

See the [LICENSE.txt](LICENSE.txt) for details.
