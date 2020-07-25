---
title: 'python学习笔记'
date: 2017-10-11 20:54:36
tags: [python,学习总结]
published: true
hideInList: false
feature: /post-images/python-xue-xi-bi-ji.jpg
---

### 字符串 

`有些情况下是有很多转义字符的,可以这样写,好处是可以省去写繁琐的反斜杠...`
```python
print r''' "哈哈哈哈哈😄",\\\\ 6666%%%% "U" "u" '''
```
打印中文, u'''.... '''[](link)
```python
print(u'我就能打中文,怎么了');//单行
//我就能打中文,怎么了 
#-*- coding: utf-8 -*-
print (u'''静夜思
床前明月光，
疑是地上霜。
举头望明月，
低头思故乡。''')///多行

静夜思
床前明月光，
疑是地上霜。
举头望明月，
低头思故乡。
```

<!-- more -->

### 一些基本数据类型的互相转换
```python
	
int(x [,base ])         将x转换为一个整数    
long(x [,base ])        将x转换为一个长整数    
float(x )               将x转换到一个浮点数    
complex(real [,imag ])  创建一个复数    
str(x )                 将对象 x 转换为字符串    
repr(x )                将对象 x 转换为表达式字符串    
eval(str )              用来计算在字符串中的有效Python表达式,并返回一个对象    
tuple(s )               将序列 s 转换为一个元组    
list(s )                将序列 s 转换为一个列表    
chr(x )                 将一个整数转换为一个字符    
unichr(x )              将一个整数转换为Unicode字符    
ord(x )                 将一个字符转换为它的整数值    
hex(x )                 将一个整数转换为一个十六进制字符串    
oct(x )                 将一个整数转换为一个八进制字符串   
 
 
chr(65)='A'
ord('A')=65
 
int('2')=2;
str(2)='2'


```


### if-else

- 缩进请严格按照Python的习惯写法：`4个空格`，不要使用Tab，更不要混合Tab和空格，否则很容易造成因为缩进引起的语法错误。`如果你在Python交互环境下敲代码，还要特别留意缩进，并且退出缩进需要多敲一行回车`

- if - else
```python
score = 55
if score >= 60:
    print 'passed'
else:
    print 'failed'
```
- if - elif - else 多分支判断
```python
score = 85

if score >= 90:
    print 'excellent'
elif score >= 80:
    print 'good'
elif score >= 60:
    print 'passed'
else:
    print 'failed'
```



### 循环语句相关

for循环遍历
```python
L = [75, 92, 59, 68]
sum = 0.0
for num in L:
    sum += num    
print sum / 4
```

while循环
```python
//求100以内的奇数和
sum = 0
x = 1
while x < 100:
    if x % 2: 
        sum += x
    x += 1
print sum
```

```python
/**利用 "while True" 无限循环配合 "break" 语句，计算 1 + 2 + 4 + 8 + 16 + ... 的前20项的和。*/
sum = 0
x = 1
n = 1
while True:
  if n > 20:
      break
  sum += x
  x *= 2
  n += 1
print sum
```

///break 和continue
```python
sum = 0
x = 0
while True:
    x = x + 1
    if x > 100:
        break
    if x % 2 == 0 :
        continue
    sum += x
print sum
```

//对100以内的两位数，请使用一个两重循环打印出所有十位数数字比个位数数字小的数，例如，23（2 < 3）。
```python
for x in [ 1,2,3,4,5,6,7,8,9 ]:
    for y in [ 0,1,2,3,4,5,6,7,8,9 ]:
         if x < y :
             print x*10 + y
```


### python的 list 操作
创建和访问都很简单,其中有一个特殊一点就是-1下标代表最后一个元素,以此类推..

插入操作: append(item)和 insert (index,item)
```python
L = ['Adam', 'Lisa', 'Bart']
L.insert(0,'WGB')
print L

L.append('666')
print L

L.insert(-1,"888888888")
print L
```
删除操作: 
```python
L = ['Adam', 'Lisa', 'Paul','P','PAPP','PAD','Pel','PB','PLL','PCCl','Jaul','OOl','Qaul', 'Bart']
L.pop() //默认是移除最后一个
print L
L.pop(0) //第1项
print L
L.pop(1)//第2项
print L
L.pop(2)//第3项
print L
L.pop(3)//第4项
print L
```
替换操作: 
1. 把之前的元素删掉,再添加新元素取代它
2. 直接访问下标,修改它的值

```python
L = ['Adam', 'Lisa', 'Bart']
L.pop(1)
L.insert(1,'Job')
print L
L[1] = "iOS"
print L
//['Adam', 'Job', 'Bart']
//['Adam', 'iOS', 'Bart']
```


### dict 和 set的操作

