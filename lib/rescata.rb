module Rescata
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def rescata(method_name, options = {})
      raise ArgumentError, 'Rescuer method was not found, supply it with a hash with key :with as an argument' unless options[:with]
    end
  end
end