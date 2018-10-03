require 'redmine'

require_dependency 'redmine_chatwork/listener'
require_dependency 'issue_patch'

Redmine::Plugin.register :redmine_chatwork do
  name 'Redmine Chatwork'
  author 'Yoshiaki Tanaka'
  url 'https://github.com/wate/redmine_chatwork'
  author_url 'https://github.com/wate/'
  description 'A Redmine plugin to notify updates to ChatWork rooms'
  version '0.7.1'

  requires_redmine :version_or_higher => '3.4.0'

  settings :default => {
      'room' => nil,
      'token' => nil,
      'post_updates' => '1',
      'post_wiki_updates' => '1'
  },
  :partial => 'settings/chatwork_settings'
end

ActionDispatch::Callbacks.to_prepare do
	require_dependency 'issue'
	unless Issue.included_modules.include? RedmineChatWork::IssuePatch
		Issue.send(:include, RedmineChatWork::IssuePatch)
	end
end
