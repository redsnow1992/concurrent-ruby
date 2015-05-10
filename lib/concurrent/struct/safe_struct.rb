require 'concurrent/struct/abstract_struct'
require 'concurrent/synchronization'

module Concurrent
  module SafeStruct
    include AbstractStruct

    def values
      synchronize { ns_values }
    end
    alias_method :to_a, :values

    def values_at(*indexes)
      synchronize { ns_values_at(indexes) }
    end

    def to_h
      synchronize { ns_to_h }
    end

    def [](member)
      synchronize { ns_get(member) }
    end

    def ==(other)
      synchronize { ns_equivalent(other) }
    end
    alias_method :eql?, :==

    def each
      return enum_for(:each) unless block_given?
      synchronize { ns_each(&Proc.new) }
    end

    def each_pair
      return enum_for(:each_pair) unless block_given?
      synchronize { ns_each_pair(&Proc.new) }
    end

    def select
      return enum_for(:select) unless block_given?
      synchronize { ns_select(&Proc.new) }
    end

    def []=(member, value)
      if member.is_a? Integer
        if member >= @values.length
          raise IndexError.new("offset #{member} too large for struct(size:#{@values.length})")
        end
        synchronize { @values[member] = value }
      else
        send("#{member}=", value)
      end
    rescue NoMethodError
      raise NameError.new("no member '#{member}' in struct")
    end

    def self.new(*args, &block)
      clazz_name = nil
      if args.length == 0
        raise ArgumentError.new('wrong number of arguments (0 for 1+)')
      elsif args.length > 0 && args.first.is_a?(String)
        clazz_name = args.shift
      end
      FACTORY.define_struct(clazz_name, *args, &block)
    end

    FACTORY = Class.new(Synchronization::Object) do
      def define_struct(name, *members, &block)
        synchronize do
          clazz = AbstractStruct.define_struct_class(SafeStruct, Synchronization::Object, name, *members, &block)
          members.each_with_index do |member, index|
            clazz.send(:define_method, member) do
              synchronize { @values[index] }
            end
            clazz.send(:define_method, "#{member}=") do |value|
              synchronize { @values[index] = value }
            end
          end
          clazz
        end
      end
    end.new
    private_constant :FACTORY
  end
end
