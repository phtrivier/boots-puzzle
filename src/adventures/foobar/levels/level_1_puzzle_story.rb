Story.for("level_1_puzzle") do
  tunnel(:tunnel_top, :tunnel_bottom)

  story_event :middle do |puzzle|
    puts "some cell that does not get moved !"
  end

end
