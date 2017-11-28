defmodule PiPhone do
  @moduledoc """
  A simple server to capture all PiPhone messages. Users can register for
  messages.

  PiPhone is an old dial telephone (Mary Lou's) that broadcasts UPD messages.

  Here are the types of messages that are emitted from the phone:

    "piphone://piphone?piid=80:1f:02:ee:86:9b&piip=null&event=dialing"
    "piphone://piphone?piid=80:1f:02:ee:86:9b&piip=null&event=dialed&digit=6"
    "piphone://piphone?piid=80:1f:02:ee:86:9b&piip=10.0.1.213&event=offhook
    "piphone://piphone?piid=80:1f:02:ee:86:9b&piip=10.0.1.213&event=onhook"
  """
  use GenServer
  require Logger

# --------- GenServer Startup Functions

  @doc """
  Starts the GenServer.
  """
  def start_link do
    IO.inspect {:starting}
    {:ok, _} = GenServer.start_link(__MODULE__, :ok, [name: PiPhoneService, timeout: 20000])
  end

  @doc """
  Read the rain data file and generate the list of rain gauge tips. This
  is held in the state as tips. tip_inches is amount of rain for each tip.
  """
  def init (:ok) do
    port = Application.fetch_env!(:train, :piphone)[:port]
    tcp_start port

    {:ok, %{ mstate: :idle, time: nil, speed: nil}}
  end

  # --------- Client APIs

  def handle_packet packet do
    event = parse_packet packet
    GenServer.call PiPhoneService, {:handle_packet, event}
  end

  # --------- GenServer Callbacks

  def handle_call({:handle_packet, event}, _from, state) do
#    IO.inspect {:handle_packet, event}
    { mstate, time, speed } =
      piphone_state state.mstate, state.time, state.speed, event
    {:reply, :ok, %{ state | mstate: mstate, time: time, speed: speed }}
  end

  # --------- Pi Phone State Machine

  defp piphone_state :idle, _, speed, ["dialed", "2"] do
    time = System.monotonic_time(:millisecond)
    {:speed, time, speed}
  end

  defp piphone_state :speed, time, _, ["dialed", number] do
    elapsed = System.monotonic_time(:millisecond) - time
    cond do
      elapsed > 5000 ->
        {:idle, nil, nil}
      true ->
        {num,""} = Integer.parse number
        speed = num
        TrainServer.set_speed speed
        {:idle, nil, nil}
    end
  end

  # If waiting for speed number dialed, skip the dailing state.
  defp piphone_state :speed, time, speed, ["dialing"] do
    {:speed, time, speed}
  end

  defp piphone_state _, _, speed, _ do
    {:idle, nil, speed}
  end

# --------- Private Support Functions

  # ---------- TCP server

  defp tcp_start port do
    socket = start_controller_messaging(port)
    spawn(PiPhone, :message_accept, [socket])
  end

  def start_controller_messaging port do
    {:ok, socket} = :gen_udp.open(port,
                    [:binary, active: false, reuseaddr: true])
    socket
  end

  def message_accept socket do
#    IO.inspect {:accept}
    read_packet_data socket
    message_accept socket
  end

  # Added this since Elixir was first receiving just the opening
  # `{` from the controller. This code reads until the controller
  # closes the channel.
  defp read_packet_data socket do
    resp = :gen_udp.recv(socket, 0, 10000)
#    IO.inspect {:resp, resp}
    case resp do
      {:ok, {_host, _port, data}} ->
        handle_packet data
      _ ->
        resp
    end
  end

  def parse_packet packet do
#    IO.inspect {:p, packet}
    packet
    |> URI.decode
    |> URI.parse
    |> Map.fetch!(:query)
    |> URI.query_decoder
    |> Enum.to_list
    |> Enum.filter(fn {a,_} -> (a == "digit") or (a == "event") end)
    |> Enum.map(fn {_,b} -> b end)
  end

end
