require 'json'
[Object, Array, Hash].each do |klass|
  klass.class_eval <<-RUBY, __FILE__, __LINE__
    def jsonize(options = nil)
      ::JSON.generate self, :quirks_mode => true
    end
  RUBY
end
