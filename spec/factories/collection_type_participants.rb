# frozen_string_literal: true

# OVERRIDE Hyrax v3.4.2 This file required for various specs (no changes)
FactoryBot.define do
  factory :collection_type_participant, class: Hyrax::CollectionTypeParticipant do
    association :hyrax_collection_type, factory: :collection_type
    sequence(:agent_id) { |n| "user#{n}@example.com" }
    agent_type  { 'user' }
    access      { Hyrax::CollectionTypeParticipant::MANAGE_ACCESS }
  end
end
