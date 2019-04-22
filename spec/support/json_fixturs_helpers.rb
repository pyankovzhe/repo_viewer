# frozen_string_literal: true

module JsonFixturesHelpers
  def fixture(name)
    JSON.parse(File.read(File.join(SPEC_DIR, 'fixtures', name)))
  end
end
