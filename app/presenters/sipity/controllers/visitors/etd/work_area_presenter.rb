module Sipity
  module Controllers
    module Visitors
      module Etd
        # Responsible for presenting the ETD work area to visitors
        class WorkAreaPresenter < Visitors::Core::WorkAreaPresenter
          def view_submitted_etds_url
            Figaro.env.curate_nd_url_for_etds!
          end
        end
      end
    end
  end
end
