require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest

  def setup
    @admin     = users(:michael)
    @non_admin = users(:archer)
  end

  test "index as admin including pagination and delete links" do
    log_in_as(@admin)														#adminとしてログイン
    get users_path															#indexにgetアクションで飛ぶ
    assert_template 'users/index'											#users/indexアクションで指定されたテンプレートが描写されているか確認
    assert_select 'div.pagination'											#ページネーションが存在しているか確認
    first_page_of_users = User.paginate(page: 1)							#index内の１ページ目がユーザーモデルのpaginate(page: 1)に対応するか確認
    first_page_of_users.each do |user|										#indexの１ページ目の中のデータを走査
      assert_select 'a[href=?]', user_path(user), text: user.name			#showページへのリンクがあるか
      unless user == @admin 												#adminじゃない限り
        assert_select 'a[href=?]', user_path(user), text: 'delete'			#deleteボタンが表示されるか確認
      end
    end
    assert_difference 'User.count', -1 do									#この処理の間にUser.countの数が-1になってたらtrue
      delete user_path(@non_admin)											#adminじゃないユーザーを消す
    end
  end

  test "index as non-admin" do
    log_in_as(@non_admin)													#adminじゃないユーザーとしてログイン
    get users_path															#indexページにgetアクションで飛ぶ
    assert_select 'a', text: 'delete', count: 0								#aタグのdeleteと書かれたものが０個であることを確認
  end
end