#!/usr/bin/ruby
# Based on: https://gist.github.com/chmanie/4f2838f4548d25b9c883f7d6d074f67c

# Midi in/out filters
# -------------------
# Add regular expression patterns to avoid connect a midi in/out for a
# specific device. For example, to disable midi out for a Korg NTS-1,
# add /NTS-1/ to the $noMidiOutDevices list.
$noMidiOutDevices = []
$noMidiInDevices = []

def matchList(list, s)
  list.each do |pattern|
    match = pattern.match(s)
    unless match.nil?
      return true
    end
  end
  return false
end

# Unconnect everything
system "aconnect -x"

t = `aconnect -i -l`
$devices = {}
$names = {}
$device = 0
t.lines.each do |l|
  match = /client (\d*)\:(?:\s'(.*?)'\s.*?)?/.match(l)
  name = ""
  # We skip empty lines and the "Through" port
  unless match.nil? || match[1] == '0' || /Through/=~l
    $device = match[1]
    $devices[$device] = []
    $names[$device] = match[2]
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
        # Probably not a good idea to connect a port to itself
        isSame = (device1 == device2 && port1 == port2)
        noOut = matchList($noMidiOutDevices, $names[device1])
        noIn = matchList($noMidiInDevices, $names[device2])
        unless isSame || noOut || noIn
          system "aconnect #{device1}:#{port1} #{device2}:#{port2}"
        end
      end
    end
  end
end
