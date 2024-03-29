# frozen_string_literal: true

RSpec.describe SearchHistoryController, type: :controller do
  routes { Blacklight::Engine.routes }

  describe 'index' do
    let(:one) { Search.create }
    let(:two) { Search.create }
    let(:three) { Search.create }

    it 'only fetches searches with ids in the session' do
      session[:history] = [one.id, three.id]
      get :index
      searches = assigns(:searches)
      expect(searches).to include(one)
      expect(searches).not_to include(two)
    end

    it 'tolerates bad ids in session' do
      session[:history] = [one.id, three.id, 'NOT_IN_DB']
      get :index
      searches = assigns(:searches)
      expect(searches).to include(one)
      expect(searches).to include(three)
    end

    it 'does not fetch any searches if there is no history' do
      session[:history] = []
      get :index
      searches = assigns(:searches)
      expect(searches).to be_empty
    end
  end
end
