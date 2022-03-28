require 'jwt'
class SatisfactionSurveysDigitalProvinceController < ApplicationController
  include PollsHelper

  layout "digital_province_terminal"

  before_action :load_terminal
  before_action :load_question

  load_and_authorize_resource class: "Poll"

  ::Poll::Answer # trigger autoload

  def index
  end

  def answer
    unless @error.present?
      logger.info "@question.answer_type= #{@question.answer_type}"
      case @question.answer_type
      when "simple", "multiple", "star_rating", "smileys", "free_text"
        answer = @question.answers.new(terminal: @terminal)
        answer.answer = params[:answer]
        answer.save!
        logger.info "se almacena answer"
      end

      redirect_to satisfaction_surveys_digital_province_index_path(locale: I18n.locale, t: params[:t], page: @current_page+1)
    end
  end

  private

    def load_terminal
      hmac_secret = "q3t6w9z$C&E)H@McQfTjWnZr4u7x!A%D"
      token = params[:t]

      logger.info "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
      logger.info "token= #{token}"

      begin
        decoded_token = JWT.decode token, hmac_secret, true, {algorithm: 'HS256'}
        payload = decoded_token.first
        logger.info "payload= #{payload}"

        terminal_code = payload['code']
        logger.info "terminal.code= #{terminal_code}"
        
        if terminal_code.present?
          # @terminal = Terminal.find_or_create_by!(code: terminal_code)
          @terminal = Terminal.find_by(code: terminal_code)
          unless @terminal.present?
            logger.error "El dispositivo '#{terminal_code}' no está registrado, contacte con el administrador"
            @error = "El dispositivo '#{terminal_code}' no está registrado, contacte con el administrador"
          else
            logger.info "terminal.id= #{@terminal.id}"
          end
        else
          logger.error "El dispositivo no puede registrarse correctamente, código de dispositivo obligatorio"
          @error = "El dispositivo no puede registrarse correctamente, código de dispositivo obligatorio"
        end
      rescue JWT::VerificationError
        logger.error "Se ha producido un error al verificar la firma, contacte con el administrador"
        @error = "Se ha producido un error al verificar la firma, contacte con el administrador"
      rescue JWT::ExpiredSignature
        logger.error "La firma ha expirado, recargue o reinicie la aplicación"
        @error = "La firma ha expirado, recargue o reinicie la aplicación"
      rescue Exception => e
        logger.error e
        @error = "Se ha producido un error, contacte con el administrador"
      end
      logger.info "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    end

    def load_question
      unless @error.present?
        @current_page = params[:page].to_i

        if @terminal.poll.present?
          @questions_count = @terminal.poll.questions.count
          if @questions_count > 0
            if @current_page > 0 && @current_page <= @questions_count
              @question = @terminal.poll.questions.order(:id).limit(1).offset(@current_page-1).first
            end
          else
            @error = "La encuesta asignada al dispositivo no contiene preguntas, contacte con el administrador"
          end
        else
          @error = "El dispositivo no tiene asignada ninguna encuesta, contacte con el administrador"
        end
      end
    end

end
