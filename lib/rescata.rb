module Rescata
  def self.included(base)
    class << base; attr_accessor :rescues; end
    base.extend ClassMethods
    base.rescues = {}
  end

  module ClassMethods
    def rescata(method_name, options = {})
      raise ArgumentError, 'Error class must be an Exception or sub-class' if options[:in] && options[:in].is_a?(Class) && (options[:in] <= Exception).nil?

      raise ArgumentError, 'Rescuer method was not found, supply it with a hash with key :with as an argument' unless options[:with]
      rescues[method_name] = options[:with]
    end

    def method_added(method_name)
      if rescues.keys.include? method_name
        alias_method_name = "rescuing_old_#{method_name}"
        unless instance_methods.include? alias_method_name.to_sym
          send :alias_method, alias_method_name, method_name
          send :define_method, method_name do
            begin 
              send(alias_method_name)
            rescue
              this = self
              self.class.instance_eval do
                this.send(rescues[method_name])
              end
            end
          end
        end
      end
    end
  end
end