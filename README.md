_A lightweight, flexible plug for loading and validating resources._

If you've written a web application, you've almost certainly run into this scenario: a user requests a resource and you need to make sure that they can access it. It could be students and essays, customers and orders, books and quotes, whatever. It's a universal need.

Let's say you have two resources:

```elixir
resources :books, BookController do
  resources :quotes, QuoteController
end
```

If a user wants a book, you need to make sure the book exists and belongs to them. If they request a quote in a book, you need to make sure first that the book exists and belongs to the user, then that the quote exists and belongs to the book. If everything matches up, pass those records on to the controller; if not, send back an error message.

LoadResource makes that easy for Phoenix apps and any other Elixir projects using plug and Ecto.

## Features

* Lightweight: no dependencies beyond Ecto
* Flexible: straightforward options make it easy to handle many common cases
* Tested: fully tested in ExUnit and linted by [Credo](https://github.com/rrrene/credo)
* Documented: [fully documented on hex.pm](https://hexdocs.pm/load_resource/0.1.0)

Feedback or pull requests for additional configuration very welcome! See below.

## Installation

Add LoadResource to your `mix.exs`:

```
{:load_resource, "~> 0.1.0"}
```

Update your `config.exs` to tell LoadResource which Ecto repo to use:

```elixir
config :load_resource, repo: YourCoolApp.Repo
```

## Usage

Let's take our book example from above:

```elixir
plug LoadResource.Plug, [model: Book, not_found: &MyErrorHandler.not_found/1]
```

Bam! That's all you need. If the `id` param of the incoming request matches a book in the `books` table, it will be available to your controller as `conn.assigns[:book]`; if not, it'll halt the request and pass `conn` over to your error handler to customize the error response.

### Nested Resources

Now let's take the scope example. In our QuoteController, we first need to load the book, which may come in as `book_id`:

```elixir
plug LoadResource.Plug, [model: Book, id_key: "book_id", not_found: &MyErrorHandler.not_found/1]
```

If that succeeds, we want to check for a quote scoped to that book’s data. That's as easy as adding a second LoadResource.Plug:

```elixir
plug LoadResource.Plug, [model: Quote, scopes: [:book], not_found: &MyErrorHandler.not_found/1]
```

LoadResource makes it straightforward to chain resource plugs in the same controller. If you pass in a scope that's an atom, the package will use the results of a previous LoadResource plug (e.g. `conn.assigns[:book]`) to check against the Quote’s `book_id` column.

### Scopes

There are so many other conditions you might need to check when validating a resource. LoadResource makes those checks as easy as possible by composing together any Scope structs that you provide.

For instance, the above `:book` example expands internally to:

```elixir
%LoadResource.Scope{column: :book_id, value: fn(conn) -> conn.assigns[:book] end}
```

`column` is what field to check on the target table and `value` is a function that, given the request (`conn`), says what value to expect. The value can be an atom, string, number, boolean, or a map/struct containing an `:id` key. (Any other result will raise an error.)

So, for instance, if you use [Guardian](https://github.com/ueberauth/guardian) for authentication, you could check that a book belongs to the signed in user:

```elixir
alias LoadResource.Scope

plug LoadResource.Plug, [
  model: Book,
  scopes: [%Scope{column: :user_id, value: &Guardian.Plug.current_resource/1}],
  not_found: &MyErrorHandler.not_found/1
]
```

Or if you want to validate another parameter in the request matches up:

```elixir
scope = %Scope{column: :book_type, value: fn(conn) -> conn.params[:book_type] end}]

plug LoadResource.Plug, [
  model: Book,
  scopes: [scope],
  not_found: MyErrorHandler.not_found/1
]
```

### Accepted Options

LoadResource.Plug takes the following options:

* `model`: an Ecto model representing the resource you want to load (required)
* `not_found`: a function/1 that gets called if the record can't be found and `required: true` (required)
* `id_key`: what param in the incoming request represents the ID of the record (optional, default: "id")
* `required`: whether to halt the plug pipeline and return an error response if the record can't be found (optional, default: true)
* `scopes`: an list of` :atom`s and/or `Scope`s as described above (optional, default: [])

## Known Limitations

`LoadResource` can do a lot, but it can't do everything. Here are some known limitations:

* If a map is returned from a scope’s `value` function call, the value we check must be on the `:id` key. It would be straightforward to add an optional field on `Scope` to configure this.
* Join tables are not currently supported. The package currently assumes all fields needed to validate a resource are on the resource itself.
* Only single record lookups are supported. (It would be fairly straightforward to handle multiple records if someone needs that functionality.)

## Why build a package?

Loading resources in Phoenix and other plug-based apps is just complicated enough and definitely common enough that a generalized solution seems worth building. Plus, it was fun. 🤗

There are a few packages that do this in Elixir, such as [Canary](https://hex.pm/packages/canary) and [PolicyWonk](https://hex.pm/packages/policy_wonk), but both assume or provide a more elaborate authentication and permissioning system than many small or medium apps need.

If you need role-based permissioning, flexible access policies, etc. definitely check them out. If those sound far more complicated than you need, LoadResource may well meet your needs.

## Contributing

Feedback and bugs reports are very welcome! Feel free to open a Github issue if something's on your mind; even better, open a pull request! PRs with working tests will get merged faster, though I'm happy to help with any changes.

Please note that this project is released with a Contributor Code of Conduct. By participating in
this project you agree to abide by its terms. See
[code_of_conduct.md](https://github.com/arsduo/load_resource/blob/master/CODE_OF_CONDUCT.md) for more information.

### Docker Setup

LoadResource uses Docker to ensure a consistent development environment. Once you have [Docker
installed](https://docs.docker.com/engine/installation/), just run `docker-compose run
load_resource bash`. This will compile the environment and put you in a bash shell in which you can
run `mix test`, access `iex`, etc.

Any changes you make to files will show up in the Docker environment automatically, though if you
change package dependencies or the Docker configuration itself, you'll need to exit Docker and run
`docker-compose build` to rebuild the image.

