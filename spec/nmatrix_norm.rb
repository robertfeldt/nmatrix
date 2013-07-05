# = NMatrix
#
# A linear algebra library for scientific computation in Ruby.
# NMatrix is part of SciRuby.
#
# NMatrix was originally inspired by and derived from NArray, by
# Masahiro Tanaka: http://narray.rubyforge.org
#
# == Copyright Information
#
# SciRuby is Copyright (c) 2010 - 2012, Ruby Science Foundation
# NMatrix is Copyright (c) 2012, Ruby Science Foundation
#
# Please see LICENSE.txt for additional copyright notices.
#
# == Contributing
#
# By contributing source code to SciRuby, you agree to be bound by
# our Contributor Agreement:
#
# * https://github.com/SciRuby/sciruby/wiki/Contributor-Agreement
#
# == nmatrix_norm.rb
#
# Tests for vector and matrix norms.
#

# Can we use require_relative here instead?
require File.join(File.dirname(__FILE__), "spec_helper.rb")

describe "vector norms" do
  [:int8, :int16, :int32, :int64, :float32, :float64, :rational32, :rational64, :rational128].each do |dtype|
    context dtype do
      it "correctly calculates L1 (manhattan) norm" do
        n = NVector.new(5, [-2, -1,  0,  1,  2], dtype)
        r = n.norm(1)
        r.should == (2 + 1 + 0 + 1 + 2)

        r2 = n.manhattan_norm
        r2.should == (2 + 1 + 0 + 1 + 2)
      end

      it "correctly calculates L2 (euclidean) norm" do
        n = NVector.new(5, [-2, -1,  0,  1,  2], dtype)

        r = n.norm(2)
        r.should == Math.sqrt(4 + 1 + 0 + 1 + 4) # Should not be exact eq check...

        r2 = n.euclidean_norm
        r2.should == Math.sqrt(4 + 1 + 0 + 1 + 4) # Should not be exact eq check...
      end

      it "correctly calculates Lp norms" do
        n = NVector.new(5, [-2, -1,  0,  1,  2], dtype)

        (3..10).each do |p|
          r = n.norm(2)
          r.should == (((-2)**p + 1 + 0 + 1 + 2**p) ** (1.0 / p)) # Should not be exact eq check...
        end
      end
    end
  end
end