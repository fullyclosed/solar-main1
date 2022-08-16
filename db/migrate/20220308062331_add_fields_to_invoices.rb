class AddFieldsToInvoices < ActiveRecord::Migration[7.0]
  def change
    add_column :invoices, :document, :string
    add_column :invoices, :scope, :string
    add_column :invoices, :task, :string
    add_column :invoices, :description, :string
    add_column :invoices, :issue_date, :string
    add_column :invoices, :due_date, :string
  end
end
