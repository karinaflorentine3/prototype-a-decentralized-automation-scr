# x4l6_prototype_a_dec.rb

require 'socket'
require 'json'
require 'securerandom'

class DecentralizedAutomationScriptMonitor
  attr_reader :node_id, :script_monitor

  def initialize(node_id)
    @node_id = node_id
    @script_monitor = {}
  end

  def add_script(script_name, script_code)
    script_monitor[script_name] = { code: script_code, executions: 0 }
  end

  def execute_script(script_name, input_data)
    if script_monitor.key?(script_name)
      script_monitor[script_name][:executions] += 1
      # Execute the script with input_data
      # For demonstration purposes, simply print the script code and input data
      puts "Executing script #{script_name}: #{script_monitor[script_name][:code]}"
      puts "Input data: #{input_data}"
    else
      puts "Script #{script_name} not found"
    end
  end

  def broadcast_script_execution(node, script_name, input_data)
    # Create a UDP socket for broadcasting
    udp_socket = UDPSocket.new
    # Send a message to the node with the script execution request
    udp_socket.send("EXECUTE_SCRIPT #{script_name} #{input_data}", 0, node, 2000)
    udp_socket.close
  end

  def listen_for_script_executions
    # Create a UDP socket for listening
    udp_socket = UDPSocket.new
    udp_socket.bind('0.0.0.0', 2000)

    loop do
      message, sender_ip, sender_port = udp_socket.recvfrom(1024)
      if message.start_with?("EXECUTE_SCRIPT")
        script_name, input_data = message.split[1..2]
        execute_script(script_name, input_data)
      end
    end
  end
end

# Example usage
node_id = SecureRandom.uuid
monitor = DecentralizedAutomationScriptMonitor.new(node_id)

monitor.add_script('script1', 'puts "Hello, world!"')
monitor.add_script('script2', 'puts "Goodbye, world!"')

# Start listening for script execution requests
Thread.new { monitor.listen_for_script_executions }

# Broadcast a script execution request to another node
monitor.broadcast_script_execution('192.168.1.100', 'script1', 'Hello, world!')