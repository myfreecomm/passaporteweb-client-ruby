# encoding: utf-8
module PassaporteWeb

  module Attributable

    def set_attributes(hash)
      self.class::ATTRIBUTES.each do |attribute|
        value = hash[attribute.to_s] if hash.has_key?(attribute.to_s)
        value = hash[attribute.to_sym] if hash.has_key?(attribute.to_sym)
        instance_variable_set("@#{attribute}".to_sym, value)
      end
      @persisted = true
    end
    private :set_attributes

  end

end
