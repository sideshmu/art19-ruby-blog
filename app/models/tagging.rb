class Tagging < ApplicationRecord
  # belongs_to :tag, counter_cache: taggings_count  
  belongs_to :tag, counter_cache: true
  belongs_to :article
end
