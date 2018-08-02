module RedmineChatWork
  module IssuePatch
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
      base.class_eval do
        unloadable
        after_create :create_from_issue
        after_save :save_from_issue
      end
    end

    module ClassMethods
    end

    module InstanceMethods
      def create_from_issue
        @create_already_fired = true
        Redmine::Hook.call_hook(:redmine_chatwork_issues_new_after_save, {:issue => self})
        return true
      end

      def save_from_issue
        if !@create_already_fired && !self.current_journal.nil?
          Redmine::Hook.call_hook(:redmine_chatwork_issues_edit_after_save, {:issue => self, :journal => self.current_journal})
        end
        return true
      end
    end
  end
end
