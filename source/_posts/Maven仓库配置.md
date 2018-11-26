---
layout: post
title: "Maven仓库配置"
date: 2018-10-20 23:53
comments: true
tags: 
	- 技术
---


本文会介绍三种开发中可用的仓库配置
* 本地仓库
* 局域网仓库
* JCenter仓库
#### 一、本地仓库

1.配置需要生成仓库的module

```
apply plugin: 'maven'

uploadArchives{
    repositories.mavenDeployer{
        // 配置本地仓库路径，项目根目录下的repository目录中
        repository(url: uri('../repository'))
        pom.groupId = "com.rolan.eventplugin"// 唯一标识（通常为模块包名，也可以任意）
        pom.artifactId = "eventplugin" // 项目名称（通常为类库模块名称，也可以任意）
        pom.version = "1.0.0" // 版本号
    }
}

-----或者以下这种方式
apply plugin: 'maven-publish'
publishing {
    publications {
        mavenJava(MavenPublication) {
            groupId 'com.rolan.eventplugin'
            artifactId 'eventplugin'
            version '1.0.0'
            from components.java
        }
    }
}
publishing {
    repositories {
        maven {
            // change to point to your repo, e.g. http://my.org/repo
            url uri('../maven')//发布到本地目录中
        }
    }
}
```
2.发布

```
./gradlew publish

或者可以点击AndroidStudio右边的build中的uploadArchives选项
```
3.使用
  经过第二个步骤会在指定的目录下生成仓库，上面我们指定了项目的根目录下的maven
```
  //这里是插件编写的使用方式 如果是module.参考第二种或者第三种使用方法
【project/build.gradle】
 classpath 'com.rolan.eventplugin:eventplugin:1.0.0'
 
 
【app/build.gradle】
apply plugin: com.rolan.eventplugin.EventStonePlugin//需要写包名+类名

```
#### 二、局域网仓库

* 下载Nexus3
```
https://www.sonatype.com/download-oss-sonatype
选择系统对应版本的maven管理  

```
* 运行
```
mac:

  nexus.properties:配置相关属性
  ./nexus-2.11.3-01/bin/nexus start 启动服务
  
Windows：
   1.解压，选择不同操作系统对应的目录，如：nexus-2.14.8-01-bundle\nexus-2.14.8-01\bin\jsw\windows-x86-64
   
   2.点击console-nexus.bat启动nexus
```

* 管理

```
127.0.0.1:8081/nexus
默认账号：admin/admin123
```
* 发布

```
apply plugin: 'maven'
task androidSourcesJar(type: Jar) {//打包main目录下代码和资源的 task
    classifier = 'sources'
    from android.sourceSets.main.java.srcDirs
}

artifacts {//配置需要上传到maven仓库的文件
    archives androidSourcesJar
}

uploadArchives {//上传到Maven仓库的task
    repositories {
        mavenDeployer {
            //指定maven仓库url
            repository(url: "http://localhost:8081/nexus/content/repositories/releases/") {
            //nexus登录默认用户名和密码
            authentication(userName: "admin", password: "admin123")
            }
            pom.groupId = "com.rolan.eventplugin"
            pom.artifactId = "eventplugin" ）
            pom.version = "1.0.0" // 版本号
        }
    }
}
```
* 使用
```
allprojects {
    repositories {
        jcenter()
        maven { 
            url 'http://localhost:8081/nexus/content/repositories/releases/' 
        }
    }
}

implementation 'com.rolan.eventplugin:eventplugin:1.0.0'
```
#### 二、发布到JCenter

* 注册账号
```
https://bintray.com  这里要注册开发者账号 不要注册企业账号
```
* 创建组织(create organizations)

```
组织id: jyblife
组织名称：jyb
```
* 创建maven仓库
```
name:maven 写死maven
仓库类型选择maven
```
* add new package
```
name:eventplugin 对应后面publish里面的artifactId
version control: 0.0.1
```
* 项目配置
```
classpath 'com.novoda:bintray-release:0.9'

apply plugin: 'com.novoda.bintray-release'

publish {
    userOrg = '组织ID' 
    groupId = 'com.rolan.eventplugin' 
    artifactId = 'eventplugin' //项目名称 上面add new package中的name
    publishVersion = '1.0.2' //版本号
    desc = '' 
    website = '' //项目主页，可以不写
}
```
* 使用
```
allprojects {
    repositories {
    google()
    jcenter()
    maven { url ' https://dl.bintray.com/jyblife/maven' }
    }
}


implementation 'com.rolan.eventplugin:eventplugin:1.0.0'
```
* 常见错误
```
1.HTTP/1.1 404 Not Found
这个一般是 add new package中的name和publish中的artifactId不一致

2.按build提示关掉 lint
```






