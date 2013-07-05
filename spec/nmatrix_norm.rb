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
          r.should == ((2**p + 1 + 0 + 1 + 2**p) ** (1.0 / p)) # Should not be exact eq check...
        end
      end

      it "uses the euclidean norm as the default" do
        n = NVector.new(5, [-2, -1,  0,  1,  2], dtype)
        r = n.norm()
        r.should == n.norm(2)
        r.should == n.euclidean_norm
      end      
    end
  end
end

# The expected values is based on SciPy documentation on this page:
#   http://docs.scipy.org/doc/scipy/reference/tutorial/linalg.html
describe "matrix norms" do
  [:int8, :int16, :int32, :int64, :float32, :float64, :rational32, :rational64, :rational128].each do |dtype|
    context dtype do
      before do
        @n = NMatrix.new(:dense, [2, 2], [1, 2, 3, 4], dtype)
      end

      it "correctly calculates matrix norm with ord=INFINITY" do
        r = @n.norm(Float::INFINITY)
        r.should == 7
      end

      it "correctly calculates matrix norm with ord=-INFINITY" do
        r = @n.norm(-Float::INFINITY)
        r.should == 3
      end

      it "correctly calculates matrix norm with ord=1" do
        r = @n.norm(1)
        r.should == 6
      end

      it "correctly calculates matrix norm with ord=-1" do
        r = @n.norm(-1)
        r.should == 4
      end

      it "correctly calculates matrix norm with ord=2" do
        r = @n.norm(2)
        r.should == 5.4649857042190426 # Should not be exact eq!?
      end

      it "correctly calculates matrix norm with ord=-2" do
        r = @n.norm(-2)
        r.should == 0.36596619062625746 # Should not be exact eq!?
      end

      it "correctly calculates frobenius norm" do
        r = @n.norm(:frobenius)
        r.should == 5.4772255750516612 # Should not be exact eq!?
      end

      it "uses the frobenius norm by default" do
        r = @n.norm
        r.should == @n.norm(:frobenius) # Should not be exact eq!?
      end

      it "raises an exception for norms with an ord not in [-Float::INFINITY, -2, -1, :frobenius, 1, 2, Float::INFINITY]" do
        lamda {@n.norm(3)}.should_raise ArgumentError
        lamda {@n.norm(-3)}.should_raise ArgumentError
        lamda {@n.norm(:fro)}.should_raise ArgumentError
        lamda {@n.norm("frobenius")}.should_raise ArgumentError
      end
    end
  end
end