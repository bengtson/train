defmodule Train.Status do
  @moduledoc """
  Provides the functionality needed to send status packets to the Tack Status
  Server. Status and useful metrics are sent periodically.
  Things to fix:
    - Host and Port are not used from the configuration file.
  """
  use GenServer

  defmodule Status do
    defstruct [ :name, :icon, :status, :state, :link, :hover, :metrics, :text ]
  end

  defmodule Metric do
    defstruct [ :name, :value ]
  end

  # --------- GenServer Startup Functions

  @doc """
  Starts the GenServer. This of course calls init with the :ok parameter.
  """
  def start_link do
    {:ok, _} = GenServer.start_link(__MODULE__, :ok, [name: StatusServer])
  end

  @doc """
  Read the rain data file and generate the list of rain gauge tips. This
  is held in the state as tips. tip_inches is amount of rain for each tip.
  """
  def init (:ok) do
    [host: host, port: port, start: _start] = Application.fetch_env!(:train, :status_server)
    start()
    {:ok, %{}}
  end

  def start do
    spawn(__MODULE__,:update_tick,[])
  end

  def request_update do
    IO.inspect {:setting_update_flag}
    GenServer.call StatusServer, :set_update_flag
  end

  def update_status do
    GenServer.call StatusServer, :update_status
  end

  def handle_call(:update_status, _from, state) do
#    IO.inspect {:checking_status}
    status = generate_status()
    send_packet status
    {:reply, :ok, state}
  end

  #------------ Tack Status
  def update_tick do
    Process.sleep(10000)
    update_status()
    update_tick()
  end

  def generate_status do

#    IO.inspect {:generating_status}

    {speed, pwm_speed} = TrainServer.get_speed

    metrics =
      [
        %Metric{name: "Speed", value: "#{speed} (#{pwm_speed})"},
      ]

    {{_year,month,day},{_hour,_min,_sec}} = :calendar.local_time()
    icon_filename =
      cond do
        (month >= 11 && day > 15) || month == 12 ->
          "christmas-engine-2.jpg"
        true ->
          "trolley-1.png"
      end

    status =
      cond do
        speed == 0 ->
          "Lake Sara Station"
        speed == 1 ->
          "All Aboard!"
        true ->
          "Enroute"
      end

    stat = %Status{
      name: "Train",
      icon: get_icon("assets/static/images/" <> icon_filename),
      status: status,
      metrics: metrics,
      state: :nominal,
      link: "http://10.0.1.211:4408"
    }

    stat
  end

  defp send_packet stat do
#    IO.inspect {:sending_packet}
    with  {:ok, packet} <- Poison.encode(stat),
          {:ok, socket} <- :gen_tcp.connect('10.0.1.202', 21200,
                           [:binary, active: false])
    do
            :gen_tcp.send(socket, packet)
            :gen_tcp.close(socket)
            :ok
    else
      _ ->  :ok
    end
  end

  defp get_icon path do
    {:ok, icon} = File.read path
    icon = Base.encode64 icon
    icon
  end

end
