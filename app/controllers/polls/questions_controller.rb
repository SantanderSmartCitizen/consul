require "json"
class Polls::QuestionsController < ApplicationController

  load_and_authorize_resource :poll
  load_and_authorize_resource :question, class: "Poll::Question"

  has_orders %w[most_voted newest oldest], only: :show

  def answer

    token = params[:token]

    case @question.answer_type
    when "simple", "star_rating", "smileys", "free_text"
      answer = @question.answers.find_or_initialize_by(author: current_user)

      answer.answer = params[:answer]
    
      answer.touch if answer.persisted?
      answer.save!
      answer.record_voter_participation(token)

      @answers_by_question_id = { @question.id => [params[:answer]] }

    when "multiple"
      # if answer.answer.present?
      #   answer_json = JSON.parse(answer.answer)
        
      #   logger.info("XXXXXXXXXXXXXXXXXXXXXXX")
      #   logger.info("answer_json = ")
      #   logger.info(answer_json)
      #   logger.info("XXXXXXXXXXXXXXXXXXXXXXX")

      # else
      #   answer.answer = params[:answer]

      #   logger.info("XXXXXXXXXXXXXXXXXXXXXXX")
      #   logger.info("params[:answer] = ")
      #   logger.info(params[:answer])
      #   logger.info("answer.answer = ")
      #   logger.info(answer.answer)
      #   logger.info("XXXXXXXXXXXXXXXXXXXXXXX")
      # end

      answer = @question.answers.find_or_initialize_by(author: current_user, answer: params[:answer])

      if answer.persisted?
        answer.destroy!
      else
        answer.save!
        answer.record_voter_participation(token)
      end

      @answers_by_question_id = { @question.id => @question.answers.where(author: current_user).pluck(:answer) }

    end




  end
end
