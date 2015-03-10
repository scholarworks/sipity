#!/usr/bin/env ruby -wU

Sipity::Models::Processing::Strategy.all.each do |strategy|
  # Create a diagraph file with correct header information
  puts "Strategy: #{strategy.name}"
  puts "\tState:"
  strategy.strategy_states.each do |state|
    puts "\t\t#{state.name}"
    state.originating_strategy_state_actions.includes(:strategy_action, :strategy_state_action_permissions).each do |state_action|
      puts "\t\t\t#{state_action.strategy_action.name} -> #{state_action.strategy_state_action_permissions.map {|o| o.role.name }.inspect}"
    end
  end
  puts "\tAction:"
  strategy.strategy_actions.includes(:resulting_strategy_state).each do |action|
    if action.resulting_strategy_state.present?
      puts "\t\t#{action.name} -> #{action.resulting_strategy_state.name}"
    else
      puts "\t\t#{action.name}"
    end
  end
  puts "\tRole:"
  strategy.roles.each do |role|
    puts "\t\t#{role.name}"
  end
end
# ::Kernel.require 'byebug'; ::Kernel.byebug; true;
