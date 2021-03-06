defmodule HitbserverWeb.Mixfile do
  use Mix.Project

  def project do
    [
      app: :hitbserver_web,
      version: "0.0.1",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {HitbserverWeb.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.3.0"},
      {:phoenix_pubsub, "~> 1.0"},
      # {:pdf_generator, "~> 0.3.6"},
      {:phoenix_html, "~> 2.10"},
      {:httpoison, "~> 1.0"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:distillery, "~> 2.0", runtime: false},
      {:cowboy, "~> 1.0"},
      {:json, "~> 1.0"},
      {:remote_ip, "~> 0.1.4"},
      {:hitb, in_umbrella: true},
      {:edit, in_umbrella: true},
      {:stat, in_umbrella: true},
      {:library, in_umbrella: true},
      {:server, in_umbrella: true},
      {:block, in_umbrella: true},
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, we extend the test task to create and migrate the database.
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [test: ["ecto.create --quiet", "ecto.migrate", "test"]]
  end
end
