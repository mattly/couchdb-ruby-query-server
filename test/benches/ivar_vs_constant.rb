module Smackdown
  extend self
  HSH = {}

  def hsh 
    @hsh ||= {}
  end

  ARY = []
  
  def ary
    @ary ||= []
  end
end

require 'benchmark'

puts "\nsetting hash key"
n = 100000
Benchmark.bm do |x|
  x.report("to ::CONSTANT       ") do
    n.times {|i| Smackdown::HSH[(i%1000).to_s] = i }
  end

  x.report("to @ivar via .method") do
    n.times {|i| Smackdown.hsh[(i%1000).to_s] = i }
  end
end

puts "\nreading hash key"
n = 1000000
Benchmark.bm do |x|
  x.report("from ::CONSTANT       "){ n.times{|i| Smackdown::HSH[(i%1000).to_s] } }
  x.report("from @ivar via .method"){ n.times{|i| Smackdown.hsh[(i%1000).to_s] } }
end
      
puts "\npushing to array, clearing every 1000"
n = 100000
Benchmark.bm do |x|
  x.report("to ::CONSTANT       ") do
    n.times do |i|
      Smackdown::ARY.clear if i%1000 == 1
      Smackdown::ARY << i
    end
  end

  x.report("to @ivar via .method") do
    n.times do |i|
      Smackdown.ary.clear if i%1000 == 1
      Smackdown.ary << i
    end
  end
end

puts "\nmapping from array"
n = 1000

Smackdown.ary.clear
Smackdown::ARY.clear
1000.times do
  Smackdown::ARY << rand(10000)
  Smackdown.ary << rand(10000)
end

Benchmark.bm do |x|
  x.report("from ::CONSTANT       ") do
    n.times { Smackdown::ARY.map{|i| i.to_s } }
  end

  x.report("from @ivar via .method") do
    n.times { Smackdown.ary.map{|i| i.to_s } }
  end
end

