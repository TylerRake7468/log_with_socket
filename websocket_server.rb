require 'faye/websocket'
require 'eventmachine'
require 'em-websocket'


class ServerApp
    def initialize(path)
      @path = path
      @clients = []
      @last_position = 0
      @file = File.open(@path, 'r')
      @file.seek(0, IO::SEEK_END)
    end

    def start
        EM.run do
            EM::WebSocket.run(host: '0.0.0.0', port: '8080') do |ws|
                ws.onopen do |handshake|
                    @clients << ws
                    puts "Connected to Client...!"
                    send_last_ten_lines(ws)
                end

                ws.onmessage do |event|
                end

                ws.onclose do
                    puts "Disconnected to Client : #{ws}"
                    @clients.delete(ws)
                end
            end
            EM.add_periodic_timer(1){ check_for_updates }
        end
    end

    def send_last_ten_lines(ws)
        lines = File.readlines(@path).last(10).join
        ws.send lines
    end

    def check_for_updates
        begin
            new_data = @file.read
            return if new_data.empty?

            @clients.each{|client| client.send new_data }
        rescue StandardError => e
            puts "Unable to load file , error : #{e.message}"
        end
    end
end

sp = ServerApp.new('/home/lalitmali/Desktop/rails7/SocketPro/log_with_socket/logfile.log')
sp.start