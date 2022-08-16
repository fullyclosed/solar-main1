class AddFieldsToInvoice < ActiveRecord::Migration[7.0]
  def change
    add_column :invoices, :name, :string
    add_column :invoices, :email, :string
    add_column :invoices, :payment_reference, :string
    add_column :invoices, :receiver_type, :string
    add_column :invoices, :amount_currency, :string
    add_column :invoices, :amount, :string
    add_column :invoices, :source_currency, :string
    add_column :invoices, :target_currency, :string
    add_column :invoices, :clabe, :string
    add_column :invoices, :id_number, :string
    add_column :invoices, :country_code, :string
    add_column :invoices, :city, :string
    add_column :invoices, :address, :string
    add_column :invoices, :postcode, :string
  end
end
