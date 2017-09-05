# frozen_string_literal: true

ActiveAdmin.register_page 'Dashboard' do
  menu priority: 1, label: 'Dashboard'

  content title: 'Dashboard' do
    columns do
      column do
        panel 'Users' do
          h1 do
            span User.count
            span class: "small" do
              text = 'Reported (' + Report.users.distinct.count('reportable_id').to_s + ')'
              link = link_to(text, admin_reports_path("q[reportable_type_eq]": 'User'))
              safe_join ['- ', link]
            end
          end
        end
      end

      column do
        panel 'Cars' do
          h1 do
            span Car.count
            span class: "small" do
              text = 'Reported (' + Report.cars.distinct.count('reportable_id').to_s + ')'
              link = link_to(text, admin_reports_path("q[reportable_type_eq]": 'Car'))
              safe_join ['- ', link]
            end
          end
        end
      end

      column do
        panel 'Posts' do
          h1 do
            span Post.count
            span class: "small" do
              text = 'Reported (' + Report.posts.distinct.count('reportable_id').to_s + ')'
              link = link_to(text, admin_reports_path("q[reportable_type_eq]": 'Post'))
              safe_join ['- ', link]
            end
          end
        end
      end

      column do
        panel 'Comments' do
          h1 Comment.count
        end
      end
    end

    columns do
      column do
        panel 'Signups' do
          chart = Admin::Charts::SignupsChart.new(params[:signups_chart])
          render 'chart_signups', labels: chart.labels, data: chart.data
        end
      end

      column
    end
  end
end
