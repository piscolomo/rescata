require File.expand_path("../lib/rescata", File.dirname(__FILE__))

scope do
  class User
    include Rescata
    def get_talks
      raise "throwing an error!"
    end

    def rescue_get_talks
      puts "rescued!"
    end
  end

  test "raise error if rescuer method is not sent" do
    assert_raise(ArgumentError) do
      Class.new(User) do
        include Rescata
        rescata :get_talks
      end
    end
  end

  test "rescue an error" do
    Class.new(User) do
      include Rescata
      rescata :get_talks, with: :rescue_get_talks
    end
  end
end