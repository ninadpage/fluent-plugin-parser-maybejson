# fluent-plugin-parser-maybejson

This Fluentd parser plugin aims to simplify parsing JSON formatted logs
emitted by applications running inside docker containers.

A line in the Docker log file might look like this JSON:

```json
[1]
{"log":"2014/09/25 21:15:03 Got request with path wombat\n",
 "stream":"stderr",
 "time":"2014-09-25T21:15:03.499185026Z"}
```

If some applications in turn use JSON for structured logging, then the
line in Docker log file might look like this:

```json
[2]
{"log":
 "{\"message\": \"Hello!\", \"key\": \"value\", \"name\": \"__main__\"}\n",
 "stream":"stderr",
 "time":"2014-09-25T21:15:03.499185026Z"}
```

The built-in parser filter can parse a JSON formatted key, but it requires
_all_ logs to be JSON formatted. If they are not, it either ignores them
or raises errors.

This plugin provides a `maybe_json` format parser (built on top of
`JSONParser`), which attempts to parse `log` (key can be changed using
`key_name` parameter) as a JSON encoded string, and if that fails, leaves
the value unchanged.

Optionally, you can specify `hash_value_field_nonjson` parameter if you want
to wrap non-JSON logs in a specified key. Default is `nil`.

For record [1] above (non-JSON logs), with `hash_value_field_nonjson=nil`,
(assuming `hash_value_field` parameter of JSONParser is `log`),
result is below:

```json
{"log":"2014/09/25 21:15:03 Got request with path wombat\n",
 "stream":"stderr"}
```

For record [1], with `hash_value_field_nonjson=raw_log`, result is below:

```json
{"log":{"raw_log":"2014/09/25 21:15:03 Got request with path wombat\n"},
 "stream":"stderr"}
```

(`time` is parsed by parser filter, and is available separately -
unless `time_parse` is `false`.)

Note that if you've set `hash_value_field` parameter of JSONParser to `nil`,
you *must* use `hash_value_field_nonjson` to make sure this parser returns
a Hash and not a String for non-JSON logs.

For record [2] above (JSON logs), result is below:

```json
{"log":
 {"message": "Hello!", "key": "value", "name": "__main__"},
 "stream":"stderr"}
```

If you prefer "flat" log records, you may set `hash_value_field=nil` and
`hash_value_field_nonjson=message`, then use the
[record_transformer](https://docs.fluentd.org/v0.12/articles/filter_record_transformer)
filter to remove the `log` key, which would be redundant after parsing it.

Then record [1] (non-JSON logs) would be:

```json
{"message":"2014/09/25 21:15:03 Got request with path wombat\n",
 "stream":"stderr"}
```

And record [2] (JSON logs) would be:

```json
{"message": "Hello!", "key": "value", "name": "__main__",
 "stream":"stderr"}
```

## Configurations

### hash_value_field_nonjson

The key which will be used to wrap non-JSON logs in a Hash. Default is `nil`.

Since this is a subclass of
[JSONParser](https://docs.fluentd.org/v0.12/articles/parser_json),
all parameters of `JSONParser` are also supported.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fluent-plugin-parser-maybejson'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fluent-plugin-parser-maybejson

## Usage Example

---- fluentd.conf ----

```aconf
<filter **>
  @type parser
  format maybe_json
  key_name log
  hash_value_field log
  hash_value_field_nonjson raw_log
  reserve_data true
</filter>
```

## Contributing

Bug reports and pull requests are welcome on GitHub at
<https://github.com/ninadpage/fluent-plugin-parser-maybejson>.
