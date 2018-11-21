require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest

	def setup
		@user = users(:michael)
	end

	test "login with invalid information" do
		get login_path													#ログイン用パスを開く
		assert_template 'sessions/new'									#新しいセッションのフォームが正しく表示されたことを確認する
		post login_path, params:{session: {email:"", password:""}}		#わざと無効なparamsハッシュを使ってセッション用パスにPOSTする
		assert_template 'sessions/new'									#新しいセッションのフォームが再度表示され、
		assert_not flash.empty?											#フラッシュメッセージが追加されることを確認
		get root_path													#別のページ (Homeページなど) にいったん移動する
		assert flash.empty?												#移動先のページでフラッシュメッセージが表示されていないことを確認する
	end

	test "login with valid information followed by logout" do
		get login_path													#ログイン用パスを開く
		post login_path, params: {session: {email: @user.email,			
							password: 'password'}}
		assert is_logged_in?											#ログインしているか確認
		assert_redirected_to @user 										#リダイレクト先が正しいかチェック
		follow_redirect!												#そのページに実際に移動
		assert_template 'users/show'									#showページが正しく表示されたことを確認
		assert_select "a[href=?]",login_path,count: 0					#渡したパターンに一致するリンクが０かどうかを確認する
		assert_select "a[href=?]",logout_path
		assert_select "a[href=?]",user_path(@user)
		delete logout_path
		assert_not is_logged_in?										#ログアウトしているか確認
		assert_redirected_to root_url									#リダイレクト先がちゃんとしているか確認
		follow_redirect!												#移動
		assert_select "a[href=?]",login_path
		assert_select "a[href=?]",logout_path, count:0
		assert_select "a[href=?]",user_path(@user), count:0
	end
end
