class JIRA::Issue_new < JIRA::DynamicEntity

  # @return [String]
  add_attribute :id, 'id', :content

# @return [String]
  add_attribute :key, 'key', :content

  # @return [String]
  add_attribute :summary, 'summary', :content

  # @return [String]
  add_attribute :description, 'description', :content

  # @return [String]
  add_attribute :type, 'type', :content

  # @return [String]
  add_attribute :status, 'status', :content

  # @return [String]
  add_attribute :assignee, 'assignee', :content

  # @return [String]
  add_attribute :reporter, 'reporter', :content

  # @return [String]
  add_attribute :priority, 'priority', :content

  # @return [String]
  add_attribute :project, 'project', :content

  # @return [String]
  add_attribute :resolution, 'resolution', :content

  # @return [String]
  add_attribute :environment, 'environment', :content

  # @return [Number]
  add_attribute :votes, 'votes', :to_i

  # @return [Time]
  add_attribute :updated, 'updated', :to_iso_date

  # @return [Time]
  add_attribute :created, 'created', :to_iso_date

  ##
  # This is actually a Time object with no time resolution.
  #
  # @return [Time]
  add_attribute :duedate, 'duedate', :to_iso_date

  # @return [Array<JIRA::Version>]
  add_attribute :affectsVersions, 'affectsVersions', [:children_as_objects, JIRA::Version]

  # @return [Array<JIRA::Version>]
  add_attribute :fixVersions, 'fixVersions', [:children_as_objects, JIRA::Version]

  # @return [Array<JIRA::Component>]
  add_attribute :components, 'components', [:children_as_objects, JIRA::Component]

  # @return [Array<JIRA::CustomFieldValue>]
  add_attribute :customFieldValues, 'customFieldValues', [:children_as_objects, JIRA::CustomFieldValue]

  # @return [Array<String>]
  add_attribute :attachmentNames, 'attachmentNames', :contents_of_children

  ##
  # Get the value of a custom field given the custom field id, returns
  # nil if the issue does not have a value for that field.
  #
  # @param [String] id the custom field id (e.g. 'customfield_10150')
  # @return [JIRA::CustomFieldValue,nil]
  def custom_field id
    custom_field_values.find { |field_value| field_value.id == id }
  end

  def soapify_for msg
    msg.add 'priority', @priority_id
    msg.add 'type', @type_id
    msg.add 'project', @project_name

    msg.add 'summary', @summary
    msg.add 'description', @description

    msg.add 'components' do |submsg|
      (@components || []).each { |component|
        submsg.add 'components' do |component_msg|
          component_msg.add 'id', component.id
        end
      }
    end
    msg.add 'affectsVersions' do |submsg|
      (@affects_versions || []).each { |version|
        submsg.add 'affectsVersions' do |version_msg|
          version_msg.add 'id', version.id
        end
      }
    end
    msg.add 'fixVersions' do |submsg|
      (@fix_versions || []).each { |version|
        submsg.add 'fixVersions' do |version_msg|
          version_msg.add 'id', version.id end
      }
    end

    msg.add 'reporter', @reporter_username unless @reporter_username.nil?
    msg.add 'assignee', (@assignee_username || '-1')
    msg.add_complex_array 'customFieldValues', (@custom_field_values || [])

    msg.add 'environment', @environment unless @environment.nil?
    msg.add 'duedate', @due_date.xmlschema unless @due_date.nil?
  end
end
