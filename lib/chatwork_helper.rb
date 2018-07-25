require 'httpclient'

module ChatWorkHelper

  def speak(room, header, body=nil, footer=nil)
    url = 'https://api.chatwork.com/v2/rooms/'
    token = Setting.plugin_redmine_chatwork['token']
    content = create_body body, header, footer
    reqHeader = {'X-ChatWorkToken' => token}
    endpoint = "#{url}#{room}/messages"

    begin
      client = HTTPClient.new
      client.ssl_config.cert_store.set_default_paths
      client.ssl_config.ssl_version = :auto
      client.post_async(endpoint, "body=#{content}", reqHeader)

    rescue Exception => e
      Rails.logger.info("cannot connect to #{endpoint}")
      Rails.logger.info(e)
    end
  end

  def create_body(body=nil, header=nil, footer=nil)
    msg_title = ''
    msg_body = ''
    if header
      msg_title = '[title]'
      msg_title << '[' + header[:status] + ']' if header[:status]
      msg_title << header[:title] if header[:title]
      msg_title << ' / ' + header[:project] if header[:project]
      msg_title << '[/title]'

      msg_body << header[:url] + "\n" if header[:url]
      msg_body << l(:field_updated_by) + ': ' + header[:by] if header[:by]
      msg_body << '  ' + l(:field_assigned_to) + ': ' + header[:assigned_to] if header[:assigned_to]
      msg_body << '  ' + l(:field_author) + ': ' + header[:author] if header[:author]
    end
    msg_body << '[hr]' + body if body && ! body.empty?

    msg_footer = ''
    msg_footer << '[hr]' + footer if footer && ! footer.empty?

    CGI.escape '[info]' + msg_title + msg_body + msg_footer + '[/info]'
  end

  def escape(msg)
    msg.to_s
  end

  def object_url(obj)
    if Setting.host_name.to_s =~ /\A(https?\:\/\/)?(.+?)(\:(\d+))?(\/.+)?\z/i
      host, port, prefix = $2, $4, $5
      Rails.application.routes.url_for(obj.event_url({
           :host => host,
           :protocol => Setting.protocol,
           :port => port,
           :script_name => prefix
       }))
    else
      Rails.application.routes.url_for(obj.event_url({
           :host => Setting.host_name,
           :protocol => Setting.protocol
       }))
    end
  end

  def check_disabled(proj)
    return nil if proj.blank?

    cf = ProjectCustomField.find_by_name("ChatWork Notice Disabled")
    state = proj.custom_value_for(cf).value rescue nil
    return false if state.nil? or state == '0'
    true
  end

  def room_for_project(proj)
    return nil if proj.blank?

    cf = ProjectCustomField.find_by_name("ChatWork Room URL")

    val = [
        (proj.custom_value_for(cf).value rescue nil),
        (room_for_project proj.parent),
        Setting.plugin_redmine_chatwork['room'],
    ].find { |v| v.present? }

    return nil unless val

    return val if val =~ /^\d+$/

    rid = val.match(/#!rid\d+/)
    return nil unless rid
    rid[0][5..val.length]
  end

  def detail_to_field(detail)
    if detail.property == "cf"
      key = CustomField.find(detail.prop_key).name rescue nil
      title = key
    elsif detail.property == "attachment"
      key = "attachment"
      title = I18n.t :label_attachment
    else
      key = detail.prop_key.to_s.sub("_id", "")
      title = I18n.t "field_#{key}"
    end

    value = escape detail.value.to_s

    case key
      when "tracker"
        tracker = Tracker.find(detail.value) rescue nil
        value = escape tracker.to_s
      when "project"
        project = Project.find(detail.value) rescue nil
        value = escape project.to_s
      when "status"
        return ''
      when "priority"
        priority = IssuePriority.find(detail.value) rescue nil
        value = escape priority.to_s
      when "category"
        category = IssueCategory.find(detail.value) rescue nil
        value = escape category.to_s
      when "assigned_to"
        user = User.find(detail.value) rescue nil
        value = escape user.to_s
      when "fixed_version"
        version = Version.find(detail.value) rescue nil
        value = escape version.to_s
      when "attachment"
        attachment = Attachment.find(detail.prop_key) rescue nil
        value = "<#{object_url attachment}|#{escape attachment.filename}>" if attachment
      when "parent"
        issue = Issue.find(detail.value) rescue nil
        value = "<#{object_url issue}|#{escape issue}>" if issue
    end

    value = "-" if value.empty?
    result = "\n#{title}: #{value}"
    result
  end
end
