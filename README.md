# Setup Elixir Project

A GitHub Action that gets a Mix project ready for CI. It installs Erlang and
Elixir, fetches and compiles the dependencies, compiles the app, and caches
all of it between runs.

```yaml
steps:
  - uses: actions/checkout@v6
  - uses: marmelasoft/elixir-setup@v1
  - run: mix test
```

With no inputs, the action reads the Erlang and Elixir versions from
`.tool-versions` or `mise.toml`, and compiles in the `test` environment.

## What it does

1. Installs Erlang, Elixir, Hex and Rebar with
   [`erlef/setup-beam`](https://github.com/erlef/setup-beam).
2. Restores `deps/` and `_build/<env>/` from the cache.
3. Runs `mix deps.get`, unless the cache was saved with the same `mix.lock`.
4. Compiles the dependencies with `mix loadpaths`, then the app with
   `mix compile --all-warnings --warnings-as-errors`.
5. Saves the caches right away, so they are kept even when a later step
   fails.
6. Sets `MIX_ENV` for the rest of the job, so later steps reuse the
   compiled build.

## Caches

| Cache | Path | Key changes when | Falls back to |
| --- | --- | --- | --- |
| Build | `deps/` and `_build/<env>/` | every commit | the latest build for the same `mix.lock`, then any build |
| PLTs | `priv/plts/` | `mix.lock` changes | the latest PLTs |

The build and PLT keys also hold the exact Erlang and Elixir versions and the
Mix environment. A new version starts a new build. Each commit saves a fresh
build, so the next run compiles only the files that changed since.

`deps/` and `_build/` share one cache because each needs the other. `_build/`
links to each dependency's `priv/` folder in `deps/`, and compiling some
dependencies writes into `deps/`, such as a NIF's `.so` file. Cached apart,
they can get out of step, and a NIF fails to load.

To throw away every cache, change `cache-key`.

## Inputs

| Input | Default | Description |
| --- | --- | --- |
| `otp-version` | | Erlang/OTP version. Leave it and `elixir-version` empty to read both from a version file. |
| `elixir-version` | | Elixir version. |
| `version-file` | | `.tool-versions` or `mise.toml`. When empty and no versions are given, the action looks for `.tool-versions`, then `mise.toml`. |
| `version-type` | `loose` | `strict` takes versions as written. `loose` picks the latest version that matches. Always `strict` with a version file. |
| `mix-env` | `MIX_ENV`, or `test` | Mix environment to compile and cache. |
| `build-deps` | `true` | Compile the dependencies. |
| `build-app` | `true` | Compile the app. |
| `build-flags` | `--all-warnings --warnings-as-errors` | Flags for `mix compile`. |
| `install-hex` | `true` | Install Hex. |
| `install-rebar` | `true` | Install Rebar. |
| `cache-plts` | `false` | Build and cache the Dialyzer PLTs. |
| `plts-path` | `priv/plts` | Folder that holds the PLTs. |
| `cache-key` | `v1` | Change it to start every cache from scratch. |
| `pre-deps-hook` | | Shell command to run before fetching the dependencies. |

## Outputs

| Output | Description |
| --- | --- |
| `otp-version` | Exact Erlang/OTP version installed. |
| `elixir-version` | Exact Elixir version installed. |
| `mix-env` | Mix environment the action compiled and cached. |
| `build-cache-hit` | `true` when the cache of `deps/` and `_build/` matched this commit exactly. |
| `plt-cache-hit` | `true` when the PLT cache matched `mix.lock` exactly. |

## Examples

### Test against several versions

```yaml
jobs:
  test:
    runs-on: ubuntu-24.04
    strategy:
      matrix:
        otp: ["28", "29"]
        elixir: ["1.19", "1.20"]
    steps:
      - uses: actions/checkout@v6
      - uses: marmelasoft/elixir-setup@v1
        with:
          otp-version: ${{ matrix.otp }}
          elixir-version: ${{ matrix.elixir }}
      - run: mix test
```

### Run Dialyzer

Keep the PLTs in `priv/plts` in `mix.exs`:

```elixir
def project do
  [
    # ...
    dialyzer: [
      plt_core_path: "priv/plts",
      plt_local_path: "priv/plts"
    ]
  ]
end
```

Then turn on `cache-plts`:

```yaml
- uses: marmelasoft/elixir-setup@v1
  with:
    cache-plts: true
- run: mix dialyzer --format github
```

### Fetch from a private Hex organization

The hook runs before `mix deps.get`. Pass secrets through `env`, so they never
end up in the command itself:

```yaml
- uses: marmelasoft/elixir-setup@v1
  env:
    HEX_ORG_KEY: ${{ secrets.HEX_ORG_KEY }}
  with:
    pre-deps-hook: mix hex.organization auth acme --key "$HEX_ORG_KEY"
```

## Releasing

Publish a GitHub release with a tag like `v1.2.3`. The release workflow then
points the `v1` tag at it, so everyone on `@v1` gets the new version.

```sh
gh release create v1.2.3 --generate-notes
```
