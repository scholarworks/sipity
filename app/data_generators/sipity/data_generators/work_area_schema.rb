module Sipity
  module DataGenerators
    # Responsible for defining the schema for building work areas.
    class WorkAreaSchema < Dry::Validation::Schema
      key(:name) { |name| name.filled? }
      key(:slug) { |slug| slug.filled? }
      key(:actions) do |actions|
        actions.array? do
          actions.each do |action|
            action.key(:name) { |name| name.str? }
            action.key(:states) do |states|
              states.array? do
                states.each do |state|
                  state.key(:name) { |name| name.str? }
                  state.key(:roles) do |roles|
                    roles.array? do
                      roles.each { |role| role.str? }
                    end
                  end
                end
              end
            end
          end
        end
      end
      key(:group_role_map) do |group_role_map|
        group_role_map.array? do
          group_role_map.each do |group_role|
            group_role.key(:group) { |group| group.str? }
            group_role.key(:role) { |role| role.str? }
          end
        end
      end
    end
  end
end
