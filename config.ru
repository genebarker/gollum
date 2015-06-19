#!/usr/bin/env ruby
#--------------------------------------------------------------------
# - example custom rack for the Gollum wiki engine
# - file should be placed in wiki root
# - environment var $RACK_APP should be set to the filename 
# - entrypoint.sh script will run this app using:
#   $ rackup $RACK_APP -p 4567
#--------------------------------------------------------------------
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
}

Precious::App.set(:gollum_path, gollum_path)
Precious::App.set(:default_markup, :markdown)
Precious::App.set(:wiki_options, wiki_options)
run Precious::App

# set author
class Precious::App
    before do
        session['gollum.author'] = {
            :name => "John Doe",
            :email => "jdoe@example.com",
        }
    end
end
