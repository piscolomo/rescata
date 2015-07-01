require File.expand_path("../lib/rescata", File.dirname(__FILE__))

scope do
  test "raise error if rescuer method is not sent" do
    assert_raise(ArgumentError) do
      Class.new do
        include Rescata
        rescata :get_talks
      end
    end
  end

  test "rescue an error" do
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

  test "rescue an error passing the error variable" do
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

  test "raise error if error class sent is not a class" do
    assert_raise(ArgumentError) do
      Class.new do
        include Rescata
        rescata :get_talks, with: :rescue_get_talks, in: "whatever"
      end
    end
  end

  test "raise error if error class sent is not a Exception class or subclass" do
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
      rescata :get_talks, with: :rescue_get_talks, in: StandardError

      def get_talks
        raise StandardError, "raised because i want"
      end

      def rescue_get_talks
        "rescued!"
      end
    end

    assert_equal User.new.get_talks, "rescued!"
  end

  # test "raise error if different class error raises" do
  #   class User
  #     rescata :get_talks, with: :rescue_get_talks, in: NameError

  #     def get_talks
  #       raise StandardError, "raised because i want"
  #     end

  #     def rescue_get_talks
  #       "rescued!"
  #     end
  #   end

  #   assert_raise(ArgumentError) do
  #     User.new.get_talks
  #   end
  # end
end