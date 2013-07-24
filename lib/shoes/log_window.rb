module Shoes::LogWindow
  def self.setup
    stack do
      flow do
        background black
        stack do
          tagline "Shoes Console", :stroke => white
        end
        button "Clear", :margin => 6, :width => 80, :height => 40 do
          Shoes.log.clear
        end
      end
      @log, @hash = stack, nil
      update
      every(0.2) do
        update
      end
    end
  end

  def self.update
    if @hash != Shoes.log.hash
      @hash = Shoes.log.hash
      @log.clear do
        i = 0
        Shoes.log.each do |typ, msg, at, mid, rbf, rbl|
          stack do
            background "#f1f5e1" if i % 2 == 0
            inscription strong(typ.to_s.capitalize, :stroke => "#05C"), " in ", 
            flow do
              stack :margin => 4, :width => -20 do
                s = msg.to_s
                s << "\n#{msg.backtrace.join("\n")}" if msg.kind_of?(Exception)
                para s, :margin => 4, :margin_top => 0
              end
            end
          end
          i += 1
        end
      end
    end
  end
end
