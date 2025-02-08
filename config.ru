# config.ru
require 'truemail'
# This assumes Truemail provides a server class (commonly Truemail::Server)
run Truemail::Server
