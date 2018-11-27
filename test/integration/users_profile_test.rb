require 'test_helper'

class UsersProfileTest < ActionDispatch::IntegrationTest
  include ApplicationHelper

  def setup
  	@user = users(:michael)
  end

  test "profile display" do
  	get user_path(@user)										#showページに飛ぶ
  	assert_template 'users/show'								#showページが表示されているか確認
  	assert_select 'title', full_title(@user.name)				#titleが存在しtitleがちゃんとしてるか確認
  	assert_select 'h1', text: @user.name						#h1が存在しuserネームのテキストがあるか
  	assert_select 'h1>img.gravatar'								#h1の中にgravatarというクラスのimgが存在するか
  	assert_match @user.microposts.count.to_s, response.body		#そのページのどこかしらにマイクロポストの投稿数が存在するのであれば、次のように探し出してマッチできる
  	assert_select 'div.pagination'								#ページネーションがあるかどうか
  	@user.microposts.paginate(page: 1).each do |micropost|
  		assert_match micropost.content, response.body			# そのページのどこかしらにマイクロポストのコンテントが存在するのであれば、次のように探し出してマッチできる。
  	end
  end
end
