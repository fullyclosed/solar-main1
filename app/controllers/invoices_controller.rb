require 'roo'
class InvoicesController < ApplicationController
  before_action :set_invoice, only: %i[ show edit update destroy ]
  before_action :authenticate_user!

  def index
    @pagy, @invoices = pagy(Invoice.all, items: 50)
  end

  def show
    if params[:download] == 'true'
        respond_to do |format|
          format.html
          format.pdf { render template: "invoices/invoice", pdf: "#{@invoice.payment_reference}",
            disposition: "attachment",
            page_size: "A4",
            margin: { top: 0, bottom: 0, left: 0, right: 0 }
          }
        end
      return
    end
    respond_to do |format|
      format.html
      format.pdf { render template: "invoices/invoice", pdf: "#{@invoice.payment_reference}" }
    end
  end


  def download
    require 'zip'
    #grab some test records
    if params[:end_date].present? && params[:start_date].present?
      @invoices = Invoice.where(:created_at => params[:start_date]..params[:end_date]).limit(5)
    else
      @invoices = Invoice.last(params[:last].to_i)
    end
    return if @invoices.empty?
    stringio = Zip::OutputStream.write_buffer do |zio|
        @invoices.each do |invoice|
          @invoice = invoice
          dec_pdf = WickedPdf.new.pdf_from_string(render_to_string(:template => 'invoices/invoice', :layout => false))
          zio.put_next_entry("#{invoice.document}.pdf")
          zio << dec_pdf
        end
      end
      stringio.rewind
      binary_data = stringio.sysread
      send_data(binary_data, :type => 'application/zip', :filename => "invoices.zip")
  end




  def new
    @invoice = Invoice.new
  end

  def edit
  end


  def create
    file =  params[:file]
    alert = false;

    extension = file.path.split('.').last
    
    if extension == "xlsx" || extension == "xls"
      
      if extension == "xls"
        sheet = Roo::Excel.new(file.path)
      end
      if extension == "xlsx"
        sheet = Roo::Excelx.new(file.path)
      end
      header = sheet.row(1)
      (2..sheet.last_row).map do |i|
        row = Hash[[header, sheet.row(i)].transpose]
        begin
          Invoice.create!(row)
        rescue ActiveRecord::RecordInvalid => e
          puts e.message
          alert = true;
        end
      end 
    end

    if extension == "csv"
      CSV.foreach(file.path, headers: true) do |row|
        begin
          Invoice.create!(row.to_hash)
        rescue ActiveRecord::RecordInvalid => e
          puts e.message
          alert = true;
        end
    end
  end
   


    if alert
      redirect_to invoices_path, alert: 'Some invoices were not created'
    else
      redirect_to invoices_path, notice: 'Invoices were successfully created'
    end

    # @invoice = Invoice.new(invoice_params)
    # respond_to do |format|
    #   if @invoice.save
    #     format.html { redirect_to invoice_url(@invoice), notice: "Invoice was successfully created." }
    #     format.json { render :show, status: :created, location: @invoice }
    #   else
    #     format.html { render :new, status: :unprocessable_entity }
    #     format.json { render json: @invoice.errors, status: :unprocessable_entity }
    #   end
    # end
  end
 
  def update
    respond_to do |format|
      if @invoice.update(invoice_params)
        format.html { redirect_to invoice_url(@invoice), notice: "Invoice was successfully updated." }
        format.json { render :show, status: :ok, location: @invoice }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @invoice.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @invoice.destroy

    respond_to do |format|
      format.html { redirect_to invoices_url, notice: "Invoice was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_invoice
      @invoice = Invoice.find(params[:id])
    end

    def invoice_params
      params.require(:invoice).permit(:controller)
    end
end
