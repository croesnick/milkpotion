use Mix.Config

config :milkpotion,
  api_key: "123",
  shared_secret: "456",
  rate_limit_interval: 10,
  max_requests_per_interval: 1,
  max_retries_if_over_rate: 2
