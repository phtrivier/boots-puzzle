module GuiHelper
  def cut_text(text, fitter)
    res = []
    text.split("\n").each do |token|
      if (fitter.fit?(token))
        res << token
      end
    end
    res
  end
end
