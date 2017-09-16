defmodule Slackir.RandomChannel do
  use Slackir.Web, :channel

  def join("random:lobby", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("shout", message, socket) do
    spawn(__MODULE__, :save_message, [message])
    broadcast! socket, "shout", message
    {:noreply, socket}
  end

  def save_message(message) do
    Slackir.Message.changeset(%Slackir.Message{}, message)
    |> Slackir.Repo.insert
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (random:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
