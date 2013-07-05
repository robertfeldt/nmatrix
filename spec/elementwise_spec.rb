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
# == nmatrix_spec.rb
#
# Element-wise operation tests.
#

# Can we use require_relative here instead?
require File.join(File.dirname(__FILE__), "spec_helper.rb")

describe NMatrix do

  context "list" do
    before :each do
      @n = NMatrix.new(:list, 2, 0, :int64)
      @m = NMatrix.new(:list, 2, 0, :int64)
      @n[0,0] = 52
      @m[1,1] = -48
      @n[1,1] = 40
    end

    it "should perform scalar math" do
      x = @n * 3
      x[0,0].should == 52 * 3
      x[1,1].should == 40 * 3
      x[0,1].should == 0

      r = NMatrix.new(:list, 3, 1)
      y = r + 3
      y[0,0].should == 4
    end

    it "should perform element-wise addition" do
      r = NMatrix.new(:dense, 2, [52, 0, 0, -8], :int64).cast(:list, :int64)
      (@n+@m).should == r
    end

    it "should perform element-wise subtraction" do
      r = NMatrix.new(:dense, 2, [52, 0, 0, -88], :int64).cast(:list, :int64)
      (@n-@m).should == r
    end

    it "should perform element-wise multiplication" do
      r = NMatrix.new(:dense, 2, [52, 0, 0, -1920], :int64).cast(:list, :int64)
      m = NMatrix.new(:list, 2, 1, :int64)
      m[1,1] = -48
      (@n*m).should == r
    end

    it "should perform element-wise division" do
      m = NMatrix.new(:list, 2, 1, :int64)
      m[1,1] = 2
      r = NMatrix.new(:dense, 2, [52, 0, 0, 20], :int64).cast(:list, :int64)
      (@n/m).should == r
    end

    it "should perform element-wise modulo" do
      pending "% operator not yet implemented for matrices"
    end

    it "should handle element-wise equality (=~)" do
      (@n =~ @m).cast(:dense, :byte).should == NMatrix.new(:dense, 2, [0, 1, 1, 0], :byte)
    end

    it "should handle element-wise inequality (!~)" do
      (@n !~ @m).cast(:dense, :byte).should == NMatrix.new(:dense, 2, [1, 0, 0, 1], :byte)
    end

    it "should handle element-wise less-than (<)" do
      (@n < @m).should == NMatrix.new(:list, 2, 0, :byte)
    end

    it "should handle element-wise greater-than (>)" do
      (@n > @m).should == NMatrix.new(:dense, 2, [1, 0, 0, 1], :byte).cast(:list, :byte)
    end

    it "should handle element-wise greater-than-or-equals (>=)" do
      (@n >= @m).cast(:dense, :byte).should == NMatrix.new(:dense, 2, [1, 1, 1, 1], :byte)
    end

    it "should handle element-wise less-than-or-equals (<=)" do
      (@n <= @m).cast(:dense, :byte).should == NMatrix.new(:dense, 2, [0, 1, 1, 0], :byte)
    end
  end

  context "dense" do
    context "elementwise arithmetic" do
      before :each do
        @n = NMatrix.new(:dense, 2, [1,2,3,4], :int64)
        @m = NMatrix.new(:dense, 2, [-4,-1,0,66], :int64)
      end

      it "adds" do
        r = @n+@m
        r.should == NMatrix.new(:dense, [2,2], [-3, 1, 3, 70], :int64)
      end

      it "subtracts" do
        r = @n-@m
        r.should == NMatrix.new(:dense, [2,2], [5, 3, 3, -62], :int64)
      end

      it "multiplies" do
        r = @n*@m
        r.should == NMatrix.new(:dense, [2,2], [-4, -2, 0, 264], :int64)
      end

      it "divides in the Ruby way" do
        m = @m.clone
        m[1,0] = 3
        r = @n/m
        r.should == NMatrix.new(:dense, [2,2], [-1, -2, 1, 0], :int64)
      end

      it "modulo" do
        pending "% operator not yet implemented"
        r = @n % @m
        r.should == NMatrix.new(:dense, [2,2], [0, 1, 2, 3], :int64)
      end
    end

    context "elementwise comparisons" do
      before :each do
        @n = NMatrix.new(:dense, 2, [1,2,3,4], :int64)
        @m = NMatrix.new(:dense, 2, [-4,-1,3,2], :int64)
      end

      it "equals" do
        r = @n =~ @m
        r.should == NMatrix.new(:dense, [2,2], [0, 0, 1, 0], :byte)
      end

      it "is not equal" do
        r = @n !~ @m
        r.should == NMatrix.new(:dense, [2,2], [1, 1, 0, 1], :byte)
      end

      it "is less than" do
        r = @n < @m
        r.should == NMatrix.new(:dense, [2,2], 0, :byte)
      end

      it "is greater than" do
        r = @n > @m
        r.should == NMatrix.new(:dense, [2,2], [1, 1, 0, 1], :byte)
      end

      it "is less than or equal to" do
        r = @n <= @m
        r.should == NMatrix.new(:dense, [2,2], [0, 0, 1, 0], :byte)
      end

      it "is greater than or equal to" do
        n = NMatrix.new(:dense, [2,2], [ 1,  2, 2, 4], :int64)
        r = n >= @m
        r.should == NMatrix.new(:dense, [2,2], [1, 1, 0, 1], :byte)
      end
    end

    context "elementwise abs" do
      [:int8, :int16, :int32, :int64, :float32, :float64, :rational32, :rational64, :rational128].each do |dtype|
        context dtype do
          it "takes abs of matrix" do
            n = NMatrix.new(:dense, [2,2], [-1, 1, 0, -12], dtype)
            r = n.abs
            r.should == NMatrix.new(:dense, [2,2], [1, 1, 0, 12], dtype)
          end

          it "takes abs of vector" do
            n = NVector.new(3, [-1, 0, 1], dtype)
            r = n.abs
            r.should == n = NVector.new(3, [1, 0, 1], dtype)
          end
        end
      end

      [:complex64, :complex128].each do |dtype|
        context dtype do
          it "calculates the abs of complex numbers in all quadrants" do
            n = NMatrix.new(:dense, [2,2], [Complex(3, 4), Complex(-3, 4), Complex(-3, -4), Complex(3, -4)], dtype)
            r = n.abs
            r.should == NMatrix.new(:dense, [2,2], [5, 5, 5, 5], dtype)
          end

          it "can take the abs of only the real part" do
            n = NMatrix.new(:dense, [2,2], [Complex(3, 4), Complex(-3, 4), Complex(-3, -4), Complex(3, -4)], dtype)
            r = n.real_abs
            r.should == NMatrix.new(:dense, [2,2], [Complex(3, 4), Complex(3, 4), Complex(3, -4), Complex(3, -4)], dtype)
          end

          it "can take the abs of only the imaginary part" do
            n = NMatrix.new(:dense, [2,2], [Complex(3, 4), Complex(-3, 4), Complex(-3, -4), Complex(3, -4)], dtype)
            r = n.imag_abs
            r.should == NMatrix.new(:dense, [2,2], [Complex(3, 4), Complex(-3, 4), Complex(-3, 4), Complex(3, 4)], dtype)
          end
        end
      end
    end
  end
end
