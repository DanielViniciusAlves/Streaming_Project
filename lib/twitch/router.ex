defmodule Twitch.Router do
  use Plug.Router

  plug Corsica, max_age: 600, origins: "*", expose_headers: ~w(X-Foo)
  plug :match
  plug :dispatch

  get "/" do
    send_resp(conn, 200, "Welcome")
  end

  get "/test" do
    Plug.Conn.send_file(conn, 200, "output/index.m3u8")
  end

  get "/:username/:filename" do
    IO.puts "File reached"
    filename = conn.params["filename"]
    username = conn.params["username"]
    file_path = "output/#{filename}"

    # Get user stream uid in the database
    
    if File.exists?(file_path) do
      Plug.Conn.send_file(conn, 200, file_path)
    else
      send_resp(conn, 404, "File not found")
    end
  end

  match _ do
    send_resp(conn, 404, "Oops!")
  end  
end
