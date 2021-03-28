module IdentificationAttached
  extend ActiveSupport::Concern

  included do
    has_one_attached :identification
    validates :identification, content_type: [:png, :jpg, :jpeg, 'application/pdf']
  end
end