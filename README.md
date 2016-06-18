[![Build Status](https://travis-ci.org/croesnick/milkpotion.svg?branch=master)](https://travis-ci.org/croesnick/milkpotion) [![Coverage Status](https://coveralls.io/repos/github/croesnick/milkpotion/badge.svg?branch=master)](https://coveralls.io/github/croesnick/milkpotion?branch=master)

# Milkpotion

_milkpotion_ is an api wrapper for [Remember the Milk](https://www.rememberthemilk.com) written in Elixir.

## Installation

Add _milkpotion_ to your list of dependencies in `mix.exs`:

    def deps do
      [{:milkpotion, "~> 0.0.3"}]
    end

## Configuration

_milkpotion_ exposes a couple of configuration options which you might want to set in your config (either globally or per environment in `config/*.exs`) as well:

    config :milkpotion,
      api_key: "your api key for Remember the Milk",
      shared_secret: "your shared secret",
      # Specify how many calls to the RTM api are allowed per interval;
      # the default are shown below. The interval is specified in
      # milliseconds.
      rate_limit_interval: 1_000,
      max_requests_per_interval: 1,
      # How many time should the `RateLimiter` retry the call if it still
      # receives a 503 from the RTM service?
      max_retries_if_over_rate: 5

## Usage

Having properly set your api key ans shared secret, you are good to go. :)

### Authentication

Build an authentication url. Call it and RTM will ask you to grant the respective permissions (here: read-only) to your app. On succes, the rtm service will then redirect you to your specified callback url with a frob attached as a query parameter.

    auth_url = "read" |> Milkpotion.Base.Url.init_auth

Having the frob, your can acquire an auth token.

    {:ok, %{"auth_token" => token}} = Milkpotion.Auth.get_token(frob)

Having a token at hand, you can request any method you want:

    {:ok, body} = "rtm.test.echo" |> Milkpotion.Base.Url.rest(token) |> Milkpotion.Request.get

We will wrap more and more functionality of the rtm api in the future by introducing modules similiar to the `Auth` module (intended to wrap the `rtm.auth.*` methods.)

## Contributing

Feature requests, bugs, and any kind of comments are always welcome.

Contributing
------------

In general, we follow the "fork-and-pull" Git workflow.

 1. **Fork** the repo on GitHub
 2. **Clone** the project to your own machine
 3. **Commit** changes to your own branch
 4. **Push** your work back up to your fork
 5. Submit a **Pull request** so that we can review your changes

NOTE: Be sure to merge the latest from "upstream" before making a pull request!

## Versioning

We use [semantic versioning](http://semver.org/). For the versions available, see the [tags on this repository](https://github.com/croesnick/milkpotion/tags).

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
