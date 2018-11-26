require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  
  def setup
  	@user = users(:michael)
  end

  test "unsuccessful edit" do
  	log_in_as(@user)                                                 #ログインする
  	get edit_user_path(@user)                                        #editページにリダイレクト
  	assert_template 'users/edit'                                     #editページが出るのかテスト
  	patch user_path(@user),params:{user:{ name: "",                  #4箇所間違える編集をする
  							email: "foo@invalid",
  							password: "foo",
  							password_confirmation: "bar"}}
  	assert_template 'users/edit'                                     #編集に失敗するのでちゃんとeditにrenderするのかテスト
  	assert_select "div.alert", "The form contains 4 errors ."        #errorが四つ出るのかテスト
  end

  test "successful edit with friendly forwarding" do
  	get edit_user_path(@user)                                        #editページにgetで飛ぶ
  	log_in_as(@user)                                                 #ログインする
  	assert_redirected_to edit_user_url(@user)                        #入りたかったeditページにリダイレクトするかチェック
  	name = "Foo Bar"
  	email = "foo@bar.com"
  	patch user_path(@user), params:{user:{name: name,                #パウワード無しのeditデータをpatchで送信
  							email: email,
  							password:  "",
  							password_confirmation:  ""}}
  	assert_not flash.empty?                                          #flash.empty? -> flashが空ならtrue その逆なのでflashに何か入ったらtrue
  	assert_redirected_to @user                                       #userのshowページにリダイレクトするかチェック
  	@user.reload                                                     #データベースからユーザーモデルのレコードを再取得する
  	assert_equal name, @user.name                                    #test内の変数nameと@user
  	assert_equal email, @user.email                                  #同様にemailも確認
  end
end
