class Comment < ApplicationRecord
  include Approval, Visible

  belongs_to :article
end
