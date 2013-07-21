str, t = "", nil
Shoes.app :height => 500, :width => 450 do
  background rgb(77, 77, 77)
  stack :margin => 10 do
  end
  stack :margin => 10 do
    t = para "", :font => "Monospace 12px", :stroke => white
  end
  keypress do |k|
    case k
    when String
      str += k
    when :backspace
      str.slice!(-1)
    when :tab
      str += "  "
    when :alt_q
      quit
    when :alt_c
      self.clipboard = str
    when :alt_v
      str += self.clipboard
    end
    t.replace str
  end
end
