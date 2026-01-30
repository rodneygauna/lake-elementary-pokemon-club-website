class StudentSeason < ApplicationRecord
  # ----- Associations -----
  belongs_to :student
  belongs_to :season

  # ----- Validations -----
  validates :student_id, uniqueness: { scope: :season_id, message: "is already enrolled in this season" }

  # ----- Callbacks -----
  # None for now

  # ----- Scopes -----
  scope :ordered, -> { joins(:season).order("seasons.start_date DESC") }
  scope :for_season, ->(season) { where(season: season) }
  scope :for_student, ->(student) { where(student: student) }
end
