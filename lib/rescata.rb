module Rescata
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def rescata
    end
  end
end