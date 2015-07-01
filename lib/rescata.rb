module Rescata
  def self.included(base)
    class << base; attr_accessor :rescues; end
    base.extend ClassMethods
    base.rescues = {}
  end

  module ClassMethods
    def rescata(method_name, options = {})
      if options[:in]
        error_classes = Array(options[:in])
        error_classes.each do |klass|
          raise ArgumentError, 'Error class must be an Exception or sub-class' if klass.is_a?(Class) ? (klass <= Exception).nil? : true
        end
      end

      raise ArgumentError, 'Rescuer method was not found, supply it with a hash with key :with as an argument' unless options[:with]
      rescues[method_name] ||= {}
      rescues[method_name][:rescuer] = options[:with]
      rescues[method_name][:error_class] = options[:in] if options[:in]
    end

    def method_added(method_name)
      if rescues.keys.include? method_name
        rescuer_method = rescues[method_name][:rescuer]
        error_class = rescues[method_name][:error_class]
        alias_method_name = "rescuing_old_#{method_name}"
        unless instance_methods.include? alias_method_name.to_sym
          send :alias_method, alias_method_name, method_name
          send :define_method, method_name do
            begin 
              send(alias_method_name)
            rescue => e
              raise e if error_class && !e.instance_of?(error_class)
              instance_eval do
                rescuer_arity =  method(rescuer_method).arity
                rescuer_arity == 0 ? send(rescuer_method) : send(rescuer_method, e)
              end
            end
          end
        end
      end
    end
  end
end