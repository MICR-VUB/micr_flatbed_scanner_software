defmodule ScanService.Router do
  use Plug.Router

  plug :match
  plug Plug.Parsers, parsers: [:json], json_decoder: Jason
  plug :dispatch

  post "/scan" do
    params = conn.body_params
    udev_name = Map.get(params, "device")
    output_path = Map.get(params, "output")

    with {:ok, bus, dev} <- resolve_bus_and_device(udev_name),
         false <- is_nil(output_path) do

      # Defaults for optional scan parameters
      res  = Map.get(params, "resolution", 300)
      mode = Map.get(params, "mode", "Color")
      t    = Map.get(params, "t", 0)
      l    = Map.get(params, "l", 0)
      x    = Map.get(params, "x", 210)
      y    = Map.get(params, "y", 297)

      output_dir = Path.dirname(output_path)
      output_name = Path.basename(output_path)

      scan_cmd = """
      scanimage --resolution #{res} --mode #{mode} -t #{t} -l #{l} -x #{x} -y #{y} > /scans/#{output_name}
      """

      docker_args = [
        "run", "--rm",
        "--device=/dev/bus/usb/#{bus}/#{dev}",
        "-v", "#{output_dir}:/scans",
        "arch-epsonscan2",
        "bash", "-c", scan_cmd
      ]

      IO.puts("Running: docker #{Enum.join(docker_args, " ")}")

      {output, status} = System.cmd("docker", docker_args, stderr_to_stdout: true)

      if status == 0 do
        send_resp(conn, 200, Jason.encode!(%{status: "ok", output: output_path}))
      else
        send_resp(conn, 500, Jason.encode!(%{status: "error", message: output}))
      end
    else
      {:error, msg} ->
        send_resp(conn, 400, Jason.encode!(%{error: msg}))

      true ->
        send_resp(conn, 400, Jason.encode!(%{error: "Missing required parameter: 'output'"}))
    end
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end

  def resolve_bus_and_device(udev_name) do
    device_path = "/dev/#{udev_name}"

    case File.read_link(device_path) do
      {:ok, real_path} ->
        full_path =
          if String.starts_with?(real_path, "/") do
            real_path
          else
            Path.expand(real_path, Path.dirname(device_path))
          end

        case Regex.run(~r|/bus/usb/(\d{3})/(\d{3})$|, full_path) do
          [_, bus, dev] -> {:ok, bus, dev}
          _ -> {:error, "Could not extract bus/device from path: #{full_path}"}
        end

      {:error, reason} ->
        {:error, "Could not resolve device: #{reason}"}
    end
  end
end
