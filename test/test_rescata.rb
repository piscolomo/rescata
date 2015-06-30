require File.expand_path("../lib/rescata", File.dirname(__FILE__))

scope do
  class User
    include Rescata

    rescata
  end

  test "testing..." do
    assert_equal 1, 1
  end
end