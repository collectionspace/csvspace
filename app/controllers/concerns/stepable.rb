# frozen_string_literal: true

module Stepable
  extend ActiveSupport::Concern

  included do
    protect_from_forgery except: %i[cancel reset] # tokens regenerated [CR]
    before_action :set_batch, except: :create
    before_action :set_batch_for_create, only: :create
  end

  def cancel!
    authorize @batch, policy_class: Step::Policy
    ApplicationJob.cancel!(@batch.job_id)
    @batch.cancel!
    @batch.update(job_id: nil)
  end

  def reset!
    authorize @batch, policy_class: Step::Policy
    @step.destroy
    @batch.retry!
  end

  def set_batch
    @batch = authorize Batch.find(params[:batch_id])
  end

  def set_batch_for_create
    @batch = authorize Batch.find(params[:batch_id]), policy_class: Step::Policy
  end
end
