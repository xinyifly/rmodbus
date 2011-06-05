# RModBus - free implementation of ModBus protocol on Ruby.
#
# Copyright (C) 2008-2011  Timin Aleksey
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
require 'socket'
require 'timeout'

module ModBus
  # Implementation clients(master) ModBusTCP
  class TCPClient < Client
    include Timeout
    attr_reader :ipaddr, :port
    
    # Connect with ModBus server
    #
    # ipaddr - ip of the server
    #
    # port - port TCP connections
    #
    def self.connect(ipaddr, port = 502)
      cl = TCPClient.new(ipaddr, port) 
      yield cl
      cl.close
    end

    # Connect with a ModBus server
    #
    # ipaddr - ip of the server
    #
    # port - port TCP connections
    def initialize(ipaddr, port = 502)
      @transaction = 0
      @ipaddr, @port = ipaddr, port
      tried = 0
      begin
        timeout(1, ModBusTimeout) do
          @sock = TCPSocket.new(@ipaddr, @port)
        end
      rescue ModBusTimeout => err
        raise ModBusTimeout.new, 'Timed out attempting to create connection'
      end
      super()
    end

    def with_slave(uid)
      TCPSlave.new(uid, @sock)
    end

    # Close TCP connections
    def close
      @sock.close unless @sock.closed?
    end

    # Check TCP connections
    def closed?
      @sock.closed?
    end
  end
end
