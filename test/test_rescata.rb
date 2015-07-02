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

  test "rescue from a class error passing error variable" do
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

  test "rescue from a sent array of error classes" do
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
end