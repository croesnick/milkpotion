[![Build Status](https://travis-ci.org/croesnick/milkpotion.svg?branch=master)](https://travis-ci.org/croesnick/milkpotion) [![Coverage Status](https://coveralls.io/repos/github/croesnick/milkpotion/badge.svg?branch=master)](https://coveralls.io/github/croesnick/milkpotion?branch=master)

# Milkpotion

_milkpotion_ is an api wrapper for [Remember the Milk](https://www.rememberthemilk.com) written in Elixir.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add milkpotion to your list of dependencies in `mix.exs`:

        def deps do
          [{:milkpotion, "~> 0.0.1"}]
        end

  2. Ensure milkpotion is started before your application:

        def application do
          [applications: [:milkpotion]]
        end
