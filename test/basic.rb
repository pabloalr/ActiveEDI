$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'active_edi'
require 'test/unit'
require 'date'

class Teste < ActiveEDI::Base
  def self.schema
    {
      :tipo  => {:pos => 1, :size => 2, :type => :numeric},
      :indic => {:pos => 2, :size => 1, :type => :string},
      :datem => {:pos => 3, :size => 8, :type => :date},
      :totno => {:pos => 4, :size => 11, :type => :numeric, :decimal => 2},
      :totii => {:pos => 4, :size => 11, :type => :numeric, :decimal => 2},
      :totan => {:pos => 4, :size => 11, :type => :numeric, :decimal => 2},
      :totbb => {:pos => 4, :size => 11, :type => :numeric, :decimal => 2},
      :totxx => {:pos => 4, :size => 11, :type => :numeric, :decimal => 2}
    }
  end
end

class ActiveBasicTest < Test::Unit::TestCase

  def setup
    @t = Teste.new
    @t.tipo = 10
    @t.indic = "E"
    @t.datem = Date.today
    @t.totno = 9999.99
    @t.totii = 10
    @t.totan = 30.01
    @t.totbb = 31.0
    @t.totxx = 12345678901.12 
    @line = "10E#{Date.today.strftime("%d%m%Y")}00000009999990000000001000000000000300100000000031001234567890112" 
  end

  def test_return_objects
    assert_return_string
    assert_return_date
    assert_return_numeric
  end

  def test_parser
    @x = Teste.parse(@line)
    assert_instance_of Teste, @x
    assert_equal @t.tipo, 10
    assert_equal @t.indic, "E"
    assert_equal @t.datem, Date.today
    assert_equal @t.totno, 9999.99
    assert_equal @t.totii, 10
    assert_equal @t.totan, 30.01
    assert_equal @t.totbb, 31.0
    assert_equal @t.totxx, 12345678901.12 
  end

  def assert_return_string
    assert_instance_of String, @t.indic
    assert_equal "E", @t.indic
  end

  def assert_return_date
    assert_instance_of Date, @t.datem
    assert_equal Date.today, @t.datem
  end

  def assert_return_numeric
    assert_instance_of Fixnum, @t.tipo
    assert_equal 10, @t.tipo
    assert_instance_of Float, @t.totno
    assert_equal 9999.99, @t.totno
    assert_instance_of Float, @t.totii
    assert_equal 10.0, @t.totii
    assert_instance_of Float, @t.totan
    assert_equal 30.01, @t.totan
    assert_instance_of Float, @t.totbb
    assert_equal 31.0, @t.totbb
    assert_instance_of Float, @t.totxx
    assert_equal 12345678901.12, @t.totxx
  end

end
