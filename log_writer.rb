file_path = '/home/lalitmali/Desktop/rails7/SocketPro/log_with_socket/logfile.log'

loop do
    File.open(file_path, 'a') do |file|
      file.puts("New log entry at #{Time.now}")
    end
    sleep 1
end