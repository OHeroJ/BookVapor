<p align="center">
    <img src="https://user-images.githubusercontent.com/1342803/36623515-7293b4ec-18d3-11e8-85ab-4e2f8fb38fbd.png" width="320" alt="API Template">
    
</center>

## 环境

* Vapor3.1.0
* Swift4.2

## 项目规范

* [规范](https://github.com/vapor-community/styleguide)



## 功能

* [x]  用户注册、登入、密码找回, 适用于第三方登录
* [x] 支持微信小程序
* [x] 角色管理
* [x] 权限管理
* [x] 用户管理
* [x] 资源管理
* [ ] 其他, 完善中

## 安装

### 安装 swift & vapor

```
sudo apt-get install swift vapor

swift --version # 查看 swift 版本
```

### Postgresql

```
sudo apt-get install postgresql # 安装 Postgresql

createuser root -P  # 创建一个用户，密码 lai12345
createdb book -O root -E UTF8 -e # 创建数据库
```

### vapor fetch 问题

如果在 vapor fetch 的时候很慢，建议先运行 vapor clean, 然后执行 vapor run 如果你想看进度的话。可以

```
vapor clean 
vapor fetch 
ls -all    #看是否有.build 目录
cd .build  
du -sh *  # 这里就可以进行看.build 文件的大小的变化
```


## 预览

![](https://github.com/OHeroJ/BookCoin/blob/master/slide2.gif)

### 环境配置

#### 数据库配置

```
brew install postgresql  # 安装 psql
createuser root -P lai12345  # 创建数据库用户
createdb book -O root -E UTF8 -e # 创建数据库
``` 

#### 运行 vapor

```
brew install vapor/tap/vapor
vapor run 
```


### 下载 demo 

```
git clone https://github.com/OHeroJ/book.git
```

然后切到项目目录下

```
npm run dev
```