和其他他语言一样,key是唯一的且不能为空,查找速度快,键值访问
```
dict的第一个特点是查找速度快，无论dict有10个元素还是10万个元素，查找速度都一样。而list的查找速度随着元素增加而逐渐下降。
不过dict的查找速度快不是没有代价的，dict的缺点是占用内存大，还会浪费很多内容，list正好相反，占用内存小，但是查找速度慢。
由于dict是按 key 查找，所以，在一个dict中，key不能重复。
```

- 通过键值访问修改value或者添加元素

set([1,2,3,4]) 就是set( )里面包装一个list,但是元素不能重复,和其他语言类似,用来排重还是阔以的
set 用 in操作符来判断是不是自己元素
```
s = set(['adam','bart'])
print 'adam' in s //True
print 'bart' in s //True
print 'Bart' in s //False
```

判断月份是不是对的,如果使用if-else将会很繁琐
```
months = set(['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'])
x1 = 'Feb'
x2 = 'Sun'

if x1 in months:
    print 'x1: ok'
else:
    print 'x1: error'

if x2 in months:
    print 'x2: ok'
else:
    print 'x2: error'
```

遍历set 
```
///请用 for 循环遍历如下的set，打印出 name: score 来。
s = set([('Adam', 95), ('Lisa', 85), ('Bart', 59)])
for t in s:
    print t[0],":",t[1]
    
/** log: */

Lisa : 85
Adam : 95
Bart : 59

```

set也有add和remove操作
```
///不能添加重复的元素,否则为无效操作
>>> s = set([1, 2, 3])
>>> s.add(4)
>>> print s
set([1, 2, 3, 4])
```
```
///移除操作针对已有的元素进行删除,移除不存在的元素时会报错
>>> s = set([1, 2, 3, 4])
>>> s.remove(4)
>>> print s
set([1, 2, 3])
```

### python 网络请求相关

```
urlopen一般可以接受三个参数：
urlopen(url, data, timeout)

第一个参数url即为URL
第二个参数data是访问URL时要传送的数据，默认为None
第三个timeout是设置超时时间，默认为 socket._GLOBAL_DEFAULT_TIMEOUT
```

修改请求头: 找到Google Chrome打开开发者工具,找到network , 然后刷新网页,查看请求头,把请求头copy出来进行调试  或者直接 浏览器打开
`http://httpbin.org/headers` 测试header的一个工具站点.
将headers组装进Request对象中 
```python
import urllib.request
from  urllib.request import  Request

headers = {
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8",
    "Accept-Encoding": "gzip, deflate",
    "Accept-Language": "zh-CN,zh;q=0.8,en;q=0.6",
    "Connection": "close",
    "Host": "httpbin.org",
    "Upgrade-Insecure-Requests": "1",
    "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.100 Safari/537.36"
  }


req = Request('http://httpbin.org/headers',headers=headers)
resp=urllib.request.urlopen(req)
print (resp.read().decode('utf-8'))
```

#### 使用Get方法访问
携带一些信息访问一些网页
```python
import  urllib.request
import  urllib.parse

query = {

    'q' : "火影忍者"
}

base_url="https://www.bing.com/search?"

url = base_url + urllib.parse.urlencode(query=query)

html = urllib.request.urlopen(url).read().decode('utf-8')

print(html)

```


#### POST访问
```	python
import urllib.request
import urllib.parse
from urllib.request import  Request

data = urllib.parse.urlencode({
    "q":"python",
    "name":"wgb",
    "action": "two click 666"
})

base_url = "http://httpbin.org/post"
req = Request(base_url,data=bytes(data,"utf-8"))
html = urllib.request.urlopen(req).read().decode('utf-8')
print(html)

```

