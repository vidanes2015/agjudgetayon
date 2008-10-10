pdf.font "#{Prawn::BASEDIR}/data/fonts/DejaVuSans.ttf"

pdf.footer [pdf.margin_box.left, pdf.margin_box.bottom - 25] do
  pdf.stroke_horizontal_rule
  pdf.text "Page #{pdf.page_count()}", :size => 12, :align=>:center
end

pdf.text @title, :size=>14, :align=>:center
pdf.text "#{Time.now.to_s}", :size=>8, :align=>:center
pdf.move_down 14
pdf.table @data,     
   :font_size  => 10, 
   :horizontal_padding => 10,
   :vertical_padding   => 2,
   :border_width       => 1,
   :position           => :center,
   :headers            => @headers,
   :align              => :left,
   :align_headers      => :center
pdf.text "* Score not yet locked in.", :size=>8, :align=>:center
pdf.move_down 20           
           
x = pdf.bounds.width()/4
space = 20
height = (@judges.size/2 + @judges.size%2)*40
i = 0
pdf.y -= 60
while i < @judges.size
  if pdf.y < pdf.bounds.bottom+15
    pdf.start_new_page
    pdf.y -= 60
  end
  if (i == 0 and @judges.size%2 == 1) 
    pdf.bounding_box([2*x-100, pdf.y], :width=>200, :height=>100) do
     pdf.text "______________________________________",  :align=>:center
     pdf.text "#{@judges[i].alias} (#{@judges[i].name})", :size=>8, :align=>:center
   end
   i += 1
 else
   pdf.bounding_box([x-100,pdf.y], :width=>200, :height=>100) do
     pdf.text "______________________________________",  :align=>:center
     pdf.text "#{@judges[i].alias} (#{@judges[i].name})", :size=>8, :align=>:center
   end
   pdf.y += 2*pdf.font.height()
   pdf.bounding_box([3*x-100,pdf.y], :width=>200, :height=>100) do
     pdf.text "______________________________________",  :align=>:center
     pdf.text "#{@judges[i+1].alias} (#{@judges[i+1].name})", :size=>8, :align=>:center
   end
   i += 2
  end
  pdf.y -=20
end
