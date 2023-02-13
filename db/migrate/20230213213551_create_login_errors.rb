class CreateLoginErrors < ActiveRecord::Migration[5.0]
  def change
    create_table :login_errors do |t|
      t.string :issuer
      t.string :username
      t.string :error

      t.timestamps
    end
  end
end
