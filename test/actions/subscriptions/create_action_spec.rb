# frozen_string_literal: true

require 'rails_helper'

describe Subscriptions::CreateAction do
  args = {
    type: type,
    google_subscription_id: google_subscription_id,
    purchase_token: purchase_token,
    apple_receipt: apple_receipt,
    duration: duration,
    start_offset: start_offset,
    end_offset: end_offset
  }
  subject(:call) { described_class.call(args) }

  let(:offer) { create(:offer, :apple, duration: 1, active: true) }
  let(:user) { create(:user) }

  let(:expected_subscription_attributes) do
    {
      platform: platform,
      offer: offer,
      price: offer.price,
      duration: 1,
      duration_unit: 'month',
      trial_allowed: true,
      trial_duration: 3,
      ends_at: Time.zone.at(1_590_569_330),
      session: nil,
      token: latest_receipt
    }
  end

  it 'creates new apple subscription' do
    let(:type) { 'apple' }
    let(:platform) { Subscription::APPLE_PLATFORM }
    expect { call }.to change(Subscription, :count).by(1)

    expect(call).to be_success
    expect(call.value!).to have_attributes(expected_subscription_attributes)
  end

  it 'creates new google subscription' do
    let(:type) { 'android' }
    let(:platform) { Subscription::GOOGLE_PLATFORM }
    expect { call }.to change(Subscription, :count).by(1)

    expect(call).to be_success
    expect(call.value!).to have_attributes(expected_subscription_attributes)
  end
end
