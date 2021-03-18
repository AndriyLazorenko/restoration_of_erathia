defmodule RestorationOfErathia.MixProject do
  use Mix.Project

  def project do
    [
      app: :restoration_of_erathia,
      version: "0.1.1",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      source_url: "https://github.com/AndriyLazorenko/restoration_of_erathia",
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :crypto]
    ]
  end

  defp description() do
    "A tool to assist with restoring deleted files, made for Linux OS"
  end

  defp package() do
    [
    licenses: ["MIT License"],
    links: %{"Github" => "https://github.com/AndriyLazorenko/restoration_of_erathia"}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.21", only: :dev, runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
