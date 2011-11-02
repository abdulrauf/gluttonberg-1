class BlogMigration < ActiveRecord::Migration 
  def self.up
    create_table :gb_blogs do |t|
      t.string :name, :null => false
      t.string :slug, :null => false
      t.text :description
      t.integer :user_id, :null => false
      t.column :state , :string
      t.boolean :moderation_required, :default => true
      t.datetime :published_at 
      t.timestamps
    end
    
    create_table :gb_articles do |t|
      t.string :slug, :null => false
      t.integer :blog_id, :null => false
      t.integer :user_id, :null => false
      t.integer :author_id, :null => false      
      t.column :state , :string #use for publishing
      t.column :disable_comments , :boolean , :default => false 
      t.datetime :published_at 
      t.timestamps
    end
    
    create_table :gb_comments do |t|
      t.text :body
      t.string :author_name
      t.string :author_email
      t.string :author_website
      t.references :commentable, :polymorphic => true
      t.integer :author_id
      t.boolean :moderation_required, :default => true
      t.boolean :approved, :default => false
      t.datetime :notification_sent_at
      t.timestamps
    end
    
    create_table :gb_comment_subscriptions do |t|
      t.integer :article_id
      t.string :author_name
      t.string :author_email
      t.string :reference_hash
      t.timestamps
    end
    
    create_table :gb_article_localizations do |t|
      t.string :title, :null => false
      t.text :excerpt
      t.text :body
      t.integer :featured_image_id
      t.column :article_id, :integer
      t.column :locale_id, :integer
      t.column :version, :integer
      t.timestamps
    end
    
    begin
      Gluttonberg::Blog.create_versioned_table
    rescue => e
      puts e
    end
    
    begin
      Gluttonberg::ArticleLocalization.create_versioned_table
    rescue => e
      puts e
    end
    
  end

  def self.down
    drop_table :gb_comments
    drop_table :gb_articles
    drop_table :gb_article_localizations
    drop_table :gb_blogs
    drop_table :gb_comment_subscriptions
  end
end
