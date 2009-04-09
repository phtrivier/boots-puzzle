class Chat

  @@chatters = {}

  def self.clear_chatters
    @@chatters = {}
  end

  def self.find_chatter(chatter_name)
    @@chatters[chatter_name]
  end

  def self.chatter chatter_name, params
    @@chatters[chatter_name] = params
  end

end
