require 'concurrent/atomic/weak_key_map'

module Concurrent

  # @!macro [attach] abstract_thread_local_var
  #   A `ThreadLocalVar` is a variable where the value is different for each thread.
  #   Each variable may have a default value, but when you modify the variable only
  #   the current thread will ever see that change.
  #   
  #   @example
  #     v = ThreadLocalVar.new(14)
  #     v.value #=> 14
  #     v.value = 2
  #     v.value #=> 2
  #   
  #   @example
  #     v = ThreadLocalVar.new(14)
  #   
  #     t1 = Thread.new do
  #       v.value #=> 14
  #       v.value = 1
  #       v.value #=> 1
  #     end
  #   
  #     t2 = Thread.new do
  #       v.value #=> 14
  #       v.value = 2
  #       v.value #=> 2
  #     end
  #   
  #     v.value #=> 14
  class AbstractThreadLocalVar

    module ThreadLocalRubyStorage

      protected

      def allocate_storage
        @storage = WeakKeyMap.new
      end

      def get
        @storage[Thread.current]
      end

      def set(value, &block)
        key = Thread.current

        @storage[key] = value

        if block_given?
          begin
            block.call
          ensure
            @storage.delete key
          end
        end
      end
    end

    module ThreadLocalJavaStorage

      protected

      def allocate_storage
        @var = java.lang.ThreadLocal.new
      end

      def get
        @var.get
      end

      def set(value)
        @var.set(value)
      end

    end

    NIL_SENTINEL = Object.new

    def initialize(default = nil)
      @default = default
      allocate_storage
    end

    def value
      value = get

      if value.nil?
        @default
      elsif value == NIL_SENTINEL
        nil
      else
        value
      end
    end

    def value=(value)
      bind value
    end

    def bind(value, &block)
      if value.nil?
        stored_value = NIL_SENTINEL
      else
        stored_value = value
      end

      set stored_value, &block

      value
    end

  end

  # @!macro abstract_thread_local_var
  class ThreadLocalVar < AbstractThreadLocalVar
    if Concurrent.on_jruby?
      include ThreadLocalJavaStorage
    else
      include ThreadLocalRubyStorage
    end
  end
end
