Story.for "level_2" do 
  
  chatter :master, :master do |puzzle, count|
    case count
    when 1 then puzzle.chat(i18n("level2.insane")) 
    when 2 then puzzle.chat(i18n("level2.insane2"))
    else puzzle.chat_i18n("level1.justdoit")
    end
  end
  
  story_switch :electric1 do
    on do |puzzle|
      puzzle.chat_i18n("level2.no_lightning",:master)
    end
  end
  
  story_switch :switch do
    on do |puzzle|
      puzzle.set_cell_by_name(:door, Walkable.new)
      puzzle.chat_i18n("level2.open", :master)
    end
  end

  decorate_cell(:book1, :book1)
  
end
