# spring-boot-sharding-jdbc读写分离

###### 1、 引入jar包
     <dependency>
         <groupId>org.springframework.boot</groupId>
         <artifactId>spring-boot-starter-web</artifactId>
     </dependency>
     <dependency>
         <groupId>org.mybatis.spring.boot</groupId>
         <artifactId>mybatis-spring-boot-starter</artifactId>
         <version>1.3.2</version>
     </dependency>

     <dependency>
         <groupId>mysql</groupId>
         <artifactId>mysql-connector-java</artifactId>
     </dependency>

     <dependency>
         <groupId>com.alibaba</groupId>
         <artifactId>druid-spring-boot-starter</artifactId>
         <version>1.1.10</version>
     </dependency>

     <dependency>
         <groupId>io.shardingsphere</groupId>
         <artifactId>sharding-jdbc-spring-boot-starter</artifactId>
         <version>3.1.0.M1</version>
     </dependency>
    
###### 2.0、数据库配置(读写分离)
    sharding:
      jdbc:
        datasource:
          names: db-master,db-slave  # 名称之间不可以出现空格
          db-master: #org.apache.tomcat.jdbc.pool.DataSource
            type: com.alibaba.druid.pool.DruidDataSource
            driverClassName: com.mysql.jdbc.Driver
            url: jdbc:mysql://192.168.140.77:3306/cool?useUnicode=true&characterEncoding=utf8&tinyInt1isBit=false&useSSL=false&serverTimezone=GMT
            username: root
            password: 123456
            #最大连接数
            maxPoolSize: 20
          db-slave: # 配置第一个从库
            type: com.alibaba.druid.pool.DruidDataSource
            driverClassName: com.mysql.jdbc.Driver
            url: jdbc:mysql://192.168.140.159:3306/cool?useUnicode=true&characterEncoding=UTF-8&allowMultiQueries=true&useSSL=false&serverTimezone=GMT
            username: root
            password: 123456
            maxPoolSize: 20
        config:
          masterslave: # 配置读写分离
            load-balance-algorithm-type: round_robin # 配置从库选择策略，提供轮询与随机，这里选择用轮询//random 随机 //round_robin 轮询
            name: db1s1
            master-data-source-name: db-master
            slave-data-source-names: db-slave
        props:
          sql: # 开启SQL显示，默认值: false，注意：仅配置读写分离时不会打印日志！！！
            show: true
    
    mybatis:
      mapper-locations: classpath*:mybatis/*Mapper.xml
      type-aliases-package: com.wujk.springbootshardingjdbc
      
###### 2.1 数据库配置(分表+读写分离) 用于分表的字段不能为空即使是自增长主键
    sharding:
      jdbc:
        datasource:
          names: db-master,db-slave  # 名称之间不可以出现空格
          db-master: #org.apache.tomcat.jdbc.pool.DataSource
            type: com.alibaba.druid.pool.DruidDataSource
            driverClassName: com.mysql.jdbc.Driver
            url: jdbc:mysql://192.168.140.77:3306/cool?useUnicode=true&characterEncoding=utf8&tinyInt1isBit=false&useSSL=false&serverTimezone=GMT
            username: root
            password: 123456
            #最大连接数
            maxPoolSize: 20
          db-slave: # 配置第一个从库
            type: com.alibaba.druid.pool.DruidDataSource
            driverClassName: com.mysql.jdbc.Driver
            url: jdbc:mysql://192.168.140.159:3306/cool?useUnicode=true&characterEncoding=UTF-8&allowMultiQueries=true&useSSL=false&serverTimezone=GMT
            username: root
            password: 123456
            maxPoolSize: 20
        config:
          sharding:
            tables:
              User:
                actual-data-nodes: ds_0.User_$->{0..3}
                table-strategy:
                  standard:
                    sharding-column: id
                    precise-algorithm-class-name: com.wujk.springbootshardingjdbc.MyPreciseShardingAlgorithm
            master-slave-rules:
              ds_0:
                master-data-source-name: db-master
                slave-data-source-names: db-slave
        props:
          sql: # 开启SQL显示，默认值: false，注意：仅配置读写分离时不会打印日志！！！
            show: true

###### 2.2 数据库配置(分库分表+读写分离) 用于分表的字段不能为空即使是自增长主键 
    sharding:
      jdbc:
        datasource:
          names: db-master-0,db-master-1,db-slave-0,db-slave-1 # 名称之间不可以出现空格
          db-master-0: #org.apache.tomcat.jdbc.pool.DataSource
            type: com.alibaba.druid.pool.DruidDataSource
            driverClassName: com.mysql.jdbc.Driver
            url: jdbc:mysql://192.168.140.77:3306/cool?useUnicode=true&characterEncoding=utf8&tinyInt1isBit=false&useSSL=false&serverTimezone=GMT
            username: root
            password: 123456
            #最大连接数
            maxPoolSize: 20
          db-master-1: #org.apache.tomcat.jdbc.pool.DataSource
            type: com.alibaba.druid.pool.DruidDataSource
            driverClassName: com.mysql.jdbc.Driver
            url: jdbc:mysql://192.168.140.77:3306/cool2?useUnicode=true&characterEncoding=utf8&tinyInt1isBit=false&useSSL=false&serverTimezone=GMT
            username: root
            password: 123456
            #最大连接数
            maxPoolSize: 20
          db-slave-0: # 配置第一个从库
            type: com.alibaba.druid.pool.DruidDataSource
            driverClassName: com.mysql.jdbc.Driver
            url: jdbc:mysql://192.168.140.159:3306/cool?useUnicode=true&characterEncoding=UTF-8&allowMultiQueries=true&useSSL=false&serverTimezone=GMT
            username: root
            password: 123456
            maxPoolSize: 20
          db-slave-1: # 配置第一个从库
            type: com.alibaba.druid.pool.DruidDataSource
            driverClassName: com.mysql.jdbc.Driver
            url: jdbc:mysql://192.168.140.159:3306/cool2?useUnicode=true&characterEncoding=UTF-8&allowMultiQueries=true&useSSL=false&serverTimezone=GMT
            username: root
            password: 123456
            maxPoolSize: 20
        config:
          sharding:
            default-database-strategy:
              inline:
                sharding-column: id
                algorithm-expression: ds_$->{id % 2}
            tables:
              User:
                actual-data-nodes: ds_$->{0..1}.User_$->{0..3}
                table-strategy:
                  inline:
                    sharding-column: id
                    algorithm-expression: User_$->{id % 4}
                key-generator-column-name: id
            master-slave-rules:
              ds_0:
                master-data-source-name: db-master-0
                slave-data-source-names: db-slave-0
              ds_1:
                master-data-source-name: db-master-1
                slave-data-source-names: db-slave-1
        props:
          sql: # 开启SQL显示，默认值: false，注意：仅配置读写分离时不会打印日志！！！
            show: true  
            
###### 2.3 数据库配置(分库分表+读写分离，有的表分库分表，有的分库，有的分表，有的只有读写分离) 用于分表的字段不能为空即使是自增长主键
    sharding:
      jdbc:
        datasource:
          names: db-master-0,db-master-1,db-slave-0,db-slave-1 # 名称之间不可以出现空格
          db-master-0: #org.apache.tomcat.jdbc.pool.DataSource
            type: com.alibaba.druid.pool.DruidDataSource
            driverClassName: com.mysql.jdbc.Driver
            url: jdbc:mysql://192.168.140.77:3306/cool?useUnicode=true&characterEncoding=utf8&tinyInt1isBit=false&useSSL=false&serverTimezone=GMT
            username: root
            password: 123456
            #最大连接数
            maxPoolSize: 20
          db-master-1: #org.apache.tomcat.jdbc.pool.DataSource
            type: com.alibaba.druid.pool.DruidDataSource
            driverClassName: com.mysql.jdbc.Driver
            url: jdbc:mysql://192.168.140.77:3306/cool2?useUnicode=true&characterEncoding=utf8&tinyInt1isBit=false&useSSL=false&serverTimezone=GMT
            username: root
            password: 123456
            #最大连接数
            maxPoolSize: 20
          db-slave-0: # 配置第一个从库
            type: com.alibaba.druid.pool.DruidDataSource
            driverClassName: com.mysql.jdbc.Driver
            url: jdbc:mysql://192.168.140.159:3306/cool?useUnicode=true&characterEncoding=UTF-8&allowMultiQueries=true&useSSL=false&serverTimezone=GMT
            username: root
            password: 123456
            maxPoolSize: 20
          db-slave-1: # 配置第一个从库
            type: com.alibaba.druid.pool.DruidDataSource
            driverClassName: com.mysql.jdbc.Driver
            url: jdbc:mysql://192.168.140.159:3306/cool2?useUnicode=true&characterEncoding=UTF-8&allowMultiQueries=true&useSSL=false&serverTimezone=GMT
            username: root
            password: 123456
            maxPoolSize: 20
        config:
          sharding:
            tables:
              User:  # 分库分表
                actual-data-nodes: ds_$->{0..1}.User_$->{0..3}
                database-strategy:
                  inline:
                    sharding-column: id
                    algorithm-expression: ds_$->{id % 2}
                table-strategy:
                  inline:
                    sharding-column: id
                    algorithm-expression: User_$->{id % 4}
                key-generator-column-name: id
              pass: # 分表
                actual-data-nodes: ds_0.pass_$->{0..3}
                table-strategy:
                  inline:
                    sharding-column: id
                    algorithm-expression: pass_$->{id % 4}
              result:
                actual-data-nodes: ds_$->{0..1}.result
                database-strategy:
                  inline:
                    sharding-column: id
                    algorithm-expression: ds_$->{id % 2}
                key-generator-column-name: id
            master-slave-rules:
              ds_0:
                master-data-source-name: db-master-0
                slave-data-source-names: db-slave-0
              ds_1:
                master-data-source-name: db-master-1
                slave-data-source-names: db-slave-1
            default-data-source-name: ds_0 # 配置默认数据源
        props:
          sql: # 开启SQL显示，默认值: false，注意：仅配置读写分离时不会打印日志！！！
            show: true
               
###### 3、sql查询
    @Mapper
    public interface UserMapper {
    
        Integer insert(User user);
    
        List<User> list();
    
    }
    ........
    
###### 4、controller
    @RestController
    public class ShardingJdbcController {
    
        @Autowired
        UserMapper userMapper;
    
        @PostMapping("insert")
        @Transactional
        public int insert(@RequestBody User user) {
            return userMapper.insert(user);
        }
    
        @GetMapping("list")
        public List<User> list() {
            return userMapper.list();
        }
    
    }
    
###### 5、启动
    @SpringBootApplication(exclude = {DruidDataSourceAutoConfigure.class})
    public class SpringbootShardingJdncApplication {
    
        public static void main(String[] args) {
            SpringApplication.run(SpringbootShardingJdncApplication.class, args);
        }
    }
    
    
#### sharding-jdbc配置
##### 数据分片
    sharding.jdbc.datasource.names= #数据源名称，多数据源以逗号分隔
     
    sharding.jdbc.datasource.<data-source-name>.type= #数据库连接池类名称
    sharding.jdbc.datasource.<data-source-name>.driver-class-name= #数据库驱动类名
    sharding.jdbc.datasource.<data-source-name>.url= #数据库url连接
    sharding.jdbc.datasource.<data-source-name>.username= #数据库用户名
    sharding.jdbc.datasource.<data-source-name>.password= #数据库密码
    sharding.jdbc.datasource.<data-source-name>.xxx= #数据库连接池的其它属性
     
    sharding.jdbc.config.sharding.tables.<logic-table-name>.actual-data-nodes= #由数据源名 + 表名组成，以小数点分隔。多个表以逗号分隔，支持inline表达式。缺省表示使用已知数据源与逻辑表名称生成数据节点。用于广播表（即每个库中都需要一个同样的表用于关联查询，多为字典表）或只分库不分表且所有库的表结构完全一致的情况
     
    #分库策略，缺省表示使用默认分库策略，以下的分片策略只能选其一
     
    #用于单分片键的标准分片场景
    sharding.jdbc.config.sharding.tables.<logic-table-name>.database-strategy.standard.sharding-column= #分片列名称
    sharding.jdbc.config.sharding.tables.<logic-table-name>.database-strategy.standard.precise-algorithm-class-name= #精确分片算法类名称，用于=和IN。该类需实现PreciseShardingAlgorithm接口并提供无参数的构造器
    sharding.jdbc.config.sharding.tables.<logic-table-name>.database-strategy.standard.range-algorithm-class-name= #范围分片算法类名称，用于BETWEEN，可选。该类需实现RangeShardingAlgorithm接口并提供无参数的构造器
     
    #用于多分片键的复合分片场景
    sharding.jdbc.config.sharding.tables.<logic-table-name>.database-strategy.complex.sharding-columns= #分片列名称，多个列以逗号分隔
    sharding.jdbc.config.sharding.tables.<logic-table-name>.database-strategy.complex.algorithm-class-name= #复合分片算法类名称。该类需实现ComplexKeysShardingAlgorithm接口并提供无参数的构造器
     
    #行表达式分片策略
    sharding.jdbc.config.sharding.tables.<logic-table-name>.database-strategy.inline.sharding-column= #分片列名称
    sharding.jdbc.config.sharding.tables.<logic-table-name>.database-strategy.inline.algorithm-expression= #分片算法行表达式，需符合groovy语法
     
    #Hint分片策略
    sharding.jdbc.config.sharding.tables.<logic-table-name>.database-strategy.hint.algorithm-class-name= #Hint分片算法类名称。该类需实现HintShardingAlgorithm接口并提供无参数的构造器
     
    #分表策略，同分库策略
    sharding.jdbc.config.sharding.tables.<logic-table-name>.table-strategy.xxx= #省略
     
    sharding.jdbc.config.sharding.tables.<logic-table-name>.key-generator.column= #自增列名称，缺省表示不使用自增主键生成器
    sharding.jdbc.config.sharding.tables.<logic-table-name>.key-generator.type= #自增列值生成器类型，缺省表示使用默认自增列值生成器。可使用用户自定义的列值生成器或选择内置类型：SNOWFLAKE/UUID
    sharding.jdbc.config.sharding.tables.<logic-table-name>.key-generator.props.<property-name>= #自增列值生成器属性配置, 比如SNOWFLAKE算法的worker.id与max.tolerate.time.difference.milliseconds
     
    sharding.jdbc.config.sharding.tables.<logic-table-name>.logic-index= #逻辑索引名称，对于分表的Oracle/PostgreSQL数据库中DROP INDEX XXX语句，需要通过配置逻辑索引名称定位所执行SQL的真实分表
     
    sharding.jdbc.config.sharding.binding-tables[0]= #绑定表规则列表
    sharding.jdbc.config.sharding.binding-tables[1]= #绑定表规则列表
    sharding.jdbc.config.sharding.binding-tables[x]= #绑定表规则列表
     
    sharding.jdbc.config.sharding.broadcast-tables[0]= #广播表规则列表
    sharding.jdbc.config.sharding.broadcast-tables[1]= #广播表规则列表
    sharding.jdbc.config.sharding.broadcast-tables[x]= #广播表规则列表
     
    sharding.jdbc.config.sharding.default-data-source-name= #未配置分片规则的表将通过默认数据源定位
    sharding.jdbc.config.sharding.default-database-strategy.xxx= #默认数据库分片策略，同分库策略
    sharding.jdbc.config.sharding.default-table-strategy.xxx= #默认表分片策略，同分表策略
    sharding.jdbc.config.sharding.default-key-generator.type= #默认自增列值生成器类型，缺省将使用org.apache.shardingsphere.core.keygen.generator.impl.SnowflakeKeyGenerator。可使用用户自定义的列值生成器或选择内置类型：SNOWFLAKE/UUID
    sharding.jdbc.config.sharding.default-key-generator.props.<property-name>= #自增列值生成器属性配置, 比如SNOWFLAKE算法的worker.id与max.tolerate.time.difference.milliseconds
     
    sharding.jdbc.config.sharding.master-slave-rules.<master-slave-data-source-name>.master-data-source-name= #详见读写分离部分
    sharding.jdbc.config.sharding.master-slave-rules.<master-slave-data-source-name>.slave-data-source-names[0]= #详见读写分离部分
    sharding.jdbc.config.sharding.master-slave-rules.<master-slave-data-source-name>.slave-data-source-names[1]= #详见读写分离部分
    sharding.jdbc.config.sharding.master-slave-rules.<master-slave-data-source-name>.slave-data-source-names[x]= #详见读写分离部分
    sharding.jdbc.config.sharding.master-slave-rules.<master-slave-data-source-name>.load-balance-algorithm-class-name= #详见读写分离部分
    sharding.jdbc.config.sharding.master-slave-rules.<master-slave-data-source-name>.load-balance-algorithm-type= #详见读写分离部分
    sharding.jdbc.config.config.map.key1= #详见读写分离部分
    sharding.jdbc.config.config.map.key2= #详见读写分离部分
    sharding.jdbc.config.config.map.keyx= #详见读写分离部分
     
    sharding.jdbc.config.props.sql.show= #是否开启SQL显示，默认值: false
    sharding.jdbc.config.props.executor.size= #工作线程数量，默认值: CPU核数
     
    sharding.jdbc.config.config.map.key1= #用户自定义配置
    sharding.jdbc.config.config.map.key2= #用户自定义配置
    sharding.jdbc.config.config.map.keyx= #用户自定义配置
    
##### 读写分离
    #省略数据源配置，与数据分片一致
     
    sharding.jdbc.config.sharding.master-slave-rules.<master-slave-data-source-name>.master-data-source-name= #主库数据源名称
    sharding.jdbc.config.sharding.master-slave-rules.<master-slave-data-source-name>.slave-data-source-names[0]= #从库数据源名称列表
    sharding.jdbc.config.sharding.master-slave-rules.<master-slave-data-source-name>.slave-data-source-names[1]= #从库数据源名称列表
    sharding.jdbc.config.sharding.master-slave-rules.<master-slave-data-source-name>.slave-data-source-names[x]= #从库数据源名称列表
    sharding.jdbc.config.sharding.master-slave-rules.<master-slave-data-source-name>.load-balance-algorithm-class-name= #从库负载均衡算法类名称。该类需实现MasterSlaveLoadBalanceAlgorithm接口且提供无参数构造器
    sharding.jdbc.config.sharding.master-slave-rules.<master-slave-data-source-name>.load-balance-algorithm-type= #从库负载均衡算法类型，可选值：ROUND_ROBIN，RANDOM。若`load-balance-algorithm-class-name`存在则忽略该配置
     
    sharding.jdbc.config.config.map.key1= #用户自定义配置
    sharding.jdbc.config.config.map.key2= #用户自定义配置
    sharding.jdbc.config.config.map.keyx= #用户自定义配置
     
    sharding.jdbc.config.props.sql.show= #是否开启SQL显示，默认值: false
    sharding.jdbc.config.props.executor.size= #工作线程数量，默认值: CPU核数
    sharding.jdbc.config.props.check.table.metadata.enabled= #是否在启动时检查分表元数据一致性，默认值: false
    
##### 数据治理
    #省略数据源、数据分片和读写分离配置
     
    sharding.jdbc.config.sharding.orchestration.name= #数据治理实例名称
    sharding.jdbc.config.sharding.orchestration.overwrite= #本地配置是否覆盖注册中心配置。如果可覆盖，每次启动都以本地配置为准
    sharding.jdbc.config.sharding.orchestration.registry.server-lists= #连接注册中心服务器的列表。包括IP地址和端口号。多个地址用逗号分隔。如: host1:2181,host2:2181
    sharding.jdbc.config.sharding.orchestration.registry.namespace= #注册中心的命名空间
    sharding.jdbc.config.sharding.orchestration.registry.digest= #连接注册中心的权限令牌。缺省为不需要权限验证
    sharding.jdbc.config.sharding.orchestration.registry.operation-timeout-milliseconds= #操作超时的毫秒数，默认500毫秒
    sharding.jdbc.config.sharding.orchestration.registry.max-retries= #连接失败后的最大重试次数，默认3次
    sharding.jdbc.config.sharding.orchestration.registry.retry-interval-milliseconds= #重试间隔毫秒数，默认500毫秒
    sharding.jdbc.config.sharding.orchestration.registry.time-to-live-seconds= #临时节点存活秒数，默认60秒