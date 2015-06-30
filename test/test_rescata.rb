require File.expand_path("../lib/rescata", File.dirname(__FILE__))

scope do
  class User
    include Rescata
  end

  test "raise error if rescuer method is not sent" do
    assert_raise(ArgumentError) do
      class User
        rescata :get_talks
      end
    end
  end

  test "rescue an error" do
    class User
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
end