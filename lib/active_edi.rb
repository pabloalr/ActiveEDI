$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'iconv'
require 'active_edi/base.rb'
require 'active_edi/attributes.rb'

ActiveEDI::Base.class_eval do
  include ActiveEDI::Attributes
end
