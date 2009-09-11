class BaseDecorationCell < StaticCell
  
  attr_writer :background_cell

  def self.from_symbols(symbols)
    res = {}
    symbols.each do |s|
      res[s] = "decoration/img/#{s}.png"
    end
    res
  end

  Sources = from_symbols([:book1, :book2, 
                         :scroll1, 
                         :chest1, :chest2, 
                         :mirror])

  # Sources = { :book1 => "decoration/img/book1.png" ,
  #   :book2 => "decoration/img/book2.png",
  #   :scroll1 => "decoration/img/scroll1.png"
  #   :chest1 => "decoration/img/chest1.png",
  #   :chest2 => "decoration/img/chest2.png",
  #   :mirror => "decoration/img/mirror.png",
  # }

  def initialize(decoration_cell_type)
    @decoration_cell_type = decoration_cell_type
  end

  def src
    puts "Getting source for decoration #{@decoration_cell_type}"
    res = nil
    if (@background_cell != nil)
      if (@background_cell.src.is_a? Array)
        res = @background_cell.src
        res << Sources[@decoration_cell_type] 
      else
        res = [@background_cell.src, Sources[@decoration_cell_type]]
      end
    else
      res = Sources[@decoration_cell_type]
    end
    puts "Source : #{res}"
    res
  end

end
