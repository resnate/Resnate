node :review do
  { :review => partial("reviews/show", :object => @address), :activity => @activity }
end