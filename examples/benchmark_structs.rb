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
create frozen array       0.070000   0.000000   0.070000 (  0.066659)
create frozen struct      0.130000   0.000000   0.130000 (  0.131200)
create safe struct        1.440000   0.000000   1.440000 (  1.438497)
create final struct       1.460000   0.000000   1.460000 (  1.457180)
create immutable struct   0.540000   0.000000   0.540000 (  0.543110)
-------------------------------------------------- total: 3.640000sec

                              user     system      total        real
create frozen array       0.060000   0.000000   0.060000 (  0.063805)
create frozen struct      0.150000   0.000000   0.150000 (  0.138850)
create safe struct        1.420000   0.000000   1.420000 (  1.420694)
create final struct       1.400000   0.000000   1.400000 (  1.397313)
create immutable struct   0.540000   0.000000   0.540000 (  0.535394)

Object access...
Rehearsal --------------------------------------------------------------
read from frozen array       0.030000   0.000000   0.030000 (  0.035155)
read from frozen struct      0.040000   0.000000   0.040000 (  0.034896)
read from safe struct        0.230000   0.000000   0.230000 (  0.232889)
read from final struct       0.230000   0.000000   0.230000 (  0.229081)
read from immutable struct   0.060000   0.000000   0.060000 (  0.065804)
----------------------------------------------------- total: 0.590000sec

                                 user     system      total        real
read from frozen array       0.040000   0.000000   0.040000 (  0.037103)
read from frozen struct      0.040000   0.000000   0.040000 (  0.033774)
read from safe struct        0.230000   0.000000   0.230000 (  0.232363)
read from final struct       0.240000   0.000000   0.240000 (  0.245618)
read from immutable struct   0.080000   0.000000   0.080000 (  0.074343)
