require 'concurrent/struct/abstract_struct'
require 'concurrent/synchronization'

module Concurrent
  module ImmutableStruct
    include AbstractStruct

    def initialize(*values)
      ns_initialize(*values)
    end

    def values
      ns_values
    end
    alias_method :to_a, :values

    def values_at(*indexes)
      ns_values_at(indexes)
    end

    def to_h
      ns_to_h
    end

    def [](member)
      ns_get(member)
    end

    def ==(other)
      ns_equivalent(other)
    end
    alias_method :eql?, :==

    def each
      return enum_for(:each) unless block_given?
      ns_each(&Proc.new)
    end

    def each_pair
      return enum_for(:each_pair) unless block_given?
      ns_each_pair(&Proc.new)
    end

    def select
      return enum_for(:select) unless block_given?
      ns_select(&Proc.new)
    end

    def self.new(*args, &block)
      clazz_name = nil
      if args.length == 0
        raise ArgumentError.new('wrong number of arguments (0 for 1+)')
      elsif args.length > 0 && args.first.is_a?(String)
        clazz_name = args.shift
      end
      FACTORY.define_struct(clazz_name, args, &block)
    end

    FACTORY = Class.new(Synchronization::Object) do
      def define_struct(name, members, &block)
        synchronize do
          AbstractStruct.define_struct_class(ImmutableStruct, nil, name, members, &block)
        end
      end
    end.new
    private_constant :FACTORY
  end
end
