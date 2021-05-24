require 'rails_helper'

RSpec.describe "/api/auth", type: :request do
  let(:merchant) { create(:merchant) }
  let(:valid_attributes) {
    {
      email: merchant.email,
      password: merchant.password
    }
  }

  describe "POST /login" do
    context "with valid parameters" do
      it "returns auth token" do
        post api_auth_login_url, params: valid_attributes
        expect(response).to be_successful
      end
    end
  end
end
