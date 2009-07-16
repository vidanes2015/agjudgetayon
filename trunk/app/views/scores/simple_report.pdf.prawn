pdf.font "#{Prawn::BASEDIR}/data/fonts/DejaVuSans.ttf"

pdf.footer [pdf.margin_box.left, pdf.margin_box.bottom - 25] do
  pdf.stroke_horizontal_rule
  pdf.text "Page #{pdf.page_count()}", :size => 12, :align=>:center
end

pdf.text @title, :size=>14, :align=>:center
pdf.text "#{Time.now.to_s}", :size=>8, :align=>:center
pdf.move_down 14

# pdf.text "#{(@judges.collect {|j| j.alias}).join(", ")} - #{Round.total_possible_for_judge_grouping(@judges)}", :size=>12, :align=>:center
# for r in @judges[0].rounds
#   pdf.text "#{r.description} - #{r.max_score}", :size=>10, :align=>:center
# end
# pdf.move_down 14
# pdf.text "#{(@other_judges.collect {|j| j.alias}).join(", ")} - #{Round.total_possible_for_judge_grouping(@other_judges)}", :size=>12, :align=>:center
# for r in @other_judges[0].rounds
#   pdf.text "#{r.description} - #{r.max_score}", :size=>10, :align=>:center
# end
# pdf.move_down 14
pdf.table @data,     
   :font_size  => 10, 
   :horizontal_padding => 10,
   :vertical_padding   => 2,
   :border_width       => 1,
   :position           => :center,
   :headers            => @headers,
   :align_headers      => :center,
   :align              => :left,
   :row_colors         => @row_colors
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