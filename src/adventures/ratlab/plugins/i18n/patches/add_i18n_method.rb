class Puzzle

  def chat_i18n(key, chatter_name=nil, args=[])
    chat(i18n(key,args),chatter_name)
  end

  def i18n(key, args=[])

    ensure_translations_loaded!

    if (Translations.has_key?(key))
      translate(key,args)
    else
      "Missing translation for #{key}"
    end
  end

  def ensure_translations_loaded!
    if (!Puzzle.const_defined?("Translations"))
      require "add_translations"
    end
  end

  def translate(key, args)
    base_translation = Translations[key]
    args.each_with_index do |arg, index|
      base_translation.gsub!("{"+i+"}", arg)
    end
    return base_translation
  end
  
end
