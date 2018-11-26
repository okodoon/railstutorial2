require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest
  
  def setup
  	ActionMailer::Base.deliveries.clear
  	@user = users(:michael)
  end

  test "password resets" do
    get new_password_reset_path												#password_resetsのnewアクションにgetで飛ぶ
    assert_template 'password_resets/new'									#password_resetsのnewが表示されているか確認
    # メールアドレスが無効
    post password_resets_path, params: { password_reset: { email: "" } }	#postでpassword_resets_path = password_resetsのcreateアクションに#emailを空っぽで送信
    assert_not flash.empty?													#何かフラッシュメッセージが出たらtrue
    assert_template 'password_resets/new'									#password_resetsのnewが表示されているか確認
    # メールアドレスが有効
    post password_resets_path,												#次はcreateに有効なemailアドレスを送る
         params: { password_reset: { email: @user.email } }					
    assert_not_equal @user.reset_digest, @user.reload.reset_digest			#@userのreset_digestとリロードしたreset_digestが異なることを確認# =>新しいreset_digestが生成される
    assert_equal 1, ActionMailer::Base.deliveries.size						#送信したメールの数は1なのか
    assert_not flash.empty?													#何かフラッシュメッセージが出たらtrue
    assert_redirected_to root_url 											#root_urlにリダイレクトするか確認
    # パスワード再設定フォームのテスト
    user = assigns(:user)													#:userインスタンス変数を検証
    # メールアドレスが無効
    get edit_password_reset_path(user.reset_token, email: "")				#editアクションにメールアドレスを空にして飛ぶ
    assert_redirected_to root_url  											#root_urlにリダイレクトするか確認
    # 無効なユーザー
    user.toggle!(:activated)												#activatedを復活
    get edit_password_reset_path(user.reset_token, email: user.email)		#tokenに無効な文字列を渡してeditアクションに飛ぶ
    assert_redirected_to root_url 											#root_urlにリダイレクトするか確認
    user.toggle!(:activated)												#activatedを復活
    # メールアドレスが有効で、トークンが無効
    get edit_password_reset_path('wrong token', email: user.email)			#invalidなトークンでeditページに
    assert_redirected_to root_url 											#root_urlにリダイレクト
    # メールアドレスもトークンも有効
    get edit_password_reset_path(user.reset_token, email: user.email)		#有効なトークンとメアドでeditに入る
    assert_template 'password_resets/edit'									#editページが表示されているか確認
    assert_select "input[name=email][type=hidden][value=?]", user.email 	#登録フォームが必要なのが揃っているか確認
    # 無効なパスワードとパスワード確認
    patch password_reset_path(user.reset_token),							#updateアクションにemailと揃わないパスワードを送る
          params: { email: user.email,
                    user: { password:              "foobaz",
                            password_confirmation: "barquux" } }
    assert_select 'div#error_explanation'									#エラーが出るか確認
    # パスワードが空
    patch password_reset_path(user.reset_token),							#次はパスワードをからにしてupdate
          params: { email: user.email,
                    user: { password:              "",
                            password_confirmation: "" } }
    assert_select 'div#error_explanation'									#エラーが出るか確認
    # 有効なパスワードとパスワード確認
    patch password_reset_path(user.reset_token),							#正しいパスでupdate
          params: { email: user.email,
                    user: { password:              "foobaz",
                            password_confirmation: "foobaz" } }
    assert is_logged_in?													#loginしているか確認
    assert_not flash.empty?													#フラッシュメッセージが出るか確認
    assert_redirected_to user 												#showページに飛ぶか確認
  end

  test "expired token" do
  	get new_password_reset_path
  	post password_resets_path,
  		params: {password_reset:{email: @user.email}}
  	@user = assigns(:user)
  	@user.update_attribute(:reset_sent_at, 3.hours.ago)
  	patch password_reset_path(@user.reset_token),
  		params:{email: @user.email,
  				user: {password: "foobar",
  					password_confirmation: "foobar"}}
  	assert_response :redirect
  	follow_redirect!
  	assert_match "expired", response.body
  end
end

