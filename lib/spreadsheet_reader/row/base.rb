module SpreadsheetReader

=begin
  class Base
    def self.attr_accessor(*vars)
      @attributes ||= []
      @attributes.concat vars
      super(*vars)
    end

    def self.attributes
      @attributes.sort_by {|sym| sym.to_s}
    end

    def attributes
      self.class.attributes
    end
  end
=end


  module Base

    #
    # Provides a way for any class to retrieve the attributes defined via attr_accessor
    # It is based on @sepp2k answer at http://stackoverflow.com/a/2487338/2056593 by @sepp2k
    #
    # class MyClass
    #   include SpreadsheetReader::Base
    #   attr_accessor :my_attr1, :my_attr2
    # end
    #
    # MyClass.attributes # [:my_attr1, :my_attr2]
    # MyClass.new.attributes # [:my_attr1, :my_attr2]
    #

    def self.included(base)
      base.extend(ClassMethods)
    end

    # Taken from http://stackoverflow.com/a/2487338/2056593 by @sepp2k

    def attributes
      self.class.attributes
    end

    module ClassMethods
      def attr_accessor(*vars)
        @attributes ||= []
        @attributes.concat vars
        super(*vars)
      end

      def attributes
        attrs = @attributes
        #super_class = self.superclass
        #while super_class != Object
        #  attrs.concat self.superclass.attributes
        #  super_class = super_class.superclass
        #end
        attrs.sort_by {|sym| sym.to_s}
      end

    end

  end

end