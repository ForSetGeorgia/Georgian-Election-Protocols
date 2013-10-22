#!/usr/bin/env ruby

# vpn switcher

require "net/http"
require "open-uri"

# client.conf files should be placed in /etc/openvpn/
paths = Dir.glob("/etc/openvpn/*.conf")
@vpns = paths.map { |a| a.split("/")[-1] }

def get_current_ip
  current_ip = `curl -s icanhazip.com`.strip
  puts "Current IP Address: #{current_ip}"
end

def acquire_vpn_server
  client = @vpns.sample
  puts "Acquiring VPN connection at #{client}"
  `nohup openvpn /etc/openvpn/#{client} > /dev/null 2>&1 &`
  #`openvpn /etc/openvpn/#{client} &`
  puts "Acquired VPN connection at #{client}"
  sleep(10)
end

def switch_vpn_server
  drop_vpn_server
  acquire_vpn_server
end

def drop_vpn_server
    process = `ps -e | grep openvpn`
    process_number = process.split(" ")[0]
  if process_number
    puts "VPN server connection found."
    puts "Dropping VPN connection ..."
    puts "Killing process #{process_number}"
    `kill #{process_number}`
    sleep(15)
  else
    puts "There is no current VPN connection."
  end
end

def remote_server_up?(server, port=80)
  http = Net::HTTP.start(server, port, {open_timeout: 5, read_timeout: 5})
  response = http.head("/")
  response.code == "200"
rescue Timeout::Error, SocketError
  false
end

def check_target_server(server)
  if remote_server_up?(server)
    puts "Server: #{server} is up and running."
  else
    puts "Server: #{server} is not responding."
    attempt = 1
    while attempt <= 5 do
      puts "Attempt #{attempt} to contact server: #{server}"
      response = remote_server_up?(server)
      if response == true
        puts "Server: #{server} is back online."
        break
      else
        "Attempt #{attempt.to_s} failed."
        attempt += 1
        sleep(5)
      end      
    end
  end
  if response == false
    puts "Switching VNP server" 
    switch_vpn_server
  end    
end


