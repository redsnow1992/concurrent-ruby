#!/usr/bin/env ruby

$: << File.expand_path('../../lib', __FILE__)

require 'benchmark'
require 'concurrent'

n = 500_000

StructPair = Struct.new(:left, :right)
SafePair = Concurrent::SafeStruct.new(:left, :right)
ImmutablePair = Concurrent::ImmutableStruct.new(:left, :right)

array_pair = [true, false].freeze
struct_pair = StructPair.new(true, false)
safe_pair = SafePair.new(true, false)
immutable = ImmutablePair.new(true, false)

puts "Object creation...\n"
Benchmark.bmbm do |x|
  x.report('create frozen array') { n.times{ [true, false].freeze } }
  x.report('create frozen struct') { n.times{ StructPair.new(true, false).freeze } }
  x.report('create safe struct') { n.times{ SafePair.new(true, false) } }
  x.report('create immutable struct') { n.times{ ImmutablePair.new(true, false) } }
end

puts "\n"

puts "Object access...\n"
Benchmark.bmbm do |x|
  x.report('read from frozen array') { n.times{ array_pair.last } }
  x.report('read from frozen struct') { n.times{ struct_pair.right } }
  x.report('read from safe struct') { n.times{ safe_pair.right } }
  x.report('read from immutable struct') { n.times{ immutable.right } }
end

__END__


Object creation...
Rehearsal -----------------------------------------------------------
create frozen array       0.070000   0.000000   0.070000 (  0.063610)
create frozen struct      0.130000   0.000000   0.130000 (  0.130142)
create safe struct        1.400000   0.000000   1.400000 (  1.404866)
create immutable struct   0.550000   0.000000   0.550000 (  0.546921)
-------------------------------------------------- total: 2.150000sec

                              user     system      total        real
create frozen array       0.070000   0.000000   0.070000 (  0.063068)
create frozen struct      0.140000   0.000000   0.140000 (  0.135902)
create safe struct        1.370000   0.000000   1.370000 (  1.371264)
create immutable struct   0.550000   0.000000   0.550000 (  0.545862)

Object access...
Rehearsal --------------------------------------------------------------
read from frozen array       0.030000   0.000000   0.030000 (  0.035195)
read from frozen struct      0.040000   0.000000   0.040000 (  0.033263)
read from safe struct        0.230000   0.000000   0.230000 (  0.228534)
read from immutable struct   0.060000   0.000000   0.060000 (  0.069687)
----------------------------------------------------- total: 0.360000sec

                                 user     system      total        real
read from frozen array       0.030000   0.000000   0.030000 (  0.034308)
read from frozen struct      0.040000   0.000000   0.040000 (  0.034345)
read from safe struct        0.240000   0.000000   0.240000 (  0.240889)
read from immutable struct   0.080000   0.000000   0.080000 (  0.069762)
