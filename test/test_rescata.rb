require File.expand_path("../lib/rescata", File.dirname(__FILE__))

scope do
  test "raise if rescuer method is not sent" do
    assert_raise(ArgumentError) do
      Class.new do
        include Rescata
        rescata :get_talks
      end
    end
  end

  test "rescue an error with method" do
    User = Class.new do
      include Rescata
      rescata :get_talks, with: :rescue_get_talks

      def get_talks
        raise "throwing an error!"
      end

      def rescue_get_talks
        "rescued!"
      end
    end

    assert_equal User.new.get_talks, "rescued!"
  end

  test "rescue an error with method passing the error variable" do
    User = Class.new do
      include Rescata
      rescata :get_talks, with: :rescue_get_talks

      def get_talks
        raise "i want"
      end

      def rescue_get_talks(e)
        "rescued because #{e.message}"
      end
    end

    assert_equal User.new.get_talks, "rescued because i want"
  end

  test "raise if rescuer is not a method or a proc" do
    assert_raise(ArgumentError) do
      Class.new do
        include Rescata
        rescata :get_talks, with: "whatever"
      end
    end
  end

  test "raise if error class sent is not a class" do
    assert_raise(ArgumentError) do
      Class.new do
        include Rescata
        rescata :get_talks, with: :rescue_get_talks, in: "whatever"
      end
    end
  end

  test "raise if error class sent is not a Exception class or subclass" do
    assert_raise(ArgumentError) do
      Class.new do
        include Rescata
        rescata :get_talks, with: :rescue_get_talks, in: User
      end
    end
  end

  test "rescue from a class error" do
    User = Class.new do
      include Rescata
      rescata :get_talks, with: :rescue_get_talks, in: ArgumentError

      def get_talks
        raise ArgumentError
      end

      def rescue_get_talks
        "rescued!"
      end
    end

    assert_equal User.new.get_talks, "rescued!"
  end

  test "rescue with method from a class error passing error variable" do
    User = Class.new do
      include Rescata
      rescata :get_talks, with: :rescue_get_talks, in: ArgumentError

      def get_talks
        raise ArgumentError, "i want"
      end

      def rescue_get_talks(e)
        "rescued because #{e.message}"
      end
    end

    assert_equal User.new.get_talks, "rescued because i want"
  end

  test "raise if different class error raises" do
    User = Class.new do
      include Rescata
      rescata :get_talks, with: :rescue_get_talks, in: NameError

      def get_talks
        raise StandardError
      end

      def rescue_get_talks
        "rescued!"
      end
    end

    assert_raise(StandardError) do
      User.new.get_talks
    end
  end

  test "raise if error class sent in array is not a class" do
    assert_raise(ArgumentError) do
      Class.new do
        include Rescata
        rescata :get_talks, with: :rescue_get_talks, in: [NameError, "whatever"]
      end
    end
  end

  test "raise if error class sent in array is not a Exception class or subclass" do
    assert_raise(ArgumentError) do
      Class.new do
        include Rescata
        rescata :get_talks, with: :rescue_get_talks, in: [NameError, User]
      end
    end
  end

  test "rescue with method from a sent array of error classes" do
    User = Class.new do
      include Rescata
      rescata :get_talks, with: :rescue_get_talks, in: [NameError, ArgumentError]

      def get_talks
        raise ArgumentError
      end

      def rescue_get_talks
        "rescued!"
      end
    end

    assert_equal User.new.get_talks, "rescued!"
  end

  test "raise if different class error raise from array of error classes" do
    User = Class.new do
      include Rescata
      rescata :get_talks, with: :rescue_get_talks, in: [NameError, ArgumentError]

      def get_talks
        raise StandardError
      end

      def rescue_get_talks
        "rescued!"
      end
    end

    assert_raise(StandardError) do
      User.new.get_talks
    end
  end

  test "rescue an error with proc" do
    User = Class.new do
      include Rescata
      rescata :get_talks, with: lambda{"rescued"}

      def get_talks
        raise "throwing an error"
      end
    end

    assert_equal User.new.get_talks, "rescued"
  end

  test "rescue an error with proc sending error variable" do
    User = Class.new do
      include Rescata
      rescata :get_talks, with: lambda{|e| "rescued because #{e.message}"}

      def get_talks
        raise "i want"
      end
    end

    assert_equal User.new.get_talks, "rescued because i want"
  end

  test "rescue with proc from a class error passing error variable" do
    User = Class.new do
      include Rescata
      rescata :get_talks, with: lambda{|e| "rescued because #{e.message}"}, in: ArgumentError

      def get_talks
        raise ArgumentError, "i want"
      end
    end

    assert_equal User.new.get_talks, "rescued because i want"
  end

  test "rescue with proc from a sent array of error classes" do
    User = Class.new do
      include Rescata
      rescata :get_talks, with: lambda{"rescued"}, in: [NameError, ArgumentError]

      def get_talks
        raise ArgumentError
      end
    end

    assert_equal User.new.get_talks, "rescued"
  end

  test "rescue an error with block" do
    User = Class.new do
      include Rescata
      rescata :get_talks do
        "rescued"
      end

      def get_talks
        raise "throwing an error"
      end
    end

    assert_equal User.new.get_talks, "rescued"
  end

  test "rescue an error with block sending error variable" do
    User = Class.new do
      include Rescata
      rescata :get_talks do |e|
        "rescued because #{e.message}"
      end

      def get_talks
        raise "i want"
      end
    end

    assert_equal User.new.get_talks, "rescued because i want"
  end

  test "rescue with block from a class error passing error variable" do
    User = Class.new do
      include Rescata
      rescata :get_talks, in: ArgumentError do |e|
        "rescued because #{e.message}"
      end

      def get_talks
        raise ArgumentError, "i want"
      end
    end

    assert_equal User.new.get_talks, "rescued because i want"
  end

  test "rescue with block from a sent array of error classes" do
    User = Class.new do
      include Rescata
      rescata :get_talks, in: [NameError, ArgumentError] do
        "rescued"
      end

      def get_talks
        raise ArgumentError
      end
    end

    assert_equal User.new.get_talks, "rescued"
  end

  test "no screw up with child classes" do
    User = Class.new do
      include Rescata
      rescata :get_talks, with: :rescue_get_talks

      def get_talks
        raise "OH NOOO"
      end

      def rescue_get_talks
        "yep"
      end
    end

    Student = Class.new(User) do
      def demo
        "hi"
      end
    end
    
    assert_equal Student.new.demo, "hi"
  end

  test "rescuing from method of parent class" do
    User = Class.new do
      include Rescata
      rescata :get_talks, with: :rescue_get_talks

      def get_talks
        raise "OH NOOO"
      end

      def rescue_get_talks
        "yep"
      end
    end

    Student = Class.new(User)
    assert_equal Student.new.get_talks, "yep"
  end

  test "rescuing multiples methods at once with a method" do
    User = Class.new do
      include Rescata
      rescata [:get_talks, :other_method], with: :rescue_get_talks

      def get_talks
        raise "OH NOOO"
      end

      def other_method
        raise "OH NOOO"
      end

      def rescue_get_talks
        "yep"
      end
    end
    assert_equal User.new.get_talks, "yep"
    assert_equal User.new.other_method, "yep"
  end

  test "rescuing multiples methods at once with a method and particular class error" do
    User = Class.new do
      include Rescata
      rescata [:get_talks, :other_method], with: :rescue_get_talks, in: ArgumentError

      def get_talks
        raise StandardError, "OH NOOO"
      end

      def other_method
        raise ArgumentError, "OH NOOO"
      end

      def rescue_get_talks
        "yep"
      end
    end

    assert_raise(StandardError) do
      User.new.get_talks
    end
    assert_equal User.new.other_method, "yep"
  end

  test "rescuing multiples methods at once with lambda and particular class error" do
    User = Class.new do
      include Rescata
      rescata [:get_talks, :other_method], with: lambda{|e| "#{e.message} i want"}, in: ArgumentError

      def get_talks
        raise StandardError, "OH NOOO"
      end

      def other_method
        raise ArgumentError, "raised because"
      end
    end

    assert_raise(StandardError) do
      User.new.get_talks
    end
    assert_equal User.new.other_method, "raised because i want"
  end

  test "rescuing multiples methods at once with block and particular class error" do
    User = Class.new do
      include Rescata
      rescata [:get_talks, :other_method], in: ArgumentError do |e|
        "#{e.message} i want"
      end

      def get_talks
        raise StandardError, "OH NOOO"
      end

      def other_method
        raise ArgumentError, "raised because"
      end
    end

    assert_raise(StandardError) do
      User.new.get_talks
    end
    assert_equal User.new.other_method, "raised because i want"
  end

  test "rescuing same method with multiple rescatas as first assert" do
    User = Class.new do
      include Rescata
      rescata :get_talks, with: :rescue_get_talks, in: StandardError
      rescata :get_talks, with: :rescue_get_talks2, in: ArgumentError
    
      def get_talks
        raise StandardError, "OH NOOO"
      end

      def rescue_get_talks
        "yep"
      end

      def rescue_get_talks2
        "yep2"
      end
    end

    assert_equal User.new.get_talks, "yep"
  end

  test "rescuing same method with multiple rescatas as last assert" do
    User = Class.new do
      include Rescata
      rescata :get_talks, with: :rescue_get_talks, in: StandardError
      rescata :get_talks, with: :rescue_get_talks2, in: ArgumentError
    
      def get_talks
        raise ArgumentError, "OH NOOO"
      end

      def rescue_get_talks
        "yep"
      end

      def rescue_get_talks2
        "yep2"
      end
    end

    assert_equal User.new.get_talks, "yep2"
  end

  test "ensure with a method" do
    User = Class.new do
      include Rescata
      rescata :get_talks, with: :rescue_get_talks, ensuring: :ensure_method
      
      attr_accessor :x
      def initialize
        @x = 1
      end

      def get_talks
        raise "throwing an error!"
      end

      def rescue_get_talks
        "rescued!"
      end

      def ensure_method
        @x += 1
      end
    end

    u = User.new
    u.get_talks
    assert_equal u.x, 2
  end

  test "ensure with a lambda" do
    User = Class.new do
      include Rescata
      rescata :get_talks, with: :rescue_get_talks, ensuring: lambda{|u| u.x += 1 }
      
      attr_accessor :x
      def initialize
        @x = 1
      end

      def get_talks
        raise "throwing an error!"
      end

      def rescue_get_talks
        "rescued!"
      end
    end

    u = User.new
    u.get_talks
    assert_equal u.x, 2
  end
end