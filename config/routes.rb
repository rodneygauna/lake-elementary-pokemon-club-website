Rails.application.routes.draw do
  get "home/index"
  get "bylaws", to: "home#bylaws"
  resource :session
  resources :passwords, param: :token
  resources :events do
    # Attendance tracking - admin only
    post "attendances/toggle/:student_id", to: "attendances#toggle", as: :toggle_attendance
  end
  resources :students do
    resources :user_students, only: [ :create ]
  end
  resources :user_students, only: [ :destroy ]

  # Public donor recognition page
  get "donors", to: "donors#public_index", as: :public_donors

  # Public resources page
  get "resources", to: "documents#public_index", as: :public_resources
  get "resources/:id/download", to: "documents#download", as: :resource_download

  # User profile management (users can edit their own profile)
  resource :user, only: [ :show, :edit, :update ] do
    get :email_preferences, on: :member
    patch :update_email_preferences, on: :member
  end

  # Admin management
  namespace :admin do
    resources :users
    resources :donors do
      resources :donations
    end
    resources :documents
    resources :seasons do
      member do
        post :bulk_enroll
      end
    end
    # Reports
    get "reports", to: "reports#index", as: :reports
    get "reports/attendance", to: "reports#attendance_report", as: :attendance_report
  end

  # Student season management (admin only)
  resources :students, only: [] do
    namespace :admin do
      resources :student_seasons, only: [ :create, :destroy ]
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#index"
end
