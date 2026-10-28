Rails.application.routes.draw do
  root to: redirect('/portal/applications')

  get '/health', to: 'health#show'
  post '/graphql', to: 'graphql#execute'

  scope '/portal', as: :portal do
    get  '/sign-in',  to: 'portal/sessions#new',     as: :sign_in
    post '/sign-in',  to: 'portal/sessions#create'
    delete '/sign-out', to: 'portal/sessions#destroy', as: :sign_out

    get  '/applications',     to: 'portal/applications#index',  as: :applications
    get  '/applications/new', to: 'portal/applications#new',    as: :new_application
    post '/applications',     to: 'portal/applications#create'

    get   '/applications/:reference',          to: 'portal/applications#show',     as: :application
    post  '/applications/:reference/submit',   to: 'portal/applications#submit',   as: :submit_application
    post  '/applications/:reference/withdraw', to: 'portal/applications#withdraw', as: :withdraw_application

    get  '/applications/:reference/corrections', to: 'portal/corrections#show',   as: :corrections
    post '/applications/:reference/corrections', to: 'portal/corrections#create'

    get  '/applications/:reference/inspections', to: 'portal/inspections#show',   as: :inspections
    post '/applications/:reference/inspections', to: 'portal/inspections#create'
  end

  scope '/staff', as: :staff do
    get '/', to: 'staff/dashboard#show', as: :dashboard
    get '/search', to: 'staff/searches#show', as: :search
  end

  scope '/hooks', as: :hooks do
    post '/zoning',     to: 'webhooks/zoning#create',     as: :zoning
    post '/cashiering', to: 'webhooks/cashiering#create', as: :cashiering
  end
end
