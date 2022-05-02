class CreateArticlesTagsJoinTable < ActiveRecord::Migration[7.0]
  def change
    create_join_table :articles, :tags do |t|
      t.index :article_id
      t.index :tag_id
    end
  end
end
