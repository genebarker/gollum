# gollumrack.rb
#!/usr/bin/env ruby
#
# Custom rack for the Gollum wiki engine
# - uses custom base_path
# - has scaffolding to set gollum_author

__DIR__ = File.expand_path(File.dirname(__FILE__))
$: << __DIR__
require 'rubygems'
require 'gollum/app'

gollum_path = File.expand_path(File.dirname(__FILE__))
options = {
    'port' => 4567,
    'bind' => '0.0.0.0',
}
wiki_options = {
    :live_preview => false,
    :allow_editing => true,
    :allow_uploads => true,
    :universal_toc => false,
    :base_path => 'wiki',
}

Precious::App.set(:gollum_path, gollum_path)
Precious::App.set(:default_markup, :markdown)
Precious::App.set(:wiki_options, wiki_options)
#run Precious::App
base_path = wiki_options[:base_path]

require 'rack'

class MapGollum
    def initialize base_path
        @mg = Rack::Builder.new do
            map '/' do
                run Proc.new { [302, { 'Location' => "/#{base_path}" }, []] }
            end

            map "/#{base_path}" do
                run Precious::App
            end
        end
    end

    def call(env)
        request = Rack::Request.new(env)
        # insert your logic to set gollum_author here
        #gollum_author = {
        #        :name => 'Unknown author',
        #        :email => 'unknown@example.com'
        #    }
        #env['rack.session'] = { 'gollum.author' => gollum_author }
        @mg.call(env)
    end
end
# Rack::Handler does not work with Ctrl + C. Use Rack::Server instead.
Rack::Server.new(:app => MapGollum.new(base_path), :Port => options['port'], :Host => options['bind']).start
