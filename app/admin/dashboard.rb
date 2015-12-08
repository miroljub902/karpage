ActiveAdmin.register_page 'Dashboard' do

  menu priority: 1, label: 'Dashboard'

  content title: 'Dashboard' do
    columns do
      column do
        panel 'Users' do
          h1 User.count
        end
      end

      column do
        panel 'Cars' do
          h1 Car.count
        end
      end

      column do
        panel 'Posts' do
          h1 Post.count
        end
      end

      column do
        panel 'Comments' do
          h1 Comment.count
        end
      end
    end
  end
end
