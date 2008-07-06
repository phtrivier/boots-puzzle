class BadCellCharError < RuntimeError
  attr_accessor :char
  def initialize(c)
    @char = c
  end
end

class BadDimension < RuntimeError
end

class NoEntry < RuntimeError
end

