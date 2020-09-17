# frozen_string_literal: true

module WorkflowMetadata
  extend ActiveSupport::Concern
  include CableReady::Broadcaster
  CHECK_IN_INCREMENT = 5 # can checkin every 5% of the time

  def abort?
    return unless checkin?

    batch.reload.cancelled?
  end

  # this enables a throttle on the frequency of requests from jobs
  # i.e. rather than check after every row, check after N% of rows
  def checkin?
    # (((step_num_row.to_f / batch.num_rows) * 100) % 5).zero?
    (((step_num_row.to_f / 10) * 100) % CHECK_IN_INCREMENT).zero?
  end

  def current_runtime
    ((completed_at || Time.current.utc) - started_at).round
  end

  def done?
    done
  end

  def errors?
    step_errors.positive?
  end

  def increment_error!
    update(step_errors: step_errors + 1)
  end

  def increment_row!
    update(step_num_row: step_num_row + 1)
  end

  def increment_warning!
    update(step_warnings: step_warnings + 1)
  end

  def percentage_complete?
    # (step_num_row * 100) / batch.num_rows
    (step_num_row * 100 / 10) # TODO: replace placeholder job
  end

  def running?
    batch.reload.running?
  end

  def update_header
    selector = '#header_' + ActionView::RecordIdentifier.dom_id(self)
    dom_html = status_renderer.render(
      partial: 'step/header', locals: { batch: batch.reload, step: self }
    )

    cable_ready['step'].morph(selector: selector, html: dom_html)
    cable_ready.broadcast
  end

  def update_progress
    return unless checkin?

    selector = '#progress_' + ActionView::RecordIdentifier.dom_id(self)
    dom_html = status_renderer.render(
      partial: 'step/progress', locals: { step: self }
    )

    cable_ready['step'].morph(selector: selector, html: dom_html)
    cable_ready.broadcast
  end

  def warnings?
    step_warnings.positive?
  end

  private

  # Renderer for realtime updates (uses Superuser so compatible with tests)
  def status_renderer
    ApplicationController.renderer_with_signed_in_user(User.superuser)
  end
end
