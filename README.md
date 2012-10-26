# Backstop::Dimensioned

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'backstop-dimensioned'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install backstop-dimensioned

## Usage

Multi dimensional + Multi sample data:

```
curl -X POST -d
'[{"metric":"test-foo","period":60,"measure_time":1351199760,"dimensions":["test","joe"],"sum":120,"min":8,"max":12,"count":10}]' localhost:5000/publish/custom/dimensioned
```

Single sample data, non-dimensioned data:

```
curl -X POST -d
'[{"metric":"joe.test-foo","period":60,"measure_time":1351199760,"value":120}]' localhost:5000/publish/custom/dimensioned
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
