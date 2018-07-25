namespace :redmine_chatwork do
  desc "Send reminders about issues due in the next days"
  task :reminder => :environment do
    require 'chatwork_helper'

    include Redmine::I18n
    include ChatWorkHelper

    I18n.locale = ENV['LOCALE'] || I18n.default_locale

    days = 7
    days = ENV['days'].to_i if ENV['days']

    if ENV['projects']
      project_ids = ENV['projects'].split(',').each(&:strip!)
      projects = Project.find_by_ids(project_ids)
    else
      projects = Project.all
    end

    trackers = ENV['trackers'].split(',').each(&:strip!) if ENV['trackers']
    return unless projects
    projects.each do |project|
      room = room_for_project project
      next unless room
      scope = Issue.where(:project_id => project.id)
      scope = scope.where(:tracker_id => trackers) if trackers && !trackers.empty?
      scope = scope.where("due_date <= ?", days.day.from_now.to_date)
      scope = scope.order(:due_date)
      reminder_issues = scope.includes(:tracker ,:status, :assigned_to, :project)
      if reminder_issues.size > 0
        msg_title = '[title]' + project.to_s + ' ' + l(:text_issue_reminder)+ '[/title]'
        msg_body = l(:mail_subject_reminder, :count => reminder_issues.size, :days => days) + "\n"

        reminder_issues.each do |issue|
          msg_body << '[hr][' + issue.status.to_s + '] ' + issue.to_s + "\n"
          msg_body << object_url(issue) + "\n"
          msg_body << l(:field_assigned_to) + ':' + issue.assigned_to.to_s
          msg_body << ' ' + l(:field_due_date) + ':' + issue.due_date.to_s + "\n"
        end
        body = '[info]' + msg_title + msg_body + '[/info]'
        puts body
      end
    end
  end
end
