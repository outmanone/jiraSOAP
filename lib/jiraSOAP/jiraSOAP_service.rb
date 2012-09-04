class JiraSOAP_Service < JIRA::JIRAService

  include Singleton
 
  attr_reader :_statuses
  attr_reader :_priorities
  attr_reader :_resolutions
  attr_reader :_issue_types
  attr_reader :_custom_fields
 
  def initialize
    #puts Rails.root
    auth=getAuth
    super auth["url"]
    self.login auth["username"],auth["password"]
       
  end
 
  def initBaseInfo
    #puts statuses
    if @_custom_fields.blank?
      @_statuses=self.statuses
      @_priorities=self.priorities
      @_resolutions=self.resolutions
      @_issue_types=self.issue_types
      @_custom_fields=self.custom_fields
    end
  end

  protected
  #it should return : {:url=>"",:username=>"",:auth=>"password"}
  def getAuth
    raise "let child class to implement."
  end
end
