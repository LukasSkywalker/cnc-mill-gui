require 'serialport'

def run_program(code)
  SerialPort.open('/dev/ttyUSB0', 115200, 8, 1, SerialPort::NONE) do |sp|
    sp.write("\r\n\r\n")
    sleep(2)
    sp.flush_input

    code.each do |line|
      puts "> #{line}\n"
      sp.write("#{line}\n")

      output = nil
      while try_again?(output)
        sleep(1)
        output = sp.gets
        puts output if output && output.start_with?("<")
        sp.write("?")
      end
      puts "< #{output}"
    end
  end
end

private

def try_again?(output)
  output.nil? || output.start_with?("<")
end