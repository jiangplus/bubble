defmodule BubbleWeb.PageController do
  use BubbleWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
