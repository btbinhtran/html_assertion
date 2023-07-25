# Credit to assert_html
This package was made from assert_html from Kr00lIX
https://github.com/Kr00lIX/assert_html

If somehow the features of this package are put in for assert_html, I would love to redirect people to use the assert_html package.

# HtmlAssertion

[![Build Status](https://travis-ci.com/btbinhtran/html_assertion.svg?branch=master)](https://travis-ci.com/btbinhtran/html_assertion)
[![Hex pm](https://img.shields.io/hexpm/v/html_assertion.svg?style=flat)](https://hex.pm/packages/html_assertion)
[![Coverage Status](https://coveralls.io/repos/github/btbinhtran/html_assertion/badge.svg?branch=master)](https://coveralls.io/github/btbinhtran/html_assertion?branch=master)

HTMLAssertion adds assertions for testing rendered HTML using CSS selectors.

Use them in your Phoenix controller and integration tests.

## Installation

The package can be installed
by adding `html_assertion` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:html_assertion, "~> 0.1.4", only: :test}
  ]
end
```

### Usage in Phoenix Controller and Integration Test

Import the HTML assertion functions in `YourAppWeb.ConnCase`. Remember to replace all instances of `YourApp` with your app module name.

```elixir
defmodule YourAppWeb.ConnCase do
  .
  .
  .
  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest
      alias YourAppWeb.Router.Helpers, as: Routes
      use HTMLAssertion
      # The default endpoint for testing
      @endpoint YourAppWeb.Endpoint
    end
  end
  .
  .
  .
end
```

Assuming the `html_response(conn, 200)` returns:
```html
<!DOCTYPE html>
<html>
<head>
  <title>PAGE TITLE</title>
</head>
<body>
  <a href="/signup">Sign up</a>
  <a href="/help">Help</a>
</body>
</html>
```

An example controller test:
```elixir
defmodule YourAppWeb.PageControllerTest do
  use YourAppWeb.ConnCase, async: true

  test "should get index", %{conn: conn} do
    conn = conn
    |> get(Routes.page_path(conn, :index))

    html_response(conn, 200)
    # Page title is "PAGE TITLE"
    |> assert_select("title", "PAGE TITLE")
    # Page title is "PAGE TITLE" and there is only one title element
    |> assert_select("title", count: 1, text: "PAGE TITLE")
    # Page title matches "PAGE" and there is only one title element
    |> assert_select("title", count: 1, match: "PAGE")
    # Page has one link with href value "/signup"
    |> assert_select("a[href='/signup']", count: 1)
    # Page has at least one link
    |> assert_select("a", min: 1)
    # Page has at most two links
    |> assert_select("a", max: 2)
    # Page contains no forms
    |> refute_select("form")
  end
end
```

Read the docs at [https://hexdocs.pm/html_assertion](https://hexdocs.pm/html_assertion/HTMLAssertion.html).

