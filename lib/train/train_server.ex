defmodule TrainServer do
  @moduledoc """
  Handles control of the train.

  Initialization of the
  """
  use GenServer

  @train_slowest 70
  @train_fastest 150

  @doc """
  Starts the GenServer. This of course calls init with the :ok parameter.
  """
  def start_link do
    {:ok, _} = GenServer.start_link(__MODULE__, :ok, [name: TrainServer])
  end

  @doc """
  """
  def init (:ok) do
    initialize_ports()
    {:ok, %{speed: 0, pwm_speed: 0}}
  end

  # --------- Client APIs

  # Speed will be 0 - 9.
  def set_speed speed do
    pwm_speed = speed_to_pwm_speed speed
    GenServer.call TrainServer, {:set_speed, speed, pwm_speed}
    IO.puts "Setting Speed to: #{pwm_speed}%"
  end

  def get_speed do
    GenServer.call TrainServer, :get_speed
  end

  def faster do
    GenServer.call TrainServer, :faster
  end

  def slower do
    GenServer.call TrainServer, :slower
  end

  # ---------- GenServer Callbacks

  def handle_call({:set_speed, speed, pwm_speed}, _from, state) do
    cmd "gpio", ["pwm", "1", "#{pwm_speed}"], :os.type
    {:reply, :ok, %{ state | speed: speed, pwm_speed: pwm_speed}}
  end

  def handle_call(:faster, _from, state) do
    speed = if state.speed >= 9 do 9 else state.speed + 1 end
    pwm_speed = speed_to_pwm_speed speed
    cmd "gpio", ["pwm", "1", "#{pwm_speed}"], :os.type
    {:reply, :ok, %{ state | speed: speed, pwm_speed: pwm_speed}}
  end

  def handle_call(:slower, _from, state) do
    speed = if state.speed <= 0 do 0 else state.speed - 1 end
    pwm_speed = speed_to_pwm_speed speed
    cmd "gpio", ["pwm", "1", "#{pwm_speed}"], :os.type
    {:reply, :ok, %{ state | speed: speed, pwm_speed: pwm_speed}}
  end

  def handle_call(:get_speed, _from, state) do
    {:reply, {state.speed, state.pwm_speed}, state}
  end

  # Sets up the GPIO port for hardware PWM control.
  @port_init_commands [
    "gpio mode 1 pwm",
    "gpio pwm-ms",
    "gpio pwmr 256",
    "gpio pwmc 4",
    "gpio pwm 1 0"
  ]

  def initialize_ports do
    @port_init_commands
    |> Enum.map(&String.split/1)
    |> Enum.map(fn [c | p] -> cmd(c,p,:os.type) end)
  end

  def cmd c,p,{:unix,:linux} do
    try do
      a = System.cmd c, p
    rescue
      ErlangError -> IO.puts "Error!"
    end
#    IO.puts "Executing: #{c}, #{IO.inspect p}"
  end

  def cmd c,_,_ do
    IO.puts "Skipping System Command: #{c}"
  end

  def speed_to_pwm_speed speed do
    slope = (@train_fastest - @train_slowest) / (9.0-1.0)
    intercept = @train_fastest - slope * 9.0
    pwm_speed = slope * speed + intercept
    pwm_speed = trunc pwm_speed
    pwm_speed = if speed == 0 do 0 else pwm_speed end
    pwm_speed
  end

end