[用于测试: 国内免费代理IP](http://www.xicidaili.com)

### 设置代理
```python
from urllib.request import ProxyHandler, build_opener

proxy_handler = ProxyHandler({
    'http': 'http://122.72.32.74:80',
})
opener = build_opener(proxy_handler)
response = opener.open('http://www.baidu.com')
print(response.read())

```

#### cookies

```
import http.cookiejar, urllib.request

cookies = http.cookiejar.CookieJar()
handler = urllib.request.HTTPCookieProcessor(cookies)
opener = urllib.request.build_opener(handler)
response = opener.open('http://www.baidu.com')
for cookie in cookie:
    print(cookie.name + "="+ cookie.value)
```

### 异常处理

- URLError
```
import urllib.request
import urllib.error

try:
    response = urllib.request.urlopen('http://nd.com') # 不存在
except urllib.error.URLError as e:
    print(e.reason)
else:
    html = response.read().decode('utf-8')
    print(html)
```

- HTTPError
```
import urllib.request
import urllib.error

try:
    response = urllib.request.urlopen('http://nd.com') # 不存在
except urllib.error.HttpError as e:
    print(e.reason)
else:
    html = response.read().decode('utf-8')
    print(html)
```


### 正则的使用` import re`
```python
import  re
 print(re.match("123","123wqwfsdoonsnssms").group())#从起始位置开始匹配,没有在起始位置则none
print(re.search("123","23sdd123kkkddl").span())# 返回第一个匹配结果的范围

```

#### re.compile函数
 有时候，我们可能会在代码中大量重复使用相同的模式，这时我们可以将正则字符串编译成正则对象，以便于复用该匹配模式。
```
string  = "fjfjkks12345skisnn56777kkjsns #$%fi~~````"
pattern = re.compile('(\d+)')
# result = re.search(pattern,string)
# print(result.group())

result = re.findall(pattern,string)
print(result)


```

#### 爬取糗事百科的段子~
```python
import re
import  urllib.request
import random
from  urllib.request import  Request

user_agent = ['Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.100 Mobile Safari/537.36',
              'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.100 Safari/537.36'
              ]
headers = { "User-Agent" : random.choice(user_agent)}

urlString = "https://www.qiushibaike.com/"
request = Request(urlString,headers=headers)
htmlString = urllib.request.urlopen(request).read().decode('utf-8')
# print(htmlString)
pattern = re.compile('<div\s*?class="content".*?<span>(.*?)</span>',re.S)
result = re.findall(pattern,htmlString)
for res in result:
    res = re.sub('<br/>','',res)
    res = res.strip()
    print(res+'\n')
```

#### 百思不得姐的段子
```python
import re
import  urllib.request
import random
from  urllib.request import  Request

user_agent = ['Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.100 Mobile Safari/537.36',
              'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.100 Safari/537.36'
              ]
headers = { "User-Agent" : random.choice(user_agent)}

urlString = "http://www.budejie.com/text/"
request = Request(urlString,headers=headers)
htmlString = urllib.request.urlopen(request).read().decode('utf-8')
# print(htmlString)
pattern = re.compile('<a href="/detail-\d+.html">(.*?)</a>',re.S)
result = re.findall(pattern,htmlString)
for res in result:
    res = re.sub('<br/>','',res)
    res = res.strip()
    print(res+'\n')

```

###### 正则技巧是需要取得的内容使用 `(.*?)`正则匹配, `\d+`代表一串数字若干, `.*?`代表除了换行符外的其他任意字符...
`玩这个东西,对于正则一定要烂熟于心啊`


#### 时需要数据组装或者数据改造
```python

#coding:utf-8
import re
import  urllib.request
import random
from  urllib.request import  Request

user_agent = ['Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.100 Mobile Safari/537.36',
              'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.100 Safari/537.36'
              ]
headers = { "User-Agent" : random.choice(user_agent)}

urlString = "http://www.budejie.com/text/"
request = Request(urlString,headers=headers)
htmlString = urllib.request.urlopen(request).read().decode('utf-8')
# print(htmlString)
pattern1 = re.compile('<a href="/detail-\d+.html">(.*?)</a>',re.S) # 获取内容
pattern2 = re.compile('<a href="/user/others-\d+.html" class="u-user-name" target="_blank">(.*?)</a>')#获取用户名

result1 = re.findall(pattern1,htmlString)
result2 = re.findall(pattern2,htmlString)

# index,value in enumerate(l)

# result1 len = 44
# result2 len = 20
# 越界操作了咋办---->反过来写呗 没有名字的不显示不可以嘛

for index,nickName in enumerate(result2):
    # print(index,value)
    value = result1[index]
    value = re.sub('<br/>','',value)
    value = value.strip()
    print('作者: ' + nickName + "\n" + "段子: " + value + '\n')

```

##  几行代码简单生成词云 (实践)

#### 1. 准备文本文件,也就是文章或者大量的词语,用于分词系统切割,然后进行分析,词频高的会展示出来字体高亮且加粗加大
####  2. pycharm里使用pip包管理工具,类似于iOS中的cocoapods般的存在, 先安装几个库`matplotlib`,`wordcloud`,`jieba`
```python
sudo brew install pip ///安装pip
sudo easy_install pip ///以上两种方式均可

```
#### 3. 开始写代码
- 把第三方库引入
- 读取文本
- 切割文本即分词
- 设置词云属性
- 渲染文本为词云
- 展示即完成

```python
import matplotlib.pyplot as plt
from wordcloud import WordCloud
import jieba

text_from_file_with_apath = open('/Users/wangguibin/Desktop/ciyun.txt').read()

wordlist_after_jieba = jieba.cut(text_from_file_with_apath, cut_all=True)
wl_space_split = " ".join(wordlist_after_jieba)

my_wordcloud = WordCloud(background_color = 'white',    # 设置背景颜色
                font_path = '/Library/Fonts/Songti.ttc',# 设置字体格式，如不设置显示不了中文
                max_font_size = 50,            # 设置字体最大值
                random_state = 10,            # 设置有多少种随机生成状态，即有多少种配色方案
                ).generate(wl_space_split)

plt.imshow(my_wordcloud)
plt.axis("off")
plt.show()
```


 **先写这么多,后续有时间继续探索,人生苦短,我用python**
