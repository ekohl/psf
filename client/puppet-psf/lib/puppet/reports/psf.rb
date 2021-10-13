# frozen_string_literal: true

require 'socket'

Puppet::Reports.register_report(:psf) do
  desc 'Sends reports to PSF (puppetserver-foreman)'

  def process
    socket_path = '/run/psf/report'
    timeout = 90

    Puppet.info "Submitting report to PSF at #{socket_path}"
    Timeout.timeout(timeout, nil, 'Uploading report to PSF expired') do
      UNIXSocket.open(socket_path) do |socket|
        socket.send self.to_json, 0
        socket.close_write
        response = socket.readline
        Puppet.info "PSF report upload: #{response}"
      end
    end
  rescue StandardError => e
    Puppet.err "Could not send report to PSF: #{e}\n#{e.backtrace}"
  end
end
