module Rescata
  def self.included(base)
    class << base; attr_accessor :rescues; end
    base.extend ClassMethods
    base.rescues = {}
  end

  module ClassMethods
    def rescata(methods, options = {}, &block)
      error_classes = Array(options[:in])
      error_classes.each do |klass|
        raise ArgumentError, 'Error class must be an Exception or sub-class' if klass.is_a?(Class) ? (klass <= Exception).nil? : true
      end

      options[:with] = block if block_given?
      raise ArgumentError, 'Rescuer is incorrectly, supply it like a Method or a Proc with a hash with key :with as an argument' unless options[:with] && (options[:with].is_a?(Symbol) || options[:with].is_a?(Proc))

      Array(methods).each do |method_name|
        rescues[method_name] ||= []
        rescues[method_name] << {
          rescuer: options[:with]
        }.merge(options[:in] ? {error_class: error_classes} : {})
        .merge(options[:ensuring] ? {ensurer: options[:ensuring]} : {})
      end
    end

    def method_added(method_name)
      return unless rescues && collection = rescues[method_name]
      alias_method_name = :"rescuing_old_#{method_name}"
      return if instance_methods.include?(alias_method_name)
      alias_method alias_method_name, method_name
      define_method method_name do
        begin 
          send(alias_method_name)
        rescue => e
          handler = collection.select{|i| i[:error_class] ? i[:error_class].include?(e.class) : true }.first
          rescuer, error_classes, ensurer = handler[:rescuer], handler[:error_class], handler[:ensurer]
          raise e if error_classes && !error_classes.include?(e.class)
          case rescuer
          when Symbol
            method(rescuer).arity == 0 ? send(rescuer) : send(rescuer, e)
          when Proc
            rescuer.arity == 0 ? rescuer.call : rescuer.call(e)
          end
        ensure
          ensurer.is_a?(Symbol) ? send(ensurer) : ensurer.call(self) if ensurer
        end
      end
    end
  end
end