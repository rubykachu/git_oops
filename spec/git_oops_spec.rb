# frozen_string_literal: true

require "spec_helper"

RSpec.describe GitOops do
  it "has a version number" do
    expect(GitOops::VERSION).not_to be nil
  end

  it "has ResetCommand available" do
    expect(GitOops::Commands::ResetCommand).to be_a(Class)
  end
end
