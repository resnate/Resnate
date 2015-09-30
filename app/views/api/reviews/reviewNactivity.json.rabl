node :review do
  { :review => partial("app/views/api/reviews/show", :object => @address), :activity => @activity }
end