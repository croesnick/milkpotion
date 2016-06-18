use Mix.Config

config :milkpotion,
  rest_endpoint: "https://www.rememberthemilk.com/services/rest/",
  auth_endpoint: "https://www.rememberthemilk.com/services/auth/",
  rate_limit_interval: 1_000,
  max_requests_per_interval: 1,
  max_retries_if_over_rate: 5

config :logger,
  :console,
  format:   "$time $metadata[$level] $message\n",
  metadata: [:request_id]

import_config "#{Mix.env}.exs"
