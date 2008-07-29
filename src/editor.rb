class EditorCell
  attribute_accessor :type
  attribute_accessor :image
end

Shoes.app :title => "Puzzle editor" do

#   @w = ask "Puzzle\'s Width ?"

#   @w = @w.to_i

#   if (@w <= 0)
#     alert "Bad width !"
#     Kernel.exit(-1)
#     exit
#   end

#   @h = ask "Puzzle\'s Height ?"

#   @h = @h.to_i
#   if (@h <= 0)
#     alert "Bad Height !"
#     Kernel.exit(-1)
#     exit
#   end

  # FIXME : use unhardwired values
  @w = 10;
  @h = 7;

  @cells = []
  @h.times do
    @cells << []
  end

  flow do
    stack :width => '20%' do
      border black, :strokewidth => 1
      para "list of available tools"
      para "list of selected tools"
    end

    stack :width => '60%' do
      border black, :strokewidth => 1
      para "grid of selectable cells"
    end

    stack :width => '20%' do
      border black, :strokewidth => 1
      para "list of special cells (with positions)"
    end
  end
end
