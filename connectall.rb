#!/usr/bin/ruby
# Source: https://gist.github.com/chmanie/4f2838f4548d25b9c883f7d6d074f67c

# Midi out filter
$noMidiOutDevices = [/NTS-1/]
$noMidiInDevices = []

def matchList(list, device)
  $list.each do |pattern|
    match = pattern.match(device)
    unless match.nil?
      return true
    end
  end
  return false
end

t = `aconnect -i -l`
$devices = {}
$device = 0
t.lines.each do |l|
  match = /client (\d*)\:((?:(?!client).)*)?/.match(l)
  # we skip empty lines and the "Through" port
  unless match.nil? || match[1] == '0' || /Through/=~l
    $device = match[1]
    $devices[$device] = []
  end
  match = /^\s+(\d+)\s/.match(l)
  if !match.nil? && !$devices[$device].nil?
    $devices[$device] << match[1]
  end
end

$devices.each do |device1, ports1|
  ports1.each do |port1|
    $devices.each do |device2, ports2|
      ports2.each do |port2|
        # probably not a good idea to connect a port to itself
        isSame = (device1 == device2 && port1 == port2)
        noOut = matchList($noMidiOutDevices, device1)
        noIn = matchList($noMidiInDevices, device2)
        unless isSame || noOut || noIn
          system "aconnect #{device1}:#{port1} #{device2}:#{port2}"
        end
      end
    end
  end
end
