require 'rubygems'
require 'net/http'
require 'uri'
require 'wait_for'

HERE = File.expand_path('..', __FILE__)

namespace :stub do
  desc 'Start/Restart stub server on http://localhost:3000'
  task :start => :stop do
    puts 'Starting the stub server...'
    system('thin start -l build/stubServer.log -R config.ru -d')
  end

  task :restart do
    exec('thin restart -R config.ru -d')
  end

  desc 'Stop stub server on http://localhost:3000'
  task :stop do
    begin
      puts 'Stopping the stub service...'
      verbose(false) do
        system('thin stop -q > /dev/null')
      end
    rescue
      puts 'Stub service was not running'
    end
  end
end