---
title: '重新入门python爬虫到放弃'
date: 2018-09-12 22:32:29
tags: [python,效率,工具,学习总结]
published: true
hideInList: false
feature: /post-images/chong-xin-ru-men-python-pa-chong-dao-fang-qi.jpg
---

 > 最近项目不忙,乘此机会重新学习了一下python爬虫, 引发了一些思考,以下几点:
  
 1. 学习python真的是从众现象一时热吗? 学了有什么用,能改变现状吗? 如果不学又当如何,干点什么事情好呢 
 2. 学习python到了现在是个分水岭,几乎各方面的知识都有所涉及,到底是往哪个方向发展呢?

	- [x] 数据爬虫 (网络请求,页面解析,设置headers,代理ip,cookies,处理异常,ajax&&JS等动态页面数据的获取,伪装浏览器的访问等... requests,BeautifulSoup,xpath,正则,selenium,phantomJS,scrapy) 
	- [x] 数据分析可视化(pyecharts,Echarts,csv,json等)
	- [x] web前端 (Django ...)
	- [x] 后端 (数据库+服务器)
	- [x] 机器学习 (尚未涉及)
	- [x] 用来写工具/脚本 (用过别人写好的)
	- [x] 做游戏 (听说吃鸡就是python在做的)
	- [x] ...

3. 此时此刻,真的有些迷茫 , 但是人总是想着改变,只能说目前没有别的想法 ,学到一个是一个吧 ,但愿能派上用场吧


<!-- more -->

</br>
</br>
</br>

[TOC]

## 爬虫技巧
"人生苦短,我用`python`",也许是因为简单,也许是因为效率高... 这门语言已经风靡全球,有些学校已经列为必修课了。

### 下载器,使用什么框架爬取 (必备)
#### requests + BeautifulSoup (正则或者xpath也可)
- 用传统正则解析
```python
import urllib.request
from urllib.request import Request
from urllib.parse import urlencode
import re
import random

base_url = 'https://www.douban.com/doulist/3936288/'
pattern = re.compile('<div\sclass="title">\s.*?<a.*?>(.*?)</a>',re.S)
user_agent = [
    'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.1; WOW64; Trident/5.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; .NET4.0C; .NET4.0E)',
    'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.11 (KHTML, like Gecko) Chrome/23.0.1271.64 Safari/537.11',
]
for i in range(0,250,25):
    data = {
        'start':i
    }
    data = bytes(urlencode(data),'utf-8')
    headers = {'User-Agent':random.choice(user_agent)}
    requ = Request(base_url,data)
    html = urllib.request.urlopen(requ).read().decode('utf-8')
    results = re.findall(pattern,html)
    for result in results:
        result = re.sub('\n','',result)
        print(result)


```
- 用BeautifulSoup解析
```python
import  urllib.request
import  re
import  random
from urllib.request import  Request
from  urllib.parse import  urlencode
from  bs4 import  BeautifulSoup
import urllib.error


base_url = 'https://www.douban.com/doulist/3936288/'
user_agent = ['Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.1; WOW64; Trident/5.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; .NET4.0C; .NET4.0E)','Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.11 (KHTML, like Gecko) Chrome/23.0.1271.64 Safari/537.11']

for i in range(0,250,25):
    data = {
        'start':i
    }

data = bytes(urlencode(data),'utf-8') #参数打成二进制
header = { 'User-Agent' : random.choice(user_agent) } #请求头
req = Request(base_url,data,headers=header) # url + 参数+ 请求头伪装成浏览器
try:
    response = urllib.request.urlopen(req)
except urllib.error.HttpError as e:
    print(e.reason)
else:
    html = response.read().decode('utf-8')
    # print(html)

####注意以下是骚操作
    soup =BeautifulSoup(html,'html.parser')
    for item in soup.select('.title'): #类访问到div
        a = item.select('a')[0] #取到div里的a标签
        title = a.get_text() #获取a标签的文本内容
        print(title)

```

