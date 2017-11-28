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
    {:ok, %{speed: 0}}
  end

  # --------- Client APIs

  # Speed will be 0 - 9.
  def set_speed speed do
    slope = (@train_fastest - @train_slowest) / (9.0-1.0)
    intercept = @train_fastest - slope * 9.0
    pwm_speed = slope * speed + intercept
    pwm_speed = trunc pwm_speed
    pwm_speed = if speed == 0 do 0 else pwm_speed end
    GenServer.call TrainServer, {:set_speed, pwm_speed}
    IO.puts "Setting Speed to: #{pwm_speed}%"
  end

  def get_speed do
    GenServer.call TrainServer, :get_speed
  end

  # ---------- GenServer Callbacks

  def handle_call({:set_speed, speed}, _from, state) do
    System.cmd "gpio", ["pwm", "1", "#{speed}"]
    {:reply, :ok, %{ state | speed: speed}}
  end

  def handle_call(:get_speed, _from, state) do
    {:reply, state.speed, state}
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
    |> Enum.map(fn [c | p] -> cmd(c,p) end)
  end

  def cmd c,p do
    System.cmd c, p
#    IO.puts "Executing: #{c}, #{IO.inspect p}"
  end

end
