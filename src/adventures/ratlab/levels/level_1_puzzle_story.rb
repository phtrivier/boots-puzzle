Story.for "level_1" do

  chatter :master, :master do |puzzle, count|
    if (count == 1)
      puzzle.chat(i18n("level1.hi"))
    else
      puzzle.chat(i18n("level1.justdoit"))
    end
  end

  decorate_cell(:book1, :book1)
  decorate_cell(:book2, :book2)
  decorate_cell(:scroll1, :scroll1)
  decorate_cell(:mirror, :mirror)

  tunnel(:tunnel_left, :tunnel_right)
  
  story_event :tunnel_left do |puzzle,called,count|
    if (count == 0)
      chat( i18n("level1.eureka"), :master)
    else
      chat( i18n("level1.okthisworks"), :master)
    end
  end

  story_event :tunnel_out do |puzzle|
    chat(i18n("level1.getout"), :master)
  end

end
