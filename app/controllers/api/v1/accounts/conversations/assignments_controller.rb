class Api::V1::Accounts::Conversations::AssignmentsController < Api::V1::Accounts::Conversations::BaseController
  # assign agent to a conversation
  def create
    # if params[:assignee_id] is not a valid id, it will set to nil, hence unassigning the conversation
    assignee = Current.account.users.find_by(id: params[:assignee_id])
    
    @agents ||= Current.account.users.order_by_full_name
    
    # Check if assignment of agent is valid
    assignment_maximum = 0
    assignment_maximum = assignee.account_users.first["limits"] if assignee.account_users.first["limits"] != nil
    Rails.logger.info "Assignment Maximum Limits: #{assignment_maximum}"
    
    conversation_count = ::Conversation.where(assignee_id: params[:assignee_id]).length
    Rails.logger.info "Assignment Conversation Count: #{conversation_count}"
    
    unless assignment_maximum > conversation_count
      Rails.logger.info "NEXT AGENT ASSIGNMENT"
      assignee = assignee_next(assignment_maximum: assignment_maximum, conversation_count: conversation_count, assignee: assignee)
    end
    
    @conversation.update_assignee(assignee)
    render json: assignee
  end
  
  def assignee_next(assignment_maximum:, conversation_count:, assignee:)
    
    next_assignee = @agents.where("account_users.id > ?", assignee["id"]).first
    Rails.logger.info "NEXT ASSIGNMENT ID: #{next_assignee["id"]}"
    return @agents.where("account_users.id > ?", assignee["id"]).first if assignment_maximum <= conversation_count
    # if assignment_maximum > conversation_count
      # Get next agent
    # next_assignee = @agents.where("account_users.id > ?", assignee["id"]).first
    next_assignment_maximum = next_assignee.account_users.first["limits"]
    next_conversation_count = ::Conversation.where(assignee_id: next_assignee["id"]).length
    
    assignee_next(assignment_maximum: next_assignment_maximum, conversation_count: next_conversation_count, assignee: next_assignee) unless next_assignment_maximum > next_conversation_count
  end
  
end
