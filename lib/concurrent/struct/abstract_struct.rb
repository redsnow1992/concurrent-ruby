module Concurrent
  module AbstractStruct

    def length
      self.class::MEMBERS.length
    end
    alias_method :size, :length

    def members
      self.class::MEMBERS.dup
    end

    protected

    def ns_values
      @values.dup
    end

    def ns_values_at(indexes)
      @values.values_at(*indexes)
    end

    def ns_to_h
      length.times.reduce({}){|memo, i| memo[self.class::MEMBERS[i]] = @values[i]; memo}
    end

    def ns_get(member)
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

    def ns_equivalent(other)
      self.class == other.class && self.values == other.values
    end

    def ns_each
      values.each{|value| yield value }
    end

    def ns_each_pair
      @values.length.times do |index|
        yield self.class::MEMBERS[index], @values[index]
      end
    end

    def ns_select
      values.select{|value| yield value }
    end

    def self.define_struct_class(parent, base, name, *members, &block)
      clazz = Class.new(base || Object) do
        include parent
        self.const_set(:MEMBERS, members.collect{|member| member.to_s.to_sym}.freeze) 
        def ns_initialize(*values)
          raise ArgumentError.new('struct size differs') if values.length > length
          @values = values.fill(nil, values.length..length-1)
        end
      end
      unless name.nil?
        begin
          parent.const_set(name, clazz)
          parent.const_get(name)
        rescue NameError
          raise NameError.new("identifier #{name} needs to be constant") 
        end
      end
      members.each_with_index do |member, index|
        clazz.send(:define_method, member) do
          @values[index]
        end
      end
      clazz.class_exec(&block) unless block.nil?
      clazz
    end
  end
end
