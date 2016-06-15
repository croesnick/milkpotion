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
     {:meck, "~> 0.8", only: :test}
   ]
  end

  def application do
    [ applications: [:logger, :httpoison, :ex_rated] ]
  end
end
