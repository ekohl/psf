#!/usr/bin/env ruby

require 'socket'
require 'timeout'

SOCKET_DIR = '/run/psf'
ENC_TIMEOUT = 10
FACTS_TIMEOUT = 10
REPORT_TIMEOUT = 10


def enc(hostname)
  Timeout.timeout(ENC_TIMEOUT, nil, 'ENC retrieval expired') do
    UNIXSocket.open(File.join(SOCKET_DIR, 'enc')) do |socket|
      socket.puts(hostname)
      socket.close_write
      puts socket.read
    end
  end
end

def facts(path)
  data = File.read(path)
  Timeout.timeout(FACTS_TIMEOUT, nil, 'Fact upload expired') do
    UNIXSocket.open(File.join(SOCKET_DIR, 'facts')) do |socket|
      socket.puts(data)
      socket.close_write
      puts socket.readline
    end
  end
end

def report(path)
  data = File.read(path)
  Timeout.timeout(REPORT_TIMEOUT, nil, 'Report upload expired') do
    UNIXSocket.open(File.join(SOCKET_DIR, 'report')) do |socket|
      socket.puts(data)
      socket.close_write
      puts socket.readline
    end
  end
end

action = ARGV.shift
unless action
  STDERR.puts "Usage: #{$PROGRAM_NAME} [enc|facts|report] ARGUMENT"
  exit 1
end

case action
when 'enc'
  hostname = ARGV.shift
  if hostname
    enc(hostname)
  else
    STDERR.puts "Usage: #{$PROGRAM_NAME} #{action} HOSTNAME"
    exit 1
  end
when 'facts'
  path = ARGV.shift
  if path
    facts(path)
  else
    STDERR.puts "Usage: #{$PROGRAM_NAME} #{action} FACT_FILE.[json|yaml]"
    exit 1
  end
when 'report'
  path = ARGV.shift
  if path
    report(path)
  else
    STDERR.puts "Usage: #{$PROGRAM_NAME} #{action} REPORT.[json|yaml]"
    exit 1
  end
else
  STDERR.puts "Unknow action '#{action}'"
  exit 1
end
