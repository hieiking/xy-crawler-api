---
title: API Reference

language_tabs: # must be one of https://git.io/vQNgJ
  - ruby

toc_footers:
  - <a href='https://github.com/lord/slate'>Documentation Powered by Slate</a>

includes:
  - errors

search: true
---

# 介绍

API 文档。

# V1

## 创建抓取商品

### HTTP 请求

`POST http://my-site/api/v1/products`

### 请求参数

参数名 | 是否必需 | 描述
------| --------| -------
id    |  否     | 商品 id，自增长属性|
name  |  是     | 商品名称，唯一|
keywords| 是    | 搜索关键词|
upper_p| 否    |价格上限|
lower_p| 否    |价格下限|
alarm_p| 否    |警报价格|
filter| 否     |过滤词|

### 响应

```json
{
  "product":
  {
    "id":1,
    "name":"wonder gallery",
    "keywords":"wonder gallery",
    "upper_p":2500,
    "lower_p":1800,
    "alarm_p":2000,
    "created_at":"2015-05-02T07:47:14.708Z",
    "updated_at":"2015-05-02T07:47:14.708Z"
   }
}
```

## 查看指定商品

### HTTP 请求

`GET http://my-site/api/v1/products/<id>`

### 响应
```json
{
  "product":
  {
    "id":1,
    "name":"wonder gallery",
    "keywords":"wonder gallery",
    "upper_p":2500,
    "lower_p":1800,
    "alarm_p":2000,
    "created_at":"2015-05-02T07:47:14.708Z",
    "updated_at":"2015-05-02T07:47:14.708Z"
   }
}
```