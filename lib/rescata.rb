module Rescata
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def rescata(method_name, options = {})
      puts method_name
      puts options
    end
  end
end