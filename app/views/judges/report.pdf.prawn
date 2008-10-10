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
   :align_headers      => :center,
   :align              => :left,
   :row_colors         => @row_colors
pdf.text "* Score not yet locked in.", :size=>8, :align=>:center
pdf.move_down 10

for r in @rounds
  pdf.text "#{r.abbreviation} - #{r.description}", :size=>10, :align=>:center
end

pdf.move_down 30
pdf.text "______________________________________", :align=>:center
pdf.text "#{@judge.name}", :size=>8, :align=>:center
