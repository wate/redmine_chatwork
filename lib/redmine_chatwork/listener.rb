require 'chatwork_helper'

class ChatWorkListener < Redmine::Hook::Listener

  include ChatWorkHelper

  def controller_issues_new_after_save(context={})
    issue = context[:issue]
    room = room_for_project issue.project
    disabled = check_disabled issue.project

    return if disabled
    return unless room
    return if issue.is_private?

    header = {
        :project => escape(issue.project),
        :title => escape(issue),
        :url => object_url(issue),
        :assigned_to => escape(issue.assigned_to),
        :status => escape(issue.status.to_s),
        :by => escape(issue.author),
        :author => escape(issue.author)
    }

    body = escape issue.description if issue.description

    speak room, header, body
  end

  def controller_issues_edit_after_save(context={})
    issue = context[:issue]
    journal = context[:journal]
    room = room_for_project issue.project
    disabled = check_disabled issue.project

    return if disabled
    return unless room and Setting.plugin_redmine_chatwork['post_updates'] == '1'
    return if issue.is_private?
    return if not journal.notes

    header = {
        :project => escape(issue.project),
        :title => escape(issue),
        :url => object_url(issue),
        :author => escape(issue.author),
        :assigned_to => escape(issue.assigned_to.to_s),
        :status => escape(issue.status.to_s),
        :by => escape(journal.user.to_s)
    }

    body = escape journal.notes if journal.notes
    detail = journal.details.map { |d| detail_to_field d }
    footer = detail.join

    speak room, header, body, footer.strip
  end

  def controller_wiki_edit_after_save(context = {})
    return unless Setting.plugin_redmine_chatwork['post_wiki_updates'] == '1'

    project = context[:project]
    page = context[:page]
    room = room_for_project project
    disabled = check_disabled project

    return if disabled
    return unless room

    header = {
        :project => escape(project),
        :title => escape(page.title),
        :url => object_url(page)
    }

    body = l(:text_wiki_content_updated, :author => page.content.author)

    speak room, header, body
  end

end
