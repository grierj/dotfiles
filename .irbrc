require 'rubygems'
require 'irb/ext/save-history'
IRB.conf[:SAVE_HISTORY] = 10000
IRB.conf[:HISTORY_FILE] = File.expand_path('~/.irb-history')
require 'irb/completion'
require 'pp'
