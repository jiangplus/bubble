defmodule BubbleWeb.PubsubController do
  use BubbleWeb, :controller
  use Joken.Config

  def index(conn, _params) do
    json(conn, "hello")
  end

  def add_key(conn, _params) do
    conn.query_params |> IO.inspect
    auth_token = conn.query_params["auth_token"]
    key_user = conn.query_params["key_user"]
    key = conn.query_params["key"]

    {:ok, claims} = verify_and_validate(auth_token)
    {:ok, rds} = Redix.start_link()
    Redix.command(rds, ["SET", "bubble:#{key_user}:secret", key])
    json(conn, "ok")
  end

  def remove_key(conn, _params) do
    conn.query_params |> IO.inspect
    auth_token = conn.query_params["auth_token"]
    key_user = conn.query_params["key_user"]

    {:ok, claims} = verify_and_validate(auth_token)
    {:ok, rds} = Redix.start_link()
    Redix.command(rds, ["DEL", "bubble:#{key_user}:secret"])
    json(conn, "ok")
  end

  def list_keys(conn, _params) do
    conn.query_params |> IO.inspect
    {:ok, rds} = Redix.start_link()
    {:ok, keys} = Redix.command(rds, ["keys", "bubble*"])
    data = keys 
      |> Enum.map(fn key -> 
        [_x, y, _z] = String.split(key, ":")
        y
      end)

    json(conn, data)
  end

  def publish(conn, _params) do
    conn.query_params |> IO.inspect
    chan = conn.query_params["chan"] || "chan"
    data = conn.query_params["data"] || ""

    auth_user = conn.query_params["auth_user"]
    auth_token = conn.query_params["auth_token"]

    {:ok, rds} = Redix.start_link()
    {:ok, auth_user_secret} = Redix.command(rds, ["GET", "bubble:#{auth_user}:secret"])

    if !auth_user_secret do
      raise "auth key invalid"
    end

    signer = Joken.Signer.create("HS256", auth_user_secret)
    {:ok, claims} = Joken.verify(auth_token, signer)
    if claims["chan"] != chan do
      raise "unauthorized channel"
    end

    Redix.command(rds, ["PUBLISH", chan, data])
    json(conn, "ok")
  end

  def subscribe(conn, _params) do
    conn.query_params |> IO.inspect
    chan = conn.query_params["chan"] || "chan"

    auth_user = conn.query_params["auth_user"]
    auth_token = conn.query_params["auth_token"]

    {:ok, rds} = Redix.start_link()
    {:ok, auth_user_secret} = Redix.command(rds, ["GET", "bubble:#{auth_user}:secret"])

    if !auth_user_secret do
      IO.inspect auth_user_secret
      json(conn, %{"error" => "auth key invalid"})
    else
      signer = Joken.Signer.create("HS256", auth_user_secret)
      {:ok, claims} = Joken.verify(auth_token, signer)
      if claims["chan"] != chan do
        raise "unauthorized channel"
      end

      conn = put_resp_header(conn, "content-type", "text/event-stream")
      conn = send_chunked(conn, 200)

      {:ok, pubsub} = Redix.PubSub.start_link()
      {:ok, ref} = Redix.PubSub.subscribe(pubsub, chan, self())
      send_message(conn, chan, pubsub, ref)
      conn
    end
  end
  
  defp send_message(conn, chan, pubsub, ref) do
    receive do
      {:redix_pubsub, ^pubsub, ^ref, :message, %{channel: chan, payload: payload}} ->
        IO.puts("Received a message at channel #{chan} #{payload}")
        chunk(conn, "event: \"message\"\n\ndata: {\"message\": \"#{payload}\"}\n\n")
        send_message(conn, chan, pubsub, ref)
    end
  end
end
