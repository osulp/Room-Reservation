class Admin::CleaningRecordsController < AdminController
  def index
    @cleaning_records = CleaningRecord.order(:start_date).decorate
    respond_with(@cleaning_records)
  end

  def new
    @cleaning_record = CleaningRecord.new.decorate
    respond_with(@cleaning_record)
  end


  # TODO: Figure out why respond_with isn't rendering new correctly.
  def create
    params = cleaning_record_params
    params[:weekdays] ||= []
    params[:weekdays].reject!{|x| x.blank?}
    @cleaning_record = CleaningRecord.new(params)
    if @cleaning_record.save
      flash[:success] = 'Succesfully Created Cleaning Record'
      redirect_to admin_cleaning_records_path
    else
      build_errors
      @cleaning_record = @cleaning_record.decorate
      render :action => 'new'
    end
  end

  def edit
    @cleaning_record = CleaningRecord.find(params[:id]).decorate
    respond_with @cleaning_record
  end


  # TODO: Figure out why respond_with isn't rendering new correctly.
  def update
    @cleaning_record = CleaningRecord.find(params[:id])
    params = cleaning_record_params
    params[:weekdays] ||= []
    params[:weekdays].reject!{|x| x.blank?}
    if @cleaning_record.update(params)
      flash[:success] = 'Cleaning Record Updated'
      redirect_to admin_cleaning_records_path
    else
      build_errors
      @cleaning_record = @cleaning_record.decorate
      render :action => 'edit'
    end
  end

  def destroy
    @cleaning_record = CleaningRecord.find(params[:id])
    flash[:success] = 'Cleaning record deleted' if @cleaning_record.destroy
    @cleaning_record = @cleaning_record.decorate
    respond_with(@cleaning_record, :location => admin_cleaning_records_path)
  end

  private

  def build_errors
    flash[:error] = @cleaning_record.errors.full_messages
    flash[:error] |= @cleaning_record.cleaning_record_rooms.map{|x| x.errors.full_messages}.flatten
    flash[:error] |= @cleaning_record.rooms.map{|x| x.errors.full_messages}.flatten
    flash[:error] = flash[:error].to_sentence
  end

  def cleaning_record_params
    params.require(:cleaning_record).permit(:start_date, :end_date, :start_time, :end_time,  {:room_ids => [], :weekdays => []})
  end
end
