# PostalSearchJp

Search addresses in Japan by postal code, and vice versa.

[![Travis](https://img.shields.io/travis/tearoom6/postal_search_jp.svg)](https://travis-ci.org/tearoom6/postal_search_jp)
[![Gem](https://img.shields.io/gem/dtv/postal_search_jp.svg)](https://rubygems.org/gems/postal_search_jp)
![license](https://img.shields.io/github/license/tearoom6/postal_search_jp.svg)

## Requisites

- Java 8
- JRuby 9
- AWS account

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'postal_search_jp'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install postal_search_jp

## Setup

```sh
# Install dependencies.
$ bundle install
$ jruby -S jbundle install

# Set env variables.
# It's just samples (random generated). Use yours.
$ export AWS_ACCESS_KEY_ID="4J4BIQ863ZM4ZLOYFI6H"
$ export AWS_SECRET_ACCESS_KEY="HYXOHI93FW7QV+RGXA62CIFCT1GRMTD2DFZP4BFR"
$ export AWS_REGION="us-west-2"
```

## Usage

```ruby
# Configuration.
PostalSearchJp.configure(
  # AWS credentials can be skip to set here if you set env variables above.
  aws_access_key_id:     '4J4BIQ863ZM4ZLOYFI6H',
  aws_secret_access_key: 'HYXOHI93FW7QV+RGXA62CIFCT1GRMTD2DFZP4BFR',
  aws_region:            'us-east-1',           # Athena is only available in 'us-east-1' or 'us-west-2' currentry.
  s3_bucket:             'my-postal-search-jp',
  s3_path:               'my_postal_search_jp', # Default value is 'postal_search_jp'
  athena_db_name:        'postalsearchjp',      # Default value is 'postalsearchjp'
  athena_table_name:     'jp_postal_codes',     # Default value is 'jp_postal_codes'
)

# Upload data file S3 & define Athena schema.
# It should be called only once.
PostalSearchJp.setup

# Search by address.
PostalSearchJp.search_by_address('井の頭')
# => [#<struct PostalSearchJp::JpPostalCode postal_code="\"1810001\"", prefecture="\"東京都\"", city="\"三鷹市\"", street="\"井の頭\"", prefecture_kana="\"TOKYO TO\"", city_kana="\"MITAKA SHI\"", street_kana="\"INOKASHIRA\"">]

# Find by postal code.
PostalSearchJp.find_by_postal_code('1810001')
# => #<struct PostalSearchJp::JpPostalCode postal_code="1810001", prefecture="東京都", city="三鷹市", street="井の頭", prefecture_kana="TOKYO TO", city_kana="MITAKA SHI", street_kana="INOKASHIRA">
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tearoom6/postal_search_jp.

