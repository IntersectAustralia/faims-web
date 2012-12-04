require 'spec_helper'

describe Permission do
  describe "Validations" do
    it { should validate_presence_of(:entity) }
    it { should validate_presence_of(:action) }
  end
end
