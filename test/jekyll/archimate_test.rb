require "test_helper"

class Jekyll::ArchimateTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Jekyll::Archimate::VERSION
  end
end
