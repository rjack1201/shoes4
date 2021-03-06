require 'shoes/spec_helper'

describe Shoes::Dimensions do

  let(:left) {10}
  let(:top) {20}
  let(:width) {100}
  let(:height) {150}
  let(:parent) {double 'parent', width: width, height: height}
  subject {Shoes::Dimensions.new parent, left, top, width, height}

  describe 'initialization' do
    describe 'without arguments' do
      subject {Shoes::Dimensions.new parent}

      its(:left) {should eq 0}
      its(:top) {should eq 0}
      its(:width) {should eq nil}
      its(:height) {should eq nil}
      its(:absolutely_positioned?) {should be_false}
      its(:absolute_x_position?) {should be_false}
      its(:absolute_y_position?) {should be_false}
    end

    describe 'with 2 arguments' do
      subject {Shoes::Dimensions.new parent, left, top}

      its(:left) {should eq left}
      its(:top) {should eq top}
      its(:width) {should eq nil}
      its(:height) {should eq nil}
      its(:absolutely_positioned?) {should be_true}
      its(:absolute_x_position?) {should be_true}
      its(:absolute_y_position?) {should be_true}
    end

    describe 'with 4 arguments' do
      subject {Shoes::Dimensions.new parent, left, top, width, height}

      its(:left) {should eq left}
      its(:top) {should eq top}
      its(:width) {should eq width}
      its(:height) {should eq height}
    end

    describe 'with relative width and height' do
      subject {Shoes::Dimensions.new parent, left, top, 0.5, 0.5}

      its(:left) {should eq left}
      its(:top) {should eq top}
      its(:width) {should be_within(1).of 0.5 * width}
      its(:height) {should be_within(1).of 0.5 * height}
      
      describe 'width/height change of the parent' do
        let(:parent) {Shoes::Dimensions.new nil, left, top, width, height}
        
        # note that here the first assertion/call is necessary as otherwise
        # the subject will only lazily get initialized after the parent width
        # is already adjusted and therefore wrong impls WILL PASS the tests
        # (jay for red/green/refactor :-) )
        it 'adapts width' do
          subject.width.should be_within(1).of 0.5 * width
          parent.width = 700
          subject.width.should be_within(1).of 350
        end

        it 'adapts height' do
          subject.height.should be_within(1).of 0.5 * height
          parent.height = 800
          subject.height.should be_within(1).of 400
        end
      end
    end

    describe 'with a hash' do
      subject { Shoes::Dimensions.new parent, left:   left,
                                              top:    top,
                                              width:  width,
                                              height: height }

      its(:left) {should eq left}
      its(:top) {should eq top}
      its(:width) {should eq width}
      its(:height) {should eq height}
      its(:absolutely_positioned?) {should be_true}
      its(:absolute_x_position?) {should be_true}
      its(:absolute_y_position?) {should be_true}

      context 'missing width' do
        subject { Shoes::Dimensions.new parent, left:   left,
                                                top:    top,
                                                height: height }

        its(:width) {should eq nil}
      end
    end

    describe 'absolute_left and _top' do
      its(:absolute_left) {should eq nil}
      its(:absolute_top) {should eq nil}
    end

    describe 'absolute extra values' do
      it 'has an appropriate absolute_right' do
        subject.absolute_left = 10
        subject.absolute_right.should eq width + 10
      end

      it 'has an appropriate absolute_bottom' do
        subject.absolute_top = 15
        subject.absolute_bottom.should eq height + 15
      end
    end
  end

  describe 'setters' do
    it 'also has a setter for left' do
      subject.left = 66
      subject.left.should eq 66
    end
  end

  describe 'additional dimension methods' do
    its(:right) {should eq left + width}
    its(:bottom) {should eq top + height}

    describe 'without height and width' do
      let(:width) {nil}
      let(:height) {nil}
      its(:right) {should eq left}
      its(:bottom) {should eq top}
    end
  end

  describe 'in_bounds?' do
    it {should be_in_bounds 30, 40}
    it {should be_in_bounds left, top}
    it {should be_in_bounds left + width, top + height}
    it {should_not be_in_bounds 0, 0}
    it {should_not be_in_bounds 0, 40}
    it {should_not be_in_bounds 40, 0}
    it {should_not be_in_bounds 200, 50}
    it {should_not be_in_bounds 80, 400}
    it {should_not be_in_bounds 1000, 1000}
  end

  describe 'absolute positioning' do
    subject {Shoes::Dimensions.new parent}
    its(:absolutely_positioned?) {should be_false}

    describe 'changing left' do
      before :each do
        subject.left = left
      end

      its(:absolute_x_position?) {should be_true}
      its(:absolute_y_position?) {should be_false}
      its(:absolutely_positioned?) {should be_true}
    end

    describe 'changing top' do
      before :each do
        subject.top = top
      end

      its(:absolute_x_position?) {should be_false}
      its(:absolute_y_position?) {should be_true}
      its(:absolutely_positioned?) {should be_true}
    end
  end

  describe Shoes::AbsoluteDimensions do
    subject {Shoes::AbsoluteDimensions.new left, top, width, height}
    it 'has the same absolute_left as left' do
      subject.absolute_left.should eq left
    end

    it 'has the same absolute_top as top' do
      subject.absolute_top.should eq top
    end

    describe 'not adapting floats to parent values' do
      subject {Shoes::AbsoluteDimensions.new left, top, 1.04, 2.10}
      it 'does not adapt width' do
        subject.width.should be_within(0.01).of 1.04
      end

      it 'does not adapt height' do
        subject.height.should be_within(0.01).of 2.10
      end
    end
  end
end

describe Shoes::DimensionsDelegations do

  describe 'with a DSL class and a dimensions method' do
    let(:dimensions) {double('dimensions')}

    class DummyClass
      include Shoes::DimensionsDelegations
      def dimensions
      end
    end

    subject do
      dummy = DummyClass.new
      dummy.stub dimensions: dimensions
      dummy
    end

    it 'forwards left calls to dimensions' do
      dimensions.should_receive :left
      subject.left
    end

    it 'forwards bottom calls to dimensions' do
      dimensions.should_receive :bottom
      subject.bottom
    end

    it 'forwards setter calls like left= do dimensions' do
      dimensions.should_receive :left=
      subject.left = 66
    end

    it 'forwards absolutely_positioned? calls to the dimensions' do
      dimensions.should_receive :absolutely_positioned?
      subject.absolutely_positioned?
    end
  end

  describe 'with any backend class that has a defined dsl method' do
    let(:dsl){double 'dsl'}

    class AnotherDummyClass
      include Shoes::BackendDimensionsDelegations
      def dsl
      end
    end

    subject do
      dummy = AnotherDummyClass.new
      dummy.stub dsl: dsl
      dummy
    end

    it 'forwards calls to dsl' do
      dsl.should_receive :left
      subject.left
    end
  end

end