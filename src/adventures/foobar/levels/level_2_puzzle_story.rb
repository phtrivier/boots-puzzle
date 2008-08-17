module Level2PuzzleStory
  def init_story
    story_event :middle, Walkable do |pu|
      puts "Hello everyone !!"
    end
  end
end
