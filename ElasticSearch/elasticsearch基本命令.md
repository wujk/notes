# elasticsearch基本命令
- 创建customer索引：
    -
        PUT /customer?pretty
        
        返回：
        {
          "acknowledged" : true,
          "shards_acknowledged" : true,
          "index" : "customer"
        }
- 创建customer索引：带分片信息
    -
        PUT /customer?pretty
        {
          "settings": {
            "number_of_shards": 12,  #分片个数，在创建索引不指定时 默认为 5；
            "number_of_replicas": 1  #数据副本，一般设置为1；
          }
        }
        
        返回：
        {
          "acknowledged" : true,
          "shards_acknowledged" : true,
          "index" : "customer"
        }
         
       
- 列出当前所有的index
    -
       GET /_cat/indices?v
       
       返回：
       health status index                           uuid                   pri rep docs.count docs.deleted store.size pri.store.size
       green  open   customer1                       qiWTX8KlT0q3ENuFRkiSqA   5   1          0            0      2.5kb          1.2kb
              close  .monitoring-kibana-6-2019.10.14 4JXn_FIFQk6J8jr0bFKGDg                                                          
       green  open   customer                        h3lppuSqTGmHG9jDwXrHgg   5   1          2            0     15.2kb          7.5kb
       green  open   book                            2Ucu7ZJ2QkS_iGxgW6kFWQ   5   1          0            0      2.5kb          1.2kb
              close  .kibana_1                       CkTYYsE6RdeoyFDOQI8SrQ                                                          
       green  open   person                          REDSKYusQ0GHVZ75Kd9uXw   5   1          0            0      2.5kb          1.2kb
              close  .monitoring-es-6-2019.10.14     bFCADIczR5S3kKuzZtR4Vw                                                          
              close  .kibana_task_manager            4ZQDZ9vbSm6p8MnX_MUePg  
              
- 删除index
    -
        DELETE /customer?pretty
        
        返回：
        {
          "acknowledged" : true
        }
        
- 向costomer插一条数据
    -
        PUT /customer/_doc/1?pretty
        {
          "name": "wjk"
        }
        
        返回：
        {
          "_index" : "customer",
          "_type" : "_doc",
          "_id" : "1",
          "_version" : 1,
          "result" : "created",
          "_shards" : {
            "total" : 2,
            "successful" : 2,
            "failed" : 0
          },
          "_seq_no" : 0,
          "_primary_term" : 1
        }

- 新增数据时，不指定ID的情况
    -
      POST /customer/_doc?pretty
      {
        "name": "wjk"
      }
      
      返回：
      {
        "_index" : "customer",
        "_type" : "_doc",
        "_id" : "kxNWy20BOpnnFceJOZBz",
        "_version" : 1,
        "result" : "created",
        "_shards" : {
          "total" : 2,
          "successful" : 2,
          "failed" : 0
        },
        "_seq_no" : 0,
        "_primary_term" : 1
      }
        
- 查询刚刚插入的数据
    -
        GET /customer/_doc/1?pretty
        
        返回：
        {
          "_index" : "customer",
          "_type" : "_doc",
          "_id" : "1",
          "_version" : 1,
          "_seq_no" : 0,
          "_primary_term" : 1,
          "found" : true,
          "_source" : {
            "name" : "wjk"
          }
        }
        
- 使用PUT更新数据
    -
        PUT /customer/_doc/1?pretty
        {
          "name": "wjkmjf"
        }
        
        返回：
        {
          "_index" : "customer",
          "_type" : "_doc",
          "_id" : "1",
          "_version" : 2,
          "result" : "updated",
          "_shards" : {
            "total" : 2,
            "successful" : 2,
            "failed" : 0
          },
          "_seq_no" : 1,
          "_primary_term" : 1
        }
 
- 使用POST更新数据
    -
        POST /customer/_doc/1/_update?pretty
        {
          "doc": {
            "name": "mjfwjk"
          }
        }
        
        返回：
        {
          "_index" : "customer",
          "_type" : "_doc",
          "_id" : "1",
          "_version" : 3,
          "result" : "updated",
          "_shards" : {
            "total" : 2,
            "successful" : 2,
            "failed" : 0
          },
          "_seq_no" : 2,
          "_primary_term" : 1
        }
        
- 查询所有数据
    -
        GET /customer/_doc/_search?pretty
        
        返回：
        {
          "took" : 381,
          "timed_out" : false,
          "_shards" : {
            "total" : 12,
            "successful" : 12,
            "skipped" : 0,
            "failed" : 0
          },
          "hits" : {
            "total" : 3,
            "max_score" : 1.0,
            "hits" : [
              {
                "_index" : "customer",
                "_type" : "_doc",
                "_id" : "khNWy20BOpnnFceJGJBY",
                "_score" : 1.0,
                "_source" : {
                  "name" : "Jane Doe"
                }
              },
              {
                "_index" : "customer",
                "_type" : "_doc",
                "_id" : "kxNWy20BOpnnFceJOZBz",
                "_score" : 1.0,
                "_source" : {
                  "name" : "wjk"
                }
              },
              {
                "_index" : "customer",
                "_type" : "_doc",
                "_id" : "1",
                "_score" : 1.0,
                "_source" : {
                  "name" : "mjfwjk"
                }
              }
            ]
          }
        }

- 删除数据
    -
        DELETE /customer/_doc/1?pretty
        
        返回：
        {
          "_index" : "customer",
          "_type" : "_doc",
          "_id" : "1",
          "_version" : 5,
          "result" : "not_found",
          "_shards" : {
            "total" : 2,
            "successful" : 2,
            "failed" : 0
          },
          "_seq_no" : 4,
          "_primary_term" : 1
        }
        
