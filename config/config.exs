use Mix.Config

config :logger,
  :console,
  format:   "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :milkpotion,
  api_key: nil,
  shared_secret: nil,
  rtm_rate_limit_rps: 1,
  rtm_rate_limit_max_tries: 10

import_config "#{Mix.env}.exs"
