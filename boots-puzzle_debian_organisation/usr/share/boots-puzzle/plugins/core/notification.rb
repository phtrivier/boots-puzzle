module Notification

  attr_reader :listeners

  def add_listener(listener)
   @listeners << listener
  end

  def add_listeners(ls)
   if (ls != nil)
     ls.each do |l|
        @listeners << l
      end
    end
  end

  def fire!(event, options = {})
    @listeners.each do |listener|
      msg = "handle_#{event}".to_sym
      if (listener.respond_to?(msg))
        listener.send(msg, options)
      end
    end
  end

  def self.event_sender_shortcut(name)
    self.instance_eval do
      define_method name do |txt|
        fire!(name, { :msg => txt})
      end
    end
  end

  event_sender_shortcut :message
  event_sender_shortcut :info
  event_sender_shortcut :error

end
