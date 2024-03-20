class AddIndicesToHyraxCounterMetrics < ActiveRecord::Migration[6.1]
  def change
    add_index :hyrax_counter_metrics, :worktype
    add_index :hyrax_counter_metrics, :resource_type
    add_index :hyrax_counter_metrics, :work_id
    add_index :hyrax_counter_metrics, :date
  end
end