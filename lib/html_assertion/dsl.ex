defmodule HTMLAssertion.DSL do
  @moduledoc ~S"""
  Add additional syntax to passing current context inside block

  ### Example: pass context
  ```
  assert_select html, ".container" do
    assert_select "form", action: "/users" do
      refute_select ".flash_message"
      assert_select ".control_group" do
        assert_select "label", class: "title", text: ~r{Full name}
        assert_select "input", class: "control", type: "text"
      end
      assert_select("a", text: "Submit", class: "button")
    end
    assert_select ".user_list" do
      assert_select "li"
    end
  end
  ```

  ## Example 2: print current context for debug

  ```
  assert_select(html, ".selector") do
    IO.inspect(assert_select, label: "current context html")
  end
  ```
  """
  alias HTMLAssertion, as: HTML
  alias HTMLAssertion.Debug

  defmacro assert_select(context, selector \\ nil, attributes \\ nil, maybe_do_block \\ nil) do
    Debug.log(context: context, selector: selector, attributes: attributes, maybe_do_block: maybe_do_block)
    {args, block} = extract_block([context, selector, attributes], maybe_do_block)

    call_select_fn(:assert, args, block)
    |> Debug.log_dsl()
  end

  defmacro refute_select(context, selector \\ nil, attributes \\ nil, maybe_do_block \\ nil) do
    Debug.log(context: context, selector: selector, attributes: attributes, maybe_do_block: maybe_do_block)
    {args, block} = extract_block([context, selector, attributes], maybe_do_block)

    call_select_fn(:refute, args, block)
    |> Debug.log_dsl()
  end

  defp call_select_fn(matcher, args, block \\ nil)

  defp call_select_fn(:assert, args, nil) do
    quote do
      HTML.assert_select(unquote_splicing(args))
    end
  end

  defp call_select_fn(:refute, args, nil) do
    quote do
      HTML.refute_select(unquote_splicing(args))
    end
  end

  defp call_select_fn(matcher, args, block) do
    block_arg =
      quote do
        fn unquote(context_var()) ->
          unquote(Macro.prewalk(block, &postwalk/1))
        end
      end

    call_select_fn(matcher, args ++ [block_arg])
  end

  # found do: block if exists
  defp extract_block(args, do: do_block) do
    {args, do_block}
  end

  defp extract_block(args, _maybe_block) do
    args
    |> Enum.reverse()
    |> Enum.reduce({[], nil}, fn
      arg, {args, block} when is_list(arg) ->
        {maybe_block, updated_arg} = Keyword.pop(arg, :do)

        {
          (updated_arg == [] && args) || [updated_arg | args],
          block || maybe_block
        }

      nil, {args, block} ->
        {args, block}

      arg, {args, block} ->
        {[arg | args], block}
    end)
  end

  # replace assert_select without arguments to context
  defp postwalk({:assert_select, env, nil}) do
    context_var(env)
  end

  defp postwalk({:assert_select, env, arguments}) do
    context = context_var(env)
    {args, block} = extract_block([context | arguments], nil)

    call_select_fn(:assert, args, block)
  end

  # replace refute_select without arguments to context
  defp postwalk({:refute_select, env, nil}) do
    context_var(env)
  end

  defp postwalk({:refute_select, env, arguments}) do
    context = context_var(env)
    {args, block} = extract_block([context | arguments], nil)

    call_select_fn(:refute, args, block)
  end

  defp postwalk(segment) do
    segment
  end

  defp context_var(env \\ []) do
    {:assert_select_context, env, nil}
  end
end
