require 'test_helper'

class MicropostsControllerTest < ActionDispatch::IntegrationTest
  
  def setup
  	@micropost = microposts(:orange)
  end

  test "should redirect create when not logged in" do
  	assert_no_difference 'Micropost.count' do 									#Micropost.countが次の動作の中で変化しなければtrue
  		post microposts_path, params: {micropost: {content: "Lorem ipsum"}}		#createに投稿
  	end
  	assert_redirected_to login_url												#ログインしていないのでrootに飛ぶことを確認
  end

  test "should redirect destroy when not logged in" do
  	assert_no_difference 'Micropost.count' do  									#micropost.countが次の動作の中で変化しなければtrue
  		delete micropost_path(@micropost)										#投稿をdelete
  	end
  	assert_redirected_to login_url												#ログインしていないのでrootに飛ぶことを確認
  end

  test "should redirect destroy for wrong micropost" do
    log_in_as(users(:michael))
    micropost = microposts(:ants)
    assert_no_difference 'Micropost.count' do
      delete micropost_path(micropost)
    end
    assert_redirected_to root_url
  end
end
