require "administrate/base_dashboard"

class AnnouncementDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::String,
    kind: Field::Select.with_options(collection: Announcement::TYPES),
    title: Field::String,
    description: Field::Text,
    published_at: Field::DateTime,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :id,
    :kind,
    :title,
    :published_at
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :id,
    :kind,
    :title,
    :description,
    :published_at,
    :created_at,
    :updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :kind,
    :title,
    :description,
    :published_at
  ].freeze

  # Overwrite this method to customize how announcements are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(announcement)
  #   "Announcement ##{announcement.id}"
  # end
end
