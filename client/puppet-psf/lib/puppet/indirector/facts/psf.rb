# frozen_string_literal: true

require 'socket'
require 'puppet/indirector/json'

class Puppet::Node::Facts::Psf < Puppet::Indirector::JSON
  SOCKET_PATH = '/run/psf/facts'
  TIMEOUT = 90

  desc "Save facts to PSF (puppetserver-foreman) which forwards it to the right destination."

  def save(request)
    Puppet.info "Submitting facts to PSF at #{SOCKET_PATH}"
    Timeout.timeout(TIMEOUT, nil, 'Uploading facts to PSF expired') do
      UNIXSocket.open(SOCKET_PATH) do |socket|
        socket.send to_json(request.instance), 0
        socket.close_write
        response = socket.readline
        Puppet.info "PSF fact upload: #{response}"
      end
    end
  rescue StandardError => e
    Puppet.err "Could not send facts to PSF: #{e}\n#{e.backtrace}"
  end
end
