require 'yardstick/rake/verify'

Yardstick::Rake::Verify.new(:yardstick) do |verify|
  verify.verbose = true
  verify.threshold = 100
end
