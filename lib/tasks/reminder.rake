namespace :redmine_chatwork do
  desc "Send reminders about issues due in the next days"
  task :reminder => :environment do
    require 'chatwork_helper'

    include Redmine::I18n
    include ChatWorkHelper

    I18n.locale = ENV['LOCALE'] || I18n.default_locale

    days = 7
    days = ENV['days'].to_i if ENV['days']

    projects = Project.where(:status => 1)
    if ENV['projects']
      project_ids = ENV['projects'].split(',').each(&:strip!)
      projects = projects.where(:id => project_ids)
    end
    return unless projects
    tracker_ids = ENV['trackers'].split(',').each(&:strip!) if ENV['trackers']
    closed_status_ids = IssueStatus.where(:is_closed => true).pluck(:id)
    projects.each do |project|
      room = room_for_project project
      next unless room
      scope = Issue.where(:project_id => project.id)
      scope = scope.where(:is_private => 0)
      scope = scope.where(:tracker_id => tracker_ids) if tracker_ids && !tracker_ids.empty?
      scope = scope.where("due_date <= ?", days.day.from_now.to_date)
      scope = scope.where("status_id NOT IN (?)", closed_status_ids)
      scope = scope.order(:due_date)
      issues = scope.includes(:tracker ,:status, :assigned_to, :project)
      if issues.size > 0
        msg_title = '[title]' + l(:text_issue_reminder)+ ' / ' + project.to_s + '[/title]'
        msg_body = l(:mail_subject_reminder, :count => issues.size, :days => days) + "\n"
        issues.each do |issue|
          msg_body << '[hr][' + issue.status.to_s + '] ' + issue.to_s + "\n"
          msg_body << object_url(issue) + "\n"
          msg_body << l(:field_assigned_to) + ':' + issue.assigned_to.to_s
          msg_body << ' ' + l(:field_due_date) + ':' + issue.due_date.to_s + "\n"
        end
        content = '[info]' + msg_title + msg_body + '[/info]'
        puts content
        speak room, content
      end
    end
  end
end
