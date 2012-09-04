##
# Represents a field mapping.
class JIRA::Field < JIRA::NamedEntity
  add_attribute :id, 'id', :content
  add_attribute :name, 'name', :content
end
