defmodule TrainWeb.PageController do
  use TrainWeb, :controller

  def index(conn, _params) do
    {speed, _s} = TrainServer.get_speed
    conn = assign(conn, :speed, speed)
    render conn, "index.html"
  end

  def command(conn, _params) do
    %{"speed" => speed} = conn.params
    {intspeed,""} = Integer.parse speed
    TrainServer.set_speed intspeed
    index conn, []
  end

  def faster(conn, _params) do
    TrainServer.faster
    index conn, []
  end

  def slower(conn, _params) do
    TrainServer.slower
    index conn, []
  end
end
