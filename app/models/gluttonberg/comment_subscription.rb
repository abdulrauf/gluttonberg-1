module Gluttonberg
  class CommentSubscription < ActiveRecord::Base
    set_table_name "gb_comment_subscriptions"
    
    before_save    :generate_reference_hash
    belongs_to     :article
    
    def self.notify_subscribers_of(article , comment)
      subscribers = self.find(:all , :conditions => {:article_id => article.id})
      subscribers.each do |subscriber|
        unless subscriber.author_email == comment.writer_email
          Notifier.delay.comment_notification(subscriber , article , comment ) #.deliver # its using delayed job but i am setting sent time immediately
          comment.notification_sent_at = Time.now
          comment.save
        end
      end
    end
    
    def generate_reference_hash
      unless self.reference_hash
        self.reference_hash = Digest::SHA1.hexdigest(Time.now.to_s + self.author_email + self.article_id.to_s) 
      end
    end
      
  end
end