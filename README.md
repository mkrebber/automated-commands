# AutomatedCommands

Still using TestUnit? Great! This gem helps automate DHHs [commands][1] gem which runs all test inside your Rails console.

## Installation

Add this line to your application's Gemfile:

    gem 'automated-commands', require: 'automated_commands'

And then execute:

    $ bundle

## Usage

You basically need to follow two steps to get it up and running:

``` bash
$ RAILS_ENV=test bundle exec rails c
```
``` ruby
irb(main):001:0> start_test_listener
```

That's it! Now when you are changing any files located under `test` your tests will be automatically be run.

## TODO

- tests

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

[1]:https://github.com/rails/commands