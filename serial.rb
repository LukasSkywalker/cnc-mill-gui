require 'serialport'

def run_program(code)
  SerialPort.open('/dev/ttyUSB1', 115200, 8, 1, SerialPort::NONE) do |sp|
    sp.write("\r\n\r\n")
    sleep(2)

    code.each do |line|
      puts "> #{line}\n"
      sp.write("#{line}\n")

      output = (sp.gets || '<none>').chomp
      puts "< #{output}"
    end
  end
end
