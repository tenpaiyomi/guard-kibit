# frozen_string_literal: true

# A workaround for declaring `class Kibit`
# before `class Kibit < Guard` in kibit.rb
module GuardKibitVersion
  # http://semver.org/
  MAJOR = 1
  MINOR = 0
  PATCH = 0

  def self.to_s
    [MAJOR, MINOR, PATCH].join('.')
  end
end
