require 'shoes/spec_helper'

describe Shoes::Rect do
  let(:left) { 44 }
  let(:top) { 66 }
  let(:width) { 111 }
  let(:height) { 333 }
  let(:app) { Shoes::App.new }
  let(:parent) { app }
  subject { Shoes::Slot.new(app, parent, left: left, top: top, width: width, height: height) }

  it_behaves_like "object with dimensions"

  describe "relative dimensions from parent" do
    let(:relative_opts) { { left: left, top: top, width: relative_width, height: relative_height } }

    subject { Shoes::Slot.new(app, parent, relative_opts) }

    it_behaves_like "object with relative dimensions"
  end
end
