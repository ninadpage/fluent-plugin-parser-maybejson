#
# github.com/ninadpage
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#

# The following Fluentd parser plugin, aims to simplify parsing JSON formatted
# logs emitted by applications running inside docker containers.
#
# A line in the Docker log file might look like this JSON:
#
# {"log":"2014/09/25 21:15:03 Got request with path wombat\n",
#  "stream":"stderr",
#   "time":"2014-09-25T21:15:03.499185026Z"} [1]
#
# If some applications in turn use JSON for structured logging, then the
# line in Docker log file might look like this:
#
# {"log":
#  "{\"message\": \"Hello!\", \"key\": \"value\", \"name\": \"__main__\"}\n",
#  "stream":"stderr",
#  "time":"2014-09-25T21:15:03.499185026Z"} [2]
#
# The built-in parser filter can parse a JSON formatted key, but it requires
# _all_ logs to be JSON formatted. If they are not, it either ignores them
# or raises errors.
#
# This plugin provides a 'maybe_json' format parser (built on top of
# JSONParser), which attempts to parse `log` (key can be changed using
# `key_name` parameter) as an JSON encoded string, and if that fails, leaves
# the value unchanged.
# 
# Optionally, you can specify `hash_value_field_nonjson` parameter if you want
# to wrap non-JSON logs in a specified key. Default is `nil`. 
# 
# For record [1] above (non-JSON logs), with `hash_value_field_nonjson=nil`,
# (assuming `hash_value_field` parameter of JSONParser is `log`),
# result is below:
# {"log":"2014/09/25 21:15:03 Got request with path wombat\n",
#  "stream":"stderr",
#   "time":"<time-formatted-by-parser-filter>"}
#
# For record [1] above, with `hash_value_field_nonjson=raw_log`,
# result is below:
# {"log":"{"raw_log":"2014/09/25 21:15:03 Got request with path wombat\n"},
#  "stream":"stderr",
#   "time":"<time-formatted-by-parser-filter>"}
#
# Note that if you've set `hash_value_field` parameter of JSONParser to `nil`,
# you *must* use `hash_value_field_nonjson` to make sure this parser returns
# a Hash and not a String for non-JSON logs.
#
# For record [2] above, result is below:
# {"log":
#  {"message": "Hello!", "key": "value", "name": "__main__"},
#  "stream":"stderr",
#  "time":"<time-formatted-by-parser-filter>"}
#
# If you prefer "flat" log records, you may set `hash_value_field=nil` and
# `hash_value_field_nonjson=message`, then use the record_transformer filter
# to remove the `log` key, which would be redundant after parsing it.
#
# Then record [1] (non-JSON) would be:
# {"message":"2014/09/25 21:15:03 Got request with path wombat\n",
#  "stream":"stderr",
#   "time":"<time-formatted-by-parser-filter>"}
#
# And record [2] (JSON) would be:
# {"message": "Hello!", "key": "value", "name": "__main__",
#  "stream":"stderr",
#  "time":"<time-formatted-by-parser-filter>"}
#
# Usage:
#
# ---- fluentd.conf ----
#
# <filter **>
#   @type parser
#   format maybe_json
#   key_name log
#   hash_value_field log
#   hash_value_field_nonjson raw_log
#   reserve_data true
# </filter>
#
# ----   EOF       ---

module Fluent
  class TextParser
    class MaybeJSONParser < JSONParser
      Plugin.register_parser("maybe_json", self)

      config_param :hash_value_field_nonjson, :string, default: nil

      def parse(text)
        super do |time, record|
          
          if record.nil?
            # Parsing failed, return text as log
            record = @hash_value_field_nonjson ? {@hash_value_field_nonjson => text} : text
          end

          if block_given?
            yield time, record
          else
            return time, record
          end
        end
      end
    end
  end
end
