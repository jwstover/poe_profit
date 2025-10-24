defmodule PoeProfitWeb.PageController do
  use PoeProfitWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
