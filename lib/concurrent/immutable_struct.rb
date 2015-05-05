require 'concurrent/synchronization'

module Concurrent
  module ImmutableStruct

    def length
      self.class::MEMBERS.length
    end
    alias_method :size, :length

    def members
      self.class::MEMBERS.dup
    end

    def values
      @values.dup
    end
    alias_method :to_a, :values

    def values_at(*indexes)
      @values.values_at(*indexes)
    end

    def to_h
      length.times.reduce({}){|memo, i| memo[self.class::MEMBERS[i]] = @values[i]; memo}
    end

    def [](member)
      if member.is_a? Integer
        if member >= @values.length
          raise IndexError.new("offset #{member} too large for struct(size:#{@values.length})")
        end
        @values[member]
      else
        send(member)
      end
    rescue NoMethodError
      raise NameError.new("no member '#{member}' in struct")
    end

    def ==(other)
      self.class == other.class && self.values == other.values
    end
    alias_method :eql?, :==

    def each
      return enum_for(:each) unless block_given?
      values.each{|value| yield value }
    end

    def each_pair
      return enum_for(:each_pair) unless block_given?
      @values.length.times do |index|
        yield self.class::MEMBERS[index], @values[index]
      end
    end

    def select
      return enum_for(:select) unless block_given?
      values.select{|value| yield value }
    end

    def to_s
      "#<struct #{@map}>"
    end
    alias_method :inspect, :to_s

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
          clazz = Class.new do
            include ImmutableStruct
            self.const_set(:MEMBERS, members.collect{|member| member.to_s.to_sym}.freeze) 
            def initialize(*values)
              raise ArgumentError.new('struct size differs') if values.length > length
              @values = values.fill(nil, values.length..length-1)
            end
          end
          unless name.nil?
            begin
              ImmutableStruct.const_set(name, clazz)
              ImmutableStruct.const_get(name)
            rescue NameError
              raise NameError.new("identifier #{name} needs to be constant") 
            end
          end
          members.each_with_index do |member, index|
            clazz.send(:define_method, member) do
              instance_variable_get(:@values)[index]
            end
          end
          clazz.class_exec(&block) unless block.nil?
          clazz
        end
      end
    end.new
    private_constant :FACTORY
  end
end
