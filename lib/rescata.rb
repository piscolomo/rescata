module Rescata
  def self.included(base)
    class << base; attr_accessor :rescues; end
    base.extend ClassMethods
    base.rescues = {}
  end

  module ClassMethods
    def rescata(method_name, options = {})
      raise ArgumentError, 'Rescuer method was not found, supply it with a hash with key :with as an argument' unless options[:with]
      rescues[method_name] = options[:with]
    end

    def method_added(method_name)
      puts "added method #{method_name}"
      if rescues.keys.include? method_name
        puts "method found in rescues!"
      end
    end
  end
end