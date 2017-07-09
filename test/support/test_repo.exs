defmodule TestRepo do
  @moduledoc """
  A module that provides the interface we need from Ecto, saving us from having to set up an actual
  database. When a query is made, we store it in the process mailbox and return a result enqueued
  by the test (also via the process mailbox).

  The risk with this approach is that if Ecto's interface changes, this will fall out of date.
  """

  @lookup_key :test_repo_one_lookup
  @response_key :test_repo_response

  def one(query) do
    send self(), {@lookup_key, query}

    receive do
      {@response_key, response} -> response
    after
      10 -> raise "No response enqueued for TestRepo.one!"
    end
  end

  def enqueue_result(result) do
    send self(), {@response_key, result}
  end

  def last_query do
    receive do
      {@lookup_key, query} -> query
    after
      10 -> raise "No call to Repo.one made!"
    end
  end
end

