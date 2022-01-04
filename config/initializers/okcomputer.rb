require 'okcomputer'
require 'timeout'

# /status for 'upness', e.g. for load balancer
# /status/all to show all dependencies
# /status/<name-of-check> for a specific check (e.g. for nagios warning)
OkComputer.mount_at = 'status'
OkComputer.check_in_parallel = true

# REQUIRED checks, required to pass for /status/all
#  individual checks also avail at /status/<name-of-check>
OkComputer::Registry.register 'ruby_version', OkComputer::RubyVersionCheck.new

class TermsCheck < OkComputer::Check
  def check
    if Terms.current_term.blank?
      mark_failure
      mark_message 'The current term is blank'
    elsif Terms.future_terms.length != 2
      mark_failure
      mark_message "Expecting >= 2 future terms, found #{Terms.future_terms.length}"
    else
      mark_message "The current term is #{Terms.current_term.inspect} and the future terms are: #{Terms.future_terms.inspect}"
    end
  end
end
OkComputer::Registry.register 'terms_check', TermsCheck.new

ActiveSupport.on_load(:action_controller) do
  OkComputer::Registry.register 'reserve_mailer', OkComputer::ActionMailerCheck.new(ReserveMail)
  OkComputer::Registry.register 'report_mailer', OkComputer::ActionMailerCheck.new(Report)
end
