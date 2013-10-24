#!/usr/bin/env ruby

# vpn switcher

require "net/http"
require "open-uri"
require 'net/smtp'

# client.conf files should be placed in /etc/openvpn/
paths = Dir.glob("/etc/openvpn/*.conf")
@vpns = paths.map { |a| a.split("/")[-1] }

def get_current_ip
  `curl -s icanhazip.com`.strip
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

def acquire_vpn_server
  @client = @vpns.sample
  puts "Acquiring VPN connection at #{@client}"
  `nohup openvpn /etc/openvpn/#{@client} > /dev/null 2>&1 &`
  #`openvpn /etc/openvpn/#{@client} &`
  puts "Acquired VPN connection at #{@client}"
  sleep(10)
end

def remote_server_up?(server, port=80)
  uri = URI(server)
  begin
    res = Net::HTTP.get_response(uri)
    true if res.code.to_s == '200'
  rescue
    false
  end
end

def send_email
  ip = get_current_ip
  smtp = Net::SMTP.new 'smtp.gmail.com', 587
  smtp.enable_starttls
  
  message = <<MESSAGE_END
From: Scraper Server <info@jumpstart.ge>
To: Eric Barrett <eric@jumpstart.ge>, Jason Addie <jason.addie@jumpstart.ge>
Subject: Scraper server IP: #{ip} Client: #{@client}
This is a message to alert you to the fact that the protocol scraper switched to a new server.

===

Current IP: #{ip}
Current client: #{@client}

===
MESSAGE_END

  user = ENV['GMAIL_USER']
  pwd = ENV['GMAIL_PWD']
  domain = ENV['GMAIL_DOMAIN']
  from = ENV['GMAIL_FROM']
  to = ENV['GMAIL_TO'].split(',') # separated by commas
  

  smtp.start(domain, user, pwd, :login) do
    puts "Sending email alert ..."
    smtp.send_message(message, from, to)
    puts "Sent email alert."
  end
end

def switch_vpn_server
  drop_vpn_server
  acquire_vpn_server
  send_email
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
      else
        puts "Attempt #{attempt.to_s} failed."
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
