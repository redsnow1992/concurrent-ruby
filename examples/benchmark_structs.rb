#!/usr/bin/env ruby

$: << File.expand_path('../../lib', __FILE__)

require 'benchmark'
require 'concurrent'

n = 500_000

StructPair = Struct.new(:left, :right)
SafePair = Concurrent::SafeStruct.new(:left, :right)
FinalPair = Concurrent::FinalStruct.new(:left, :right)
ImmutablePair = Concurrent::ImmutableStruct.new(:left, :right)

array_pair = [true, false].freeze
struct_pair = StructPair.new(true, false)
safe_pair = SafePair.new(true, false)
final_pair = FinalPair.new(true, false)
immutable = ImmutablePair.new(true, false)

puts "Object creation...\n"
Benchmark.bmbm do |x|
  x.report('create frozen array') { n.times{ [true, false].freeze } }
  x.report('create frozen struct') { n.times{ StructPair.new(true, false).freeze } }
  x.report('create safe struct') { n.times{ SafePair.new(true, false) } }
  x.report('create final struct') { n.times{ FinalPair.new(true, false) } }
  x.report('create immutable struct') { n.times{ ImmutablePair.new(true, false) } }
end

puts "\n"

puts "Object access...\n"
Benchmark.bmbm do |x|
  x.report('read from frozen array') { n.times{ array_pair.last } }
  x.report('read from frozen struct') { n.times{ struct_pair.right } }
  x.report('read from safe struct') { n.times{ safe_pair.right } }
  x.report('read from final struct') { n.times{ final_pair.right } }
  x.report('read from immutable struct') { n.times{ immutable.right } }
end

__END__

Object creation...
Rehearsal -----------------------------------------------------------
create frozen array       0.060000   0.000000   0.060000 (  0.066632)
create frozen struct      0.130000   0.000000   0.130000 (  0.126764)
create safe struct        1.420000   0.000000   1.420000 (  1.417887)
create final struct       1.420000   0.010000   1.430000 (  1.420508)
create immutable struct   0.530000   0.000000   0.530000 (  0.534522)
-------------------------------------------------- total: 3.570000sec

                              user     system      total        real
create frozen array       0.070000   0.000000   0.070000 (  0.060200)
create frozen struct      0.130000   0.000000   0.130000 (  0.126227)
create safe struct        1.440000   0.000000   1.440000 (  1.436948)
create final struct       1.420000   0.000000   1.420000 (  1.418843)
create immutable struct   0.530000   0.000000   0.530000 (  0.534623)

Object access...
Rehearsal --------------------------------------------------------------
read from frozen array       0.040000   0.000000   0.040000 (  0.036472)
read from frozen struct      0.030000   0.000000   0.030000 (  0.033837)
read from safe struct        0.250000   0.000000   0.250000 (  0.244960)
read from final struct       0.240000   0.000000   0.240000 (  0.241092)
read from immutable struct   0.070000   0.000000   0.070000 (  0.067376)
----------------------------------------------------- total: 0.630000sec

                                 user     system      total        real
read from frozen array       0.040000   0.000000   0.040000 (  0.034032)
read from frozen struct      0.030000   0.000000   0.030000 (  0.032540)
read from safe struct        0.250000   0.000000   0.250000 (  0.250463)
read from final struct       0.240000   0.000000   0.240000 (  0.234275)
read from immutable struct   0.070000   0.000000   0.070000 (  0.069682)
