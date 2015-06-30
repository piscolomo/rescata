require File.expand_path("../lib/rescata", File.dirname(__FILE__))

scope do
  class User
    include Rescata

    rescata :get_talks, with: :rescue_get_talks

    def get_talks
      raise "throwing an error!"
    end

    def rescue_get_talks
      puts "rescued!"
    end
  end

  test "testing..." do
    assert_equal 1, 1
  end
end