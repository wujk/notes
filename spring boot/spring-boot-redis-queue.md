# spring-boot-redis

###### 1、 引入jar包
     <dependency>
         <groupId>org.springframework.boot</groupId>
         <artifactId>spring-boot-starter-web</artifactId>
     </dependency>
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
    
###### 3、消费者
    @Component
    public class Receiver {
    
        public void receiveMessage(String message) {
            System.out.println("receiveMessage " + message);
        }
    
    }
    
###### 4、消息监听容器
    @Configuration
    public class MessageListener {
    
        @Bean
        RedisMessageListenerContainer container(RedisConnectionFactory connectionFactory,
                                                MessageListenerAdapter listenerAdapter) {
    
            RedisMessageListenerContainer container = new RedisMessageListenerContainer();
            container.setConnectionFactory(connectionFactory);
            container.addMessageListener(listenerAdapter, new PatternTopic("message"));
            return container;
        }
    
        @Bean
        MessageListenerAdapter listenerAdapter(@Autowired Receiver receiver) {
            return new MessageListenerAdapter(receiver, "receiveMessage");
        }
    
    }
    
###### 5、生产者
    @RestController
    public class Producer {
    
        @Autowired
        private StringRedisTemplate redisTemplate;
    
        @RequestMapping(value = "send/{message}", method = RequestMethod.GET)
        public void send(@PathVariable String message) {
            System.out.println("send " + message);
            redisTemplate.convertAndSend("message", message);
        }
    
    }
    
