# spring-boot-activemq

### 一、spring-boot集成activeMQ

###### 1、 引入jar包
     <dependency>
         <groupId>org.springframework.boot</groupId>
         <artifactId>spring-boot-starter-web</artifactId>
     </dependency>
     <dependency>
         <groupId>org.springframework.boot</groupId>
         <artifactId>spring-boot-starter-activemq</artifactId>
     </dependency>

    
###### 2、数据库配置
    spring.activemq.broker-url=tcp://192.168.140.159:61616
    spring.activemq.user=admin
    spring.activemq.password=admin
    
###### 3、发送端配置
    @EnableJms // 开启jms
    @Configuration
    public class JmsConfig {
        private static final Logger LOG = LoggerFactory.getLogger("asdasdasd");
    
        @Bean
        public Queue queue() {   // 点对点
            return new ActiveMQQueue("spring.boot.queue");
        }
    
        @Bean
        public Topic topic() {  // 发布/订阅
            return new ActiveMQTopic("spring.boot.topic");
        }
    
    }
    
###### 4、发送
    @SpringBootApplication
    @RestController
    public class SpringBootActiveMQProducerApplication {
    
        public static void main(String[] args) {
            SpringApplication.run(SpringBootActiveMQProducerApplication.class, args);
        }
    
        @Autowired
        JmsTemplate jmsTemplate;
    
        @Autowired
        Queue queue;
    
        @Autowired
        Topic topic;
    
        @GetMapping("queue/{msg}")
        public String producerQueue(@PathVariable String msg) {
            jmsTemplate.convertAndSend(queue, msg);
            return "queue";
        }
    
        @GetMapping("topic/{msg}")
        public String producerTopic(@PathVariable String msg) {
            jmsTemplate.convertAndSend(topic, msg);
            return "topic";
        }
    }
    

###### 5、接收端配置
    @EnableJms
    @Configuration
    public class JmsConfig {
        private static final Logger LOG = LoggerFactory.getLogger("asdasdasd");
    
        // 这个用于设置 @JmsListener使用的containerFactory
        @Bean
        public JmsListenerContainerFactory<?> msgFactoryTopic(ConnectionFactory connectionFactory) {
            DefaultJmsListenerContainerFactory factory = getDefaultJmsListenerContainerFactory(connectionFactory);
            factory.setPubSubDomain(true);  // 需要开启发布模式
            return factory;
        }
    
        // 这个用于设置 @JmsListener使用的containerFactory
        @Bean
        public JmsListenerContainerFactory<?> msgFactoryQueue(ConnectionFactory connectionFactory) {
            DefaultJmsListenerContainerFactory factory = getDefaultJmsListenerContainerFactory(connectionFactory);
            return factory;
        }
    
        private DefaultJmsListenerContainerFactory getDefaultJmsListenerContainerFactory(ConnectionFactory connectionFactory) {
            DefaultJmsListenerContainerFactory factory = new DefaultJmsListenerContainerFactory();
            factory.setConnectionFactory(connectionFactory);
            return factory;
        }
    
    }

###### 6、接收
    @SpringBootApplication
    public class SpringBootActiveMQConsumerApplication {
    
        public static void main(String[] args) {
            SpringApplication.run(SpringBootActiveMQConsumerApplication.class, args);
        }
    
        @JmsListener(destination = "spring.boot.queue", containerFactory="msgFactoryQueue")
        public void consumerQueue(String msg) {
            System.out.println("consumerQueue: " + msg);
        }
    
        @JmsListener(destination = "spring.boot.topic", containerFactory="msgFactoryTopic")
        public void consumerTopic(String msg) {
            System.out.println("consumerTopic: " + msg);
        }
    }
    
### 二、开启事务

###### 1、发送端配置
    @EnableJms
    @Configuration
    public class JmsConfig {
        private static final Logger LOG = LoggerFactory.getLogger("asdasdasd");
    
        @Bean
        public Queue queue() {
            return new ActiveMQQueue("spring.boot.queue");
        }
    
        @Bean
        public Topic topic() {
            return new ActiveMQTopic("spring.boot.topic");
        }
    
        // 加入事务
        @Bean
        public PlatformTransactionManager transactionManager(ConnectionFactory connectionFactory) {
            return new JmsTransactionManager(connectionFactory);
        }
    
    }

###### 2、发送端加入 
    @Transactional

###### 3、接收端配置
    @EnableJms
    @Configuration
    public class JmsConfig {
        private static final Logger LOG = LoggerFactory.getLogger("asdasdasd");
    
        // 这个用于设置 @JmsListener使用的containerFactory
        @Bean
        public JmsListenerContainerFactory<?> msgFactoryTopic(ConnectionFactory connectionFactory, PlatformTransactionManager transactionManager) {
            DefaultJmsListenerContainerFactory factory = getDefaultJmsListenerContainerFactory(connectionFactory, transactionManager);
            factory.setPubSubDomain(true);  // 需要开启发布模式
            return factory;
        }
    
        // 这个用于设置 @JmsListener使用的containerFactory
        @Bean
        public JmsListenerContainerFactory<?> msgFactoryQueue(ConnectionFactory connectionFactory, PlatformTransactionManager transactionManager) {
            DefaultJmsListenerContainerFactory factory = getDefaultJmsListenerContainerFactory(connectionFactory, transactionManager);
            return factory;
        }
    
        private DefaultJmsListenerContainerFactory getDefaultJmsListenerContainerFactory(ConnectionFactory connectionFactory, PlatformTransactionManager transactionManager) {
            DefaultJmsListenerContainerFactory factory = new DefaultJmsListenerContainerFactory();
            factory.setTransactionManager(transactionManager); // JmsListener加入事务
            factory.setConnectionFactory(connectionFactory);
            return factory;
        }
    
        @Bean
        public PlatformTransactionManager transactionManager(ConnectionFactory connectionFactory) {
            return new JmsTransactionManager(connectionFactory);
        }
    
    }
    
###### 4、接收端加入 
    @Transactional