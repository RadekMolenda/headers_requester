require './request_headers'
require 'faye'

use Faye::RackAdapter,    :mount => '/faye',
                          :timeout => 25

use Rack::CommonLogger
use Rack::Static, :urls => ["/public"]
run RequestHeaders
