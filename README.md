chef-repo
=========
### Chefインストール
 $ curl -L https://www.opscode.com/chef/install.sh | sudo bash  
 $ sudo gem install knife-solo  
 $ knife configure  
  
### Vagrant
 $ ssh HOGE で入れますか？  
 入れなかったら、 $ vagrant ssh-config --host HOGE >> ~/.ssh/config
 
 $ ssh HOGE  
 $ sudo yum -y install rsync  
 $ exit

### レシピ流す
 $ cd HOGE  
 $ git clone https://github.com/hakopako/chef-repo.git  
 $ cd chef-repo  
 $ knife solo cook HOGE
