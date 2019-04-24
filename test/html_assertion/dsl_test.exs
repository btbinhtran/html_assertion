defmodule HTMLAssertion.DSLTest do
  use ExUnit.Case, async: true
  import HTMLAssertion.DSL

  describe "(context definition)" do
    setup do
      [html: ~S{
        <div class="container">
          <h1>Title</h1>
          <p class="hard_decision">
            <a class="active link1">Yes</a>
            <a class="link2">No</a>
          </p>
        </div>
    }]
    end

    test "gets context html for defining context", %{html: html} do
      assert_select(html) do
        assert assert_select ==
                 "\n        <div class=\"container\">\n          <h1>Title</h1>\n          <p class=\"hard_decision\">\n            <a class=\"active link1\">Yes</a>\n            <a class=\"link2\">No</a>\n          </p>\n        </div>\n    "

        assert_select("p") do
          assert assert_select == "<p class=\"hard_decision\"><a class=\"active link1\">Yes</a><a class=\"link2\">No</a></p>"
          assert_select("a.link1", class: "active", text: "Yes")
          assert_select("a.link2", id: nil, text: "No")
        end
      end
    end

    test "use macro for defining context with selector" do
      html = ~S{
          <p id="aaa">
            <a class="link">Click me</a>
          </p>
      }

      assert_select(html, "p") do
        assert_select("a", class: "link", text: "Click me", id: nil)
      end
    end

    test "use macro for defining context with selector and attributes" do
      html = ~S{
          <p class="foo" id="descr">
            <a class="link">Click me</a>
          </p>
      }

      assert_select(html, "p", class: "foo", id: "descr") do
        assert_select("a", class: "link", text: "Click me", id: nil)
      end
    end
  end

  describe "(check simple form)" do
    setup do
      [html: ~S{
        <form class="form" method="post" action="/session/login">
          <div class="form-group row -email">
            <label for="staticEmail" class="col-sm-2 col-form-label">Email</label>
            <div class="col-sm-10">
              <input type="text" readonly class="form-control-plaintext" id="staticEmail" value="email@example.com">
            </div>
          </div>
          <div class="form-group row -password">
            <label for="inputPassword" class="col-sm-2 col-form-label">Password</label>
            <div class="col-sm-10">
              <input type="password" class="form-control" id="inputPassword" placeholder="Password">
            </div>
          </div>
          <button type="submit" class="btn btn-primary mb-2">Confirm identity</button>
        </form>
      }]
    end

    test "check tags", %{html: html} do
      html
      |> assert_select("form", class: "form", method: "post", action: "/session/login") do
        refute_select(".message")

        assert_select ".-email" do
          assert_select("label", text: "Email", for: "staticEmail", class: "col-form-label")
          assert_select("div input", type: "text", readonly: true, class: "form-control-plaintext", value: "email@example.com")
        end

        assert_select(".-password") do
          assert_select("label", text: "Password", for: "inputPassword")
          assert_select("div input", placeholder: "Password", type: "password", class: "form-control", id: "inputPassword", placeholder: "Password")
        end

        assert_select("button", type: "submit", class: "primary")
      end
    end
  end

  describe "(check contains)" do
    setup do
      [html: ~S{
        <div class="content">
          <h1>Hello World</h1>
        </div>
      }]
    end

    test "expect find contain text", %{html: html} do
      assert_select(html, ~r{Hello World})
      refute_select(html, ~r{Another World})

      assert_select(html, ".content") do
        assert_select(~r{Hello World})
      end
    end
  end

  describe "(pass pipeline)" do
    test "pass html to method through pipeline" do
      ~S{
        <div id="qwe">
          <a class="link">Click me</a>
        </div>
      }
      |> assert_select("#qwe") do
        assert_select("a", class: "link", text: "Click me", id: nil)
      end
    end
  end

  describe "(check attributes)" do
    setup do
      [html: ~S{
        <label for="field_two">Two</label>
        <input id="field_two" type="radio" value="two" name="field[birds]">
      }]
    end

    test "expect refute checked without errors", %{html: html} do
      refute_select(html, "input[type=radio][value=two]", checked: true)
    end

    test "expect check attributes as map", %{html: html} do
      assert_select(html, "#field_two", %{"type" => "radio", "value" => "two", "name" => "field[birds]"})
    end
  end
end
