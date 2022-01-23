class Admin::Terminal::TerminalsController < Admin::Terminal::BaseController

  load_and_authorize_resource
  
  def index
    @terminals = Terminal.order(id: :asc).page(params[:page])
  end

  def show
    @terminal = Terminal.find(params[:id])
  end

  def new
  end

  def create
	  @terminal = Terminal.new(terminal_params)
    if @terminal.save
      notice = t("admin.terminals.new.success_notice")
      redirect_to admin_terminals_path, notice: notice
    else
      render :new
    end
  end

  def edit
  end

  def update 	
    if @terminal.update(terminal_params)
      notice = t("admin.terminals.edit.success_notice")
      redirect_to admin_terminals_path, notice: notice
    else
      render :edit
    end
  end

  def destroy
    if @terminal.destroy
      flash[:notice] = t("admin.terminals.destroy.success_notice")
    else
      flash[:error] = @terminal.errors.full_messages.join(",")
    end

    redirect_to admin_terminals_path
  end


  private

    def terminal_params
      attributes = [:code, :serial_number, :name, :description, :poll_id]
      params.require(:terminal).permit(*attributes)
    end

    def resource
      @terminal ||= Terminal.find(params[:id])
    end

end
