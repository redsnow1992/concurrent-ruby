#!/usr/bin/env ruby

$: << File.expand_path('../../lib', __FILE__)

require 'benchmark'
require 'concurrent'

n = 500_000

Pair = Struct.new(:left, :right)
ImmPair = Concurrent::ImmutableStruct.new(:left, :right)

array_pair = [true, false].freeze
struct_pair = Pair.new(true, false)
immutable = ImmPair.new(true, false)

puts "Object creation...\n"
Benchmark.bmbm do |x|
  x.report('create frozen array') { n.times{ [true, false].freeze } }
  x.report('create frozen struct') { n.times{ Pair.new(true, false).freeze } }
  x.report('create immutable struct') { n.times{ ImmPair.new(true, false) } }
end

puts "\n"

puts "Object access...\n"
Benchmark.bmbm do |x|
  x.report('read from frozen array') { n.times{ array_pair.last } }
  x.report('read from frozen struct') { n.times{ struct_pair.right } }
  x.report('read from immutable struct') { n.times{ immutable.right } }
end

__END__

Object creation...
Rehearsal -----------------------------------------------------------
create frozen array       0.070000   0.000000   0.070000 (  0.067940)
create frozen struct      0.130000   0.000000   0.130000 (  0.138427)
create immutable struct   0.440000   0.000000   0.440000 (  0.438358)
-------------------------------------------------- total: 0.640000sec

                              user     system      total        real
create frozen array       0.060000   0.000000   0.060000 (  0.059133)
create frozen struct      0.140000   0.000000   0.140000 (  0.139155)
create immutable struct   0.420000   0.000000   0.420000 (  0.421774)

Object access...
Rehearsal --------------------------------------------------------------
read from frozen array       0.040000   0.000000   0.040000 (  0.035394)
read from frozen struct      0.030000   0.000000   0.030000 (  0.034680)
read from immutable struct   0.090000   0.000000   0.090000 (  0.088073)
----------------------------------------------------- total: 0.160000sec

                                 user     system      total        real
read from frozen array       0.040000   0.000000   0.040000 (  0.035402)
read from frozen struct      0.030000   0.000000   0.030000 (  0.033434)
read from immutable struct   0.080000   0.000000   0.080000 (  0.086537)
