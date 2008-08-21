module Naming
  def self.to_camel_case(name)
    tokens = name.split("_")
    tokens.collect do |token|
      token[0,1].upcase + token[1..-1]
    end.join("")
  end
end
