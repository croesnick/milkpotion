defmodule Milkpotion.Mixfile do
  use Mix.Project

  def project do
    [app: :milkpotion,
     version: "0.0.2",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     name: "milkpotion",
     description: "milkpotion is an api wrapper for Remember the Milk",
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: ["coveralls": :test,
                         "coveralls.detail": :test,
                         "coveralls.post": :test,
                         "coveralls.html": :test],
     package: package,
     deps: deps
   ]
  end

  def package do
    [ maintainers: ["Carsten Rösnick-Neugebauer"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/croesnick/milkpotion.git"}
    ]
  end

  defp deps do
    [{:earmark, "~> 0.1", only: :dev},
     {:ex_doc, "~> 0.11", only: :dev},
     {:poison, "~> 2.0"},
     {:httpoison, "~> 0.8"},
     {:ex_rated, "~> 1.2"},
     {:excoveralls, "~> 0.5", only: :test},
     {:bypass, "~> 0.1", only: :test}
   ]
  end

  def application do
    [ applications: [:logger, :httpoison, :ex_rated],
      env: [ api_key: nil,
             shared_secret: nil,
             rate_limit_interval: 1_000,
             max_requests_per_interval: 1,
             max_retries_if_over_rate: 5 ]
    ]
  end
end
