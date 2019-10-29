# spring-boot-redis

###### 1、 引入jar包
     <dependency>
         <groupId>org.springframework.boot</groupId>
         <artifactId>spring-boot-starter-web</artifactId>
     </dependency>
     <dependency>
         <groupId>org.springframework.boot</groupId>
         <artifactId>spring-boot-starter-cache</artifactId>
     </dependency>
     <!-- 使用redis作为缓存默认，spring使用ConcurrentMapCache -->
     <dependency>
         <groupId>org.springframework.boot</groupId>
         <artifactId>spring-boot-starter-data-redis</artifactId>
     </dependency>

    
###### 2、数据库配置
    spring.redis.host=192.168.140.215
    spring.redis.port=6379
    spring.redis.password=pass
    spring.redis.database=3
    spring.redis.jedis.pool.max-active=8
    spring.redis.jedis.pool.max-wait=-1
    spring.redis.jedis.pool.max-idle=500
    spring.redis.jedis.pool.min-idle=0
    spring.redis.timeout=300  #报错Command timed out after no timeout,修改application.properties文件的redis连接超时时间，修改到200或以上
    
###### 3、开启缓存
    @SpringBootApplication
    @EnableCaching
    public class SpringBootCacheApplication {
    
        public static void main(String[] args) {
            SpringApplication.run(SpringBootCacheApplication.class, args);
        }
    
    }
    
###### 4、使用缓存
    @RestController
    public class CacheController {
    
        @Autowired
        IBeanDao beanDao;
    
        @RequestMapping(value = "/get/{id}", method = RequestMethod.GET)
        @Cacheable("cache")
        public Bean getBean(@PathVariable("id") Integer id) {
            return beanDao.getBean(id);
        }
    }
    

###### Cache缓存接口，定义缓存操作。
    实现有：RedisCache、EhCacheCache、ConcurrentMapCache等
###### 缓存管理器，管理各种缓存（cache）组件
    CacheManager	

###### 5、缓存主要注解
    @Cacheable	主要针对方法配置，能够根据方法的请求参数对其进行缓存
    @CacheEvict	清空缓存
    @CachePut	保证方法被调用，又希望结果被缓存。与@Cacheable区别在于是否每次都调用方法，常用于更新
    @EnableCaching	开启基于注解的缓存
    keyGenerator	缓存数据时key生成策略
    serialize	缓存数据时value序列化策略
    @CacheConfig	统一配置本类的缓存注解的属性

###### 6、@Cacheable/@CachePut/@CacheEvict 主要的参数
    value	缓存的名称，在 spring 配置文件中定义，必须指定至少一个
    例如：
    @Cacheable(value="mycache") 或者
    @Cacheable(value={"cache1","cache2"}
    key	缓存的 key，可以为空，如果指定要按照 SpEL 表达式编写，如果不指定，则缺省按照方法的所有参数进行组合
    例如：
    @Cacheable(value="testcache",key="#id")
    condition	缓存的条件，可以为空，使用 SpEL 编写，返回 true 或者 false，只有为 true 才进行缓存/清除缓存
    例如：@Cacheable(value="testcache",condition="#userName.length()>2")
    unless	否定缓存。当条件结果为TRUE时，就不会缓存。
    @Cacheable(value="testcache",unless="#userName.length()>2")
    allEntries    (@CacheEvict )是否清空所有缓存内容，缺省为 false，如果指定为 true，则方法调用后将立即清空所有缓存
    例如：
    @CachEvict(value="testcache",allEntries=true)
    beforeInvocation   (@CacheEvict)是否在方法执行前就清空，缺省为 false，如果指定为 true，则在方法还没有执行的时候就清空缓存，缺省情况下，如果方法执行抛出异常，则不会清空缓存
    例如：
    @CachEvict(value="testcache"，beforeInvocation=true)

###### 7、SpEL上下文数据
    Spring Cache提供了一些供我们使用的SpEL上下文数据，下表直接摘自Spring官方文档：
    
    
    methodName	    root对象	    当前被调用的方法名	                    #root.methodname
    method	        root对象  	当前被调用的方法	                        #root.method.name
    target	        root对象	    当前被调用的目标对象实例	                #root.target
    targetClass	    root对象	    当前被调用的目标对象的类	                #root.targetClass
    args	        root对象	    当前被调用的方法的参数列表	            #root.args[0]
    caches	        root对象  	当前方法调用使用的缓存列表	            #root.caches[0].name
    Argument Name	执行上下文	当前被调用的方法的参数，如findArtisan(Artisan artisan),可以通过#artsian.id获得参数	            #artsian.id
    result	        执行上下文	方法执行后的返回值（仅当方法执行后的判断有效，如 unless cacheEvict的beforeInvocation=false）	#result
    注意：
    
    1.当我们要使用root对象的属性作为key时我们也可以将“#root”省略，因为Spring默认使用的就是root对象的属性。 如
    @Cacheable(key = "targetClass + methodName +#p0")
    
    2.使用方法参数时我们可以直接使用“#参数名”或者“#p参数index”。 如：
    @Cacheable(value="users", key="#id")
    @Cacheable(value="users", key="#p0")
    
