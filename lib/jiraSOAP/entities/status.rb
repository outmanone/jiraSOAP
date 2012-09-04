##
# Contains all the metadata for an issue's status.
class JIRA::Status < JIRA::IssueProperty
  add_attribute :id, 'id', :content
  add_attribute :name, 'name', :content
end
