module Rescata
  def self.included(base)
    class << base; attr_accessor :rescues; end
    base.extend ClassMethods
    base.rescues = {}
  end

  module ClassMethods
    def rescata(method_name, options = {}, &block)
      error_classes = Array(options[:in])
      error_classes.each do |klass|
        raise ArgumentError, 'Error class must be an Exception or sub-class' if klass.is_a?(Class) ? (klass <= Exception).nil? : true
      end

      options[:with] = block if block_given?
      raise ArgumentError, 'Rescuer is incorrectly, supply it like a Method or a Proc with a hash with key :with as an argument' unless options[:with] && (options[:with].is_a?(Symbol) || options[:with].is_a?(Proc))

      rescues[method_name] ||= {}
      rescues[method_name][:rescuer] = options[:with]
      rescues[method_name][:error_class] = error_classes if options[:in]
    end

    def method_added(method_name)
      return unless rescues && rescue_name = rescues[method_name]
      rescuer = rescue_name[:rescuer]
      error_classes = rescue_name[:error_class]
      alias_method_name = :"rescuing_old_#{method_name}"
      return if instance_methods.include?(alias_method_name)
      alias_method alias_method_name, method_name
      define_method method_name do
        begin 
          send(alias_method_name)
        rescue => e
          raise e if error_classes && !error_classes.include?(e.class)
          case rescuer
          when Symbol
            method(rescuer).arity == 0 ? send(rescuer) : send(rescuer, e)
          when Proc
            rescuer.arity == 0 ? rescuer.call : rescuer.call(e)
          end
        end
      end
    end
  end
end