#### scrapy + BeautifulSoup (正则或者xpath也可)
[scrapy中文教程](https://scrapy-chs.readthedocs.io/zh_CN/0.24/intro/tutorial.html)
</br>

- BeautifulSoup
```python
html = = response.text
soup =BeautifulSoup(html) # 原理同上

```
- 正则 
```python
html = = response.text
pattern = re.compile('<div.?class="autho r.?>.?<a.?.?<a.?>(.?).?<div.?class'+ '="content".?title="(.?)">(.?)(.*?)<div class="stats.?class="number">(.?)',re.S)
items = re.findall(pattern,html)
for item in items:
     	print(item)
```
- xpath

```python
# 豆瓣电影Top250
import scrapy
import re
import json
from bs4 import  BeautifulSoup
import time

class  DoubanDianYing(scrapy.Spider):
            name = 'douban'
            allow_domains = ['movie.douban.com']
            datalist = []
            def start_requests(self):

                    headers = {
                        'User-Agent' : 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.106 Safari/537.36',
                    }


                    for page in range(0,251,25):
                        if page is not 0:
                             url = 'https://movie.douban.com/top250?start=%d&filter=' % page
                        else:
                             url = 'https://movie.douban.com/top250'
                        yield scrapy.Request(url,headers=headers)

            def parse(self, response):
                    # html = response.text
                    # bs = BeautifulSoup(html)
                    # 练习xpath
                    titles = response.xpath('//div/a/span[1]/text()').extract()
                    imgs = response.xpath('//div[@class="pic"]/a/img/@src').extract()
                    links = response.xpath('//div[@class="hd"]/a/@href').extract()
                    actors = response.xpath('//div[@class="bd"]/p/text()').extract()
                    descs = response.xpath('//span[@class="inq"]/text()').extract()
                    rating = response.xpath('//div[@class="star"]/span[@class="rating_num"]/text()').extract()
                    hots = response.xpath('//div[@class="star"]/span[4]/text()').extract()

                    for index in range(len(imgs)):
                             dic = {}
                             dic['title'] = titles[index]
                             dic['img'] = imgs[index]
                             dic['actors'] = str(actors[index]).strip().replace("\n","")
                             dic['rating'] = rating[index]
                             dic['hot'] = hots[index]
                             dic['link'] = links[index]
                             dic['desc'] = descs[index]
                             self.datalist.append(dic)
                    if len(self.datalist) == 250:
                        with open('dataSource.json', 'a+') as f:
                            json.dump(self.datalist, f, ensure_ascii=False, indent=4)

```

#### selenium + phantomJS + python3
```python
 from selenium import webdriver
 driver = webdriver.PhantomJS()
 driver.get('网址')
 html = driver.page_source # 解析原理同上

```
另外它也支持自己的解析语法: </br>
*参考博客* </br>
`参考崔庆才的博客`<https://cuiqingcai.com/2577.html> </br>
`参考知乎selenium文章`<https://zhuanlan.zhihu.com/p/29435831></br>
`参考selenium博客`<https://cuiqingcai.com/2599.html></br>
`selenium+python+PhantomJS的使用`<http://www.cnblogs.com/jinxiao-pu/p/6677782.html#_label0></br>

### 目标网站即URL (必须)
- 爬什么,心里得有数吧!
### 代理ip(可选)
- 网上一搜免费的代理ip一大堆,但是都不是很稳定的,用于学习还是可以满足的,商用的话还是建议花钱买稳定的好
### 使用cookies (可选)
- 参考[python学习笔记](http://www.wangguibin.club/#/posts/python学习笔记) 有提到代理ip怎么设置 headers怎么设置 cookies的读写删除

- 使用selenium管理cookies
```python
# cookies
from selenium import webdriver
browser = webdriver.Chrome()
browser.get('https://www.zhihu.com/explore')
print(browser.get_cookies())
browser.add_cookie({'name': 'name', 'domain': 'www.zhihu.com', 'value': 'germey'})
print(browser.get_cookies())
browser.delete_all_cookies()
print(browser.get_cookies())
```

### 如何处理AJAX和JS渲染的内容? 
- ajax 无非就是表单提交网络请求, 只要找到对应的标签节点和js函数,使用selenium的JS行为操作一番,把结果获取到进行解析即可
- JS同理
</br>

```python
# 执行JS
from selenium import webdriver

browser = webdriver.Chrome()
browser.get('https://www.zhihu.com/explore')
browser.execute_script('window.scrollTo(0, document.body.scrollHeight)')
browser.execute_script('alert("To Bottom")')
```

### 如何绕过反爬虫机制?
- 这里的反爬虫机制其实就是我们爬取数据的时候伪装成用户操作的行为一样就ok,频率和使用的硬件等信息要相似,验证码之类,或者弹窗之类的一般先模仿浏览器打开然后操作一步一步进行推进,最后到达想要的页面进行操作获取页面的数据 




[平时操练的代码已经托管在github上了](https://github.com/WangGuibin/PythonLife)

